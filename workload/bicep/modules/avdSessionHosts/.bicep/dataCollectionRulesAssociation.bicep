targetScope = 'resourceGroup'

// ========== //
// Parameters //
// ========== //
// @sys.description('Data colleciton rule association name.')
// param name string

@sys.description('VM name.')
param virtualMachineName string

@sys.description('Data collection rule ID.')
param dataCollectionRuleId string

// =========== //
// Variable declaration //
// =========== //


// =========== //
// Deployments //
// =========== //
resource symbolicname 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = {
  name: virtualMachineName
  properties: {
    dataCollectionRuleId: dataCollectionRuleId
    description: 'AVD Insights data collection rule association'
  }
}
