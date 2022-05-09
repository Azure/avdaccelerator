targetScope = 'subscription'

@description('Required. Location where to deploy AVD management plane')
param avdManagementPlaneLocation string

@description('Optional. AVD workload subscription ID, multiple subscriptions scenario')
param avdWorkloadSubsId string

@description('AVD Resource Group Name for the service objects')
param avdServiceObjectsRgName string

@description('Optional. AVD Application Group Name for the applications.')
param avdApplicationGroupNameRApp string

@description('AVD Application group for the session hosts. Desktop type.')
param avdApplicationGroupNameDesktop string

@description('Optional. AVD deploy remote app application group')
param avdDeployRAppGroup bool

@description('AVD Host Pool Name')
param avdHostPoolName string

@description('Optional. AVD host pool Custom RDP properties')
param avdHostPoolRdpProperty string 

@allowed([
  'Personal'
  'Pooled'
])
@description('Optional. AVD host pool type (Default: Pooled)')
param avdHostPoolType string

@allowed([
  'Automatic'
  'Direct'
])
@description('Optional. AVD host pool type (Default: Automatic)')
param avdPersonalAssignType string

@allowed([
  'BreadthFirst'
  'DepthFirst'
])
@description('Required. AVD host pool load balacing type (Default: BreadthFirst)')
param avdHostPoolloadBalancerType string

@description('Optional. AVD host pool maximum number of user sessions per session host')
param avhHostPoolMaxSessions int

@description('Optional. AVD host pool start VM on Connect')
param avdStartVMOnConnect bool

@description('Do not modify, used to set unique value for resource deployment')
param time string = utcNow()

//* Variables
var desktopApplicaitonGroups = [
  {
  name: avdApplicationGroupNameDesktop
  location: avdManagementPlaneLocation
  applicationGroupType: 'Desktop'
  }
]

var applicationApplicationGroups = [
  { 
  name: avdApplicationGroupNameRApp
  location: avdManagementPlaneLocation
  applicationGroupType: 'RemoteApp'
  }
]

var finalApplicationGroups = avdDeployRAppGroup ? concat(desktopApplicaitonGroups,applicationApplicationGroups): desktopApplicaitonGroups

module avdHostPool '../../carml/0.5.0/Microsoft.DesktopVirtualization/hostpools/deploy.bicep' =  {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
    name: 'AVD-HostPool-${time}'
    params: {
        name: avdHostPoolName
        location: avdManagementPlaneLocation
        hostpoolType: avdHostPoolType
        startVMOnConnect: avdStartVMOnConnect
        customRdpProperty: avdHostPoolRdpProperty
        loadBalancerType: avdHostPoolloadBalancerType
        maxSessionLimit: avhHostPoolMaxSessions
        personalDesktopAssignmentType: avdPersonalAssignType
    }
}
module avdApplicationGroups '../../carml/0.5.0/Microsoft.DesktopVirtualization/applicationgroups/deploy.bicep' = [for applicationGroup in finalApplicationGroups:  {
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

output avdAppGroupsArray array = [for (resourceId,i) in finalApplicationGroups : avdApplicationGroups[i].outputs.resourceId] 
output hostPooltoken string = avdHostPool.outputs.hostPoolRestrationInfo.token
