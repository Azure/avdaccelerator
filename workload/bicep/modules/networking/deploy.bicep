metadata name = 'AVD LZA networking'
metadata description = 'This module deploys vNet, NSG, ASG, UDR, private DNs zones'
metadata owner = 'Azure/avdaccelerator'

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

@sys.description('DDoS Protection Plan name.')
param ddosProtectionPlanName string

@sys.description('Deploy DDoS Network Protection for virtual network.')
param deployDDoSNetworkProtection bool

@sys.description('Optional. AVD Accelerator will deploy with private endpoints by default.')
param deployPrivateEndpointSubnet bool

@sys.description('Optional. Deploys private endpoints for the AVD Private Link Service. (Default: false)')
param deployAvdPrivateLinkService bool

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

@sys.description('Location where to deploy resources.')
param location string = deployment().location

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
var varCreateAvdStaicRoute = true
var varExistingAvdVnetSubId = !createVnet ? split(existingAvdSubnetResourceId, '/')[2] : ''
var varExistingAvdVnetSubRgName = !createVnet ? split(existingAvdSubnetResourceId, '/')[4] : ''
var varExistingAvdVnetName = !createVnet ? split(existingAvdSubnetResourceId, '/')[8] : ''
var varExistingAvdVnetResourceId = !createVnet
  ? '/subscriptions/${varExistingAvdVnetSubId}/resourceGroups/${varExistingAvdVnetSubRgName}/providers/Microsoft.Network/virtualNetworks/${varExistingAvdVnetName}'
  : ''
var varDiagnosticSettings = !empty(alaWorkspaceResourceId)
  ? [
      {
        workspaceResourceId: alaWorkspaceResourceId
        logCategoriesAndGroups: [] 
      }
    ]
  : []
