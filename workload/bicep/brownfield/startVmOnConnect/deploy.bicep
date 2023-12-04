targetScope = 'subscription'


// ========== //
// Parameters //
// ========== //

@description('Required. The object ID for the Azure Virtual Desktop application in Microsoft Entra ID.')
param avdObjectId string

@description('Required. The resource ID for the host pool to enable Start VM On Connect on.')
param hostPoolResourceId string

@description('Optional. The location for the host pool to enable Start VM On Connect on.')
param location string = deployment().location


// =========== //
// Variables   //
// =========== //

var varHostPoolName = split(hostPoolResourceId, '/')[8]
var varDesktopVirtualizationPowerOnContributorId = '489581de-a3bd-480d-9518-53dea7416b33'
var varResourceGroupName = split(hostPoolResourceId, '/')[4]


// =========== //
// Deployments //
// =========== //

// Role Assignment.
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(avdObjectId, varDesktopVirtualizationPowerOnContributorId, subscription().id)
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', varDesktopVirtualizationPowerOnContributorId)
    principalId: avdObjectId
  }
}

// Gets properities of the exisiting AVD host pool.
module existingHostPool 'modules/existingHostPool.bicep' = {
  name: 'get-existing-hostPool'
  scope: resourceGroup(varResourceGroupName)
  params: {
    hostPoolName: varHostPoolName
  }
}

// Enables Start VM On Connect on the AVD host pool.
module hostPool 'modules/hostPool.bicep' = {
  name: varHostPoolName
  scope: resourceGroup(varResourceGroupName)
  params: {
    hostPoolName: varHostPoolName
    hostPoolType: existingHostPool.outputs.info.hostPoolType
    loadBalancerType: existingHostPool.outputs.info.loadBalancerType
    location: location
    preferredAppGroupType: existingHostPool.outputs.info.preferredAppGroupType
  }
}
