targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@description('AVD workload subscription ID, multiple subscriptions scenario')
param workloadSubsId string

@description('Create new virtual network.')
param createVnet bool = true

@description('Deploy AVD session hosts.')
param deploySessionHosts bool

@description('Existing virtual network subnet for AVD.')
param existingAvdSubnetResourceId string

@description('Existing virtual network subnet for private endpoints.')
param existingPeSubnetResourceId string

@description('Resource Group Name for the AVD session hosts')
param computeObjectsRgName string

@description('If new virtual network required for the AVD machines. Resource Group name for the virtual network.')
param networkObjectsRgName string

@description('Name of the virtual network if required to be created.')
param vnetName string

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
param vnetPeeringName string

@description('Remote VNet peering name for AVD VNet to vHub.')
param remoteVnetPeeringName string

@description('Create virtual network peering to hub.')
param createVnetPeering bool

@description('Optional. AVD Accelerator will deploy with private endpoints by default.')
param deployPrivateEndpointSubnet bool

@description('AVD VNet address prefixes.')
param vnetAddressPrefixes string

@description('AVD subnet Name.')
param vnetAvdSubnetName string

@description('Private endpoint subnet Name.')
param vnetPrivateEndpointSubnetName string

@description('AVD VNet subnet address prefix.')
param vnetAvdSubnetAddressPrefix string

@description('Private endpoint VNet subnet address prefix.')
param vnetPrivateEndpointSubnetAddressPrefix string

@description('custom DNS servers IPs')
param dnsServers array

@description('Optional. Use Azure private DNS zones for private endpoints.')
param createPrivateDnsZones bool

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
var varAzureCloudName = environment().name
var varNetworkSecurityGroupDiagnostic = [
    'allLogs'
]
var varVirtualNetworkLogsDiagnostic = [
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
// =========== //
// Deployments //
// =========== //

// AVD network security group.
module networksecurityGroupAvd '../../../../carml/1.3.0/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
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
module networksecurityGroupPrivateEndpoint '../../../../carml/1.3.0/Microsoft.Network/networkSecurityGroups/deploy.bicep' = if (deployPrivateEndpointSubnet) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'NSG-Private-Endpoint-${time}'
    params: {
        name: privateEndpointNetworksecurityGroupName
        location: sessionHostLocation
        tags: tags
        diagnosticWorkspaceId: alaWorkspaceResourceId
        diagnosticLogsRetentionInDays: diagnosticLogsRetentionInDays
        diagnosticLogCategoriesToEnable: varNetworkSecurityGroupDiagnostic
        securityRules: []
    }
    dependsOn: []
}

