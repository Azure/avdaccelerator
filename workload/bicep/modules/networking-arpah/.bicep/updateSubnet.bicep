targetScope = 'resourceGroup'

@sys.description('Existing virtual network name for AVD.')
param vnetName string

@sys.description('Existing virtual network subnet name for AVD.')
param subnetName string

@sys.description('Existing subnet properties')
param properties object

// Get existing vnet
resource existingVnet 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: vnetName
}

// update the subnet:  attach nsg and
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: subnetName
  parent: existingVnet
  properties: properties
}
