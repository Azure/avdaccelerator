metadata name = 'W365 Accelerator - Baseline Deployment'
metadata description = 'W365 Accelerator - Deployment Baseline'
metadata owner = 'Azure/w365lza'

targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@minLength(2)
@maxLength(4)
@sys.description('The name of the resource group to deploy. (Default: W001)')
param deploymentPrefix string = 'W001'

@allowed([
  'Dev' // Development
  'Test' // Test
  'Prod' // Production
])
@sys.description('Optional. The name of the resource group to deploy. (Default: Dev)')
param deploymentEnvironment string = 'Dev'

@sys.description('Required. Location where to deploy W365 landing zone services.')
param w365Location string 

@sys.description('Required. W365 workload subscription ID')
param w365SubId string = ''

@sys.description('Optional. Existing hub virtual network for peering. (Default: "")')
param existingHubVnetResourceId string = ''

@sys.description('w365 virtual network address prefixes. (Default: 10.10.0.0/23)')
param w365VnetworkAddressPrefixes string = '10.10.0.0/23'

@sys.description('w365 virtual network subnet address prefix. (Default: 10.10.0.0/23)')
param w365vNetworkSubnetAddressPrefix string = '10.10.0.0/24'

@sys.description('Optional. custom DNS servers IPs. (Default: "")')
param customDnsIps string = ''

@sys.description('Deploy DDoS Network Protection for virtual network. (Default: true)')
param deployDDoSNetworkProtection bool = false

@sys.description('Does the hub contains a virtual network gateway. (Default: false)')
param vNetworkGatewayOnHub bool = false

// Custom Naming
@sys.description('W365 resources custom naming. (Default: false)')
param w365UseCustomNaming bool = false

@maxLength(90)
@sys.description('W365 service resources resource group custom name. (Default: rg-w365-app1-dev-use2-service-objects)')
param w365ServiceObjectsRgCustomName string = 'rg-w365-app1-dev-use2-service-objects'

@maxLength(90)
@sys.description('W365 network resources resource group custom name. (Default: rg-w365-app1-dev-use2-network)')
param w365NetworkObjectsRgCustomName string = 'rg-w365-app1-dev-use2-network'

@maxLength(90)
@sys.description('W365 network resources resource group custom name. (Default: rg-w365-app1-dev-use2-pool-compute)')
param w365ComputeObjectsRgCustomName string = 'rg-w365-app1-dev-use2-pool-compute'

@maxLength(64)
@sys.description('W365 virtual network custom name. (Default: vnet-app1-dev-use2-001)')
param w365VnetworkCustomName string = 'vnet-app1-dev-use2-001'

@maxLength(80)
@sys.description('W365 virtual network subnet custom name. (Default: snet-w365-app1-dev-use2-001)')
param w365VnetworkSubnetCustomName string = 'snet-w365-app1-dev-use2-001'

@maxLength(80)
@sys.description('W365 network security group custom name. (Default: nsg-w365-app1-dev-use2-001)')
param w365NetworksecurityGroupCustomName string = 'nsg-w365-app1-dev-use2-001'

@maxLength(80)
@sys.description('W365 route table custom name. (Default: route-w365-app1-dev-use2-001)')
param w365RouteTableCustomName string = 'route-w365-app1-dev-use2-001'

@maxLength(80)
@sys.description('W365 application security custom name. (Default: asg-app1-dev-use2-001)')
param w365ApplicationSecurityGroupCustomName string = 'asg-app1-dev-use2-001'

@sys.description('Apply tags on resources and resource groups. (Default: false)')
param createResourceTags bool = false

@sys.description('The name of workload for tagging purposes. (Default: Contoso-Workload)')
param workloadNameTag string = 'Contoso-Workload'

@allowed([
  'Light'
  'Medium'
  'High'
  'Power'
])
@sys.description('Reference to the size of the VM for your workloads (Default: Light)')
param workloadTypeTag string = 'Light'

