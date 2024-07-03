metadata name = 'AVD LZA management plane'
metadata description = 'This module deploys AVD workspace, host pool, application group scaling plan'
metadata owner = 'Azure/avdaccelerator'

targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@sys.description('Location where to deploy AVD management plane.')
param managementPlaneLocation string

@sys.description('AVD workload subscription ID, multiple subscriptions scenario.')
param subscriptionId string

@sys.description('Virtual machine time zone.')
param computeTimeZone string

@sys.description('The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@sys.description('Identity ID to grant RBAC role to access AVD application group.')
param securityPrincipalId string

@sys.description('AVD OS image source.')
param osImage string

@sys.description('Resource ID of keyvault that will contain host pool registration token.')
param keyVaultResourceId string

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
var varHostPoolRdpPropertiesDomainServiceCheck = (identityServiceProvider == 'EntraID') ? '${hostPoolRdpProperties};targetisaadjoined:i:1;enablerdsaadauth:i:1' : hostPoolRdpProperties
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
    friendlyName: 'Word'
    showInPortal: true
    filePath: 'C:\\Program Files\\Microsoft Office\\root\\Office16\\WINWORD.EXE'
  }
  {
    name: 'Microsoft Outlook'
    description: 'Microsoft Word'
    friendlyName: 'Outlook'
    showInPortal: true
    filePath: 'C:\\Program Files\\Microsoft Office\\root\\Office16\\OUTLOOK.EXE'
  }
]: []
var varRAppApplicationGroupsApps = (preferredAppGroupType == 'RailApplications') ? ((contains(osImage, 'office')) ? union(varRAppApplicationGroupsStandardApps, varRAppApplicationGroupsOfficeApps) : varRAppApplicationGroupsStandardApps) : []
var varDiagnosticSettings = !empty(alaWorkspaceResourceId) ? [
  {
    workspaceResourceId: alaWorkspaceResourceId
  }
]: []

// =========== //
// Deployments Commercial//
// =========== //
// Hostpool creation.
module hostPool '../../../../avm/1.0.0/res/desktop-virtualization/host-pool/main.bicep' = {
  scope: resourceGroup('${subscriptionId}', '${serviceObjectsRgName}')
  name: 'HostPool-${time}'
  params: {
    name: hostPoolName
    friendlyName: hostPoolFriendlyName
    location: managementPlaneLocation
    hostPoolType: hostPoolType
    startVMOnConnect: startVmOnConnect
    customRdpProperty: varHostPoolRdpPropertiesDomainServiceCheck
    loadBalancerType: hostPoolLoadBalancerType
    maxSessionLimit: hostPoolMaxSessions
    preferredAppGroupType: preferredAppGroupType
    personalDesktopAssignmentType: personalAssignType
    keyVaultResourceId: keyVaultResourceId
    tags: tags
    diagnosticSettings: varDiagnosticSettings
    agentUpdate: !empty(hostPoolAgentUpdateSchedule) ? {
        maintenanceWindows: hostPoolAgentUpdateSchedule
        maintenanceWindowTimeZone: computeTimeZone
        type: 'Scheduled'
        useSessionHostLocalTime: true
    }: {}
  }
}

// Application groups.
module applicationGroups '../../../../avm/1.0.0/res/desktop-virtualization/application-group/main.bicep' = [for applicationGroup in varApplicaitonGroups: {
  scope: resourceGroup('${subscriptionId}', '${serviceObjectsRgName}')
  name: '${applicationGroup.name}-${time}'
  params: {
    name: applicationGroup.name
    friendlyName: applicationGroup.friendlyName
    location: applicationGroup.location
    applicationGroupType: applicationGroup.applicationGroupType
    hostpoolName: hostPoolName
    tags: tags
    applications: (applicationGroup.applicationGroupType == 'RemoteApp')  ? varRAppApplicationGroupsApps : []
    roleAssignments: !empty(securityPrincipalId) ? [
      {      
        roleDefinitionIdOrName: 'Desktop Virtualization User'
        principalId: securityPrincipalId
      }
    ]: []
    diagnosticSettings: varDiagnosticSettings
  }
  dependsOn: [
    hostPool
  ]
}]

// Workspace.
module workSpace '../../../../avm/1.0.0/res/desktop-virtualization/workspace/main.bicep' = {
  scope: resourceGroup('${subscriptionId}', '${serviceObjectsRgName}')
  name: 'Workspace-${time}'
  params: {
      name: workSpaceName
      friendlyName: workSpaceFriendlyName
      location: managementPlaneLocation
      applicationGroupReferences: [
        '/subscriptions/${subscriptionId}/resourceGroups/${serviceObjectsRgName}/providers/Microsoft.DesktopVirtualization/applicationgroups/${applicationGroupName}'
      ]
      tags: tags
      diagnosticSettings: varDiagnosticSettings
  }
  dependsOn: [
    hostPool
    applicationGroups
  ]
}

// Scaling plan.
module scalingPlan '../../../../avm/1.0.0/res/desktop-virtualization/scaling-plan/main.bicep' =  if (deployScalingPlan)  {
  scope: resourceGroup('${subscriptionId}', '${serviceObjectsRgName}')
  name: 'Scaling-Plan-${time}'
  params: {
      name:scalingPlanName
      location: managementPlaneLocation
      hostPoolType: hostPoolType
      exclusionTag: scalingPlanExclusionTag
      timeZone: computeTimeZone
      schedules: scalingPlanSchedules
      hostPoolReferences: [
        {
        hostPoolArmPath: '/subscriptions/${subscriptionId}/resourceGroups/${serviceObjectsRgName}/providers/Microsoft.DesktopVirtualization/hostpools/${hostPoolName}'
        scalingPlanEnabled: true
        }
      ]
      tags: tags
      diagnosticSettings: varDiagnosticSettings
  }
  dependsOn: [
    hostPool
    applicationGroups
    workSpace
  ]
}
