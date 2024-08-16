targetScope = 'managementGroup'

@sys.description('Required. Specifies the name of the policy definition. Maximum length is 64 characters.')
@maxLength(64)
param name string

@sys.description('Optional. The display name of the policy definition. Maximum length is 128 characters.')
@maxLength(128)
param displayName string = ''

@sys.description('Optional. The policy definition description.')
param description string = ''

@sys.description('Optional. The policy definition mode. Default is All, Some examples are All, Indexed, Microsoft.KeyVault.Data.')
@allowed([
  'All'
  'Indexed'
  'Microsoft.KeyVault.Data'
  'Microsoft.ContainerService.Data'
  'Microsoft.Kubernetes.Data'
])
param mode string = 'All'

@sys.description('Optional. The policy Definition metadata. Metadata is an open ended object and is typically a collection of key-value pairs.')
param metadata object = {}

@sys.description('Optional. The policy definition parameters that can be used in policy definition references.')
param parameters object = {}

@sys.description('Required. The Policy Rule details for the Policy Definition')
param policyRule object

@sys.description('Optional. The group ID of the Management Group. If not provided, will use the current scope for deployment.')
param managementGroupId string = managementGroup().name

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: name
  properties: {
    policyType: 'Custom'
    mode: mode
    displayName: !empty(displayName) ? displayName : null
    description: !empty(description) ? description : null
    metadata: !empty(metadata) ? metadata : null
    parameters: !empty(parameters) ? parameters : null
    policyRule: policyRule
  }
}

@sys.description('Policy Definition Name')
output name string = policyDefinition.name

@sys.description('Policy Definition resource ID')
output resourceId string = extensionResourceId(tenantResourceId('Microsoft.Management/managementGroups', managementGroupId), 'Microsoft.Authorization/policyDefinitions', policyDefinition.name)

@sys.description('Policy Definition Role Definition IDs')
output roleDefinitionIds array = (contains(policyDefinition.properties.policyRule.then, 'details') ? ((contains(policyDefinition.properties.policyRule.then.details, 'roleDefinitionIds') ? policyDefinition.properties.policyRule.then.details.roleDefinitionIds : [])) : [])
