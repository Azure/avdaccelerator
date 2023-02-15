targetScope = 'subscription'


param AvdObjectId string
param HostPoolResourceId string
param Location string = deployment().location


var HostPoolName = split(HostPoolResourceId, '/')[8]
var DesktopVirtualizationPowerOnContributorId = '489581de-a3bd-480d-9518-53dea7416b33'
var ResourceGroupName = split(HostPoolResourceId, '/')[4]


resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(AvdObjectId, DesktopVirtualizationPowerOnContributorId, subscription().id)
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', DesktopVirtualizationPowerOnContributorId)
    principalId: AvdObjectId
  }
}

module existingHostPool 'modules/existingHostPool.bicep' = {
  name: 'get-existing-hostPool'
  scope: resourceGroup(ResourceGroupName)
  params: {
    HostPoolName: HostPoolName
  }
}

module hostPool 'modules/hostPool.bicep' = {
  name: HostPoolName
  scope: resourceGroup(ResourceGroupName)
  params: {
    HostPoolName: HostPoolName
    HostPoolType: existingHostPool.outputs.info.hostPoolType
    LoadBalancerType: existingHostPool.outputs.info.loadBalancerType
    Location: Location
    PreferredAppGroupType: existingHostPool.outputs.info.preferredAppGroupType
  }
}
