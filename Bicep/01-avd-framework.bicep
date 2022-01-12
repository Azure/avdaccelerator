targetScope                           = 'subscription'

@description('Name of resource group to hold Templates, HostPools, Application Groups, and Workspaces')
param avdResourceGroup string         = 'rg-prod-eus-avdresources'

@description('Name for managed identity used for Azure Image Builder')
param managedIdentityName string      =  'uai-prod-eus-imagebuilder'

@description('Name of Key Vault used for AVD deployment secrets')
@maxLength(18)
param keyVaultName string                =  'kv-prod-eus-avd'

@description('AAD object ID of security principal to grant Key Vault access')
param objectId string 

param workspaceName string = 'poc'
param hostPoolName string = 'poc'
@allowed([
  'Personal'
  'Pooled'
])
param hostPoolType string = 'Pooled'

@description('Name for Azure Compute Gallery')
param computeGalleryName string       =  'acg_prod_eus_avd'

param imageRegionReplicas array       = [
                                          'EastUs'
                                        ]

//@description('Deploy AIB build VM into an existing VNet')
//param vnetInject bool = false

@description('Create custom Start VM on Connect Role')
param createVmRole bool = true

@description('Create custom Azure Image Builder Role')
param createAibRole bool = true

@description('Do not modify, used to set unique value for resource deployment')
param time string = utcNow()

// ----------------------------------------
// Variable declaration

var defaultImage = json(loadTextContent('./Parameters/image-20h2.json'))
var startVmRoleDef = json(loadTextContent('./Parameters/role-startvm.json'))
var aibRoleDef = json(loadTextContent('./Parameters/role-aib.json'))
var storageName =  'aibscripts${take(guid(subscription().subscriptionId), 8)}'
var vdiImages = [
  json(loadTextContent('./Parameters/image-20h2-office.json'))
  json(loadTextContent('./Parameters/image-20h2.json'))
]

//var avdVnet = split(imageBuilderSubnet, '/subnets/')[0]
//var avdVnetRg = split(imageBuilderSubnet, '/')[4]

// ----------------------------------------
// Resource Group Deployments

resource avdRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: avdResourceGroup
  location: deployment().location
}

// ----------------------------------------
// Resource Deployments

module keyvault 'Modules/keyvault.bicep' = {
  scope: avdRg
  name: 'avdkv-${time}'
  params: {
    keyVaultName: keyVaultName
    objectId: objectId
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    principalType: 'User'
  }
}
module workspace 'Modules/workspace.bicep' = {
  scope: avdRg
  name: 'ws${workspaceName}-${time}'
  params: {
    name: 'workspace-${workspaceName}'
    appGroupResourceIds: [
      applicationGroup.outputs.appGroupResourceId
    ]
  }
}

module hostPool 'Modules/hostPool.bicep' = {
  scope: avdRg
  name: 'hp${hostPoolName}-${time}'
  params: {
    name: 'hostpool-${hostPoolName}'
    hostpoolType: hostPoolType
    startVMOnConnect: true
  }
}

module applicationGroup 'Modules/applicationGroup.bicep' = {
  scope: avdRg
  name: 'app-${hostPoolName}-${time}'
  params: {
    appGroupType: 'Desktop'
    hostpoolName: hostPool.outputs.hostPoolName
    name: 'app-${hostPoolName}'
  }
}

module vmRole 'Modules/custom-role.bicep' = if (createVmRole) {
  name: 'startVmRole-${time}'
  params: {
    roleDefinition: startVmRoleDef
  }
}

module aibRole 'Modules/custom-role.bicep' = if (createAibRole) {
  name: 'aibRole-${time}'
  params: {
    roleDefinition: aibRoleDef
  }
}

module aibRoleAssign 'Modules/role-assign.bicep' = if (createAibRole) {
  name: 'aibRoleAssign-${time}'
  scope: avdRg
  params: {
    roleDefinitionId: createAibRole ? aibRole.outputs.roleId : ''
    principalId: imageBuilderIdentity.outputs.identityPrincipalId
  }
}

module aibRoleAssignExisting 'Modules/role-assign.bicep' = if (!createAibRole) {
  name: 'aibRoleAssignExt-${time}'
  scope: avdRg
  params: {
    roleDefinitionId: guid(aibRoleDef.Name, subscription().id)
    principalId: imageBuilderIdentity.outputs.identityPrincipalId
  }
}

module imageBuilderIdentity 'Modules/managedidentity.bicep' = {
  scope: avdRg
  name: 'identity-${time}'
  params: {
    identityName: managedIdentityName
  }
}

module imageDefinitionTemplate 'Modules/template-image-definition.bicep' = {
  scope: avdRg
  name: 'imageSpec-${time}'
  params: {
    templateSpecDisplayName: 'Image Builder Definition'
    templateSpecName: 'Image-Definition'
    buildDefinition: defaultImage
    imageId: imageDefinitions[1].outputs.imageId
    imageRegions: imageRegionReplicas
    managedIdentityId: imageBuilderIdentity.outputs.identityResourceId
    scriptUri: ''
  }
}

module createImageGallery 'Modules/image-gallery.bicep' = {
  scope: avdRg
  name: 'gallery-${time}'
  params: {
    galleryName: computeGalleryName
  }
}

module vdiOptimizeScript 'Modules/image-scripts.bicep' = {
  scope: avdRg
  name: 'vdiscript-${time}'
  params: {
    principalId: imageBuilderIdentity.outputs.identityPrincipalId
    storageAccountName: storageName
  }
}

module imageDefinitions 'Modules/image-definition.bicep' = [for i in range(0, length(vdiImages)): {
  scope: avdRg
  name: 'image${i}-${time}'
  params: {
    sku: vdiImages[i].sku
    osType: vdiImages[i].osType
    osState: vdiImages[i].osState
    imageGalleryName: createImageGallery.outputs.galleryName
    imageName: vdiImages[i].name
    offer: vdiImages[i].offer
    publisher: vdiImages[i].publisher
  }
}]

module imageBuildDefinitions 'Modules/image-template.bicep' = [for i in range(0, length(vdiImages)): {
  scope: avdRg
  name: 'aib${i}-${time}'
  params: {
    buildDefinition: vdiImages[i]
    imageId: imageDefinitions[i].outputs.imageId
    imageRegions: imageRegionReplicas
    managedIdentityId: imageBuilderIdentity.outputs.identityResourceId
    scriptUri: vdiOptimizeScript.outputs.scriptUri
    keyVaultName: keyvault.outputs.keyVaultName
  }
}]
module buildImages 'Modules/start-image-build.bicep' = [for i in range(0, length(vdiImages)): {
  scope: avdRg
  name: 'buildImage${i}-${time}'
  params: {
    name: 'build-${vdiImages[i].name}'
    imageId: imageBuildDefinitions[i].outputs.aibImageId
    identityId: imageBuilderIdentity.outputs.identityResourceId
  }
}]
