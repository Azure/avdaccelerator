targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@sys.description('AVD workload subscription ID, multiple subscriptions scenario')
param workloadSubsId string

@sys.description('Existing virtual network subnet for AVD.')
param existingAvdSubnetResourceId string

@sys.description('If new virtual network required for the AVD machines. Resource Group name for the virtual network.')
param networkObjectsRgName string

@sys.description('AVD Network Security Group Name')
param avdNetworksecurityGroupName string

@sys.description('Created if the new VNet for AVD is created. Route Table name for AVD.')
param avdRouteTableName string

@sys.description('Location where to deploy compute services.')
param sessionHostLocation string

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Log analytics workspace for diagnostic logs.')
param alaWorkspaceResourceId string

@sys.description('Do not modify, used to set unique value for resource deployment')
param time string = utcNow()

@sys.description('Vnet resource group name')
param vnetResourceGroupName string


// =========== //
// Variable declaration //
// =========== //
// var varNetworkSecurityGroupDiagnostic = [
//     'allLogs'
// ]

var varDiagnosticSettings = !empty(alaWorkspaceResourceId)
  ? [
      {
        workspaceResourceId: alaWorkspaceResourceId
      }
    ]
  : []

var varCreateAvdStaicRoute = true
var varExistingAvdVnetName = split(existingAvdSubnetResourceId, '/')[8]
var varExistingSubnetName = split(existingAvdSubnetResourceId, '/')[10]

// =========== //
// Deployments //
// =========== //

// AVD network security group.
module networksecurityGroupAvd '../../../../avm/1.0.0/res/network/network-security-group/main.bicep' = {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'nsg-avd-${time}'
    params: {
        name: avdNetworksecurityGroupName
        location: sessionHostLocation
        tags: tags
        diagnosticSettings: varDiagnosticSettings
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

// AVD route table if creating a vnet
module routeTableAvd '../../../../avm/1.0.0/res/network/route-table/main.bicep' = {
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
            {
                name: 'AVDStunTurnTraffic'
                properties: {
                    addressPrefix: '20.202.0.0/16'
                    hasBgpOverride: true
                    nextHopType: 'Internet'
                }
            }
            {
                name: 'DirectRouteToKMS'
                properties: {
                    addressPrefix: '23.102.135.246/32'
                    hasBgpOverride: true
                    nextHopType: 'Internet'
                }
            }
            {
                name: 'DirectRouteToAZKMS01'
                properties: {
                    addressPrefix: '20.118.99.224/32'
                    hasBgpOverride: true
                    nextHopType: 'Internet'
                }
            }
            {
                name: 'DirectRouteToAZKMS02'
                properties: {
                    addressPrefix: '40.83.235.53/32'
                    hasBgpOverride: true
                    nextHopType: 'Internet'
                }
            }
        ] : []
    }
    dependsOn: []
}

// Get existing vnet
resource existingVnet 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
    name: varExistingAvdVnetName
    scope: resourceGroup('${workloadSubsId}', '${vnetResourceGroupName}')
}

resource existingSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
    name: varExistingSubnetName
    parent: existingVnet
}

// update the subnet:  attach nsg and
module updateSubnet '.bicep/updateSubnet.bicep' = {
    name: 'update-subnet-with-nsg-and-route-table-${varExistingAvdVnetName}-${varExistingSubnetName}'
    scope: resourceGroup('${workloadSubsId}', '${vnetResourceGroupName}')
    //scope: resourceGroup(vnetResourceGroupName)
    params: {
        vnetName: varExistingAvdVnetName
        subnetName: varExistingSubnetName
        // Update the nsg
        properties: union(existingSubnet.properties, {
          networkSecurityGroup: {
            id: networksecurityGroupAvd.outputs.resourceId
          }
          routeTable: {
            id: routeTableAvd.outputs.resourceId
          }
        })
      }

}

// =========== //
// Outputs //
// =========== //
output routeTableResourceId string = routeTableAvd.outputs.resourceId
output nsgResourceId string = networksecurityGroupAvd.outputs.resourceId
