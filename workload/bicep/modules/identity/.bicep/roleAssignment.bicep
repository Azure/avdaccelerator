targetScope = 'resourceGroup'

// ========== //
// Parameters //
// ========== //
@sys.description('Identity to assign the role to.')
param principalId string

@sys.description('Identity type.')
param principalType string

@sys.description('Role o be assigned.')
param roleDefinitionId string

@sys.description('Role o be assigned.')
param roleDefinitionName string

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //

// =========== //
// Deployments //
// =========== //

// Role assignment
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
 name: 'RA-${roleDefinitionName}-${time}'
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: roleDefinitionId
  }
}

// =========== //
// Outputs //
// =========== //
