targetScope = 'resourceGroup'

// ========== //
// Parameters //
// ========== //
@sys.description('Identity to assign the role to.')
param principalId string

@sys.description('Identity type.')
param principalType string

@sys.description('Role ID to be assigned.')
param roleDefinitionId string

@sys.description('Role assignment name.')
param roleAssignmentName string

// =========== //
// Variable declaration //
// =========== //

// =========== //
// Deployments //
// =========== //

// Role assignment
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
 name: roleAssignmentName
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: roleDefinitionId
  }
}

// =========== //
// Outputs //
// =========== //
