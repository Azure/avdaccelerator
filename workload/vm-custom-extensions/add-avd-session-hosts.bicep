param name string
param location string
param avdAgentPackageLocation string
param hostPoolName string
param systemData object = {}


//@secure()
param hostPoolToken string

/* Add session hosts to Host Pool */

resource addToHostPool 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  name: '${name}/Microsoft.PowerShell.DSC'
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
