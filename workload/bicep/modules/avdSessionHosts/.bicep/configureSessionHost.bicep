// ========== //
// Parameters //
// ========== //

@sys.description('Specifies whether to extend the OS disk.')
param extendOsDisk bool

@sys.description('Deploy FSlogix configuration.')
param fslogix bool

@sys.description('File share name for FSlogix storage.')
param fslogixSharePath string

@sys.description('FSLogix storage account resource ID.')
param fslogixStorageAccountResourceId string

@sys.description('AVD Host Pool Resource Id')
param hostPoolResourceId string

@sys.description('Identity domain name.')
param identityDomainName string

@sys.description('The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@allowed([
  'AES256'
  'RC4'
])
@sys.description('The encryption type for Kerberos authentication.')
param kerberosEncryption string

@sys.description('Location where to deploy compute services.')
param location string

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

@sys.description('The name of the virtual machine.')
param virtualMachineName string

@sys.description('Session host VM size.')
param virtualMachineSize string

// =========== //
// Variable declaration //
// =========== //
// var ScreenCaptureProtection = true
// Additional parameter for screen capture functionallity -ScreenCaptureProtection ${ScreenCaptureProtection} -verbose' powershell script will need to be updated too

var fslogixStorageAccountName = fslogix ? last(split(fslogixStorageAccountResourceId, '/')) : ''
var varAmdVmSizes = [
  'Standard_NV4as_v4'
  'Standard_NV8as_v4'
  'Standard_NV16as_v4'
  'Standard_NV32as_v4'
]
var varAmdVmSize = contains(varAmdVmSizes, virtualMachineSize)
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
var varNvidiaVmSize = contains(varNvidiaVmSizes, virtualMachineSize)

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

module sessionHostConfig '../../common/runCommand/deploy.bicep' = {
  name: 'Session-Host-Configuration-${time}'
  params: {
    location: location
    name: 'Set-SessionHostConfiguration'
    parameters: union(
      [
        {
          name: 'AmdVmSize'
          value: varAmdVmSize
        }
        {
          name: 'ExtendOsDisk'
          value: extendOsDisk
        }
        {
          name: 'Fslogix'
          value: fslogix
        }
        {
          name: 'IdentityServiceProvider'
          value: identityServiceProvider
        }
        {
          name: 'NvidiaVmSize'
          value: varNvidiaVmSize
        }
      ],
      fslogix ? [
        {
          name: 'FslogixFileShare'
          value: fslogixSharePath
        }
        {
          name: 'KerberosEncryption'
          value: kerberosEncryption
        }
      ] : [],
      fslogix && identityServiceProvider == 'EntraID' ? [
        {
          name: 'FslogixStorageAccountKey'
          value: fslogix ? storageAccount.listkeys().keys[0].value : ''
        }
      ] : [],
      fslogix && identityServiceProvider == 'EntraIDKerberos' ? [
        {
          name: 'IdentityDomainName'
          value: identityDomainName
        }
      ] : []
    )
    protectedParameters: '[{\'name\':\'HostPoolRegistrationToken\'},{\'value\':\'${hostPool.listRegistrationTokens().value[0].token}\'}]'
    script: loadTextContent('../../../../scripts/Set-SessionHostConfiguration.ps1')
    tags: tags
    virtualMachineName: virtualMachineName
  }
}
