// ========== //
// Parameters //
// ========== //

@sys.description('Extension deployment name.')
param name string

@sys.description('Location where to deploy compute services.')
param location string

@sys.description('Location for the AVD agent installation package.')
param baseScriptUri string

param file string

@sys.description('Arguments for domain join script.')
param scriptArguments string

@secure()
@sys.description('Domain join user password.')
param domainJoinUserPassword string

// =========== //
// Variable declaration //
// =========== //

var varscriptArgumentsWithPassword = '${scriptArguments} -DomainAdminUserPassword ${domainJoinUserPassword} -verbose'

// =========== //
// Deployments //
// =========== //

// Add Azure Files to AD DS domain.
resource dscStorageScript 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  name: '${name}/AzureFilesDomainJoin'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {}
    protectedSettings: {
      fileUris: array(baseScriptUri)
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File ${file} ${varscriptArgumentsWithPassword}'
    }
  }
}
