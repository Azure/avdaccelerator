targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@sys.description('Location where to deploy AVD management plane.')
param managementPlaneLocation string

@sys.description('AVD workload subscription ID, multiple subscriptions scenario.')
param workloadSubsId string

@sys.description('Virtual machine time zone.')
param computeTimeZone string

@sys.description('The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@sys.description('Identity ID to grant RBAC role to access AVD application group.')
param applicationGroupIdentitiesIds array

@sys.description('Identity type to grant RBAC role to access AVD application group.')
param applicationGroupIdentityType string

@sys.description('AVD OS image source.')
param osImage string

@sys.description('AVD Resource Group Name for the service objects.')
param serviceObjectsRgName string

@sys.description('AVD Application Group Name for the applications.')
param applicationGroupNameRapp string

@sys.description('AVD Application Group friendly Name for the applications.')
param applicationGroupFriendlyNameRapp string

@sys.description('AVD Application group for the session hosts. Desktop type.')
param applicationGroupNameDesktop string

@sys.description('AVD Application group for the session hosts. Desktop type (friendly name).')
param applicationGroupFriendlyNameDesktop string

@sys.description('AVD deploy remote app application group.')
param deployRappGroup bool

@sys.description('AVD deploy scaling plan.')
param deployScalingPlan bool

@sys.description('AVD Host Pool Name')
param hostPoolName string

@sys.description('AVD Host Pool friendly Name')
param hostPoolFriendlyName string

@sys.description('AVD scaling plan name')
param scalingPlanName string

@sys.description('AVD scaling plan schedules')
param scalingPlanSchedules array

@sys.description('AVD workspace name.')
param workSpaceName string

@sys.description('AVD workspace friendly name.')
param workSpaceFriendlyName string

@sys.description('AVD host pool Custom RDP properties.')
param hostPoolRdpProperties string

@allowed([
  'Personal'
  'Pooled'
])
@sys.description('Optional. AVD host pool type.')
param hostPoolType string

@allowed([
  'Automatic'
  'Direct'
])
@sys.description('Optional. AVD host pool type.')
param personalAssignType string

@allowed([
  'BreadthFirst'
  'DepthFirst'
])
@sys.description('AVD host pool load balacing type.')
param hostPoolLoadBalancerType string

@sys.description('Optional. AVD host pool maximum number of user sessions per session host.')
param hostPoolMaxSessions int

@sys.description('Optional. AVD host pool start VM on Connect.')
param startVmOnConnect bool

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Tag to exclude resources from scaling plan.')
param scalingPlanExclusionTag string

@sys.description('Log analytics workspace for diagnostic logs.')
param alaWorkspaceResourceId string

@sys.description('Diagnostic logs retention.')
param diagnosticLogsRetentionInDays int

@sys.description('Do not modify, used to set unique value for resource deployment.')
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
    createRoleAssignment: deployRappGroup ? false : true
  }
]
var varRAppApplicationGroups = [
  {
    name: applicationGroupNameRapp
    friendlyName: applicationGroupFriendlyNameRapp
    location: managementPlaneLocation
    applicationGroupType: 'RemoteApp'
    createRoleAssignment: deployRappGroup ? true : false
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
// Deployments Commercial//
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
    agentUpdate: {
      //useSessionHostLocalTime: true
      //maintenanceWindowTimeZone: computeTimeZone
      //type: 'Default'
      //maintenanceWindows: [
      //  {
      //    dayOfWeek: 'string'
      //    hour: int
      //  }
      //]
    }
  }
}

// Application groups.
module applicationGroups '../../../../carml/1.3.0/Microsoft.DesktopVirtualization/applicationgroups/deploy.bicep' = [for applicationGroup in varFinalApplicationGroups: {
  scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
  name: '${applicationGroup.name}-${time}'
  params: {
    name: applicationGroup.name
    friendlyName: applicationGroup.friendlyName
    location: applicationGroup.location
    applicationGroupType: applicationGroup.applicationGroupType
    hostpoolName: hostPoolName
    tags: tags
    applications: (applicationGroup.applicationGroupType == 'RemoteApp')  ? varRAppApplicationGroupsApps : []
    roleAssignments: (!empty(applicationGroupIdentitiesIds) && applicationGroup.createRoleAssignment) ? [
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
