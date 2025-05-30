metadata name = 'AVD LZA storage'
metadata description = 'Configures domain join settings on storage account via VM custom script extension'
metadata owner = 'Azure/avdaccelerator'

// ========== //
// Parameters //
// ========== //

@sys.description('The identity service provider for the domain join operation.')
param identityServiceProvider string

@sys.allowed([
  'AES256'
  'RC4'
])
@sys.description('The type of encryption to use for Kerberos tickets.')
param kerberosEncryption string

@sys.description('The URI of the key vault containing the domain join credentials.')
param keyVaultUri string

@sys.description('Location where to deploy compute services.')
param location string

@sys.description('The distinguished name for the organization unit in domain services for the computer object.')
param organizationalUnitPath string

@sys.description('The name of the security principal to give permissions to on the Azure Files share.')
param securityPrincipalName string

@sys.description('The name of the Azure Files share.')
param shareName string

@sys.description('The name of the storage account to use for Azure Files.')
param storageAccountName string

@sys.description('The name of the resource group containing the Azure Files share.')
param storageAccountResourceGroupName string

@sys.allowed([
  'AppAttach'
  'Fslogix'
])
@sys.description('The purpose of the Azure Files share.')
param storagePurpose string

@sys.description('The metadata tags to apply to the resource.')
param tags object

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

@sys.description('The client ID of the user-assigned identity to use for the run command.')
param userAssignedIdentityClientId string

@sys.description('Virtual machine name.')
param virtualMachineName string

// =========== //
// Deployments //
// =========== //

// Add Azure Files to AD DS domain.
module ntfsPermissions 'runCommand.bicep' = {
  name: 'NTFS-Permissions-${time}'
  params: {
    location: location
    name: 'Set-AzureFilesNtfsPermissions_${storagePurpose}'
    parameters: [
      {
        name: 'IdentityServiceProvider'
        value: identityServiceProvider
      }
      {
        name: 'KerberosEncryption'
        value: kerberosEncryption
      }
      {
        name: 'KeyVaultUri'
        value: keyVaultUri
      }
      {
        name: 'OrganizationalUnitPath'
        value: organizationalUnitPath
      }
      {
        name: 'ResourceManagerUri'
        value: environment().resourceManager
      }
      {
        name: 'SecurityPrincipalName'
        value: securityPrincipalName
      }
      {
        name: 'ShareName'
        value: shareName
      }
      {
        name: 'StorageAccountName'
        value: storageAccountName
      }
      {
        name: 'StorageAccountResourceGroupName'
        value: storageAccountResourceGroupName
      }
      {
        name: 'StoragePurpose'
        value: storagePurpose
      }
      {
        name: 'StorageSuffix'
        value: environment().suffixes.storage
      }
      {
        name: 'SubscriptionId'
        value: subscription().subscriptionId
      }
      {
        name: 'UserAssignedIdentityClientId'
        value: userAssignedIdentityClientId
      }
    ]
    script: loadTextContent('../../../../scripts/Set-AzureFilesNtfsPermissions.ps1')
    tags: tags
    virtualMachineName: virtualMachineName
  }
}
