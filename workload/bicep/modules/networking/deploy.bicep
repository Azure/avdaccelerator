targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@description('AVD workload subscription ID, multiple subscriptions scenario')
param workloadSubsId string

@description('Resource Group Name for the AVD session hosts')
param computeObjectsRgName string

// Optional parameters for the AVD session hosts virtual network.
@description('Create new virtual network')
param createVnet bool

@description('If new virtual network required for the AVD machines. Resource Group name for the virtual network.')
param networkObjectsRgName string

@description('Name of the virtual network if required to be created.')
param vNetworkName string

@description('AVD Network Security Group Name')
param avdNetworksecurityGroupName string

@description('Private endpoint Network Security Group Name')
param privateEndpointNetworksecurityGroupName string

@description('Created if a new VNet for AVD is created. Application Security Group (ASG) for the session hosts.')
param applicationSecurityGroupName string

@description('Created if the new VNet for AVD is created. Route Table name for AVD.')
param avdRouteTableName string

@description('Created if the new VNet for AVD is created. Route Table name for private endpoints.')
param privateEndpointRouteTableName string

@description('Does the hub contain a virtual network gateway.')
param vNetworkGatewayOnHub bool

@description('Existing hub virtual network for peering.')
param existingHubVnetResourceId string

@description('VNet peering name for AVD VNet to vHub.')
param vNetworkPeeringName string

@description('Create virtual network peering to hub.')
param createVnetPeering bool

@description('Optional. AVD Accelerator will deploy with private endpoints by default.')
param deployPrivateEndpointSubnet bool 

@description('AVD VNet address prefixes.')
param vNetworkAddressPrefixes string

@description('AVD subnet Name.')
param vNetworkAvdSubnetName string

@description('Private endpoint subnet Name.')
param vNetworkPrivateEndpointSubnetName string

@description('AVD VNet subnet address prefix.')
param vNetworkAvdSubnetAddressPrefix string

@description('Private endpoint VNet subnet address prefix.')
param vNetworkPrivateEndpointSubnetAddressPrefix string

@description('custom DNS servers IPs')
param dnsServers array

@description('Location where to deploy compute services.')
param sessionHostLocation string = deployment().location

@description('Tags to be applied to resources')
param tags object

@description('Log analytics workspace for diagnostic logs.')
param alaWorkspaceResourceId string

@description('Diagnostic logs retention.')
param diagnosticLogsRetentionInDays int

@description('Do not modify, used to set unique value for resource deployment')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var varNetworkSecurityGroupDiagnostic = [
    //'NetworkSecurityGroupEvent'
    //'NetworkSecurityGroupRuleCounter'
    'allLogs'
]
var varVirtualNetworkLogsDiagnostic = [
    //'VMProtectionAlerts'
    'allLogs'
]
var varVirtualNetworkMetricsDiagnostic = [
    'AllMetrics'
]

var varCreateAvdStaicRoute = true

// =========== //
// Deployments //
// =========== //

