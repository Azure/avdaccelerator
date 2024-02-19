targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@sys.description('AVD workload subscription ID, multiple subscriptions scenario')
param workloadSubsId string

@sys.description('Create new virtual network.')
param createVnet bool = true

@sys.description('Deploy application security group.')
param deployAsg bool

@sys.description('Existing virtual network subnet for AVD.')
param existingAvdSubnetResourceId string

@sys.description('Existing virtual network subnet for AVD.')
param existingAvdVnetAddressPrefixes string

@sys.description('Resource Group Name for the AVD session hosts')
param computeObjectsRgName string

@sys.description('If new virtual network required for the AVD machines. Resource Group name for the virtual network.')
param networkObjectsRgName string

@sys.description('Name of the virtual network if required to be created.')
param vnetName string

@sys.description('AVD Network Security Group Name')
param avdNetworksecurityGroupName string

@sys.description('Private endpoint Network Security Group Name')
param privateEndpointNetworksecurityGroupName string

@sys.description('Created if a new VNet for AVD is created. Application Security Group (ASG) for the session hosts.')
param applicationSecurityGroupName string

@sys.description('Created if the new VNet for AVD is created. Route Table name for AVD.')
param avdRouteTableName string

@sys.description('Created if the new VNet for AVD is created. Route Table name for private endpoints.')
param privateEndpointRouteTableName string

@sys.description('Does the hub contain a virtual network gateway.')
param vNetworkGatewayOnHub bool

@sys.description('Existing hub virtual network for peering.')
param existingHubVnetResourceId string

@sys.description('VNet peering name for AVD VNet to vHub.')
param vnetPeeringName string

@sys.description('Remote VNet peering name for AVD VNet to vHub.')
param remoteVnetPeeringName string

@sys.description('Create virtual network peering to hub.')
param createVnetPeering bool

@sys.description('Create firewall and firewall policy.')
param deployFirewall bool

@sys.description('Create firewall and firewall Policy to hub virtual network.')
param deployFirewallInHubVirtualNetwork bool

@sys.description('Firewall virtual network')
param firewallVnetResourceId string

@sys.description('VNet peering name for AVD VNet to Firewall VNet.')
param firewallVnetPeeringName string

@sys.description('Remote VNet peering name for AVD VNet to Firewall VNet.')
param firewallRemoteVnetPeeringName string

@sys.description('Firewall name')
param firewallName string

@sys.description('Firewall policy name')
param firewallPolicyName string

@sys.description('Firewall policy rule collection group name')
param firewallPolicyRuleCollectionGroupName string

@sys.description('Firewall policy rule collection group name (optional)')
param firewallPolicyOptionalRuleCollectionGroupName string

@sys.description('Firewall policy network rule collection name')
param firewallPolicyNetworkRuleCollectionName string

@sys.description('Firewall policy network rule collection name (optional)')
param firewallPolicyOptionalNetworkRuleCollectionName string

@sys.description('Firewall policy application rule collection name (optional)')
param firewallPolicyOptionalApplicationRuleCollectionName string

@sys.description('Firewall subnet adderss prefix')
param firewallSubnetAddressPrefix string

@sys.description('Optional. AVD Accelerator will deploy with private endpoints by default.')
param deployPrivateEndpointSubnet bool

@sys.description('AVD VNet address prefixes.')
param vnetAddressPrefixes string

@sys.description('AVD subnet Name.')
param vnetAvdSubnetName string

@sys.description('Private endpoint subnet Name.')
param vnetPrivateEndpointSubnetName string

@sys.description('AVD VNet subnet address prefix.')
param vnetAvdSubnetAddressPrefix string

@sys.description('Private endpoint VNet subnet address prefix.')
param vnetPrivateEndpointSubnetAddressPrefix string

@sys.description('custom DNS servers IPs')
param dnsServers array

@sys.description('Optional. Use Azure private DNS zones for private endpoints.')
param createPrivateDnsZones bool

@sys.description('Location where to deploy compute services.')
param sessionHostLocation string = deployment().location

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Log analytics workspace for diagnostic logs.')
param alaWorkspaceResourceId string