// Application security group.
module applicationSecurityGroup '../../../../carml/1.3.0/Microsoft.Network/applicationSecurityGroups/deploy.bicep' = if (deploySessionHosts) {
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
module routeTableAvd '../../../../carml/1.3.0/Microsoft.Network/routeTables/deploy.bicep' = {
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
module routeTablePrivateEndpoint '../../../../carml/1.3.0/Microsoft.Network/routeTables/deploy.bicep' = if (deployPrivateEndpointSubnet) {
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
module virtualNetwork '../../../../carml/1.3.0/Microsoft.Network/virtualNetworks/deploy.bicep' = {
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
                networkSecurityGroupId: networksecurityGroupAvd.outputs.resourceId
                routeTableId: routeTableAvd.outputs.resourceId
            }
            {
                name: vnetPrivateEndpointSubnetName
                addressPrefix: vnetPrivateEndpointSubnetAddressPrefix
                privateEndpointNetworkPolicies: 'Disabled'
                privateLinkServiceNetworkPolicies: 'Enabled'
                networkSecurityGroupId: networksecurityGroupPrivateEndpoint.outputs.resourceId
                routeTableId: routeTablePrivateEndpoint.outputs.resourceId
            }
        ] : [
            {
                name: vnetAvdSubnetName
                addressPrefix: vnetAvdSubnetAddressPrefix
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

// Private DNS zones Azure files commercial
/*
module privateDnsZoneAzureFilesCommercial '../../../../carml/1.3.0/Microsoft.Network/privateDnsZones/deploy.bicep' = if (createPrivateDnsZones && (varAzureCloudName == 'AzureCloud')) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'Private-DNS-Files-${time}'
    params: {
        location: 'global'
        name: 'privatelink.file.core.windows.net'
        virtualNetworkLinks: [
            {
                registrationEnabled: false
                virtualNetworkResourceId: virtualNetwork.outputs.resourceId
            }
        ]
    }
}
*/
module privateDnsZoneAzureFilesCommercial '.bicep/privateDnsZones.bicep' = if (createPrivateDnsZones && (varAzureCloudName == 'AzureCloud')) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'Private-DNS-Com-Files-${time}'
    params: {
        privateDnsZoneName: 'privatelink.file.core.windows.net'
        virtualNetworkResourceId: virtualNetwork.outputs.resourceId
        tags: tags
    }
}
/*
// Private DNS zones keyvault commercial.
module privateDnsZoneKeyvaultCommercial '../../../../carml/1.3.0/Microsoft.Network/privateDnsZones/deploy.bicep' = if (createPrivateDnsZones && (varAzureCloudName == 'AzureCloud')) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'Private-DNS-Keyvault-${time}'
    params: {
        location: 'global'
        name: 'privatelink.vaultcore.azure.net'
        virtualNetworkLinks: [
            {
                registrationEnabled: false
                virtualNetworkResourceId: virtualNetwork.outputs.resourceId
            }
        ]
    }
}
*/
module privateDnsZoneKeyVaultCommercial '.bicep/privateDnsZones.bicep' = if (createPrivateDnsZones && (varAzureCloudName == 'AzureCloud')) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'Private-DNS-Kv-${time}'
    params: {
        privateDnsZoneName: 'privatelink.vaultcore.azure.net'
        virtualNetworkResourceId: virtualNetwork.outputs.resourceId
        tags: tags
    }
}
/*
// Private DNS zones Azure files US gov.
module privateDnsZoneAzureFilesGov '../../../../carml/1.3.0/Microsoft.Network/privateDnsZones/deploy.bicep' = if (createPrivateDnsZones && (varAzureCloudName == 'AzureUSGovernment')) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'Private-DNS-Files-${time}'
    params: {
        location: 'global'
        name: 'privatelink.file.core.usgovcloudapi.net'
        virtualNetworkLinks: [
            {
                registrationEnabled: false
                virtualNetworkResourceId: virtualNetwork.outputs.resourceId
            }
        ]
    }
}
*/
module privateDnsZoneAzureFilesGov '.bicep/privateDnsZones.bicep' = if (createPrivateDnsZones && (varAzureCloudName == 'AzureUSGovernment')) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'Private-DNS-Gov-Files-${time}'
    params: {
        privateDnsZoneName: 'privatelink.file.core.usgovcloudapi.net'
        virtualNetworkResourceId: virtualNetwork.outputs.resourceId
        tags: tags
    }
}
/*
// Private DNS zones keyvault US gov.
module privateDnsZoneKeyvaultGov '../../../../carml/1.3.0/Microsoft.Network/privateDnsZones/deploy.bicep' = if (createPrivateDnsZones && (varAzureCloudName == 'AzureUSGovernment')) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'Private-DNS-Keyvault-${time}'
    params: {
        location: 'global'
        name: 'privatelink.vaultcore.usgovcloudapi.net'
        virtualNetworkLinks: [
            {
                registrationEnabled: false
                virtualNetworkResourceId: virtualNetwork.outputs.resourceId
            }
        ]
    }
}
*/
module privateDnsZoneKeyVaultGov '.bicep/privateDnsZones.bicep' = if (createPrivateDnsZones && (varAzureCloudName == 'AzureUSGovernment')) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'Private-DNS-Gov-Kv-${time}'
    params: {
        privateDnsZoneName: 'privatelink.vaultcore.usgovcloudapi.net'
        virtualNetworkResourceId: virtualNetwork.outputs.resourceId
        tags: tags
    }
}
// =========== //
// Outputs //
// =========== //
output applicationSecurityGroupResourceId string = applicationSecurityGroup.outputs.resourceId
output virtualNetworkResourceId string = virtualNetwork.outputs.resourceId
output azureFilesDnsZoneResourceId string = createPrivateDnsZones ? ((varAzureCloudName == 'AzureCloud') ? privateDnsZoneAzureFilesCommercial.outputs.resourceId : privateDnsZoneAzureFilesGov.outputs.resourceId) : ''
output KeyVaultDnsZoneResourceId string = createPrivateDnsZones ? ((varAzureCloudName == 'AzureCloud') ? privateDnsZoneKeyVaultCommercial.outputs.resourceId : privateDnsZoneKeyVaultGov.outputs.resourceId) : ''
