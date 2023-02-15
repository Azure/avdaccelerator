param HostPoolName string


resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2022-10-14-preview' existing = {
  name: HostPoolName
}


output info object = hostPool.properties