@sys.description('Do not modify, used to set unique value for resource deployment')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var varAzureCloudName = environment().name
var varNetworkSecurityGroupDiagnostic = [
    'allLogs'
]
var varVirtualNetworkLogsDiagnostic = varAzureCloudName == 'AzureUSGovernment' ? [
    ''
] : [
    'allLogs'
]
var varVirtualNetworkMetricsDiagnostic = [
    'AllMetrics'
]
var varCreateAvdStaicRoute = true
var varExistingAvdVnetSubId = !createVnet ? split(existingAvdSubnetResourceId, '/')[2] : ''
var varExistingAvdVnetSubRgName = !createVnet ? split(existingAvdSubnetResourceId, '/')[4] : ''
var varExistingAvdVnetName = !createVnet ? split(existingAvdSubnetResourceId, '/')[8] : ''
var varExistingAvdVnetResourceId = !createVnet ? '/subscriptions/${varExistingAvdVnetSubId}/resourceGroups/${varExistingAvdVnetSubRgName}/providers/Microsoft.Network/virtualNetworks/${varExistingAvdVnetName}' : ''
//var varExistingPeVnetSubId = split(existingPeSubnetResourceId, '/')[2]
//var varExistingPeVnetSubRgName = split(existingPeSubnetResourceId, '/')[4]
//var varExistingAPeVnetName = split(existingPeSubnetResourceId, '/')[8]
//var varExistingPeVnetResourceId = '/subscriptions/${varExistingPeVnetSubId}/resourceGroups/${varExistingPeVnetSubRgName}/providers/Microsoft.Network/virtualNetworks/${varExistingAPeVnetName}'
var varFirewallSubId = split(firewallVnetResourceId, '/')[2]
var varFirewallSubRgName = split(firewallVnetResourceId, '/')[4]
var varFirewallVnetName = split(firewallVnetResourceId, '/')[8]

resource existingFirewallVnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  scope: resourceGroup('${varFirewallSubId}', '${varFirewallSubRgName}')
  name: varFirewallVnetName
}
var firewallVnetLocation = existingFirewallVnet.location

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
        diagnosticLogCategoriesToEnable: varNetworkSecurityGroupDiagnostic
        securityRules: []
    }
    dependsOn: []
}

// Application security group.
module applicationSecurityGroup '../../../../carml/1.3.0/Microsoft.Network/applicationSecurityGroups/deploy.bicep' = if (deployAsg) {
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
        ] : []
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
        routes: []
    }
    dependsOn: []
}

