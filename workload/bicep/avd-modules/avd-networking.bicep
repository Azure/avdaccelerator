targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@description('Optional. AVD workload subscription ID, multiple subscriptions scenario')
param avdWorkloadSubsId string

@description('Resource Group Name for the AVD session hosts')
param avdComputeObjectsRgName string

// Optional parameters for the AVD session hosts virtual network.
@description('Create new virtual network')
param createAvdVnet bool

@description('Optional. If new virtual network required for the AVD machines. Resource Group name for the virtual network.')
param avdNetworkObjectsRgName string

@description('Optional. Name of the virtual network if required to be created.')
param avdVnetworkName string

@description('Network Security Group Name')
param avdNetworksecurityGroupName string

@description('Optional. Created if a new VNet for AVD is created. Application Security Group (ASG) for the session hosts.')
param avdApplicationSecurityGroupName string

@description('Optional. Created if the new VNet for AVD is created. Route Table name.')
param avdRouteTableName string

@description('Does the hub contain a virtual network gateway.')
param vNetworkGatewayOnHub bool

@description('Existing hub virtual network for peering.')
param existingHubVnetResourceId string

@description('VNet peering name for AVD VNet to vHub.')
param avdVnetworkPeeringName string

@description('Optional. Create virtual network peering to hub.')
param createAvdVnetPeering bool

@description('AVD VNet address prefixes.')
param avdVnetworkAddressPrefixes string

@description('AVD subnet Name.')
param avdVnetworkSubnetName string

@description('AVD VNet subnet address prefix.')
param avdVnetworkSubnetAddressPrefix string

@description('custom DNS servers IPs')
param dnsServers array

@description('Required. Location where to deploy compute services.')
param avdSessionHostLocation string = deployment().location

@description('Required. Tags to be applied to resources')
param avdTags object

@description('Do not modify, used to set unique value for resource deployment')
param time string = utcNow()

// =========== //
// Deployments //
// =========== //

// Network security group.
module avdNetworksecurityGroup '../../../carml/1.2.0/Microsoft.Network/networkSecurityGroups/deploy.bicep' = if (createAvdVnet) {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdNetworkObjectsRgName}')
    name: 'AVD-NSG-${time}'
    params: {
        name: avdNetworksecurityGroupName
        location: avdSessionHostLocation
        tags: avdTags
    }
    dependsOn: []
}

// Application security group.
module avdApplicationSecurityGroup '../../../carml/1.2.0/Microsoft.Network/applicationSecurityGroups/deploy.bicep' = if (createAvdVnet) {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
    name: 'AVD-ASG-${time}'
    params: {
        name: avdApplicationSecurityGroupName
        location: avdSessionHostLocation
        tags: avdTags
    }
    dependsOn: []
}

// Route table.
module avdRouteTable '../../../carml/1.2.0/Microsoft.Network/routeTables/deploy.bicep' = if (createAvdVnet) {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdNetworkObjectsRgName}')
    name: 'AVD-UDR-${time}'
    params: {
        name: avdRouteTableName
        location: avdSessionHostLocation
        tags: avdTags
    }
    dependsOn: []
}

// Virtual network.
module avdVirtualNetwork '../../../carml/1.2.0/Microsoft.Network/virtualNetworks/deploy.bicep' = if (createAvdVnet) {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdNetworkObjectsRgName}')
    name: 'AVD-vNet-${time}'
    params: {
        name: avdVnetworkName
        location: avdSessionHostLocation
        addressPrefixes: array(avdVnetworkAddressPrefixes)
        dnsServers: dnsServers
        virtualNetworkPeerings: createAvdVnetPeering ? [
            {
                remoteVirtualNetworkId: existingHubVnetResourceId
                name: avdVnetworkPeeringName
                allowForwardedTraffic: true
                allowGatewayTransit: false
                allowVirtualNetworkAccess: true
                doNotVerifyRemoteGateways: true
                useRemoteGateways: vNetworkGatewayOnHub ? true : false
                remotePeeringEnabled: true
                remotePeeringName: avdVnetworkPeeringName
                remotePeeringAllowForwardedTraffic: true
                remotePeeringAllowGatewayTransit: vNetworkGatewayOnHub ? true : false
                remotePeeringAllowVirtualNetworkAccess: true
                remotePeeringDoNotVerifyRemoteGateways: true
                remotePeeringUseRemoteGateways: false
            }
        ]: []
        subnets: [
            {
                name: avdVnetworkSubnetName
                addressPrefix: avdVnetworkSubnetAddressPrefix
                privateEndpointNetworkPolicies: 'Disabled'
                privateLinkServiceNetworkPolicies: 'Enabled'
                networkSecurityGroupName: avdNetworksecurityGroupName
                routeTableName: avdRouteTableName
            }
        ]
        tags: avdTags
    }
    dependsOn: [
        avdNetworksecurityGroup
        avdApplicationSecurityGroup
        avdRouteTable
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
output avdApplicationSecurityGroupResourceId string = avdApplicationSecurityGroup.outputs.resourceId
output avdVirtualNetworkResourceId string = avdVirtualNetwork.outputs.resourceId