var varVirtualNetworkLinks = createVnet
  ? [
      {
        virtualNetworkResourceId: virtualNetwork.outputs.resourceId
      }
    ]
  : [
      {
        virtualNetworkResourceId: varExistingAvdVnetResourceId
      }
    ]
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
        name: 'AVDServiceTraffic'
        properties: {
          addressPrefix: 'WindowsVirtualDesktop'
          hasBgpOverride: true
          nextHopType: 'Internet'
        }
      }
      {
        name: 'AVDStunInfraTurnRelayTraffic'
        properties: {
          addressPrefix: '20.202.0.0/16'
          hasBgpOverride: true
          nextHopType: 'Internet'
        }
      }
      {
        name: 'AVDTurnRelayTraffic'
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
var privateDnsZoneNames = {
  AutomationAgentService: 'privatelink.agentsvc.azure-automation.${privateDnsZoneSuffixes_AzureAutomation[environment().name]}'
  Automation: 'privatelink.azure-automation.${privateDnsZoneSuffixes_AzureAutomation[environment().name]}'
  AVDFeedConnections: 'privatelink.wvd.${privateDnsZoneSuffixes_AzureVirtualDesktop[environment().name]}'
  AVDDiscovery: 'privatelink-global.wvd.${privateDnsZoneSuffixes_AzureVirtualDesktop[environment().name]}'
  StorageFiles: 'privatelink.file.${environment().suffixes.storage}'
  StorageQueue: 'privatelink.queue.${environment().suffixes.storage}'
  StorageTable: 'privatelink.table.${environment().suffixes.storage}'
  StorageBlob: 'privatelink.blob.${environment().suffixes.storage}'
  KeyVault: replace('privatelink${environment().suffixes.keyvaultDns}', 'vault', 'vaultcore')
  Monitor: 'privatelink.monitor.${privateDnsZoneSuffixes_Monitor[environment().name]}'
  MonitorODS: 'privatelink.ods.opinsights.${privateDnsZoneSuffixes_Monitor[environment().name]}'
  MonitorOMS: 'privatelink.oms.opinsights.${privateDnsZoneSuffixes_Monitor[environment().name]}'
}

var privateDnsZoneSuffixes_AzureAutomation = {
  AzureCloud: 'net'
  AzureUSGovernment: 'us'
}
var privateDnsZoneSuffixes_AzureVirtualDesktop = {
  AzureCloud: 'microsoft.com'
  AzureUSGovernment: 'azure.us'
}
var privateDnsZoneSuffixes_Monitor = {
  AzureCloud: 'azure.com'
  AzureUSGovernment: 'azure.us'
}

// =========== //
// Deployments //
// =========== //

// AVD network security group.
module networksecurityGroupAvd '../../../../avm/1.0.0/res/network/network-security-group/main.bicep' = if (createVnet) {
  scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
  name: 'NSG-AVD-${time}'
  params: {
    name: avdNetworksecurityGroupName
    location: location
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

// Private endpoint network security group.
module networksecurityGroupPrivateEndpoint '../../../../avm/1.0.0/res/network/network-security-group/main.bicep' = if (createVnet && deployPrivateEndpointSubnet) {
  scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
  name: 'NSG-Private-Endpoint-${time}'
  params: {
    name: privateEndpointNetworksecurityGroupName
    location: location
    tags: tags
    diagnosticSettings: varDiagnosticSettings
    securityRules: []
  }
  dependsOn: []
}

// Application security group.
module applicationSecurityGroup '../../../../avm/1.0.0/res/network/application-security-group/main.bicep' = if (deployAsg) {
  scope: resourceGroup('${workloadSubsId}', '${computeObjectsRgName}')
  name: 'ASG-${time}'
  params: {
    name: applicationSecurityGroupName
    location: location
    tags: tags
  }
  dependsOn: []
}

// AVD route table.
module routeTableAvd '../../../../avm/1.0.0/res/network/route-table/main.bicep' = if (createVnet) {
  scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
  name: 'Route-Table-AVD-${time}'
  params: {
    name: avdRouteTableName
    location: location
    tags: tags
    routes: varCreateAvdStaicRoute ? varStaticRoutes : []
  }
  dependsOn: []
}

// Private endpoint route table.
module routeTablePrivateEndpoint '../../../../avm/1.0.0/res/network/route-table/main.bicep' = if (createVnet && deployPrivateEndpointSubnet) {
  scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
  name: 'Route-Table-PE-${time}'
  params: {
    name: privateEndpointRouteTableName
    location: location
    tags: tags
    routes: []
  }
  dependsOn: []
}

// DDoS Protection Plan
module ddosProtectionPlan '../../../../avm/1.0.0/res/network/ddos-protection-plan/main.bicep' = if (deployDDoSNetworkProtection) {
  scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
  name: 'DDoS-Protection-Plan-${time}'
  params: {
    name: ddosProtectionPlanName
    location: location
  }
  dependsOn: []
}

// Virtual network.
module virtualNetwork '../../../../avm/1.0.0/res/network/virtual-network/main.bicep' = if (createVnet) {
  scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
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
    subnets: deployPrivateEndpointSubnet
      ? [
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
            networkSecurityGroupId: (createVnet && deployPrivateEndpointSubnet)
              ? networksecurityGroupPrivateEndpoint.outputs.resourceId
              : ''
            routeTableId: (createVnet && deployPrivateEndpointSubnet)
              ? routeTablePrivateEndpoint.outputs.resourceId
              : ''
          }
        ]
      : [
          {
            name: vnetAvdSubnetName
            addressPrefix: vnetAvdSubnetAddressPrefix
            privateEndpointNetworkPolicies: 'Disabled'
            privateLinkServiceNetworkPolicies: 'Enabled'
            networkSecurityGroupId: createVnet ? networksecurityGroupAvd.outputs.resourceId : ''
            routeTableId: createVnet ? routeTableAvd.outputs.resourceId : ''
          }
        ]
    ddosProtectionPlanResourceId: deployDDoSNetworkProtection ? ddosProtectionPlan.outputs.resourceId : ''
    tags: tags
    diagnosticSettings: varDiagnosticSettings
  }
  dependsOn: createVnet
    ? [
        networksecurityGroupAvd
        networksecurityGroupPrivateEndpoint
        routeTableAvd
        routeTablePrivateEndpoint
      ]
    : []
}

// Private DNS zones Azure files
module privateDnsZoneAzureFiles '../../../../avm/1.0.0/res/network/private-dns-zone/main.bicep' = if (createPrivateDnsZones) {
  scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
  name: 'Private-DNS-Files-${time}'
  params: {
    name: privateDnsZoneNames.StorageFiles
    virtualNetworkLinks: varVirtualNetworkLinks
    tags: tags
  }
}

// Private DNS zones key vault
module privateDnsZoneKeyVault '../../../../avm/1.0.0/res/network/private-dns-zone/main.bicep' = if (createPrivateDnsZones) {
  scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
  name: 'Private-DNS-Kv-${time}'
  params: {
    name: privateDnsZoneNames.KeyVault
    virtualNetworkLinks: varVirtualNetworkLinks
    tags: tags
  }
}

// Private DNS zones AVD
module privateDnsZoneAVDConnection '../../../../avm/1.0.0/res/network/private-dns-zone/main.bicep' = if (createPrivateDnsZones && deployAvdPrivateLinkService) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'Private-DNS-AVD-Connection-${time}'
    params: {
        name: privateDnsZoneNames.AVDFeedConnections
        virtualNetworkLinks: varVirtualNetworkLinks
        tags: tags
    }
}

// Private DNS zones AVD Discovery
module privateDnsZoneAVDDiscovery '../../../../avm/1.0.0/res/network/private-dns-zone/main.bicep' = if (createPrivateDnsZones && deployAvdPrivateLinkService) {
    scope: resourceGroup('${workloadSubsId}', '${networkObjectsRgName}')
    name: 'Private-DNS-AVD-Discovery-${time}'
    params: {
        name: privateDnsZoneNames.AVDDiscovery
        virtualNetworkLinks: varVirtualNetworkLinks
        tags: tags
    }
}
// =========== //
// Outputs //
// =========== //
output applicationSecurityGroupResourceId string = deployAsg ? applicationSecurityGroup.outputs.resourceId : ''
output virtualNetworkResourceId string = createVnet ? virtualNetwork.outputs.resourceId : ''
output azureFilesDnsZoneResourceId string = createPrivateDnsZones ? privateDnsZoneAzureFiles.outputs.resourceId : ''
output keyVaultDnsZoneResourceId string = createPrivateDnsZones ? privateDnsZoneKeyVault.outputs.resourceId : ''
output avdDnsConnectionZoneResourceId string = (createPrivateDnsZones && deployAvdPrivateLinkService) ? privateDnsZoneAVDConnection.outputs.resourceId : ''
output avdDnsDiscoveryZoneResourceId string = (createPrivateDnsZones && deployAvdPrivateLinkService) ? privateDnsZoneAVDDiscovery.outputs.resourceId : ''
