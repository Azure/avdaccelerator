targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@description('Location where to deploy AVD management plane.')
param managementPlaneLocation string

@description('AVD workload subscription ID, multiple subscriptions scenario.')
param workloadSubsId string

@description('Virtual machine time zone.')
param computeTimeZone string

@description('The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@description('Identity ID to grant RBAC role to access AVD application group.')
param applicationGroupIdentitiesIds array

@description('Identity type to grant RBAC role to access AVD application group.')
param applicationGroupIdentityType string

@description('AVD OS image source.')
param osImage string

@description('AVD Resource Group Name for the service objects.')
param serviceObjectsRgName string

@description('AVD Application Group Name for the applications.')
param applicationGroupNameRapp string

@description('AVD Application Group friendly Name for the applications.')
param applicationGroupFriendlyNameRapp string

@description('AVD Application group for the session hosts. Desktop type.')
param applicationGroupNameDesktop string

@description('AVD Application group for the session hosts. Desktop type (friendly name).')
param applicationGroupFriendlyNameDesktop string

@description('AVD Application group app for the session hosts. Desktop type (friendly name).')
param applicationGroupAppFriendlyNameDesktop string

@description('AVD deploy remote app application group.')
param deployRappGroup bool

@description('AVD deploy scaling plan.')
param deployScalingPlan bool

@description('AVD Host Pool Name')
param hostPoolName string

@description('AVD Host Pool friendly Name')
param hostPoolFriendlyName string

@description('AVD scaling plan name')
param scalingPlanName string

@description('AVD scaling plan schedules')
param scalingPlanSchedules array

@description('AVD workspace name.')
param workSpaceName string

@description('AVD workspace friendly name.')
param workSpaceFriendlyName string

@description('AVD host pool Custom RDP properties.')
param hostPoolRdpProperties string

@allowed([
  'Personal'
  'Pooled'
])
@description('Optional. AVD host pool type.')
param hostPoolType string

@allowed([
  'Automatic'
  'Direct'
])
@description('Optional. AVD host pool type.')
param personalAssignType string

@allowed([
  'BreadthFirst'
  'DepthFirst'
])
@description('AVD host pool load balacing type.')
param hostPoolLoadBalancerType string

@description('Optional. AVD host pool maximum number of user sessions per session host.')
param hostPoolMaxSessions int

@description('Optional. AVD host pool start VM on Connect.')
param startVmOnConnect bool

@description('Tags to be applied to resources')
param tags object

@description('Tag to exclude resources from scaling plan.')
param scalingPlanExclusionTag string

@description('Log analytics workspace for diagnostic logs.')
param alaWorkspaceResourceId string

@description('Diagnostic logs retention.')
param diagnosticLogsRetentionInDays int

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var varDesktopApplicaitonGroups = [
  {
    name: applicationGroupNameDesktop
    friendlyName: applicationGroupFriendlyNameDesktop
    location: managementPlaneLocation
    applicationGroupType: 'Desktop'
  }
]
var varRAppApplicationGroups = [
  {
    name: applicationGroupNameRapp
    friendlyName: applicationGroupFriendlyNameRapp
    location: managementPlaneLocation
    applicationGroupType: 'RemoteApp'
  }
]
var varHostPoolRdpPropertiesDomainServiceCheck = (identityServiceProvider == 'AAD') ? '${hostPoolRdpProperties};targetisaadjoined:i:1;enablerdsaadauth:i:1' : hostPoolRdpProperties
var varFinalApplicationGroups = deployRappGroup ? concat(varDesktopApplicaitonGroups, varRAppApplicationGroups) : varDesktopApplicaitonGroups
var varRAppApplicationGroupsStandardApps = [
  {
    name: 'Task Manager'
    description: 'Task Manager'
    friendlyName: 'Task Manager'
    showInPortal: true
    filePath: 'C:\\Windows\\system32\\taskmgr.exe'
  }
  {
    name: 'WordPad'
    description: 'WordPad'
    friendlyName: 'WordPad'
    showInPortal: true
    filePath: 'C:\\Program Files\\Windows NT\\Accessories\\wordpad.exe'
  }
  {
    name: 'Microsoft Edge'
    description: 'Microsoft Edge'
    friendlyName: 'Edge'
    showInPortal: true
    filePath: 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe'
  }
  {
    name: 'Remote Desktop Connection'
    description: 'Remote Desktop Connection'
    friendlyName: 'Remote Desktop'
    showInPortal: true
    filePath: 'C:\\WINDOWS\\system32\\mtsc.exe'
  }
]
var varRAppApplicationGroupsOfficeApps = [
  {
    name: 'Microsoft Excel'
    description: 'Microsoft Excel'
    friendlyName: 'Excel'
    showInPortal: true
    filePath: 'C:\\Program Files\\Microsoft Office\\root\\Office16\\EXCEL.EXE'
  }
  {
    name: 'Microsoft PowerPoint'
    description: 'Microsoft PowerPoint'
    friendlyName: 'PowerPoint'
    showInPortal: true
    filePath: 'C:\\Program Files\\Microsoft Office\\root\\Office16\\POWERPNT.EXE'
  }
  {
    name: 'Microsoft Word'
    description: 'Microsoft Word'
    friendlyName: 'Outlook'
    showInPortal: true
    filePath: 'C:\\Program Files\\Microsoft Office\\root\\Office16\\WINWORD.EXE'
  }
  {
    name: 'Microsoft Outlook'
    description: 'Microsoft Word'
    friendlyName: 'Word'
    showInPortal: true
    filePath: 'C:\\Program Files\\Microsoft Office\\root\\Office16\\OUTLOOK.EXE'
  }
]
var varRAppApplicationGroupsApps = (contains(osImage, 'office')) ? union(varRAppApplicationGroupsStandardApps, varRAppApplicationGroupsOfficeApps) : varRAppApplicationGroupsStandardApps
var varHostPoolDiagnostic = [
  //'Checkpoint'
  //'Error'
  //'Management'
  //'Connection'
  //'HostRegistration'
  //'AgentHealthStatus'
  //'NetworkData'
  //'ConnectionGraphicsData'
  //'SessionHostManagement'
  'allLogs'
]
var varApplicationGroupDiagnostic = [
  //'Checkpoint'
  //'Error'
  //'Management'
  'allLogs'
]
var varWorkspaceDiagnostic = [
  //'Checkpoint'
  //'Error'
  //'Management'
  //'Feed'
  'allLogs'
]
var varScalingPlanDiagnostic = [
  //'Autoscale'
  'allLogs'
]

// =========== //
// Deployments //
// =========== //

// Hostpool.
module hostPool '../../../../carml/1.3.0/Microsoft.DesktopVirtualization/hostpools/deploy.bicep' = {
  scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
  name: 'HostPool-${time}'
  params: {
    name: hostPoolName
    friendlyName: hostPoolFriendlyName
    location: managementPlaneLocation
    type: hostPoolType
    startVMOnConnect: startVmOnConnect
    customRdpProperty: varHostPoolRdpPropertiesDomainServiceCheck
    loadBalancerType: hostPoolLoadBalancerType
    maxSessionLimit: hostPoolMaxSessions
    personalDesktopAssignmentType: personalAssignType
    tags: tags
    diagnosticWorkspaceId: alaWorkspaceResourceId
    diagnosticLogsRetentionInDays: diagnosticLogsRetentionInDays
    diagnosticLogCategoriesToEnable: varHostPoolDiagnostic
  }
}

// Application groups.
module applicationGroups '../../../../carml/1.3.0/Microsoft.DesktopVirtualization/applicationgroups/deploy.bicep' = [for applicationGroup in varFinalApplicationGroups: {
  scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
  name: 'Application-Group-${applicationGroup.name}-${time}'
  params: {
    name: applicationGroup.name
    friendlyName: applicationGroup.friendlyName
    location: applicationGroup.location
    applicationGroupType: applicationGroup.applicationGroupType
    hostpoolName: hostPool.outputs.name
    tags: tags
    applications: (applicationGroup.applicationGroupType == 'RemoteApp')  ? varRAppApplicationGroupsApps : []
    roleAssignments: !empty(applicationGroupIdentitiesIds) ? [
      {
      roleDefinitionIdOrName: 'Desktop Virtualization User'
      principalIds: applicationGroupIdentitiesIds
      principalType: applicationGroupIdentityType
      }
    ]: []     
    diagnosticWorkspaceId: alaWorkspaceResourceId
    diagnosticLogsRetentionInDays: diagnosticLogsRetentionInDays
    diagnosticLogCategoriesToEnable: varApplicationGroupDiagnostic
  }
  dependsOn: [
    hostPool
  ]
}]

// Workspace.
module workSpace '../../../../carml/1.3.0/Microsoft.DesktopVirtualization/workspaces/deploy.bicep' = {
  scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
  name: 'Workspace-${time}'
  params: {
      name: workSpaceName
      friendlyName: workSpaceFriendlyName
      location: managementPlaneLocation
      appGroupResourceIds: deployRappGroup ? [
        '/subscriptions/${workloadSubsId}/resourceGroups/${serviceObjectsRgName}/providers/Microsoft.DesktopVirtualization/applicationgroups/${applicationGroupNameDesktop}'
        '/subscriptions/${workloadSubsId}/resourceGroups/${serviceObjectsRgName}/providers/Microsoft.DesktopVirtualization/applicationgroups/${applicationGroupNameRapp}'
      ]: [
        '/subscriptions/${workloadSubsId}/resourceGroups/${serviceObjectsRgName}/providers/Microsoft.DesktopVirtualization/applicationgroups/${applicationGroupNameDesktop}'
      ]
      tags: tags
      diagnosticWorkspaceId: alaWorkspaceResourceId
      diagnosticLogsRetentionInDays: diagnosticLogsRetentionInDays
      diagnosticLogCategoriesToEnable: varWorkspaceDiagnostic
  }
  dependsOn: [
    hostPool
    applicationGroups
  ]
}

// Scaling plan.
module scalingPlan '../../../../carml/1.3.0/Microsoft.DesktopVirtualization/scalingplans/deploy.bicep' =  if (deployScalingPlan && (hostPoolType == 'Pooled'))  {
  scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
  name: 'Scaling-Plan-${time}'
  params: {
      name:scalingPlanName
      location: managementPlaneLocation
      hostPoolType: 'Pooled' //avdHostPoolType
      exclusionTag: scalingPlanExclusionTag
      timeZone: computeTimeZone
      schedules: scalingPlanSchedules
      hostPoolReferences: [
        {
        hostPoolArmPath: '/subscriptions/${workloadSubsId}/resourceGroups/${serviceObjectsRgName}/providers/Microsoft.DesktopVirtualization/hostpools/${hostPoolName}'
        scalingPlanEnabled: true
        }
      ]
      tags: tags
      diagnosticWorkspaceId: alaWorkspaceResourceId
      diagnosticLogsRetentionInDays: diagnosticLogsRetentionInDays
      diagnosticLogCategoriesToEnable: varScalingPlanDiagnostic
  }
  dependsOn: [
    hostPool
    applicationGroups
    workSpace
  ]
}

// =========== //
// Outputs //
// =========== //