// Virtual network
module virtualNetwork '../../../../carml/1.3.0/Microsoft.Network/virtualNetworks/deploy.bicep' = if (createVnet) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'vNet-${time}'
    params: {
        name: vnetName
        location: sessionHostLocation
        addressPrefixes: array(vnetAddressPrefixes)
        dnsServers: dnsServers
        peerings: createVnetPeering ? ((deployFirewall && !deployFirewallInHubVirtualNetwork) ? [
            {
                remoteVirtualNetworkId: existingHubVnetResourceId
                name: vnetPeeringName
                allowForwardedTraffic: true
                allowGatewayTransit: false
                allowVirtualNetworkAccess: true
                doNotVerifyRemoteGateways: true
                useRemoteGateways: vNetworkGatewayOnHub ? true : false
                remotePeeringEnabled: true
                remotePeeringName: remoteVnetPeeringName
                remotePeeringAllowForwardedTraffic: true
                remotePeeringAllowGatewayTransit: vNetworkGatewayOnHub ? true : false
                remotePeeringAllowVirtualNetworkAccess: true
                remotePeeringDoNotVerifyRemoteGateways: true
                remotePeeringUseRemoteGateways: false
            }
            {
                remoteVirtualNetworkId: firewallVnetResourceId
                name: firewallVnetPeeringName
                allowForwardedTraffic: true
                allowGatewayTransit: false
                allowVirtualNetworkAccess: true
                doNotVerifyRemoteGateways: true
                useRemoteGateways: false
                remotePeeringEnabled: true
                remotePeeringName: firewallRemoteVnetPeeringName
                remotePeeringAllowForwardedTraffic: true
                remotePeeringAllowGatewayTransit: false
                remotePeeringAllowVirtualNetworkAccess: true
                remotePeeringDoNotVerifyRemoteGateways: true
                remotePeeringUseRemoteGateways: false
            }
        ] : [
            {
                remoteVirtualNetworkId: existingHubVnetResourceId
                name: vnetPeeringName
                allowForwardedTraffic: true
                allowGatewayTransit: false
                allowVirtualNetworkAccess: true
                doNotVerifyRemoteGateways: true
                useRemoteGateways: vNetworkGatewayOnHub ? true : false
                remotePeeringEnabled: true
                remotePeeringName: remoteVnetPeeringName
                remotePeeringAllowForwardedTraffic: true
                remotePeeringAllowGatewayTransit: vNetworkGatewayOnHub ? true : false
                remotePeeringAllowVirtualNetworkAccess: true
                remotePeeringDoNotVerifyRemoteGateways: true
                remotePeeringUseRemoteGateways: false
            }
        ]):[]
        subnets: deployPrivateEndpointSubnet ? [
            {
                name: vnetAvdSubnetName
                addressPrefix: vnetAvdSubnetAddressPrefix
                privateEndpointNetworkPolicies: 'Disabled'
                privateLinkServiceNetworkPolicies: 'Enabled'
                networkSecurityGroupId: createVnet ? networksecurityGroupAvd.outputs.resourceId : ''
                routeTableId: createVnet ? routeTableAvd.outputs.resourceId : ''
            }
            {
                name: vnetPrivateEndpointSubnetName
                addressPrefix: vnetPrivateEndpointSubnetAddressPrefix
                privateEndpointNetworkPolicies: 'Disabled'
                privateLinkServiceNetworkPolicies: 'Enabled'
                networkSecurityGroupId: (createVnet && deployPrivateEndpointSubnet) ? networksecurityGroupPrivateEndpoint.outputs.resourceId : ''
                routeTableId: (createVnet && deployPrivateEndpointSubnet) ? routeTablePrivateEndpoint.outputs.resourceId : ''
            }
        ] : [
            {
                name: vnetAvdSubnetName
                addressPrefix: vnetAvdSubnetAddressPrefix
                privateEndpointNetworkPolicies: 'Disabled'
                privateLinkServiceNetworkPolicies: 'Enabled'
                networkSecurityGroupId: createVnet ? networksecurityGroupAvd.outputs.resourceId : ''
                routeTableId: createVnet ? routeTableAvd.outputs.resourceId : ''
            }
        ]
        tags: tags
        diagnosticWorkspaceId: alaWorkspaceResourceId
        diagnosticLogCategoriesToEnable: varVirtualNetworkLogsDiagnostic
        diagnosticMetricsToEnable: varVirtualNetworkMetricsDiagnostic
    }
    dependsOn: createVnet ? [
        networksecurityGroupAvd
        networksecurityGroupPrivateEndpoint
        routeTableAvd
        routeTablePrivateEndpoint
    ] : []
}

// Peering between existing AVD vNet and Firewall vNet
module virtualNetworkExistingAvd '../../../../carml/1.3.0/Microsoft.Network/virtualNetworks/deploy.bicep' = if (!createVnet && deployFirewall) {
    scope: resourceGroup('${varExistingAvdVnetSubId}', '${varExistingAvdVnetSubRgName}')
    name: 'Peering-Existing-vNet-${time}'
    params: {
        name: varExistingAvdVnetName
        location: sessionHostLocation
        addressPrefixes: array(existingAvdVnetAddressPrefixes)
        peerings: [
            {
                remoteVirtualNetworkId: firewallVnetResourceId
                name: firewallVnetPeeringName
                allowForwardedTraffic: true
                allowGatewayTransit: false
                allowVirtualNetworkAccess: true
                doNotVerifyRemoteGateways: true
                useRemoteGateways:  false
                remotePeeringEnabled: true
                remotePeeringName: firewallRemoteVnetPeeringName
                remotePeeringAllowForwardedTraffic: true
                remotePeeringAllowGatewayTransit: false 
                remotePeeringAllowVirtualNetworkAccess: true
                remotePeeringDoNotVerifyRemoteGateways: true
                remotePeeringUseRemoteGateways: false
            }
        ]
    }
}

// Private DNS zones Azure files commercial
module privateDnsZoneAzureFilesCommercial '.bicep/privateDnsZones.bicep' = if (createPrivateDnsZones && (varAzureCloudName == 'AzureCloud')) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'Private-DNS-Comm-Files-${time}'
    params: {
        privateDnsZoneName: 'privatelink.file.core.windows.net'
        virtualNetworkResourceId: createVnet ? virtualNetwork.outputs.resourceId : varExistingAvdVnetResourceId
        tags: tags
    }
}

