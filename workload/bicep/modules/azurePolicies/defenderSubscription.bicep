targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@description('Name of the initiative definition.')
param initiativeName string = 'Custom - Deploy Microsoft Defender for Cloud Security - AVD'

@description('Display name of the initiative.')
param initiativeDisplayName string = 'Custom - Deploy Microsoft Defender for Cloud Security - AVD'

@description('Description of the initiative.')
param initiativeDescription string = 'This initiative deploys Microsoft Defender for Cloud Security for AVD.'

@description('Category of the initiative.')
param initiativeCategory string = 'Security Center'

@description('Effect for the policy.')
@allowed([
  'DeployIfNotExists'
  'Disabled'
])
param effect string = 'DeployIfNotExists'

@description('Enable or disable the Malware Scanning add-on feature.')
@allowed([
  'true'
  'false'
])
param isOnUploadMalwareScanningEnabled string = 'true'

@description('Cap GB scanned per month per storage account.')
param capGBPerMonthPerStorageAccount int = 5000

@description('Enable or disable the Sensitive Data Threat Detection add-on feature.')
@allowed([
  'true'
  'false'
])
param isSensitiveDataDiscoveryEnabled string = 'true'

@description('Select a Defender for Key Vault plan.')
@allowed([
  'PerTransaction'
  'PerKeyVault'
])
param keyVaultSubPlan string = 'PerTransaction'

@description('Select a Defender for Resource Manager plan.')
@allowed([
  'PerSubscription'
  'PerApiCall'
])
param resourceManagerSubPlan string = 'PerApiCall'

// =========== //
// Variables for enabling policies selectively //
// =========== //
@description('Enable or disable the "Configure Azure Defender for servers to be enabled" policy.')
param enableDefForServers bool = false

@description('Enable or disable the "Configure Microsoft Defender for Storage to be enabled" policy.')
param enableDefForStorage bool = false

@description('Enable or disable the "Configure Microsoft Defender for Key Vault plan" policy.')
param enableDefForKeyVault bool = false

@description('Enable or disable the "Configure Azure Defender for Resource Manager to be enabled" policy.')
param enableDefForArm bool = false

// =========== //
// Deployments //
// =========== //
resource initiative 'Microsoft.Authorization/policySetDefinitions@2023-04-01' = {
  name: initiativeName
  properties: {
    displayName: initiativeDisplayName
    description: initiativeDescription
    version: '1.0.0'
    metadata: {
      category: initiativeCategory
      version: '1.0.0'
    }
    policyDefinitions: concat(
      [
        {
          policyDefinitionReferenceId: 'EnsureContactEmail'
          policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', '4f4f78b8-e367-4b10-a341-d9a4ad5cf1c7')
          parameters: {
            effect: {
              value: 'AuditIfNotExists'
            }
          }
        }
      ],
      enableDefForServers
        ? [
            {
              policyDefinitionReferenceId: 'DefenderForServers'
              policyDefinitionId: tenantResourceId(
                'Microsoft.Authorization/policyDefinitions',
                '8e86a5b6-b9bd-49d1-8e21-4bb8a0862222'
              )
              parameters: {
                effect: {
                  value: effect
                }
              }
            }
          ]
        : [],
      enableDefForStorage
        ? [
            {
              policyDefinitionReferenceId: 'DefenderForStorage'
              policyDefinitionId: tenantResourceId(
                'Microsoft.Authorization/policyDefinitions',
                'cfdc5972-75b3-4418-8ae1-7f5c36839390'
              )
              parameters: {
                effect: {
                  value: effect
                }
                isOnUploadMalwareScanningEnabled: {
                  value: isOnUploadMalwareScanningEnabled
                }
                capGBPerMonthPerStorageAccount: {
                  value: capGBPerMonthPerStorageAccount
                }
                isSensitiveDataDiscoveryEnabled: {
                  value: isSensitiveDataDiscoveryEnabled
                }
              }
            }
          ]
        : [],
      enableDefForKeyVault
        ? [
            {
              policyDefinitionReferenceId: 'DefenderForKeyVault'
              policyDefinitionId: tenantResourceId(
                'Microsoft.Authorization/policyDefinitions',
                '1f725891-01c0-420a-9059-4fa46cb770b7'
              )
              parameters: {
                effect: {
                  value: effect
                }
                subPlan: {
                  value: keyVaultSubPlan
                }
              }
            }
          ]
        : [],
        enableDefForArm ? [
          {
            policyDefinitionReferenceId: 'DefenderForARM'
            policyDefinitionId: tenantResourceId(
              'Microsoft.Authorization/policyDefinitions',
              'b7021b2b-08fd-4dc0-9de7-3c6ece09faf9'
            )
            parameters: {
              effect: {
                value: effect
              }
              subPlan: {
                value: resourceManagerSubPlan
              }
            }
          }
        ]:[]
    )
    
  }
}
