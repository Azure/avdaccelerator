param HostPoolName string
param HostPoolType string
param LoadBalancerType string
param Location string
param PreferredAppGroupType string


resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2022-10-14-preview' = {
  name: HostPoolName
  location: Location
  properties: {
    hostPoolType: HostPoolType
    loadBalancerType: LoadBalancerType
    preferredAppGroupType: PreferredAppGroupType
    startVMOnConnect: true
  }
}
