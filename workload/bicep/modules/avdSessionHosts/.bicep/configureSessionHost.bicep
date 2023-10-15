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

@sys.description('File share path for FSlogix storage.')
param fslogixFileShare string

@sys.description('FSLogix storage account FDQN.')
param fslogixStorageFqdn string

@sys.description('Session host VM size.')
param vmSize string

@sys.description('AVD Host Pool registration token')
@secure()
param hostPoolToken string

// =========== //
// Variable declaration //
// =========== //
// var ScreenCaptureProtection = true
var varScriptArguments = '-IdentityDomainName ${identityDomainName} -AmdVmSize ${varAmdVmSize} -IdentityServiceProvider ${identityServiceProvider} -Fslogix ${fslogix} -FslogixFileShare ${fslogixFileShare} -FslogixStorageFqdn ${fslogixStorageFqdn} -HostPoolRegistrationToken ${hostPoolToken} -NvidiaVmSize ${varNvidiaVmSize} -verbose' // -ScreenCaptureProtection ${ScreenCaptureProtection} -verbose'
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
resource sessionHostConfig 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
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
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File ${scriptName} ${varScriptArguments}'
    }
  }
}
