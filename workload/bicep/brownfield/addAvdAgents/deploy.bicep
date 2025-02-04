targetScope = 'resourceGroup'

// ========== //
// Parameters //
// ========== //

@sys.description('Subscription ID where to deploy session hosts. (Default: )')
param computeSubscriptionId string

@sys.description('Resource Group name where to deploy session hosts. (Default: )')
param computeRgResourceGroupName string

@sys.description('The name of the VM where the AVD agents will be installed. (Default: )')
param vmName string

@sys.description('AVD Host Pool resource ID. (Default: )')
param hostPoolResourceId string

@sys.description('Region of the VM to configure. (Default: )')
param vmLocation string

@sys.description('Resource ID of keyvault that contains credentials. (Default: )')
param keyVaultResourceId string

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var varHostpoolSubId = split(hostPoolResourceId, '/')[2]
var varHostpoolRgName = split(hostPoolResourceId, '/')[4]
var varHostPoolName = split(hostPoolResourceId, '/')[8]
var varKeyVaultSubId = split(keyVaultResourceId, '/')[2]
var varKeyVaultRgName = split(keyVaultResourceId, '/')[4]
var varBaseScriptUri = 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/'
var varSessionHostConfigurationScriptUri = '${varBaseScriptUri}scripts/Set-SessionHostConfiguration.ps1'
var varSessionHostConfigurationScript = './Set-SessionHostConfiguration.ps1'
// =========== //
// Deployments //
// =========== //

// Call on the hotspool
resource hostPoolGet 'Microsoft.DesktopVirtualization/hostPools@2023-09-05' existing = {
  name: varHostPoolName
  scope: resourceGroup('${varHostpoolSubId}', '${varHostpoolRgName}')
}

// Hostpool update
module hostPool '../../../../avm/1.0.0/res/desktop-virtualization/host-pool/main.bicep' = {
  scope: resourceGroup('${varHostpoolSubId}', '${varHostpoolRgName}')
  name: 'HostPool-${time}'
  params: {
    name: hostPoolGet.name
    friendlyName: hostPoolGet.properties.friendlyName
    location: hostPoolGet.location
    keyVaultResourceId: keyVaultResourceId
    hostPoolType: (hostPoolGet.properties.hostPoolType == 'Personal') ? 'Personal' : (hostPoolGet.properties.hostPoolType == 'Pooled') ? 'Pooled' : null
    startVMOnConnect: hostPoolGet.properties.startVMOnConnect
    customRdpProperty: hostPoolGet.properties.customRdpProperty
    loadBalancerType: (hostPoolGet.properties.loadBalancerType == 'BreadthFirst') ? 'BreadthFirst' : (hostPoolGet.properties.loadBalancerType == 'DepthFirst') ? 'DepthFirst' : (hostPoolGet.properties.loadBalancerType == 'Persistent') ? 'Persistent': null
    maxSessionLimit: hostPoolGet.properties.maxSessionLimit
    preferredAppGroupType: (hostPoolGet.properties.preferredAppGroupType == 'Desktop') ? 'Desktop' : (hostPoolGet.properties.preferredAppGroupType == 'RailApplications') ? 'RailApplications' : null
    personalDesktopAssignmentType: (hostPoolGet.properties.personalDesktopAssignmentType == 'Automatic') ? 'Automatic' : (hostPoolGet.properties.personalDesktopAssignmentType == 'Direct') ? 'Direct' : null
    description: hostPoolGet.properties.description
    ssoadfsAuthority: hostPoolGet.properties.ssoadfsAuthority
    ssoClientId: hostPoolGet.properties.ssoClientId
    ssoClientSecretKeyVaultPath: hostPoolGet.properties.ssoClientSecretKeyVaultPath
    validationEnvironment: hostPoolGet.properties.validationEnvironment
    ring: hostPoolGet.properties.ring
    tags: hostPoolGet.tags
    agentUpdate: hostPoolGet.properties.agentUpdate
  }
}

// call on the keyvault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: split(hostPool.outputs.keyVaultTokenSecretResourceId, '/')[8]
  scope: resourceGroup('${varKeyVaultSubId}', '${varKeyVaultRgName}')
}

// Apply AVD session host configurations
module sessionHostConfiguration './modules/configureSessionHost.bicep' = {
  scope: resourceGroup('${computeSubscriptionId}', '${computeRgResourceGroupName}')
  name: 'AVD-Agents-${vmName}-${time}'
  params: {
    location: vmLocation
    name: vmName
    hostPoolToken: keyVault.getSecret('hostPoolRegistrationToken')
    baseScriptUri: varSessionHostConfigurationScriptUri
    scriptName: varSessionHostConfigurationScript
  }
  dependsOn: []
}
