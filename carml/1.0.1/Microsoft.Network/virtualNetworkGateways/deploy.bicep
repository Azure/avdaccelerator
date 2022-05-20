@description('Required. Specifies the Virtual Network Gateway name.')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Specifies the name of the Public IP used by the Virtual Network Gateway. If it\'s not provided, a \'-pip\' suffix will be appended to the gateway\'s name.')
param gatewayPipName array = []

@description('Optional. Resource ID of the Public IP Prefix object. This is only needed if you want your Public IPs created in a PIP Prefix.')
param publicIPPrefixResourceId string = ''

@description('Optional. Specifies the zones of the Public IP address. Basic IP SKU does not support Availability Zones.')
param publicIpZones array = []

@description('Optional. DNS name(s) of the Public IP resource(s). If you enabled active-active configuration, you need to provide 2 DNS names, if you want to use this feature. A region specific suffix will be appended to it, e.g.: your-DNS-name.westeurope.cloudapp.azure.com')
param domainNameLabel array = []

@description('Required. Specifies the gateway type. E.g. VPN, ExpressRoute')
@allowed([
  'Vpn'
  'ExpressRoute'
])
param virtualNetworkGatewayType string

@description('Required. The Sku of the Gateway.')
@allowed([
  'Basic'
  'VpnGw1'
  'VpnGw2'
  'VpnGw3'
  'VpnGw1AZ'
  'VpnGw2AZ'
  'VpnGw3AZ'
  'Standard'
  'HighPerformance'
  'UltraPerformance'
  'ErGw1AZ'
  'ErGw2AZ'
  'ErGw3AZ'
])
param virtualNetworkGatewaySku string

@description('Required. Specifies the VPN type')
@allowed([
  'PolicyBased'
  'RouteBased'
])
param vpnType string = 'RouteBased'

@description('Required. Virtual Network resource ID')
param vNetResourceId string

@description('Optional. Value to specify if the Gateway should be deployed in active-active or active-passive configuration')
param activeActive bool = true

@description('Optional. Value to specify if BGP is enabled or not')
param enableBgp bool = true

@description('Optional. ASN value')
param asn int = 65815

@description('Optional. The IP address range from which VPN clients will receive an IP address when connected. Range specified must not overlap with on-premise network.')
param vpnClientAddressPoolPrefix string = ''

@description('Optional. Client root certificate data used to authenticate VPN clients.')
param clientRootCertData string = ''

@description('Optional. Thumbprint of the revoked certificate. This would revoke VPN client certificates matching this thumbprint from connecting to the VNet.')
param clientRevokedCertThumbprint string = ''

@description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 365

@description('Optional. Resource ID of the diagnostic storage account.')
param diagnosticStorageAccountId string = ''

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticWorkspaceId string = ''

@description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param diagnosticEventHubName string = ''

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'')
param roleAssignments array = []

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string = 'NotSpecified'

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. Enable telemetry via the Customer Usage Attribution ID (GUID).')
param enableDefaultTelemetry bool = true

@description('Optional. The name of logs that will be streamed.')
@allowed([
  'DDoSProtectionNotifications'
  'DDoSMitigationFlowLogs'
  'DDoSMitigationReports'
])
param publicIpdiagnosticLogCategoriesToEnable array = [
  'DDoSProtectionNotifications'
  'DDoSMitigationFlowLogs'
  'DDoSMitigationReports'
]