// AVD network security group.
module networksecurityGroupAvd '../../../../carml/1.3.0/Microsoft.Network/networkSecurityGroups/deploy.bicep' = if (createVnet) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'NSG-AVD-${time}'
    params: {
        name: avdNetworksecurityGroupName
        location: sessionHostLocation
        tags: tags
        diagnosticWorkspaceId: alaWorkspaceResourceId
        diagnosticLogsRetentionInDays: diagnosticLogsRetentionInDays
        diagnosticLogCategoriesToEnable: varNetworkSecurityGroupDiagnostic
        securityRules: [
            {
                name: 'AVDServiceTraffic'
                properties: {
                    priority: 100
                    access: 'Allow'
                    description: 'Session host traffic to AVD control plane'
                    destinationAddressPrefix: 'WindowsVirtualDesktop'
                    direction: 'Outbound'
                    sourcePortRange: '*'
                    destinationPortRange: '443'
                    protocol: 'Tcp'
                    sourceAddressPrefix: 'VirtualNetwork'
                }
            }
            {
                name: 'AzureCloud'
                properties: {
                    priority: 110
                    access: 'Allow'
                    description: 'Session host traffic to Azure cloud services'
                    destinationAddressPrefix: 'AzureCloud'
                    direction: 'Outbound'
                    sourcePortRange: '*'
                    destinationPortRange: '8443'
                    protocol: 'Tcp'
                    sourceAddressPrefix: 'VirtualNetwork'
                }
            }
            {
                name: 'AzureMonitor'
                properties: {
                    priority: 120
                    access: 'Allow'
                    description: 'Session host traffic to Azure Monitor'
                    destinationAddressPrefix: 'AzureMonitor'
                    direction: 'Outbound'
                    sourcePortRange: '*'
                    destinationPortRange: '443'
                    protocol: 'Tcp'
                    sourceAddressPrefix: 'VirtualNetwork'
                }
            }
            {
                name: 'AzureMarketPlace'
                properties: {
                    priority: 130
                    access: 'Allow'
                    description: 'Session host traffic to Azure Monitor'
                    destinationAddressPrefix: 'AzureFrontDoor.Frontend'
                    direction: 'Outbound'
                    sourcePortRange: '*'
                    destinationPortRange: '443'
                    protocol: 'Tcp'
                    sourceAddressPrefix: 'VirtualNetwork'
                }
            }
            {
                name: 'WindowsActivationKMS'
                properties: {
                    priority: 140
                    access: 'Allow'
                    description: 'Session host traffic to Windows license activation services'
                    destinationAddressPrefix: '23.102.135.246'
                    direction: 'Outbound'
                    sourcePortRange: '*'
                    destinationPortRange: '1688'
                    protocol: 'Tcp'
                    sourceAddressPrefix: 'VirtualNetwork'
                }
            }
            {
                name: 'AzureInstanceMetadata'
                properties: {
                    priority: 150
                    access: 'Allow'
                    description: 'Session host traffic to Azure instance metadata'
                    destinationAddressPrefix: '169.254.169.254'
                    direction: 'Outbound'
                    sourcePortRange: '*'
                    destinationPortRange: '80'
                    protocol: 'Tcp'
                    sourceAddressPrefix: 'VirtualNetwork'
                }
            }
            {
                name: 'RDPShortpath'
                properties: {
                    priority: 150
                    access: 'Allow'
                    description: 'Session host traffic to Azure instance metadata'
                    destinationAddressPrefix: 'VirtualNetwork'
                    direction: 'Inbound'
                    sourcePortRange: '*'
                    destinationPortRange: '3390'
                    protocol: 'Udp'
                    sourceAddressPrefix: 'VirtualNetwork'
                }
            }
        ]
    }
    dependsOn: []
}

// Private endpoint network security group.
module networksecurityGroupPrivateEndpoint '../../../../carml/1.3.0/Microsoft.Network/networkSecurityGroups/deploy.bicep' = if (createVnet && deployPrivateEndpointSubnet) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'NSG-Private-Endpoint-${time}'
    params: {
        name: privateEndpointNetworksecurityGroupName
        location: sessionHostLocation
        tags: tags
        diagnosticWorkspaceId: alaWorkspaceResourceId
        diagnosticLogsRetentionInDays: diagnosticLogsRetentionInDays
        diagnosticLogCategoriesToEnable: varNetworkSecurityGroupDiagnostic
        securityRules: [
        ]
    }
    dependsOn: []
} 

// Application security group.
module applicationSecurityGroup '../../../../carml/1.3.0/Microsoft.Network/applicationSecurityGroups/deploy.bicep' = if (createVnet) {
    scope: resourceGroup('${workloadSubsId}', '${computeObjectsRgName}')
    name: 'ASG-${time}'
    params: {
        name: applicationSecurityGroupName
        location: sessionHostLocation
        tags: tags
    }
    dependsOn: []
}

// AVD route table.
module routeTableAvd '../../../../carml/1.3.0/Microsoft.Network/routeTables/deploy.bicep' = if (createVnet) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'Route-Table-AVD-${time}'
    params: {
        name: avdRouteTableName
        location: sessionHostLocation
        tags: tags
        routes: varCreateAvdStaicRoute ? [
            {
              name: 'AVDServiceTraffic'
              properties: {
                addressPrefix: 'WindowsVirtualDesktop'
                hasBgpOverride: true
                nextHopType: 'Internet'
              }
            }
          ]: []
    }
    dependsOn: []
}

// Private endpoint route table.
module routeTablePrivateEndpoint '../../../../carml/1.3.0/Microsoft.Network/routeTables/deploy.bicep' = if (createVnet && deployPrivateEndpointSubnet) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'Route-Table-PE-${time}'
    params: {
        name: privateEndpointRouteTableName
        location: sessionHostLocation
        tags: tags
        routes: [
        ]
    }
    dependsOn: []
}

