param hostPoolName string
param hostPoolType string
param loadBalancerType string
param location string
param preferredAppGroupType string


resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2022-10-14-preview' = {
  name: hostPoolName
  location: location
  properties: {
    hostPoolType: hostPoolType
    loadBalancerType: loadBalancerType
    preferredAppGroupType: preferredAppGroupType
    startVMOnConnect: true
  }
}
