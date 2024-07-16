targetScope = 'resourceGroup'

// ========== //
// Parameters //
// ========== //
@sys.description('Name space of the private DNS zone')
param privateDnsZoneName string

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Virtual network resource ID to link private DNS zone to')
param virtualNetworkResourceId string

// =========== //
// Variable declaration //
// =========== //

// =========== //
// Deployments //
// =========== //

// Private DNS zone.
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
    name: privateDnsZoneName
    location: 'Global'
    tags: tags
}

  // Private DNS zone vNet link.
resource virtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
name: '${last(split(virtualNetworkResourceId, '/'))}-vnetlink'
parent: privateDnsZone
location: 'Global'
tags: tags
properties: {
    registrationEnabled: false
    virtualNetwork: {
    id: virtualNetworkResourceId
    }
}
}

// =========== //
// Outputs //
// =========== //
output resourceId string = privateDnsZone.id


