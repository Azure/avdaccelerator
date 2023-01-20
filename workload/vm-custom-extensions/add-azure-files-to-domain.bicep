param name string
param location string
param dscAgentPackageLocation string
param storageAccountName string
param storageAccountRG string
param domainName string
param AzureCloudEnvironment string



@secure()
param domainAdminPassword string

param domainAdminUsername string

/* Add Azure Files to AD DS domain*/

resource addAzureFilesToDomain 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  name: '${name}/Microsoft.PowerShell.DSC'
  location: location
  properties: {
    publisher: 'Microsoft.PowerShell'
    type: 'DSC'
    typeHandlerVersion: '2.73'
    autoUpgradeMinorVersion: true
    settings: {
      configuration: {
        url: dscAgentPackageLocation
        script: 'Configuration.ps1'
        function: 'DomainJoinFileShare'
      }
      configurationArguments: {
        storageAccountName: storageAccountName
        storageAccountRG: storageAccountRG
        DomainName: domainName
        AzureCloudEnvironment: AzureCloudEnvironment
        DomainAdminUserName: domainAdminUsername
      } 
    }
    protectedSettings: {
      configurationArguments: {
        DomainAdminUserPassword: domainAdminPassword
      } 
    }
  }
}