// Virtual network.
module virtualNetwork '../../../../carml/1.3.0/Microsoft.Network/virtualNetworks/deploy.bicep' = if (createVnet) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'vNet-${time}'
    params: {
        name: vNetworkName
        location: sessionHostLocation
        addressPrefixes: array(vNetworkAddressPrefixes)
        dnsServers: dnsServers
        peerings: createVnetPeering ? [
            {
                remoteVirtualNetworkId: existingHubVnetResourceId
                name: vNetworkPeeringName
                allowForwardedTraffic: true
                allowGatewayTransit: false
                allowVirtualNetworkAccess: true
                doNotVerifyRemoteGateways: true
                useRemoteGateways: vNetworkGatewayOnHub ? true : false
                remotePeeringEnabled: true
                remotePeeringName: vNetworkPeeringName
                remotePeeringAllowForwardedTraffic: true
                remotePeeringAllowGatewayTransit: vNetworkGatewayOnHub ? true : false
                remotePeeringAllowVirtualNetworkAccess: true
                remotePeeringDoNotVerifyRemoteGateways: true
                remotePeeringUseRemoteGateways: false
            }
        ]: []
        subnets: deployPrivateEndpointSubnet ? [
            {
                name: vNetworkAvdSubnetName
                addressPrefix: vNetworkAvdSubnetAddressPrefix
                privateEndpointNetworkPolicies: 'Disabled'
                privateLinkServiceNetworkPolicies: 'Enabled'
                networkSecurityGroupId: networksecurityGroupAvd.outputs.resourceId
                routeTableId: routeTableAvd.outputs.resourceId
            }
            {
                name: vNetworkPrivateEndpointSubnetName
                addressPrefix: vNetworkPrivateEndpointSubnetAddressPrefix
                privateEndpointNetworkPolicies: 'Disabled'
                privateLinkServiceNetworkPolicies: 'Enabled'
                networkSecurityGroupId: networksecurityGroupPrivateEndpoint.outputs.resourceId
                routeTableId: routeTablePrivateEndpoint.outputs.resourceId
            }
        ] : [
            {
                name: vNetworkAvdSubnetName
                addressPrefix: vNetworkAvdSubnetAddressPrefix
                privateEndpointNetworkPolicies: 'Disabled'
                privateLinkServiceNetworkPolicies: 'Enabled'
                networkSecurityGroupId: networksecurityGroupAvd.outputs.resourceId
                routeTableId: routeTableAvd.outputs.resourceId
            }
        ]
        
        tags: tags
        diagnosticWorkspaceId: alaWorkspaceResourceId
        diagnosticLogsRetentionInDays: diagnosticLogsRetentionInDays
        diagnosticLogCategoriesToEnable: varVirtualNetworkLogsDiagnostic
        diagnosticMetricsToEnable: varVirtualNetworkMetricsDiagnostic
    }
    dependsOn: [
        networksecurityGroupAvd
        networksecurityGroupPrivateEndpoint
        applicationSecurityGroup
        routeTableAvd
        routeTablePrivateEndpoint
    ]
}

// Update existing virtual network subnet (disable privete endpoint network policies).
/*
resource existingVnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = if (!empty(existingVnetSubnetResourceId))  {
    name: existingVnetName
    scope: resourceGroup('${existVnetSubsId}', '${existingVnetRgName}')
}

resource existingSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = if (!empty(existingVnetSubnetResourceId)) {
    name: existingSubnetName
    parent: existingVnet
}

module updateExistingSubnet '../carml/1.0.0/Microsoft.Network/virtualNetworks/subnets/deploy.bicep' = if (!empty(existingVnetSubnetResourceId))  {
scope: resourceGroup('${existVnetSubsId}', '${existingVnetRgName}')
name: 'Disable-NetworkPolicy-on-${existingSubnetName}-${time}'
params:{
    name: '${existingSubnetName}'
    virtualNetworkName: existingVnetName
    addressPrefix: existingSubnet.properties.addressPrefix
    networkSecurityGroupName: !(empty(existingSubnet.properties.networkSecurityGroup.id)) ? split(string(existingSubnet.properties.networkSecurityGroup.id), '/')[8] : ''
    networkSecurityGroupNameResourceGroupName: !(empty(existingSubnet.properties.networkSecurityGroup.id)) ? split(string(existingSubnet.properties.networkSecurityGroup.id), '/')[4] : ''
    routeTableName: !(empty(existingSubnet.properties.routeTable.id)) ? split(string(existingSubnet.properties.routeTable.id), '/')[8] : ''
    routeTableResourceGroupName: !(empty(existingSubnet.properties.routeTable.id)) ? split(string(existingSubnet.properties.routeTable.id), '/')[4] : ''
    //serviceEndpointPolicies: existingSubnet.properties.serviceEndpointPolicies
    privateEndpointNetworkPolicies: 'Disabled'
    tags: avdTags
    }
}
*/

// =========== //
// Outputs //
// =========== //
output applicationSecurityGroupResourceId string = applicationSecurityGroup.outputs.resourceId
output virtualNetworkResourceId string = virtualNetwork.outputs.resourceId
