param hostPoolName string
param hostPoolType string
param loadBalancerType string
param location string
param preferredAppGroupType string


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
