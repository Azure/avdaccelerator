@description('Optional. The location to deploy to.')
param location string = resourceGroup().location

@description('Required. The name of the Host Pool to create.')
param hostPoolName string

resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2024-04-08-preview' = {
  name: hostPoolName
  location: location
  properties: {
    hostPoolType: 'Pooled'
    loadBalancerType: 'BreadthFirst'
    preferredAppGroupType: 'Desktop'
  }
}

@description('The name of the created Host Pool.')
output hostPoolName string = hostPool.name