// Private DNS zones key vault commercial
module privateDnsZoneKeyVaultCommercial '.bicep/privateDnsZones.bicep' = if (createPrivateDnsZones && (varAzureCloudName == 'AzureCloud')) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'Private-DNS-Comm-Kv-${time}'
    params: {
        privateDnsZoneName: 'privatelink.vaultcore.azure.net'
        virtualNetworkResourceId: createVnet ? virtualNetwork.outputs.resourceId : varExistingAvdVnetResourceId
        tags: tags
    }
}

// Private DNS zones Azure files US goverment
module privateDnsZoneAzureFilesGov '.bicep/privateDnsZones.bicep' = if (createPrivateDnsZones && (varAzureCloudName == 'AzureUSGovernment')) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'Private-DNS-Gov-Files-${time}'
    params: {
        privateDnsZoneName: 'privatelink.file.core.usgovcloudapi.net'
        virtualNetworkResourceId: createVnet ? virtualNetwork.outputs.resourceId : varExistingAvdVnetResourceId
        tags: tags
    }
}

// Private DNS zones key vault US goverment
module privateDnsZoneKeyVaultGov '.bicep/privateDnsZones.bicep' = if (createPrivateDnsZones && (varAzureCloudName == 'AzureUSGovernment')) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'Private-DNS-Gov-Kv-${time}'
    params: {
        privateDnsZoneName: 'privatelink.vaultcore.usgovcloudapi.net'
        virtualNetworkResourceId: createVnet ? virtualNetwork.outputs.resourceId : varExistingAvdVnetResourceId
        tags: tags
    }
}

// Firewall policy
module firewallPolicy '../../../../carml/1.3.0/Microsoft.Network/firewallPolicies/deploy.bicep' = if (deployFirewall) {
    scope: resourceGroup('${varFirewallSubId}', '${varFirewallSubRgName}')
    name: 'Fw-Policy-${time}'
    params: {
        name: firewallPolicyName
        location: firewallVnetLocation
        enableProxy: true
    }
}

// Firewall policy rule collection group
// https://learn.microsoft.com/azure/firewall/protect-azure-virtual-desktop
// https://learn.microsoft.com/azure/virtual-desktop/safe-url-list
module firewallPolicyRuleCollectionGroup '../../../../carml/1.3.0/Microsoft.Network/firewallPolicies/ruleCollectionGroups/deploy.bicep' = if (deployFirewall) {
    scope: resourceGroup('${varFirewallSubId}', '${varFirewallSubRgName}')
    name: 'Fw-Policy-Rcg-${time}'
    params: {
        name: firewallPolicyRuleCollectionGroupName
        firewallPolicyName: firewallPolicyName
        priority: 1000
        ruleCollections: [
            {
                name: firewallPolicyNetworkRuleCollectionName
                priority: 1100
                ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
                action: {
                    type: 'Allow'
                }
                rules: [
                    {
                        ruleType: 'NetworkRule'
                        name: 'Auth to Msft Online Services'
                        ipProtocols: [
                            'TCP'
                        ]
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        sourceIpGroups: []
                        destinationAddresses: []
                        destinationIpGroups: []
                        destinationFqdns: [
                            'login.microsoftonline.com'
                        ]
                        destinationPorts: [
                            '443'
                        ]
                    }
                    {
                        ruleType: 'NetworkRule'
                        name: 'Service Traffic'
                        ipProtocols: [
                            'TCP'
                        ]
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        sourceIpGroups: []
                        destinationAddresses: [
                            'WindowsVirtualDesktop'
                            'AzureFrontDoor.Frontend'
                            'AzureMonitor'
                        ]
                        destinationIpGroups: []
                        destinationFqdns: []
                        destinationPorts: [
                            '443'
                        ]
                    }
                    {
                        ruleType: 'NetworkRule'
                        name: 'DNS Traffic'
                        ipProtocols: [
                            'TCP'
                            'UDP'
                        ]
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        sourceIpGroups: []
                        destinationAddresses: [
                            '*'
                        ]
                        destinationIpGroups: []
                        destinationFqdns: []
                        destinationPorts: [
                            '53'
                        ]
                    }
                    {
                        ruleType: 'NetworkRule'
                        name: 'Azure Windows Activation'
                        ipProtocols: [
                            'TCP'
                        ]
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        sourceIpGroups: []
                        destinationAddresses: [
                            '20.118.99.224'
                            '40.83.235.53'
                        ]
                        destinationIpGroups: []
                        destinationFqdns: []
                        destinationPorts: [
                            '1688'
                        ]
                    }
                    {
                        ruleType: 'NetworkRule'
                        name: 'Windows Activation'
                        ipProtocols: [
                            'TCP'
                        ]
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        sourceIpGroups: []
                        destinationAddresses: [
                            '23.102.135.246'
                        ]
                        destinationIpGroups: []
                        destinationFqdns: []
                        destinationPorts: [
                            '1688'
                        ]
                    }
                    {
                        ruleType: 'NetworkRule'
                        name: 'Agent and SxS Stack Updates'
                        ipProtocols: [
                            'TCP'
                        ]
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        sourceIpGroups: []
                        destinationAddresses: []
                        destinationIpGroups: []
                        destinationFqdns: [
                            'mrsglobalsteus2prod.blob.core.windows.net'
                        ]
                        destinationPorts: [
                            '443'
                        ]
                    }
                    {
                        ruleType: 'NetworkRule'
                        name: 'Azure Portal Support'
                        ipProtocols: [
                            'TCP'
                        ]
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        sourceIpGroups: []
                        destinationAddresses: []
                        destinationIpGroups: []
                        destinationFqdns: [
                            'wvdportalstorageblob.blob.core.windows.net'
                        ]
                        destinationPorts: [
                            '443'
                        ]
                    }
                    {
                        ruleType: 'NetworkRule'
                        name: 'Cert CRL OneOCSP'
                        ipProtocols: [
                            'TCP'
                        ]
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        sourceIpGroups: []
                        destinationAddresses: []
                        destinationIpGroups: []
                        destinationFqdns: [
                            'oneocsp.microsoft.com'
                        ]
                        destinationPorts: [
                            '80'
                        ]
                    }
                    {
                        ruleType: 'NetworkRule'
                        name: 'Cert CRL MicrosoftDotCom'
                        ipProtocols: [
                            'TCP'
                        ]
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        sourceIpGroups: []
                        destinationAddresses: []
                        destinationIpGroups: []
                        destinationFqdns: [
                            'www.microsoft.com'
                        ]
                        destinationPorts: [
                            '80'
                        ]
                    }
                ]
            }
        ]
    }
    dependsOn: [
        firewallPolicy
    ]
}

