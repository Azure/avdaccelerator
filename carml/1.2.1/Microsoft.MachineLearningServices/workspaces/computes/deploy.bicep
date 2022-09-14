// ================ //
// Parameters       //
// ================ //
@sys.description('Conditional. The name of the parent Machine Learning Workspace. Required if the template is used in a standalone deployment.')
param machineLearningWorkspaceName string

@sys.description('Required. Name of the compute.')
@minLength(2)
@maxLength(16)
param name string

@sys.description('Optional. Specifies the location of the resource.')
param location string = resourceGroup().location

@sys.description('Optional. Specifies the sku, also referred as "edition". Required for creating a compute resource.')
@allowed([
  'Basic'
  'Enterprise'
  ''
])
param sku string = ''

@sys.description('Optional. Contains resource tags defined as key-value pairs. Ignored when attaching a compute resource, i.e. when you provide a resource ID.')
param tags object = {}

@sys.description('Optional. Flag to specify whether to deploy the compute. Required only for attach (i.e. providing a resource ID), as in this case the operation is not idempontent, i.e. a second deployment will fail. Therefore, this flag needs to be set to "false" as long as the compute resource exists.')
param deployCompute bool = true

@sys.description('Optional. Location for the underlying compute. Ignored when attaching a compute resource, i.e. when you provide a resource ID.')
param computeLocation string = resourceGroup().location

@sys.description('Optional. The description of the Machine Learning compute.')
param description string = ''

@sys.description('Optional. Opt-out of local authentication and ensure customers can use only MSI and AAD exclusively for authentication.')
param disableLocalAuth bool = false

@sys.description('Optional. ARM resource ID of the underlying compute.')
param resourceId string = ''

@sys.description('Required. Set the object type.')
@allowed([
  'AKS'
  'AmlCompute'
  'ComputeInstance'
  'Databricks'
  'DataFactory'
  'DataLakeAnalytics'
  'HDInsight'
  'Kubernetes'
  'SynapseSpark'
  'VirtualMachine'
])
param computeType string

@sys.description('Optional. The properties of the compute. Will be ignored in case "resourceId" is set.')
param properties object = {}

@sys.description('Optional. Enable telemetry via the Customer Usage Attribution ID (GUID).')
param enableDefaultTelemetry bool = true

// Identity
@sys.description('Optional. Enables system assigned managed identity on the resource. Ignored when attaching a compute resource, i.e. when you provide a resource ID.')
param systemAssignedIdentity bool = false

@sys.description('Optional. The ID(s) to assign to the resource. Ignored when attaching a compute resource, i.e. when you provide a resource ID.')
param userAssignedIdentities object = {}

// ================//
// Variables       //
// ================//
var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : any(null)
} : any(null)

// ============================= //
// Existing resources references //
// ============================= //
resource machineLearningWorkspace 'Microsoft.MachineLearningServices/workspaces@2021-04-01' existing = {
  name: machineLearningWorkspaceName
}

// =========== //
// Deployments //
// =========== //
resource defaultTelemetry 'Microsoft.Resources/deployments@2021-04-01' = if (enableDefaultTelemetry) {
  name: 'pid-47ed15a6-730a-4827-bcb4-0fd963ffbd82-${uniqueString(deployment().name)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

resource machineLearningWorkspaceCompute 'Microsoft.MachineLearningServices/workspaces/computes@2022-01-01-preview' = if (deployCompute == true) {
  name: name
  location: location
  tags: empty(resourceId) ? tags : any(null)
  sku: empty(resourceId) ? {
    name: sku
    tier: sku
  } : any(null)
  parent: machineLearningWorkspace
  identity: empty(resourceId) ? identity : any(null)
  properties: union({
      description: description
      disableLocalAuth: disableLocalAuth
      computeType: computeType
    }, (!empty(resourceId) ? {
      resourceId: resourceId
    } : {
      computeLocation: computeLocation
      properties: properties
    }))
}

// =========== //
// Outputs     //
// =========== //
@sys.description('The name of the compute.')
output name string = machineLearningWorkspaceCompute.name

@sys.description('The resource ID of the compute.')
output resourceId string = machineLearningWorkspaceCompute.id

@sys.description('The resource group the compute was deployed into.')
output resourceGroupName string = resourceGroup().name

@sys.description('The principal ID of the system assigned identity. Is null in case of attaching a compute resource, i.e. when you provide a resource ID.')
output systemAssignedPrincipalId string = empty(resourceId) ? (systemAssignedIdentity && contains(machineLearningWorkspaceCompute.identity, 'principalId') ? machineLearningWorkspaceCompute.identity.principalId : '') : ''

@sys.description('The location the resource was deployed into.')
output location string = machineLearningWorkspaceCompute.location
