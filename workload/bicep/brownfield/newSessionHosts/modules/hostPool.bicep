// ========== //
// Parameters //
// ========== //

@description('Required. The name of the host pool.')
param hostPoolName string

@description('Required. The type of host pool.')
param hostPoolType string

@description('Required. The type of load balancer for the host pool.')
param loadBalancerType string

@description('Required. The location of the host pool.')
param location string

@description('Required. The preferred app group type for the host pool.')
param preferredAppGroupType string


// ========== //
// Deployments //
// ========== //

// Host pool.
resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2021-07-12' = {
  name: hostPoolName
  location: location
  properties: {
    hostPoolType: hostPoolType
    loadBalancerType: loadBalancerType
    preferredAppGroupType: preferredAppGroupType
    startVMOnConnect: true
  }
}