// Firewall policy optional rule collection group
module firewallPolicyOptionalRuleCollectionGroup '../../../../carml/1.3.0/Microsoft.Network/firewallPolicies/ruleCollectionGroups/deploy.bicep' = if (deployFirewall) {
    scope: resourceGroup('${varFirewallSubId}', '${varFirewallSubRgName}')
    name: 'Fw-Policy-Rcg-Optional-${time}'
    params: {
        name: firewallPolicyOptionalRuleCollectionGroupName
        firewallPolicyName: firewallPolicyName
        priority: 2000
        ruleCollections: [
            {
                name: firewallPolicyOptionalNetworkRuleCollectionName
                priority: 2100
                ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
                action: {
                    type: 'Allow'
                }
                rules: [
                    {
                        ruleType: 'NetworkRule'
                        name: 'NTP'
                        ipProtocols: [
                            'UDP'
                        ]
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        sourceIpGroups: []
                        destinationAddresses: []
                        destinationIpGroups: []
                        destinationFqdns: [
                            'time.windows.com'
                        ]
                        destinationPorts: [
                            '123'
                        ]
                    }
                    {
                        ruleType: 'NetworkRule'
                        name: 'SigninToMSOL365'
                        ipProtocols: [
                            'TCP'
                        ]
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        sourceIpGroups: []
                        destinationAddresses: []
                        destinationIpGroups: []
                        destinationFqdns: [
                            'login.windows.net'
                        ]
                        destinationPorts: [
                            '443'
                        ]
                    }
                    {
                        ruleType: 'NetworkRule'
                        name: 'DetectOSconnectedToInternet'
                        ipProtocols: [
                            'TCP'
                        ]
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        sourceIpGroups: []
                        destinationAddresses: []
                        destinationIpGroups: []
                        destinationFqdns: [
                            'www.msftconnecttest.com'
                        ]
                        destinationPorts: [
                            '443'
                        ]
                    }
                    {
                        ruleType: 'NetworkRule'
                        name: 'AzureInstanceMetadataServiceEndpoint'
                        ipProtocols: [
                            'TCP'
                        ]
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        sourceIpGroups: []
                        destinationAddresses: [
                            '169.254.169.254'
                        ]
                        destinationIpGroups: []
                        destinationFqdns: []
                        destinationPorts: [
                            '80'
                        ]
                    }
                    {
                        ruleType: 'NetworkRule'
                        name: 'SessionHostHealthMonitoring'
                        ipProtocols: [
                            'TCP'
                        ]
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        sourceIpGroups: []
                        destinationAddresses: [
                            '168.63.129.16'
                        ]
                        destinationIpGroups: []
                        destinationFqdns: []
                        destinationPorts: [
                            '80'
                        ]
                    }
                    {
                        ruleType: 'NetworkRule'
                        name: 'AgentTraffic'
                        ipProtocols: [
                            'TCP'
                        ]
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        sourceIpGroups: []
                        destinationAddresses: []
                        destinationIpGroups: []
                        destinationFqdns: [
                            'gcs.prod.monitoring.core.windows.net'
                        ]
                        destinationPorts: [
                            '443'
                        ]
                    }
                    {
                        ruleType: 'NetworkRule'
                        name: 'GitHub'
                        ipProtocols: [
                            'TCP'
                        ]
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        sourceIpGroups: []
                        destinationAddresses: []
                        destinationIpGroups: []
                        destinationFqdns: [
                            'github.com'
                            'raw.githubusercontent.com'
                        ]
                        destinationPorts: [
                            '443'
                        ]
                    }
                    {
                        ruleType: 'NetworkRule'
                        name: 'AzureStorage'
                        ipProtocols: [
                            'TCP'
                        ]
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        sourceIpGroups: []
                        destinationAddresses: [
                            'Storage'
                        ]
                        destinationIpGroups: []
                        destinationFqdns: []
                        destinationPorts: [
                            '443'
                        ]
                    }
                ]
            }
            {
                name: firewallPolicyOptionalApplicationRuleCollectionName
                priority: 2200
                ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
                action: {
                    type: 'Allow'
                }
                rules: [
                    {
                        ruleType: 'ApplicationRule'
                        name: 'UpdatesforOneDrive'
                        protocols: [
                            {
                                protocolType: 'Https'
                                port: 443
                            }
                        ]
                        fqdnTags: [
                            'WindowsUpdate'
                            'WindowsDiagnostic'
                            'MicrosoftActiveProtectionService'
                        ]
                        webCategories: []
                        targetFqdns: []
                        targetUrls: []
                        terminateTLS: false
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        destinationAddresses: []
                        sourceIpGroups: []
                        httpHeadersToInsert: []
                    }
                    {
                        ruleType: 'ApplicationRule'
                        name: 'TelemetryService'
                        protocols: [
                            {
                                protocolType: 'Https'
                                port: 443
                            }
                        ]
                        fqdnTags: []
                        webCategories: []
                        targetFqdns: [
                            '*.events.data.microsoft.com'
                        ]
                        targetUrls: []
                        terminateTLS: false
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        destinationAddresses: []
                        sourceIpGroups: []
                        httpHeadersToInsert: []
                    }
                    {
                        ruleType: 'ApplicationRule'
                        name: 'Windows Update'
                        protocols: [
                            {
                                protocolType: 'Https'
                                port: 443
                            }
                        ]
                        fqdnTags: []
                        webCategories: []
                        targetFqdns: [
                            '*.sfx.ms'
                        ]
                        targetUrls: []
                        terminateTLS: false
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        destinationAddresses: []
                        sourceIpGroups: []
                        httpHeadersToInsert: []
                    }
                    {
                        ruleType: 'ApplicationRule'
                        name: 'DigitcertCRL'
                        protocols: [
                            {
                                protocolType: 'Https'
                                port: 443
                            }
                        ]
                        fqdnTags: []
                        webCategories: []
                        targetFqdns: [
                            '*.digicert.com'
                        ]
                        targetUrls: []
                        terminateTLS: false
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        destinationAddresses: []
                        sourceIpGroups: []
                        httpHeadersToInsert: []
                    }
                    {
                        ruleType: 'ApplicationRule'
                        name: 'AzureDNSResolution'
                        protocols: [
                            {
                                protocolType: 'Https'
                                port: 443
                            }
                        ]
                        fqdnTags: []
                        webCategories: []
                        targetFqdns: [
                            '*.azure-dns.com'
                            '*.azure-dns.net'
                        ]
                        targetUrls: []
                        terminateTLS: false
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        destinationAddresses: []
                        sourceIpGroups: []
                        httpHeadersToInsert: []
                    }
                    {
                        ruleType: 'ApplicationRule'
                        name: 'PowerShellGallery'
                        protocols: [
                            {
                                protocolType: 'Https'
                                port: 443
                            }
                        ]
                        fqdnTags: []
                        webCategories: []
                        targetFqdns: [
                            'go.microsoft.com'
                            'onegetcdn.azureedge.net'
                        ]
                        targetUrls: []
                        terminateTLS: false
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        destinationAddresses: []
                        sourceIpGroups: []
                        httpHeadersToInsert: []
                    }
                    {
                        ruleType: 'ApplicationRule'
                        name: 'AzurePowerShell'
                        protocols: [
                            {
                                protocolType: 'Https'
                                port: 443
                            }
                        ]
                        fqdnTags: []
                        webCategories: []
                        targetFqdns: [
                            'login.microsoftonline.com'
                            'login.live.com'
                            'management.azure.com'
                            'directory.services.live.com'
                            'management.core.windows.net'
                            'provisioningapi.microsoftonline.com'
                            'graph.windows.net'
                            'query.prod.cms.rt.microsoft.com'
                        ]
                        targetUrls: []
                        terminateTLS: false
                        sourceAddresses: [
                            vnetAvdSubnetAddressPrefix
                        ]
                        destinationAddresses: []
                        sourceIpGroups: []
                        httpHeadersToInsert: []
                    }
                ]
            }
        ]
    }
    dependsOn: [
        firewallPolicyRuleCollectionGroup
    ]
}

