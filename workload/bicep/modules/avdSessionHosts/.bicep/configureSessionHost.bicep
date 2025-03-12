// ========== //
// Parameters //
// ========== //

@sys.description('Extension deployment name.')
param name string

@sys.description('The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@sys.description('Identity domain name.')
param identityDomainName string

@sys.description('Location where to deploy compute services.')
param location string

@sys.description('URI for AVD session host configuration URI path.')
param baseScriptUri string

@sys.description('URI for AVD session host configuration script.')
param scriptName string

@sys.description('Deploy FSlogix configuration.')
param fslogix bool

@sys.description('FSLogix storage account resource ID.')
param fslogixStorageAccountResourceId string

@sys.description('File share name for FSlogix storage.')
param fslogixSharePath string

@sys.description('Session host VM size.')
param vmSize string

@sys.description('AVD Host Pool Resource Id')
param hostPoolResourceId string

// =========== //
// Variable declaration //
// =========== //
// var ScreenCaptureProtection = true
// Additional parameter for screen capture functionallity -ScreenCaptureProtection ${ScreenCaptureProtection} -verbose' powershell script will need to be updated too

var fslogixStorageAccountName = fslogix ? last(split(fslogixStorageAccountResourceId, '/')) : ''

var varBaseScriptArguments = '-IdentityServiceProvider ${identityServiceProvider} -Fslogix ${fslogix} -HostPoolRegistrationToken "${hostPool.listRegistrationTokens().value[0].token}" -AmdVmSize ${varAmdVmSize} -NvidiaVmSize ${varNvidiaVmSize}'
var varBaseFSLogixScriptArguments = '-FslogixFileShare "${fslogixSharePath}"'
var varFSLogixScriptArguments = identityServiceProvider == 'EntraID'
  ? '${varBaseFSLogixScriptArguments} -FslogixStorageAccountKey "${storageAccount.listkeys().keys[0].value}"'
  : identityServiceProvider == 'EntraIDKerberos'
      ? '${varBaseFSLogixScriptArguments} -IdentityDomainName ${identityDomainName}'
      : varBaseFSLogixScriptArguments
var varScriptArguments = fslogix ? '${varBaseScriptArguments} ${varFSLogixScriptArguments}' : varBaseScriptArguments

var varAmdVmSizes = [
  'Standard_NV4as_v4'
  'Standard_NV8as_v4'
  'Standard_NV16as_v4'
  'Standard_NV32as_v4'
]
var varAmdVmSize = contains(varAmdVmSizes, vmSize)
var varNvidiaVmSizes = [
  'Standard_NV6'
  'Standard_NV12'
  'Standard_NV24'
  'Standard_NV12s_v3'
  'Standard_NV24s_v3'
  'Standard_NV48s_v3'
  'Standard_NC4as_T4_v3'
  'Standard_NC8as_T4_v3'
  'Standard_NC16as_T4_v3'
  'Standard_NC64as_T4_v3'
  'Standard_NV6ads_A10_v5'
  'Standard_NV12ads_A10_v5'
  'Standard_NV18ads_A10_v5'
  'Standard_NV36ads_A10_v5'
  'Standard_NV36adms_A10_v5'
  'Standard_NV72ads_A10_v5'
]
var varNvidiaVmSize = contains(varNvidiaVmSizes, vmSize)
// =========== //
// Deployments //
// =========== //

resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2023-09-05' existing = {
  name: last(split(hostPoolResourceId, '/'))
  scope: resourceGroup(split(hostPoolResourceId, '/')[4])
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = if (!empty(fslogixStorageAccountResourceId)) {
  name: fslogixStorageAccountName
  scope: resourceGroup(split(fslogixStorageAccountResourceId, '/')[4])
}

resource sessionHostConfig 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {
  name: '${name}/SessionHostConfig'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: array(baseScriptUri)
    }
    protectedSettings: {
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -Command .\\${scriptName} ${varScriptArguments}'
    }
  }
}