@allowed([
  'Non-business'
  'Public'
  'General'
  'Confidential'
  'Highly-confidential'
])
@sys.description('Sensitivity of data hosted (Default: Non-business)')
param dataClassificationTag string = 'Non-business'

@sys.description('Department that owns the deployment, (Dafult: Contoso-W365)')
param departmentTag string = 'Contoso-W365'

@allowed([
  'Low'
  'Medium'
  'High'
  'Mission-critical'
  'Custom'
])
@sys.description('Criticality of the workload. (Default: Low)')
param workloadCriticalityTag string = 'Low'

@sys.description('Tag value for custom criticality value. (Default: Contoso-Critical)')
param workloadCriticalityCustomValueTag string = 'Contoso-Critical'

@sys.description('Details about the application.')
param applicationNameTag string = 'Contoso-App'

@sys.description('Service level agreement level of the worload. (Contoso-SLA)')
param workloadSlaTag string = 'Contoso-SLA'

@sys.description('Team accountable for day-to-day operations. (workload-admins@Contoso.com)')
param opsTeamTag string = 'workload-admins@Contoso.com'

@sys.description('Organizational owner of the W365 deployment. (Default: workload-owner@Contoso.com)')
param ownerTag string = 'workload-owner@Contoso.com'

@sys.description('Cost center of owner team. (Default: Contoso-CC)')
param costCenterTag string = 'Contoso-CC'

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

@sys.description('Enable usage and telemetry feedback to Microsoft.')
param enableTelemetry bool = true

// =========== //
// Variable declaration //
// =========== //
// Resource naming
var varDeploymentPrefixLowercase = toLower(deploymentPrefix)
var varDeploymentEnvironmentLowercase = toLower(deploymentEnvironment)
var varW365LocationAcronym = varLocations[varSessionHostLocationLowercase].acronym
var varLocations = loadJsonContent('../variables/locations.json')
var varResourcesNamingStandard = '${varDeploymentPrefixLowercase}-${varDeploymentEnvironmentLowercase}-${varW365LocationAcronym}'
var varSessionHostLocationLowercase = toLower(replace(w365Location, ' ', ''))
var varNetworkObjectsRgName = w365UseCustomNaming
  ? w365NetworkObjectsRgCustomName
  : 'rg-w365-${varResourcesNamingStandard}-network' // max length limit 90 characters
var varServiceObjectsRgName = w365UseCustomNaming
  ? w365ServiceObjectsRgCustomName
  : 'rg-avd-${varResourcesNamingStandard}-service-objects' // max length limit 90 characters
var varComputeObjectsRgName = w365UseCustomNaming
  ? w365ComputeObjectsRgCustomName
  : 'rg-w365-${varResourcesNamingStandard}-pool-compute' // max length limit 90 characters
var varVnetName = w365UseCustomNaming ? w365VnetworkCustomName : 'vnet-${varResourcesNamingStandard}-001'
var varHubVnetName = (!empty(existingHubVnetResourceId))
  ? split(existingHubVnetResourceId, '/')[8]
  : ''
var varVnetPeeringName = 'peer-${varHubVnetName}'
var varRemoteVnetPeeringName = 'peer-${varVnetName}'
var varVnetW365SubnetName = w365UseCustomNaming
  ? w365VnetworkSubnetCustomName
  : 'snet-w365-${varResourcesNamingStandard}-001'
var varApplicationSecurityGroupName = w365UseCustomNaming
  ? w365ApplicationSecurityGroupCustomName
  : 'asg-${varResourcesNamingStandard}-001'
var varW365NetworksecurityGroupName = w365UseCustomNaming
  ? w365NetworksecurityGroupCustomName
  : 'nsg-w365-${varResourcesNamingStandard}-001'
var varW365RouteTableName = w365UseCustomNaming
  ? w365RouteTableCustomName
  : 'route-w365-${varResourcesNamingStandard}-001'
