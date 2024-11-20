metadata name = 'W365 Accelerator - Networking'
metadata description = 'W365 Accelerator - Network deployment'
metadata owner = 'Azure/w365lza'

targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@sys.description('w365 workload subscription ID, multiple subscriptions scenario')
param w365SubId string

@sys.description('Deploy application security group.')
param deployAsg bool

@sys.description('Resource Group Name for the w365 session hosts')
param computeObjectsRgName string

@sys.description('If new virtual network required for the w365 machines. Resource Group name for the virtual network.')
param networkObjectsRgName string

@sys.description('Name of the virtual network if required to be created.')
param vnetName string

@sys.description('w365 Network Security Group Name')
param w365NetworksecurityGroupName string

@sys.description('Created if a new VNet for w365 is created. Application Security Group (ASG) for the session hosts.')
param applicationSecurityGroupName string

@sys.description('Created if the new VNet for w365 is created. Route Table name for w365.')
param w365RouteTableName string

@sys.description('Does the hub contain a virtual network gateway.')
param vNetworkGatewayOnHub bool

@sys.description('Existing hub virtual network for peering.')
param existingHubVnetResourceId string

@sys.description('VNet peering name for w365 VNet to vHub.')
param vnetPeeringName string

@sys.description('Remote VNet peering name for w365 VNet to vHub.')
param remoteVnetPeeringName string

@sys.description('Create virtual network peering to hub.')
param createVnetPeering bool

@sys.description('DDoS Protection Plan name.')
param ddosProtectionPlanName string

@sys.description('Deploy DDoS Network Protection for virtual network.')
param deployDDoSNetworkProtection bool

@sys.description('w365 VNet address prefixes.')
param vnetAddressPrefixes string

@sys.description('w365 subnet Name.')
param vnetW365SubnetName string

@sys.description('w365 VNet subnet address prefix.')
param vnetW365SubnetAddressPrefix string

@sys.description('custom DNS servers IPs')
param dnsServers array

@sys.description('Location where to deploy resources.')
param location string = deployment().location

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Do not modify, used to set unique value for resource deployment')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var varAzureCloudName = environment().name
var varCreateW365StaticRoute = true
// https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-machines/windows/custom-routes-enable-kms-activation#solution
var varWindowsActivationKMSPrefixesNsg = (varAzureCloudName == 'AzureCloud')
  ? [
      '20.118.99.224'
      '40.83.235.53'
      '23.102.135.246'
    ]
  : (varAzureCloudName == 'AzureUSGovernment')
      ? [
          '23.97.0.13'
          '52.126.105.2'
        ]
      : (varAzureCloudName == 'AzureChinaCloud')
          ? [
              '159.27.28.100'
              '163.228.64.161'
              '42.159.7.249'
            ]
          : []
// https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-machines/windows/custom-routes-enable-kms-activation#solution
var varStaticRoutes = (varAzureCloudName == 'AzureCloud')
  ? [
      {
        name: 'W365ServiceTraffic'
        properties: {
          addressPrefix: 'WindowsVirtualDesktop'
          hasBgpOverride: true
          nextHopType: 'Internet'
        }
      }
      {
        name: 'W365StunInfraTurnRelayTraffic'
        properties: {
          addressPrefix: '20.202.0.0/16'
          hasBgpOverride: true
          nextHopType: 'Internet'
        }
      }
      {
        name: 'W365TurnRelayTraffic'
        properties: {
          addressPrefix: '51.5.0.0/16'
          hasBgpOverride: true
          nextHopType: 'Internet'
        }
      }
      {
        name: 'DirectRouteToKMS'
        properties: {
          addressPrefix: '20.118.99.224/32'
          hasBgpOverride: true
          nextHopType: 'Internet'
        }
      }
      {
        name: 'DirectRouteToKMS01'
        properties: {
          addressPrefix: '40.83.235.53/32'
          hasBgpOverride: true
          nextHopType: 'Internet'
        }
      }
      {
        name: 'DirectRouteToKMS02'
        properties: {
          addressPrefix: '23.102.135.246/32'
          hasBgpOverride: true
          nextHopType: 'Internet'
        }
      }
    ]
  : (varAzureCloudName == 'AzureUSGovernment')
      ? [
          {
            name: 'W365ServiceTraffic'
            properties: {
              addressPrefix: 'WindowsVirtualDesktop'
              hasBgpOverride: true
              nextHopType: 'Internet'
            }
          }
          {
            name: 'W365StunTurnTraffic'
            properties: {
              addressPrefix: '20.202.0.0/16'
              hasBgpOverride: true
              nextHopType: 'Internet'
            }
          }
          {
            name: 'DirectRouteToKMS'
            properties: {
              addressPrefix: '23.97.0.13/32'
              hasBgpOverride: true
              nextHopType: 'Internet'
            }
          }
          {
            name: 'DirectRouteToKMS01'
            properties: {
              addressPrefix: '52.126.105.2/32'
              hasBgpOverride: true
              nextHopType: 'Internet'
            }
          }
        ]
      : (varAzureCloudName == 'AzureChinaCloud')
          ? [
              {
                name: 'W365ServiceTraffic'
                properties: {
                  addressPrefix: 'WindowsVirtualDesktop'
                  hasBgpOverride: true
                  nextHopType: 'Internet'
                }
              }
              {
                name: 'W365StunTurnTraffic'
                properties: {
                  addressPrefix: '20.202.0.0/16'
                  hasBgpOverride: true
                  nextHopType: 'Internet'
                }
              }
              {
                name: 'DirectRouteToKMS'
                properties: {
                  addressPrefix: '159.27.28.100/32'
                  hasBgpOverride: true
                  nextHopType: 'Internet'
                }
              }
              {
                name: 'DirectRouteToKMS01'
                properties: {
                  addressPrefix: '163.228.64.161/32'
                  hasBgpOverride: true
                  nextHopType: 'Internet'
                }
              }
              {
                name: 'DirectRouteToKMS02'
                properties: {
                  addressPrefix: '42.159.7.249/32'
                  hasBgpOverride: true
                  nextHopType: 'Internet'
                }
              }
            ]
          : []

