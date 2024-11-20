using '../deploy-baseline.bicep'

param deploymentPrefix = 'W001'
param deploymentEnvironment = 'Dev'
param w365Location = ''
param w365SubId = ''
param existingHubVnetResourceId = ''
param w365VnetworkAddressPrefixes = '10.10.0.0/23'
param w365vNetworkSubnetAddressPrefix = '10.10.0.0/24'
param customDnsIps = ''
param deployDDoSNetworkProtection = false
param vNetworkGatewayOnHub = false
param w365UseCustomNaming = false
param w365ServiceObjectsRgCustomName = 'rg-w365-app1-dev-use2-service-objects'
param w365NetworkObjectsRgCustomName = 'rg-w365-app1-dev-use2-network'
param w365ComputeObjectsRgCustomName = 'rg-w365-app1-dev-use2-pool-compute'
param w365VnetworkCustomName = 'vnet-app1-dev-use2-001'
param w365VnetworkSubnetCustomName = 'snet-w365-app1-dev-use2-001'
param w365NetworksecurityGroupCustomName = 'nsg-w365-app1-dev-use2-001'
param privateEndpointNetworksecurityGroupCustomName = 'nsg-pe-app1-dev-use2-001'
param w365RouteTableCustomName = 'route-w365-app1-dev-use2-001'
param w365ApplicationSecurityGroupCustomName = 'asg-app1-dev-use2-001'
param createResourceTags = false
param workloadNameTag = 'Contoso-Workload'
param workloadTypeTag = 'Light'
param dataClassificationTag = 'Non-business'
param departmentTag = 'Contoso-W365'
param workloadCriticalityTag = 'Low'
param workloadCriticalityCustomValueTag = 'Contoso-Critical'
param applicationNameTag = 'Contoso-App'
param workloadSlaTag = 'Contoso-SLA'
param opsTeamTag = 'workload-admins@Contoso.com'
param ownerTag = 'workload-owner@Contoso.com'
param costCenterTag = 'Contoso-CC'
param time = ? /* TODO : please fix the value assigned to this parameter `utcNow()` */
param enableTelemetry = true

