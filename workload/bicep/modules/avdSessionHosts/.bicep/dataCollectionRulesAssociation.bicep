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
// Get Vm object
resource getVm 'Microsoft.Compute/virtualMachines@2023-09-01' existing = {
  name: virtualMachineName
}

// Deploy VM data rule collection association
resource symbolicname 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = {
  name: virtualMachineName
  scope: getVm
  properties: {
    dataCollectionRuleId: dataCollectionRuleId
    description: 'AVD Insights data collection rule association'
    
  }
  dependsOn: [
    getVm
  ]
}
