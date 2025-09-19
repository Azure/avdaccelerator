// =========== //
// Parameters  //
// =========== //

param automationAccountName string


// =========== //
// Deployments //
// =========== //

resource automationAccount 'Microsoft.Automation/automationAccounts@2024-10-23' existing = {
  name: automationAccountName
}


// =========== //
// Outputs     //
// =========== //

output name string = automationAccount.name
output properties object = automationAccount.properties
output tags object = automationAccount.tags
