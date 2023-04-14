param privateEndpointResourceId string
param privateEndpointVnetLocation string
param privateEndpointObj object
param tags object

var privateEndpointResourceName = last(split(privateEndpointResourceId, '/'))
var privateEndpoint_var = {
  name: contains(privateEndpointObj, 'name') ? (!empty(privateEndpointObj.name) ? privateEndpointObj.name : '${privateEndpointResourceName}-${privateEndpointObj.service}') : '${privateEndpointResourceName}-${privateEndpointObj.service}'
  subnetResourceId: privateEndpointObj.subnetResourceId
  service: [
    privateEndpointObj.service
  ]
  privateDnsZoneResourceIds: contains(privateEndpointObj, 'privateDnsZoneResourceIds') ? (!empty(privateEndpointObj.privateDnsZoneResourceIds) ? privateEndpointObj.privateDnsZoneResourceIds : []) : []
  customDnsConfigs: contains(privateEndpointObj, 'customDnsConfigs') ? (!empty(privateEndpointObj.customDnsConfigs) ? privateEndpointObj.customDnsConfigs : null) : null
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpoint_var.name
  location: privateEndpointVnetLocation
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateEndpoint_var.name
        properties: {
          privateLinkServiceId: privateEndpointResourceId
          groupIds: privateEndpoint_var.service
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    subnet: {
      id: privateEndpoint_var.subnetResourceId
    }
    customDnsConfigs: privateEndpoint_var.customDnsConfigs
  }
}

resource privateDnsZoneGroups 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (!empty(privateEndpoint_var.privateDnsZoneResourceIds)) {
  name: '${privateEndpoint.name}/default'
  properties: {
    privateDnsZoneConfigs: [for privateDnsZoneResourceId in privateEndpoint_var.privateDnsZoneResourceIds: {
      name: last(split(privateDnsZoneResourceId, '/'))
      properties: {
        privateDnsZoneId: privateDnsZoneResourceId
      }
    }]
  }
}
