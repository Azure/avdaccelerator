param hostPoolName string


resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2021-07-12' existing = {
  name: hostPoolName
}


output info object = hostPool.properties