// =========== //
// Deployments //
// =========== //

// w365 network security group.
module networksecurityGroupW365 '../../../../avm/1.0.0/res/network/network-security-group/main.bicep' = {
  scope: resourceGroup('${w365SubId}', '${networkObjectsRgName}')
  name: 'NSG-w365-${time}'
  params: {
    name: w365NetworksecurityGroupName
    location: location
    tags: tags
    securityRules: [
      {
        name: 'W365ServiceTraffic'
        properties: {
          priority: 100
          access: 'Allow'
          description: 'Session host traffic to W365 control plane'
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
          destinationAddressPrefixes: varWindowsActivationKMSPrefixesNsg
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
      {
        name: 'RDPShortpathTurnStun'
        properties: {
          priority: 160
          access: 'Allow'
          description: 'Session host traffic to RDP shortpath STUN/TURN'
          destinationAddressPrefix: '20.202.0.0/16'
          direction: 'Outbound'
          sourcePortRange: '*'
          destinationPortRange: '3478'
          protocol: 'Udp'
          sourceAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'RDPShortpathTurnRelay'
        properties: {
          priority: 170
          access: 'Allow'
          description: 'Session host traffic to RDP shortpath STUN/TURN'
          destinationAddressPrefix: '51.5.0.0/16'
          direction: 'Outbound'
          sourcePortRange: '*'
          destinationPortRange: '3478'
          protocol: 'Udp'
          sourceAddressPrefix: 'VirtualNetwork'
        }
      }
    ]
  }
  dependsOn: []
}

// Application security group.
module applicationSecurityGroup '../../../../avm/1.0.0/res/network/application-security-group/main.bicep' = if (deployAsg) {
  scope: resourceGroup('${w365SubId}', '${computeObjectsRgName}')
  name: 'ASG-${time}'
  params: {
    name: applicationSecurityGroupName
    location: location
    tags: tags
  }
  dependsOn: []
}

// W365 route table.
module routeTableW365 '../../../../avm/1.0.0/res/network/route-table/main.bicep' = {
  scope: resourceGroup('${w365SubId}', '${networkObjectsRgName}')
  name: 'Route-Table-W365-${time}'
  params: {
    name: w365RouteTableName
    location: location
    tags: tags
    routes: varCreateW365StaticRoute ? varStaticRoutes : []
  }
  dependsOn: []
}

// DDoS Protection Plan
module ddosProtectionPlan '../../../../avm/1.0.0/res/network/ddos-protection-plan/main.bicep' = if (deployDDoSNetworkProtection) {
  scope: resourceGroup('${w365SubId}', '${networkObjectsRgName}')
  name: 'DDoS-Protection-Plan-${time}'
  params: {
    name: ddosProtectionPlanName
    location: location
  }
  dependsOn: []
}

// Virtual network.
module virtualNetwork '../../../../avm/1.0.0/res/network/virtual-network/main.bicep' = {
  scope: resourceGroup('${w365SubId}', '${networkObjectsRgName}')
  name: 'vNet-${time}'
  params: {
    name: vnetName
    location: location
    addressPrefixes: array(vnetAddressPrefixes)
    dnsServers: dnsServers
    peerings: createVnetPeering
      ? [
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
        ]
      : []
    subnets: [
          {
            name: vnetW365SubnetName
            addressPrefix: vnetW365SubnetAddressPrefix
            privateEndpointNetworkPolicies: 'Disabled'
            privateLinkServiceNetworkPolicies: 'Enabled'
            networkSecurityGroupId: networksecurityGroupW365.outputs.resourceId
            routeTableId: routeTableW365.outputs.resourceId
          }
        ]
    ddosProtectionPlanResourceId: deployDDoSNetworkProtection ? ddosProtectionPlan.outputs.resourceId : ''
    tags: tags
  }
  dependsOn: [
        networksecurityGroupW365
        routeTableW365
      ]
}