// Azure Firewall subnet
module virtualNetworkAzureFirewallSubnet '../../../../carml/1.3.0/Microsoft.Network/virtualNetworks/subnets/deploy.bicep' = if (deployFirewall && (firewallSubnetAddressPrefix != '')) {
    scope: resourceGroup('${varFirewallSubId}', '${varFirewallSubRgName}')
    name: 'Fw-Subnet-${time}'
    params: {
        addressPrefix: firewallSubnetAddressPrefix
        name: 'AzureFirewallSubnet'
        virtualNetworkName: varFirewallVnetName
    }
}

// Azure Firewall
module azureFirewall '../../../../carml/1.3.0/Microsoft.Network/azureFirewalls/deploy.bicep' = if (deployFirewall) {
    scope: resourceGroup('${varFirewallSubId}', '${varFirewallSubRgName}')
    name: 'Fw-${time}'
    params: {
        name: firewallName
        location: firewallVnetLocation
        vNetId: firewallVnetResourceId
        firewallPolicyId: firewallPolicy.outputs.resourceId
    }
    dependsOn: [
        firewallPolicyOptionalRuleCollectionGroup
        virtualNetworkAzureFirewallSubnet
    ]
}

// AVD route table for Firewall
module routeTableAvdforFirewall '../../../../carml/1.3.0/Microsoft.Network/routeTables/deploy.bicep' = if (createVnet && deployFirewall) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'Route-Table-AVD-Fw-${time}'
    params: {
        name: avdRouteTableName
        location: sessionHostLocation
        tags: tags
        routes: varCreateAvdStaicRoute ? [
            {
                name: 'default'
                properties: {
                    addressPrefix: '0.0.0.0/0'
                    nextHopIpAddress: azureFirewall.outputs.privateIp
                    nextHopType: 'VirtualAppliance'
                }
            }
        ] : []
    }
    dependsOn: [
        azureFirewall
    ]
}

// =========== //
// Outputs //
// =========== //
output applicationSecurityGroupResourceId string = deployAsg ? applicationSecurityGroup.outputs.resourceId : ''
output virtualNetworkResourceId string = createVnet ? virtualNetwork.outputs.resourceId : ''
output azureFilesDnsZoneResourceId string = createPrivateDnsZones ? ((varAzureCloudName == 'AzureCloud') ? privateDnsZoneAzureFilesCommercial.outputs.resourceId : privateDnsZoneAzureFilesGov.outputs.resourceId) : ''
output KeyVaultDnsZoneResourceId string = createPrivateDnsZones ? ((varAzureCloudName == 'AzureCloud') ? privateDnsZoneKeyVaultCommercial.outputs.resourceId : privateDnsZoneKeyVaultGov.outputs.resourceId) : ''
