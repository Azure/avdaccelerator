param hostPoolName string


resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2022-10-14-preview' existing = {
  name: hostPoolName
}


output info object = hostPool.properties
