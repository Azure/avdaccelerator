// ========== //
// Parameters //
// ========== //

@description('Extension deployment name.')
param name string

@description('Location where to deploy compute services.')
param location string

@description('Location for the AVD agent installation package.')
param dscAgentPackageLocation string

@description('Storage account name.')
param storageAccountName string

@description('Resource Group Name for Azure Files.')
param storageAccountRG string

@description('AD domain name.')
param domainName string

@description('Azure cloud environment.')
param AzureCloudEnvironment string

@description('Sets purpose of the storage account.')
param storagePurpose string

@description('Domain join account password.')
@secure()
param domainAdminPassword string

@description('Domain join account username.')
param domainAdminUsername string

// =========== //
// Deployments //
// =========== //

// Add Azure Files to AD DS domain.
resource addAzureFilesToDomain 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  name: '${name}/AzureFilesDomainJoin'
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
        StoragePurpose: storagePurpose
      } 
    }
    protectedSettings: {
      configurationArguments: {
        DomainAdminUserPassword: domainAdminPassword
      } 
    }
  }
}