@description('Optional. The name of logs that will be streamed.')
@allowed([
  'GatewayDiagnosticLog'
  'TunnelDiagnosticLog'
  'RouteDiagnosticLog'
  'IKEDiagnosticLog'
  'P2SDiagnosticLog'
])
param virtualNetworkGatewaydiagnosticLogCategoriesToEnable array = [
  'GatewayDiagnosticLog'
  'TunnelDiagnosticLog'
  'RouteDiagnosticLog'
  'IKEDiagnosticLog'
  'P2SDiagnosticLog'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param diagnosticMetricsToEnable array = [
  'AllMetrics'
]

@description('Optional. The name of the diagnostic setting, if deployed.')
param virtualNetworkGatewayDiagnosticSettingsName string = '${name}-diagnosticSettings'

@description('Optional. The name of the diagnostic setting, if deployed.')
param publicIpDiagnosticSettingsName string = '${name}-diagnosticSettings'

var virtualNetworkGatewayDiagnosticsLogs = [for category in virtualNetworkGatewaydiagnosticLogCategoriesToEnable: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

var publicIpDiagnosticsLogs = [for category in publicIpdiagnosticLogCategoriesToEnable: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

var zoneRedundantSkus = [
  'VpnGw1AZ'
  'VpnGw2AZ'
  'VpnGw3AZ'
  'VpnGw4AZ'
  'VpnGw5AZ'
  'ErGw1AZ'
  'ErGw2AZ'
  'ErGw3AZ'
]
var gatewayPipSku = contains(zoneRedundantSkus, virtualNetworkGatewaySku) ? 'Standard' : 'Basic'
var gatewayPipAllocationMethod = contains(zoneRedundantSkus, virtualNetworkGatewaySku) ? 'Static' : 'Dynamic'
var gatewaySubnetId = '${vNetResourceId}/subnets/GatewaySubnet'
var activeActive_var = virtualNetworkGatewayType == 'ExpressRoute' ? false : activeActive

// Public IP variables
var gatewayPipName1 = length(gatewayPipName) == 0 ? '${name}-pip1' : gatewayPipName[0]
var gatewayPipName2 = activeActive_var ? (length(gatewayPipName) == 1 ? '${name}-pip2' : gatewayPipName[1]) : ''

var gatewayMultiPipArray = [
  gatewayPipName1
  gatewayPipName2
]
var gatewaySinglePipArray = [
  gatewayPipName1
]
var virtualGatewayPipName_var = !empty(gatewayPipName2) ? gatewayMultiPipArray : gatewaySinglePipArray
var gatewayPipId1 = az.resourceId('Microsoft.Network/publicIPAddresses', gatewayPipName1)
var gatewayPipId2 = activeActive_var ? az.resourceId('Microsoft.Network/publicIPAddresses', gatewayPipName2) : az.resourceId('Microsoft.Network/publicIPAddresses', gatewayPipName1)

var enableBgp_var = virtualNetworkGatewayType == 'ExpressRoute' ? false : enableBgp
var vpnType_var = virtualNetworkGatewayType == 'ExpressRoute' ? 'PolicyBased' : vpnType
var bgpSettings = {
  asn: asn
}
var publicIPPrefix = {
  id: publicIPPrefixResourceId
}
var activePassiveIpConfiguration = [
  {
    properties: {
      privateIPAllocationMethod: 'Dynamic'
      subnet: {
        id: gatewaySubnetId
      }
      publicIPAddress: {
        id: gatewayPipId1
      }
    }
    name: 'vNetGatewayConfig1'
  }
]
var activeActiveIpConfiguration = [
  {
    properties: {
      privateIPAllocationMethod: 'Dynamic'
      subnet: {
        id: gatewaySubnetId
      }
      publicIPAddress: {
        id: gatewayPipId1
      }
    }
    name: 'vNetGatewayConfig1'
  }
  {
    properties: {
      privateIPAllocationMethod: 'Dynamic'
      subnet: {
        id: gatewaySubnetId
      }
      publicIPAddress: {
        id: gatewayPipId2
      }
    }
    name: 'vNetGatewayConfig2'
  }
]
var vpnClientRootCertificates = [
  {
    name: 'RootCert1'
    properties: {
      PublicCertData: clientRootCertData
    }
  }
]
var vpmClientRevokedCertificates = [
  {
    name: 'RevokedCert1'
    properties: {
      Thumbprint: clientRevokedCertThumbprint
    }
  }
]
var vpnClientConfiguration = {
  vpnClientAddressPool: {
    addressPrefixes: [
      vpnClientAddressPoolPrefix
    ]
  }
  vpnClientRootCertificates: !empty(clientRootCertData) ? vpnClientRootCertificates : null
  vpnClientRevokedCertificates: !empty(clientRevokedCertThumbprint) ? vpmClientRevokedCertificates : null
}

resource defaultTelemetry 'Microsoft.Resources/deployments@2021-04-01' = if (enableDefaultTelemetry) {
  name: 'pid-47ed15a6-730a-4827-bcb4-0fd963ffbd82-${uniqueString(deployment().name, location)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

// Public IPs
// ==========
@batchSize(1)
resource virtualGatewayPublicIP 'Microsoft.Network/publicIPAddresses@2021-05-01' = [for (virtualGatewayPublicIpName, index) in virtualGatewayPipName_var: {
  name: virtualGatewayPublicIpName
  location: location
  tags: tags
  sku: {
    name: gatewayPipSku
  }
  properties: {
    publicIPAllocationMethod: gatewayPipAllocationMethod
    publicIPPrefix: !empty(publicIPPrefixResourceId) ? publicIPPrefix : null
    dnsSettings: length(virtualGatewayPipName_var) == length(domainNameLabel) ? {
      domainNameLabel: domainNameLabel[index]
    } : null
  }
  zones: contains(zoneRedundantSkus, virtualNetworkGatewaySku) ? publicIpZones : null
}]

@batchSize(1)
resource virtualGatewayPublicIP_lock 'Microsoft.Authorization/locks@2017-04-01' = [for (virtualGatewayPublicIpName, index) in virtualGatewayPipName_var: if (lock != 'NotSpecified') {
  name: '${virtualGatewayPublicIpName}-${lock}-lock'
  properties: {
    level: lock
    notes: lock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: virtualGatewayPublicIP[index]
}]

@batchSize(1)
resource virtualNetworkGatewayPublicIp_diagnosticSettings 'Microsoft.Insights/diagnosticsettings@2021-05-01-preview' = [for (virtualGatewayPublicIpName, index) in virtualGatewayPipName_var: if ((!empty(diagnosticStorageAccountId)) || (!empty(diagnosticWorkspaceId)) || (!empty(diagnosticEventHubAuthorizationRuleId)) || (!empty(diagnosticEventHubName))) {
  name: publicIpDiagnosticSettingsName
  properties: {
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    workspaceId: !empty(diagnosticWorkspaceId) ? diagnosticWorkspaceId : null
    eventHubAuthorizationRuleId: !empty(diagnosticEventHubAuthorizationRuleId) ? diagnosticEventHubAuthorizationRuleId : null
    eventHubName: !empty(diagnosticEventHubName) ? diagnosticEventHubName : null
    metrics: diagnosticsMetrics
    logs: publicIpDiagnosticsLogs
  }
  scope: virtualGatewayPublicIP[index]
}]

// VNET Gateway
// ============
resource virtualNetworkGateway 'Microsoft.Network/virtualNetworkGateways@2021-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    ipConfigurations: activeActive_var ? activeActiveIpConfiguration : activePassiveIpConfiguration
    activeActive: activeActive_var
    enableBgp: enableBgp_var
    bgpSettings: enableBgp_var ? bgpSettings : null
    sku: {
      name: virtualNetworkGatewaySku
      tier: virtualNetworkGatewaySku
    }
    gatewayType: virtualNetworkGatewayType
    vpnType: vpnType_var
    vpnClientConfiguration: !empty(vpnClientAddressPoolPrefix) ? vpnClientConfiguration : null
  }
  dependsOn: [
    virtualGatewayPublicIP
  ]
}

resource virtualNetworkGateway_lock 'Microsoft.Authorization/locks@2017-04-01' = if (lock != 'NotSpecified') {
  name: '${virtualNetworkGateway.name}-${lock}-lock'
  properties: {
    level: lock
    notes: lock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: virtualNetworkGateway
}

resource virtualNetworkGateway_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(diagnosticStorageAccountId) || !empty(diagnosticWorkspaceId) || !empty(diagnosticEventHubAuthorizationRuleId) || !empty(diagnosticEventHubName)) {
  name: virtualNetworkGatewayDiagnosticSettingsName
  properties: {
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    workspaceId: !empty(diagnosticWorkspaceId) ? diagnosticWorkspaceId : null
    eventHubAuthorizationRuleId: !empty(diagnosticEventHubAuthorizationRuleId) ? diagnosticEventHubAuthorizationRuleId : null
    eventHubName: !empty(diagnosticEventHubName) ? diagnosticEventHubName : null
    metrics: diagnosticsMetrics
    logs: virtualNetworkGatewayDiagnosticsLogs
  }
  scope: virtualNetworkGateway
}

module virtualNetworkGateway_rbac '.bicep/nested_rbac.bicep' = [for (roleAssignment, index) in roleAssignments: {
  name: '${uniqueString(deployment().name, location)}-VNetGateway-Rbac-${index}'
  params: {
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    resourceId: virtualNetworkGateway.id
  }
}]

@description('The resource group the virtual network gateway was deployed')
output resourceGroupName string = resourceGroup().name

@description('The name of the virtual network gateway')
output name string = virtualNetworkGateway.name

@description('The resource ID of the virtual network gateway')
output resourceId string = virtualNetworkGateway.id

@description('Shows if the virtual network gateway is configured in active-active mode')
output activeActive bool = virtualNetworkGateway.properties.activeActive
