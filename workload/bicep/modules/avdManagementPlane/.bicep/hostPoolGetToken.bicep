metadata name = 'AVD LZA host pool token get'
metadata description = 'This module gets properties of existing host pool including updates to the registration token.'
metadata owner = 'Azure/avdaccelerator'

targetScope = 'resourceGroup'

// ========== //
// Parameters //
// ========== //
@sys.description('AVD workload subscription ID, multiple subscriptions scenario.')
param subscriptionId string

@sys.description('Location where to deploy AVD management plane.')
param location string

@sys.description('Name of keyvault that will contain host pool registration token.')
param kvName string

@sys.description('AVD Resource Group Name for the service objects.')
param serviceObjectsRgName string

@sys.description('AVD Host Pool Name')
param hostPoolName string

@sys.description('AVD Host Pool properties')
param hostPoolProperties object

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Deployments Commercial//
// =========== //
// Hostpool update
resource hostPoolUpdate 'Microsoft.DesktopVirtualization/hostPools@2023-09-05' = {
  name: hostPoolName
  location: location
  tags: tags
  properties: {
    friendlyName: hostPoolProperties.friendlyName
    description: hostPoolProperties.description
    hostPoolType: hostPoolProperties.hostPoolType
    publicNetworkAccess: hostPoolProperties.publicNetworkAccess
    customRdpProperty: hostPoolProperties.customRdpProperty
    personalDesktopAssignmentType: hostPoolProperties.personalDesktopAssignmentType
    preferredAppGroupType: hostPoolProperties.preferredAppGroupType
    maxSessionLimit: hostPoolProperties.maxSessionLimit
    loadBalancerType: hostPoolProperties.loadBalancerType
    startVMOnConnect: hostPoolProperties.startVMOnConnect
    validationEnvironment: hostPoolProperties.validationEnvironment
    registrationInfo: {
      expirationTime: dateTimeAdd(time, 'PT8H')
      token: null
      registrationTokenOperation: 'Update'
    }
    vmTemplate: hostPoolProperties.vmTemplate
    agentUpdate: hostPoolProperties.agentUpdate
    ring: hostPoolProperties.ring
    ssoadfsAuthority: hostPoolProperties.ssoadfsAuthority
    ssoClientId: hostPoolProperties.ssoClientId
    ssoClientSecretKeyVaultPath: hostPoolProperties.ssoClientSecretKeyVaultPath
    ssoSecretType: hostPoolProperties.ssoSecretType
  }
}

// Add secret to keyvault
module keyVaultSecret '../../../../../avm/1.0.0/res/key-vault/vault/secret/main.bicep' = {
  name: 'HP-Token-Secret-${time}'
  scope: resourceGroup('${subscriptionId}', '${serviceObjectsRgName}')
  params: {
    keyVaultName: kvName
    name: 'hostPoolRegistrationToken'
    value: hostPoolUpdate.properties.registrationInfo.token
    contentType: 'Host pool registration token for session hosts'
  }
}
