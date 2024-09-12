targetScope = 'subscription'


// ========== //
// Parameters //
// ========== //

@description('The name of the compute gallery for managing the images.')
param computeGalleryName string

@description('The name of the deployment script for configuring an existing subnet.')
param deploymentScriptName string

@description('Determine whether to use an existing resource group.')
param existingResourceGroup bool

@description('The resource ID of an existing virtual network.')
param existingVirtualNetworkResourceId string = ''

@description('Indicates whether the image definition supports accelerated networking.')
param imageDefinitionIsAcceleratedNetworkSupported bool

@description('Indicates whether the image definition supports hibernation.')
param imageDefinitionIsHibernateSupported bool

@description('The name of the Image Definition for the Shared Image Gallery.')
param imageDefinitionName string

@allowed([
  'ConfidentialVM'
  'ConfidentialVMSupported'
  'Standard'
  'TrustedLaunch'
])
@description('The security type for the Image Definition.')
param imageDefinitionSecurityType string

@description('The offer of the marketplace image.')
param imageOffer string

@description('The publisher of the marketplace image.')
param imagePublisher string

@description('The SKU of the marketplace image.')
param imageSku string

@description('The location for the resources deployed in this solution.')
param location string = deployment().location

@description('The name of the resource group for the resources.')
param resourceGroupName string = ''

@description('The name of the storage account for the imaging artifacts.')
param storageAccountName string = ''

@description('The subnet name of an existing virtual network.')
param subnetName string = ''

@description('The key-value pairs of tags for the resources.')
param tags object = {}

@description('DO NOT MODIFY THIS VALUE! The timestamp is needed to differentiate deployments for certain Azure resources and must be set using a parameter.')
param time string = utcNow('yyyyMMddhhmmss')

@description('The name for the user assigned identity')
param userAssignedIdentityName string


// =========== //
// Variables   //
// =========== //

var varRoles = union(empty(existingVirtualNetworkResourceId) ? [] : [
  {
    resourceGroup: split(existingVirtualNetworkResourceId, '/')[4]
    name: 'Virtual Network Join'
    description: 'Allow resources to join a subnet'
    permissions: [
      {
        actions: [
          'Microsoft.Network/virtualNetworks/read'
          'Microsoft.Network/virtualNetworks/subnets/read'
          'Microsoft.Network/virtualNetworks/subnets/join/action'
          'Microsoft.Network/virtualNetworks/subnets/write' // Required to update the private link network policy
        ]
      }
    ]
  }
], [
  {
    resourceGroup: resourceGroupName
    name: 'Image Template Contributor'
    description: 'Allow the creation and management of images'
    permissions: [
      {
        actions: [
          'Microsoft.Compute/galleries/read'
          'Microsoft.Compute/galleries/images/read'
          'Microsoft.Compute/galleries/images/versions/read'
          'Microsoft.Compute/galleries/images/versions/write'
          'Microsoft.Compute/images/read'
          'Microsoft.Compute/images/write'
          'Microsoft.Compute/images/delete'
        ]
      }
    ]
  }
])


// =========== //
// Deployments //
// =========== //

// Resource group
resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = if (!existingResourceGroup) {
  name: resourceGroupName
  location: location
  tags: tags[?'Microsoft.Resources/resourceGroups'] ?? {}
  properties: {}
}

// Role definitions
resource roleDefinitions 'Microsoft.Authorization/roleDefinitions@2015-07-01' = [for i in range(0, length(varRoles)): {
  name: guid(varRoles[i].name, subscription().id)
  properties: {
    roleName: '${varRoles[i].name} (${subscription().subscriptionId})'
    description: varRoles[i].description
    permissions: varRoles[i].permissions
    assignableScopes: [
      subscription().id
    ]
  }
}]

// User assigned identity
module userAssignedIdentity 'modules/userAssignedIdentity.bicep' = {
  name: 'ID-${time}'
  scope: rg
  params: {
    location: location
    name: userAssignedIdentityName
    tags: tags
  }
}

// Role assignments
@batchSize(1)
module roleAssignments 'modules/roleAssignment.bicep' = [for i in range(0, length(varRoles)): {
  name: 'Role-Assignment-${i}-${time}'
  scope: resourceGroup(varRoles[i].resourceGroup)
  params: {
    principalId: userAssignedIdentity.outputs.PrincipalId
    roleDefinitionId: roleDefinitions[i].id
  }
  dependsOn: [
    rg
  ]
}]

// Compute gallery with image definition
module computeGallery 'modules/computeGallery.bicep' = {
  name: 'Compute-Gallery-${time}'
  scope: rg
  params: {
    computeGalleryName: computeGalleryName
    imageDefinitionName: imageDefinitionName
    imageDefinitionSecurityType: imageDefinitionSecurityType
    imageOffer: imageOffer
    imagePublisher: imagePublisher
    imageSku: imageSku
    location: location
    tags: tags
    imageDefinitionIsAcceleratedNetworkSupported: imageDefinitionIsAcceleratedNetworkSupported
    imageDefinitionIsHibernateSupported: imageDefinitionIsHibernateSupported
  }
}

// Disables the network policy for the subnet
module networkPolicy 'modules/networkPolicy.bicep' = if (!(empty(subnetName)) && !(empty(existingVirtualNetworkResourceId))) {
  name: 'Network-Policy-${time}'
  scope: rg
  params: {
    deploymentScriptName: deploymentScriptName
    location: location
    subnetName: subnetName
    tags: tags
    timestamp: time
    userAssignedIdentityResourceId: userAssignedIdentity.outputs.ResourceId
    virtualNetworkName: split(existingVirtualNetworkResourceId, '/')[8]
    virtualNetworkResourceGroupName: split(existingVirtualNetworkResourceId, '/')[4]
  }
  dependsOn: [
    roleAssignments
  ]
}

// Storage account with blob container
module storage 'modules/storageAccount.bicep' = if (!empty(storageAccountName)) {
  name: 'Storage-Account-${time}'
  scope: rg
  params: {
    location: location
    storageAccountName: storageAccountName
    tags: tags
    userAssignedIdentityPrincipalId: userAssignedIdentity.outputs.PrincipalId
    userAssignedIdentityResourceId: userAssignedIdentity.outputs.ResourceId
  }
}
