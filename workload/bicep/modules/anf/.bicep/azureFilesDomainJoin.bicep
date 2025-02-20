metadata name = 'AVD LZA storage'
metadata description = 'Configures domain join settings on storage account via VM custom script extension'
metadata owner = 'Azure/avdaccelerator'

// ========== //
// Parameters //
// ========== //

@sys.description('Virtual machine name.')
param virtualMachineName string

@sys.description('Location where to deploy compute services.')
param location string

@sys.description('Location for the AVD agent installation package.')
param baseScriptUri string

param file string

@sys.description('Arguments for domain join script.')
param scriptArguments string

@secure()
@sys.description('Domain join user password.')
param adminUserPassword string

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Deployments //
// =========== //

// Add Azure Files to AD DS domain.
module dscStorageScript '../../../../../avm/1.0.0/res/compute/virtual-machine/extension/main.bicep' = {
  name: 'VM-Ext-AVM-${time}'
  params: {
    name: 'AzureFilesDomainJoin'
    virtualMachineName: virtualMachineName
    location: location
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: false
    settings: {}
    protectedSettings: {
      fileUris: array(baseScriptUri)
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File ${file} ${scriptArguments} -AdminUserPassword ${adminUserPassword} -verbose'
    }
  }
}
