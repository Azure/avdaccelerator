@description('Required. Name of the static site.')
@minLength(1)
@maxLength(40)
param name string

@allowed([
  'Free'
  'Standard'
])
@description('Optional. Type of static site to deploy.')
param sku string = 'Free'

@description('Optional. If config file is locked for this static web app.')
param allowConfigFileUpdates bool = true

@description('Optional. Location to deploy static site. The following locations are supported: CentralUS, EastUS2, EastAsia, WestEurope, WestUS2')
param location string = resourceGroup().location

@allowed([
  'Enabled'
  'Disabled'
])
@description('Optional. State indicating whether staging environments are allowed or not allowed for a static web app.')
param stagingEnvironmentPolicy string = 'Enabled'

@allowed([
  'Disabled'
  'Disabling'
  'Enabled'
  'Enabling'
])
@description('Optional. State indicating the status of the enterprise grade CDN serving traffic to the static web app.')
param enterpriseGradeCdnStatus string = 'Disabled'

@description('Optional. Build properties for the static site.')
param buildProperties object = {}

@description('Optional. Template Options for the static site.')
param templateProperties object = {}

@description('Optional. The provider that submitted the last deployment to the primary environment of the static site.')
param provider string = 'None'

@secure()
@description('Optional. The Personal Access Token for accessing the GitHub repo.')
param repositoryToken string = ''

@description('Optional. The name of the GitHub repo.')
param repositoryUrl string = ''

@description('Optional. The branch name of the GitHub repo.')
param branch string = ''

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string = 'NotSpecified'

@description('Optional. Configuration details for private endpoints.')
param privateEndpoints array = []

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. Enable telemetry via the Customer Usage Attribution ID (GUID).')
param enableDefaultTelemetry bool = true

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
param roleAssignments array = []

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

resource defaultTelemetry 'Microsoft.Resources/deployments@2021-04-01' = if (enableDefaultTelemetry) {
  name: 'pid-47ed15a6-730a-4827-bcb4-0fd963ffbd82-${uniqueString(deployment().name, location)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

resource staticSite 'Microsoft.Web/staticSites@2021-03-01' = {
  name: name
  location: location
  tags: tags
  identity: identity
  sku: {
    name: sku
    tier: sku
  }
  properties: {
    allowConfigFileUpdates: allowConfigFileUpdates
    stagingEnvironmentPolicy: stagingEnvironmentPolicy
    enterpriseGradeCdnStatus: enterpriseGradeCdnStatus
    provider: !empty(provider) ? provider : 'None'
    branch: !empty(branch) ? branch : null
    buildProperties: !empty(buildProperties) ? buildProperties : null
    repositoryToken: !empty(repositoryToken) ? repositoryToken : null
    repositoryUrl: !empty(repositoryUrl) ? repositoryUrl : null
    templateProperties: !empty(templateProperties) ? templateProperties : null
  }
}

resource staticSite_lock 'Microsoft.Authorization/locks@2017-04-01' = if (lock != 'NotSpecified') {
  name: '${staticSite.name}-${lock}-lock'
  properties: {
    level: lock
    notes: lock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: staticSite
}

module staticSite_rbac '.bicep/nested_rbac.bicep' = [for (roleAssignment, index) in roleAssignments: {
  name: '${uniqueString(deployment().name, location)}-StaticSite-Rbac-${index}'
  params: {
    principalIds: roleAssignment.principalIds
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    resourceId: staticSite.id
  }
}]

module staticSite_privateEndpoint '.bicep/nested_privateEndpoint.bicep' = [for (privateEndpoint, index) in privateEndpoints: {
  name: '${uniqueString(deployment().name, location)}-StaticSite-PrivateEndpoints-${index}'
  params: {
    privateEndpointResourceId: staticSite.id
    privateEndpointVnetLocation: reference(split(privateEndpoint.subnetResourceId, '/subnets/')[0], '2020-06-01', 'Full').location
    privateEndpointObj: privateEndpoint
    tags: tags
  }
}]

@description('The name of the static site.')
output name string = staticSite.name

@description('The resource ID of the static site.')
output resourceId string = staticSite.id

@description('The resource group the static site was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The principal ID of the system assigned identity.')
output systemAssignedPrincipalId string = systemAssignedIdentity && contains(staticSite.identity, 'principalId') ? staticSite.identity.principalId : ''
