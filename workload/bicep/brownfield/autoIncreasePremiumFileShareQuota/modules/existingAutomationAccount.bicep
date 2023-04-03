// =========== //
// Parameters  //
// =========== //

param automationAccountName string


// =========== //
// Deployments //
// =========== //

resource automationAccount 'Microsoft.Automation/automationAccounts@2022-08-08' existing = {
  name: automationAccountName
}


// =========== //
// Outputs     //
// =========== //

output name string = automationAccount.name
output properties object = automationAccount.properties
output tags object = automationAccount.tags
