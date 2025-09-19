// ========== //
// Parameters //
// ========== //

@description('Required. The name of the host pool.')
param hostPoolName string


// ========== //
// Deployments //
// ========== //

// Host pool.
resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2025-03-01-preview' existing = {
  name: hostPoolName
}


// ========== //
// Outputs //
// ========== //

output info object = hostPool.properties
