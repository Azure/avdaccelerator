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

// Virtual network.
module virtualNetwork '../../../../carml/1.3.0/Microsoft.Network/virtualNetworks/deploy.bicep' = if (createVnet) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'vNet-${time}'
    params: {
        name: vnetName
        location: sessionHostLocation
        addressPrefixes: array(vnetAddressPrefixes)
        dnsServers: dnsServers
        peerings: createVnetPeering ? [
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
        ] : []
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


// Private DNS zones Azure files China
module privateDnsZoneAzureFilesChina '.bicep/privateDnsZones.bicep' = if (createPrivateDnsZones && (varAzureCloudName == 'AzureChinaCloud')) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'Private-DNS-Gov-Files-${time}'
    params: {
        privateDnsZoneName: 'privatelink.file.core.chinacloudapi.cn'
        virtualNetworkResourceId: createVnet ? virtualNetwork.outputs.resourceId : varExistingAvdVnetResourceId
        tags: tags
    }
}

// Private DNS zones key vault China
module privateDnsZoneKeyVaultChina '.bicep/privateDnsZones.bicep' = if (createPrivateDnsZones && (varAzureCloudName == 'AzureChinaCloud')) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'Private-DNS-Gov-Kv-${time}'
    params: {
        privateDnsZoneName: 'privatelink.vaultcore.azure.cn'
        virtualNetworkResourceId: createVnet ? virtualNetwork.outputs.resourceId : varExistingAvdVnetResourceId
        tags: tags
    }
}

// =========== //
// Outputs //
// =========== //
output applicationSecurityGroupResourceId string = deployAsg ? applicationSecurityGroup.outputs.resourceId : ''
output virtualNetworkResourceId string = createVnet ? virtualNetwork.outputs.resourceId : ''
output azureFilesDnsZoneResourceId string = createPrivateDnsZones ? ((varAzureCloudName == 'AzureCloud') ? privateDnsZoneAzureFilesCommercial.outputs.resourceId : ((varAzureCloudName == 'AzureUSGovernment') ? privateDnsZoneAzureFilesGov.outputs.resourceId : ((varAzureCloudName == 'AzureChinaCloud') ? privateDnsZoneAzureFilesChina.outputs.resourceId : ''))) : ''
output KeyVaultDnsZoneResourceId string = createPrivateDnsZones ? ((varAzureCloudName == 'AzureCloud') ? privateDnsZoneKeyVaultCommercial.outputs.resourceId : ((varAzureCloudName == 'AzureUSGovernment') ? privateDnsZoneKeyVaultGov.outputs.resourceId : ((varAzureCloudName == 'AzureChinaCloud') ? privateDnsZoneKeyVaultChina.outputs.resourceId : ''))) : ''
