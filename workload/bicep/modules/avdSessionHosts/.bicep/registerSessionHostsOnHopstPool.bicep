// ========== //
// Parameters //
// ========== //

@description('Extension deployment name.')
param name string

@description('Location where to deploy compute services.')
param location string

@description('Location for the AVD agent installation package.')
param avdAgentPackageLocation string

@description('AVD Host Pool Name')
param hostPoolName string

param systemData object = {}

@description('AVD Host Pool registration token')
//@secure()
param hostPoolToken string

// =========== //
// Deployments //
// =========== //
// Add session hosts to Host Pool.
resource addToHostPool 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  name: '${name}/HostPoolRegistration'
  location: location
  properties: {
    publisher: 'Microsoft.PowerShell'
    type: 'DSC'
    typeHandlerVersion: '2.73'
    autoUpgradeMinorVersion: true
    settings: {
      modulesUrl: avdAgentPackageLocation
      configurationFunction: 'Configuration.ps1\\AddSessionHost'
      properties: {
        hostPoolName: hostPoolName
        registrationInfoToken: hostPoolToken
        aadJoin: false
        sessionHostConfigurationLastUpdateTime: contains(systemData,'hostpoolUpdate') ? systemData.sessionHostConfigurationVersion : ''
      }
    }
  }
}
