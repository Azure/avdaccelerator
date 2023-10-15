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
param securityPrincipalIds array

@sys.description('AVD OS image source.')
param osImage string

@sys.description('AVD Resource Group Name for the service objects.')
param serviceObjectsRgName string

@sys.description('AVD Application group for the session hosts. Desktop type.')
param applicationGroupName string

@sys.description('AVD Application group for the session hosts. Desktop type (friendly name).')
param applicationGroupFriendlyNameDesktop string

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

@sys.description('Optional. The type of preferred application group type, default to Desktop Application Group.')
@allowed([
  'Desktop'
  'None'
  'RailApplications'
])
param preferredAppGroupType string = 'Desktop'

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

@sys.description('Optional. AVD host pool start VM on Connect.')
param hostPoolAgentUpdateSchedule array

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Tag to exclude resources from scaling plan.')
param scalingPlanExclusionTag string

@sys.description('Log analytics workspace for diagnostic logs.')
param alaWorkspaceResourceId string

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var varApplicaitonGroups = [
  {
    name: applicationGroupName
    friendlyName: applicationGroupFriendlyNameDesktop
    location: managementPlaneLocation
    applicationGroupType: (preferredAppGroupType == 'Desktop') ? 'Desktop' : 'RemoteApp'
  }
]
var varHostPoolRdpPropertiesDomainServiceCheck = (identityServiceProvider == 'AAD') ? '${hostPoolRdpProperties};targetisaadjoined:i:1;enablerdsaadauth:i:1' : hostPoolRdpProperties
var varRAppApplicationGroupsStandardApps = (preferredAppGroupType == 'RailApplications') ? [
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
]: []
var varRAppApplicationGroupsOfficeApps = (preferredAppGroupType == 'RailApplications') ? [
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
]: []
var varRAppApplicationGroupsApps = (preferredAppGroupType == 'RailApplications') ? ((contains(osImage, 'office')) ? union(varRAppApplicationGroupsStandardApps, varRAppApplicationGroupsOfficeApps) : varRAppApplicationGroupsStandardApps) : []
var varHostPoolDiagnostic = [
  'allLogs'
]
var varApplicationGroupDiagnostic = [
  'allLogs'
]
var varWorkspaceDiagnostic = [
  'allLogs'
]
var varScalingPlanDiagnostic = [
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
    preferredAppGroupType: preferredAppGroupType
    personalDesktopAssignmentType: personalAssignType
    tags: tags
    diagnosticWorkspaceId: alaWorkspaceResourceId
    diagnosticLogCategoriesToEnable: varHostPoolDiagnostic
    agentUpdate: !empty(hostPoolAgentUpdateSchedule) ? {
        maintenanceWindows: hostPoolAgentUpdateSchedule
        maintenanceWindowTimeZone: computeTimeZone
        type: 'Scheduled'
        useSessionHostLocalTime: true
    }: {}
  }
}

// Application groups.
module applicationGroups '../../../../carml/1.3.0/Microsoft.DesktopVirtualization/applicationgroups/deploy.bicep' = [for applicationGroup in varApplicaitonGroups: {
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
    roleAssignments: !empty(securityPrincipalIds) ? [
      {
      roleDefinitionIdOrName: 'Desktop Virtualization User'
      principalIds: securityPrincipalIds
      principalType: 'Group'
      }
    ]: []   
    diagnosticWorkspaceId: alaWorkspaceResourceId
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
      appGroupResourceIds: [
        '/subscriptions/${workloadSubsId}/resourceGroups/${serviceObjectsRgName}/providers/Microsoft.DesktopVirtualization/applicationgroups/${applicationGroupName}'
      ]
      tags: tags
      diagnosticWorkspaceId: alaWorkspaceResourceId
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