var varDDosProtectionPlanName = 'ddos-${varVnetName}'
var varAllDnsServers = '${customDnsIps},168.63.129.16'
var varDnsServers = empty(customDnsIps) ? [] : (split(varAllDnsServers, ','))
var varCreateVnetPeering = !empty(existingHubVnetResourceId) ? true : false
// Resource tagging
var varCustomResourceTags = createResourceTags
  ? {
      WorkloadName: workloadNameTag
      WorkloadType: workloadTypeTag
      DataClassification: dataClassificationTag
      Department: departmentTag
      Criticality: (workloadCriticalityTag == 'Custom') ? workloadCriticalityCustomValueTag : workloadCriticalityTag
      ApplicationName: applicationNameTag
      ServiceClass: workloadSlaTag
      OpsTeam: opsTeamTag
      Owner: ownerTag
      CostCenter: costCenterTag
    }
  : {}
var varW365DefaultTags = {
  Environment: deploymentEnvironment
  ServiceWorkload: 'W365'
  CreationTimeUTC: time
}
//
var varTelemetryId = 'pid-2ce4228c-d72c-43fb-bb5b-cd8f3ba2138e-${w365Location}'
var verResourceGroups = [
  {
    purpose: 'Pool-Compute'
    name: varComputeObjectsRgName
    location: w365Location
    enableDefaultTelemetry: false
    tags: varW365DefaultTags
  }
  {
    purpose: 'Network-Objects'
    name: varNetworkObjectsRgName
    location: w365Location
    enableDefaultTelemetry: false
    tags: varW365DefaultTags
  }
  {
    purpose: 'Service-Objects'
    name: varServiceObjectsRgName
    location: w365Location
    enableDefaultTelemetry: false
    tags: varW365DefaultTags
  }
]

// =========== //
// Deployments //
// =========== //

//  Telemetry Deployment
resource telemetrydeployment 'Microsoft.Resources/deployments@2024-03-01' = if (enableTelemetry) {
  name: varTelemetryId
  location: w365Location
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

// Resource groups.
// Compute, network
module baselineResourceGroups '../../avm/1.0.0/res/resources/resource-group/main.bicep' = [
  for resourceGroup in verResourceGroups: {
    scope: subscription(w365SubId)
    name: '${resourceGroup.purpose}-${time}'
    params: {
      name: resourceGroup.name
      location: resourceGroup.location
      enableTelemetry: resourceGroup.enableDefaultTelemetry
      tags: resourceGroup.tags
    }
  }
]

// Networking
module networking './modules/networking/deploy.bicep' = {
  name: 'Networking-${time}'
  params: {
    deployAsg: true
    w365SubId: w365SubId
    applicationSecurityGroupName: varApplicationSecurityGroupName
    computeObjectsRgName: varComputeObjectsRgName
    networkObjectsRgName: varNetworkObjectsRgName
    w365NetworksecurityGroupName: varW365NetworksecurityGroupName
    w365RouteTableName: varW365RouteTableName
    vnetAddressPrefixes: w365VnetworkAddressPrefixes
    vnetName: varVnetName
    vnetPeeringName: varVnetPeeringName
    remoteVnetPeeringName: varRemoteVnetPeeringName
    vnetW365SubnetName: varVnetW365SubnetName
    createVnetPeering: varCreateVnetPeering
    deployDDoSNetworkProtection: deployDDoSNetworkProtection
    ddosProtectionPlanName: varDDosProtectionPlanName
    vNetworkGatewayOnHub: vNetworkGatewayOnHub
    existingHubVnetResourceId: existingHubVnetResourceId
    location: w365Location
    vnetW365SubnetAddressPrefix: w365vNetworkSubnetAddressPrefix
    dnsServers: varDnsServers
    tags: createResourceTags ? union(varCustomResourceTags, varW365DefaultTags) : varW365DefaultTags
  }
  dependsOn: [
    baselineResourceGroups
  ]
}
