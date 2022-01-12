targetScope = 'subscription'

@description('Name of resource group to hold HostPools, Application Groups, and Workspaces')
param avdResourceGroup string      = 'rg-prod-eus-avdresources'

@description('Name of resource group to hold Virtual Machines')
param sessionHostRg string      = 'rg-prod-eus-avdresources'

@description('Name of Key Vault used for AVD deployment secrets')
@maxLength(24)
param keyVaultName string                

param hostPoolName string
param hostPoolToken string

param ouPath string 
param imageId string 
param subnetName string 
param vnetId string 
param domainToJoin string
@maxLength(10)
param vmName string = 'testpoc'

@maxValue(200)
param vmCount int = 1

param vmSize string = 'Standard_D2s_v4'

@description('UPN for domain joining AVD systems')
param domainJoinAccount string         

@description('Password for domain join account')
@secure()
param domainJoinPassword string

@description('Local administrator username for AVD systems')
param localAdminAccount string         = 'avdadmin'

@description('Password for domain join account')
@secure()
param localAdminPassword string

param time string = utcNow()

var domainJoinSecret = 'avdDomainJoinPassword'
var localAdminSecret = 'avdLocalAdminPassword'

resource sessionHostsRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: sessionHostRg
  location: deployment().location
}

resource avdRg 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: avdResourceGroup
}

resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2021-09-03-preview' existing = {
  name: hostPoolName
  scope: resourceGroup(avdResourceGroup)
}

module vaultSecretDj 'Modules/keyVaultSecret.bicep' = {
  scope: avdRg
  name: 'domainSecret-${time}'
  params: {
    keyVaultName: keyVaultName
    secretName: domainJoinSecret
    secretValue: domainJoinPassword
  }
}

module vaultSecretLa 'Modules/keyVaultSecret.bicep' = {
  scope: avdRg
  name: 'localSecret-${time}'
  params: {
    keyVaultName: keyVaultName
    secretName: localAdminSecret
    secretValue: localAdminPassword
  }
}

module sessionHost 'Modules/sessionhost.bicep' = {
  scope: sessionHostsRg
  name: 'sh${vmName}-${time}'
  params: {
    domainJoinPassword: domainJoinPassword
    domainToJoin: domainToJoin
    domainUserName: domainJoinAccount
    hostPoolId: hostPool.id
    hostPoolToken: hostPoolToken
    imageId: imageId
    localAdminName: localAdminAccount
    localAdminPassword: localAdminPassword
    ouPath: ouPath
    subnetName: subnetName
    vmName: vmName
    vnetId: vnetId
    count: vmCount
    vmSize: vmSize
  }
}

module tsSessionHost 'Modules/template-sessionhost.bicep' = {
  scope: avdRg
  name: 'sessionHts-${time}'
  params: {
    subnetName: subnetName
    keyVaultName: keyVaultName
    keyVaultResourceGroup: avdResourceGroup
    vmSize: vmSize
    count: vmCount
    imageId: imageId
    hostPoolName: hostPoolName
    hostPoolToken: hostPoolToken
    domainJoinUserName: domainJoinAccount
    templateSpecDisplayName: 'SessionHost-${hostPoolName}'
    domainToJoin: domainToJoin
    vmName: vmName
    ouPath: ouPath
    localAdminName: localAdminAccount 
    templateSpecName: 'SessionHost-${hostPoolName}'
    vnetId: vnetId
  }
}
