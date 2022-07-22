targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@description('Required. Location where to deploy AVD management plane.')
param avdManagementPlaneLocation string

@description('Optional. AVD workload subscription ID, multiple subscriptions scenario.')
param avdWorkloadSubsId string

@description('Required, The service providing domain services for Azure Virtual Desktop.')
param avdIdentityServiceProvider string

@description('AVD Resource Group Name for the service objects.')
param avdServiceObjectsRgName string

@description('Optional. AVD Application Group Name for the applications.')
param avdApplicationGroupNameRapp string

@description('AVD Application group for the session hosts. Desktop type.')
param avdApplicationGroupNameDesktop string

@description('Optional. AVD deploy remote app application group.')
param avdDeployRappGroup bool

@description('AVD Host Pool Name')
param avdHostPoolName string

@description('Optional. AVD host pool Custom RDP properties.')
param avdHostPoolRdpProperties string

@allowed([
  'Personal'
  'Pooled'
])
@description('Optional. AVD host pool type. (Default: Pooled)')
param avdHostPoolType string

@allowed([
  'Automatic'
  'Direct'
])
@description('Optional. AVD host pool type. (Default: Automatic)')
param avdPersonalAssignType string

@allowed([
  'BreadthFirst'
  'DepthFirst'
])
@description('Required. AVD host pool load balacing type. (Default: BreadthFirst)')
param avdHostPoolLoadBalancerType string

@description('Optional. AVD host pool maximum number of user sessions per session host.')
param avhHostPoolMaxSessions int

@description('Optional. AVD host pool start VM on Connect.')
param avdStartVmOnConnect bool

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var desktopApplicaitonGroups = [
  {
    name: avdApplicationGroupNameDesktop
    location: avdManagementPlaneLocation
    applicationGroupType: 'Desktop'
  }
]

var applicationApplicationGroups = [
  {
    name: avdApplicationGroupNameRapp
    location: avdManagementPlaneLocation
    applicationGroupType: 'RemoteApp'
  }
]
var avdHostPoolRdpPropertiesDomainServiceCheck = (avdIdentityServiceProvider == 'AAD') ? '${avdHostPoolRdpProperties}targetisaadjoined:i:1' : avdHostPoolRdpProperties
var finalApplicationGroups = avdDeployRappGroup ? concat(desktopApplicaitonGroups, applicationApplicationGroups) : desktopApplicaitonGroups

// =========== //
// Deployments //
// =========== //

// Hostpool.
module avdHostPool '../../../carml/1.2.0/Microsoft.DesktopVirtualization/hostpools/deploy.bicep' = {
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
  name: 'AVD-HostPool-${time}'
  params: {
    name: avdHostPoolName
    location: avdManagementPlaneLocation
    hostpoolType: avdHostPoolType
    startVMOnConnect: avdStartVmOnConnect
    customRdpProperty: avdHostPoolRdpPropertiesDomainServiceCheck
    loadBalancerType: avdHostPoolLoadBalancerType
    maxSessionLimit: avhHostPoolMaxSessions
    personalDesktopAssignmentType: avdPersonalAssignType
  }
}

// Application groups.
module avdApplicationGroups '../../../carml/1.2.0/Microsoft.DesktopVirtualization/applicationgroups/deploy.bicep' = [for applicationGroup in finalApplicationGroups: {
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
  name: 'Deploy-AppGroup-${applicationGroup.name}-${time}'
  params: {
    name: applicationGroup.name
    location: applicationGroup.location
    applicationGroupType: applicationGroup.applicationGroupType
    hostpoolName: avdHostPool.outputs.name
  }
  dependsOn: [
    avdHostPool
  ]
}]

// =========== //
// Outputs //
// =========== //
output avdAppGroupsArray array = [for (resourceId, i) in finalApplicationGroups: avdApplicationGroups[i].outputs.resourceId]
output hostPooltoken string = avdHostPool.outputs.hostPoolRestrationInfo.token
