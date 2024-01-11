// ========== //
// Parameters //
// ========== //

@description('Required. The name of the host pool.')
param hostPoolName string


// ========== //
// Deployments //
// ========== //

// Host pool.
resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2021-07-12' existing = {
  name: hostPoolName
}


// ========== //
// Outputs //
// ========== //

output info object = hostPool.properties
