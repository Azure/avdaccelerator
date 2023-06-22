targetScope = 'subscription'

/*   TO BE ADDED
@description('Determine if you would like to set all deployed alerts to auto-resolve.')
param SetAutoResolve bool = true

@description('Determine if you would like to enable all the alerts after deployment.')
param SetEnabled bool = false
 */

@description('Location of needed scripts to deploy solution.')
// param _ArtifactsLocation string = 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/scripts/alerts/'
param _ArtifactsLocation string = 'https://raw.githubusercontent.com/JCoreMS/avdaccelerator/main/workload/scripts/alerts/'

@description('SaS token if needed for script location.')
@secure()
param _ArtifactsLocationSasToken string = ''

@description('Alert Name Prefix (Dash will be added after prefix for you.)')
param AlertNamePrefix string = 'AVD'

@description('The Distribution Group that will receive email alerts for AVD.')
param DistributionGroup string

@allowed([
  'd'
  'p'
  't'
])
@description('The environment is which these resources will be deployed, i.e. Test, Production, Development.')
param Environment string = 't'

@description('Comma seperated string of Host Pool IDs')
param HostPools array

@description('Azure Region for Resources.')
param Location string = deployment().location

@description('The Resource ID for the Log Analytics Workspace.')
param LogAnalyticsWorkspaceResourceId string

@description('Resource Group to deploy the Alerts Solution in.')
param ResourceGroupName string

@description('Flag to determine if a new resource group needs to be created.')
@allowed([
  'New'
  'Existing'
])
param ResourceGroupStatus string

@description('The Resource Group ID for the AVD session host VMs.')
param SessionHostsResourceGroupIds array = []

@description('The Resource IDs for the Azure Files Storage Accounts used for FSLogix profile storage.')
param StorageAccountResourceIds array = []

@description('ISO 8601 timestamp used for the deployment names and the Automation runbook schedule.')
param time string = utcNow()

@description('The Resource IDs for the Azure NetApp Volumes used for FSLogix profile storage.')
param ANFVolumeResourceIds array = []

param Tags object = {}

var ActionGroupName = 'ag-avdmetrics-${Environment}-${Location}'
var AlertDescriptionHeader = 'Automated AVD Alert Deployment Solution (v2.0.1)\n'
var AutomationAccountName = 'aa-avdmetrics-${Environment}-${Location}'
var CloudEnvironment = environment().name
var HostPoolSubIdsAll = [for item in HostPools: split(item, '/')[2]]
var HostPoolSubIds = union(HostPoolSubIdsAll, [])
var HostPoolRGsAll = [for item in HostPools: split(item, '/')[4]]
var HostPoolRGs = union(HostPoolRGsAll, [])
var ResourceGroupCreate = ResourceGroupStatus == 'New' ? true : false
var RunbookNameGetStorage = 'AvdStorageLogData'
var RunbookNameGetHostPool = 'AvdHostPoolLogData'
var RunbookScriptGetStorage = 'Get-StorAcctInfov2.ps1'
var RunbookScriptGetHostPool = 'Get-HostPoolInfo.ps1'
var SessionHostRGsAll = [for item in SessionHostsResourceGroupIds: split(item, '/')[4]]
var SessionHostRGs = union(SessionHostRGsAll, [])
var StorAcctRGsAll = [for item in StorageAccountResourceIds: split(item, '/')[4]]
var StorAcctRGs = union(StorAcctRGsAll, [])
var UsrManagedIdentityName = 'id-ds-avdAlerts-Deployment'

var DesktopReadRoleRGs = union(HostPoolRGs, SessionHostRGs)

var RoleAssignments = {
  DesktopVirtualizationRead: {
    Name: 'Desktop-Virtualization-Reader'
    GUID: '49a72310-ab8d-41df-bbb0-79b649203868'
  }
  StoreAcctContrib: {
    Name: 'Storage-Account-Contributor'
    GUID: '17d1049b-9a84-46fb-8f53-869881c3d3ab'
  }
  LogAnalyticsContributor: {
    Name: 'LogAnalytics-Contributor'
    GUID: '92aaf0da-9dab-42b6-94a3-d43ce8d16293'
  }
}
// '49a72310-ab8d-41df-bbb0-79b649203868'  // Desktop Virtualization Reader
// '17d1049b-9a84-46fb-8f53-869881c3d3ab'  // Storage Account Contributor
// '92aaf0da-9dab-42b6-94a3-d43ce8d16293'  // Log Analtyics Contributor - allows writing to workspace for Host Pool and Storage Logic Apps

var LogAlertsHostPool = [
  {// Based on Runbook script Output to LAW
    name: '${AlertNamePrefix}-HP-Cap-85Prcnt-xHostPoolNamex'
    displayName: '${AlertNamePrefix}-HostPool-Capacity 85% (xHostPoolNamex)'
    description: '${AlertDescriptionHeader}This alert is based on the Action Account and Runbook that populates the Log Analytics specificed with the AVD Metrics Deployment Solution.\n-->Last Number in the string is the Percentage Remaining for the Host Pool\nOutput is:\nHostPoolName|ResourceGroup|Type|MaxSessionLimit|NumberHosts|TotalUsers|DisconnectedUser|ActiveUsers|SessionsAvailable|HostPoolPercentageLoad'
    severity: 2
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    overrideQueryTimeRange: 'P2D'
    criteria: {
      allOf: [
        {
          query: '''
          AzureDiagnostics 
          | where Category has "JobStreams" and StreamType_s == "Output" and RunbookName_s == "AvdHostPoolLogData"
          | sort by TimeGenerated
          | where TimeGenerated > now() - 5m
          | extend HostPoolName=tostring(split(ResultDescription, '|')[0])
          | extend ResourceGroup=tostring(split(ResultDescription, '|')[1])
          | extend Type=tostring(split(ResultDescription, '|')[2])
          | extend MaxSessionLimit=toint(split(ResultDescription, '|')[3])
          | extend NumberSessionHosts=toint(split(ResultDescription, '|')[4])
          | extend UserSessionsTotal=toint(split(ResultDescription, '|')[5])
          | extend UserSessionsDisconnected=toint(split(ResultDescription, '|')[6])
          | extend UserSessionsActive=toint(split(ResultDescription, '|')[7])
          | extend UserSessionsAvailable=toint(split(ResultDescription, '|')[8])
          | extend HostPoolPercentLoad=toint(split(ResultDescription, '|')[9])
          | where HostPoolPercentLoad >= 85 and HostPoolPercentLoad < 95
          | where HostPoolName == 'xHostPoolNamex'
           '''
          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'HostPoolName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'UserSessionsTotal'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'UserSessionsDisconnected'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'UserSessionsActive'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'UserSessionsAvailable'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'HostPoolPercentLoad'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          resourceIdColumng: '_ResourceId'
          operator: 'GreaterThanOrEqual'
          threshold: 1
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
  {// Based on Runbook script Output to LAW
    name: '${AlertNamePrefix}-HP-Cap-50Prcnt-xHostPoolNamex'
    displayName: '${AlertNamePrefix}-HostPool-Capacity 50% (xHostPoolNamex)'
    description: '${AlertDescriptionHeader}This alert is based on the Action Account and Runbook that populates the Log Analytics specificed with the AVD Metrics Deployment Solution.\n-->Last Number in the string is the Percentage Remaining for the Host Pool\nOutput is:\nHostPoolName|ResourceGroup|Type|MaxSessionLimit|NumberHosts|TotalUsers|DisconnectedUser|ActiveUsers|SessionsAvailable|HostPoolPercentageLoad'
    severity: 3
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    overrideQueryTimeRange: 'P2D'
    criteria: {
      allOf: [
        {
          query: '''
          AzureDiagnostics 
          | where Category has "JobStreams" and StreamType_s == "Output" and RunbookName_s == "AvdHostPoolLogData"
          | sort by TimeGenerated
          | where TimeGenerated > now() - 5m
          | extend HostPoolName=tostring(split(ResultDescription, '|')[0])
          | extend ResourceGroup=tostring(split(ResultDescription, '|')[1])
          | extend Type=tostring(split(ResultDescription, '|')[2])
          | extend MaxSessionLimit=toint(split(ResultDescription, '|')[3])
          | extend NumberSessionHosts=toint(split(ResultDescription, '|')[4])
          | extend UserSessionsTotal=toint(split(ResultDescription, '|')[5])
          | extend UserSessionsDisconnected=toint(split(ResultDescription, '|')[6])
          | extend UserSessionsActive=toint(split(ResultDescription, '|')[7])
          | extend UserSessionsAvailable=toint(split(ResultDescription, '|')[8])
          | extend HostPoolPercentLoad=toint(split(ResultDescription, '|')[9])
          | where HostPoolPercentLoad >= 50 and HostPoolPercentLoad < 85
          | where HostPoolName == 'xHostPoolNamex'         
           '''
          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'HostPoolName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'UserSessionsTotal'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'UserSessionsDisconnected'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'UserSessionsActive'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'UserSessionsAvailable'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'HostPoolPercentLoad'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          resourceIdColumng: '_ResourceId'
          operator: 'GreaterThanOrEqual'
          threshold: 1
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
  {// Based on Runbook script Output to LAW
    name: '${AlertNamePrefix}-HP-Cap-95Prcnt-xHostPoolNamex'
    displayName: '${AlertNamePrefix}-HostPool-Capacity 95% (xHostPoolNamex)'
    description: '${AlertDescriptionHeader}This alert is based on the Action Account and Runbook that populates the Log Analytics specificed with the AVD Metrics Deployment Solution.\n-->Last Number in the string is the Percentage Remaining for the Host Pool\nOutput is:\nHostPoolName|ResourceGroup|Type|MaxSessionLimit|NumberHosts|TotalUsers|DisconnectedUser|ActiveUsers|SessionsAvailable|HostPoolPercentageLoad'
    severity: 1
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    overrideQueryTimeRange: 'P2D'
    criteria: {
      allOf: [
        {
          query: '''
          AzureDiagnostics 
          | where Category has "JobStreams" and StreamType_s == "Output" and RunbookName_s == "AvdHostPoolLogData"
          | sort by TimeGenerated
          | where TimeGenerated > now() - 5m
          | extend HostPoolName=tostring(split(ResultDescription, '|')[0])
          | extend ResourceGroup=tostring(split(ResultDescription, '|')[1])
          | extend Type=tostring(split(ResultDescription, '|')[2])
          | extend MaxSessionLimit=toint(split(ResultDescription, '|')[3])
          | extend NumberSessionHosts=toint(split(ResultDescription, '|')[4])
          | extend UserSessionsTotal=toint(split(ResultDescription, '|')[5])
          | extend UserSessionsDisconnected=toint(split(ResultDescription, '|')[6])
          | extend UserSessionsActive=toint(split(ResultDescription, '|')[7])
          | extend UserSessionsAvailable=toint(split(ResultDescription, '|')[8])
          | extend HostPoolPercentLoad=toint(split(ResultDescription, '|')[9])
          | where HostPoolPercentLoad >= 95 
          | where HostPoolName == 'xHostPoolNamex'        
           '''
          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'HostPoolName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'UserSessionsTotal'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'UserSessionsDisconnected'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'UserSessionsActive'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'UserSessionsAvailable'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'HostPoolPercentLoad'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          resourceIdColumng: '_ResourceId'
          operator: 'GreaterThanOrEqual'
          threshold: 1
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
  {
    name: '${AlertNamePrefix}-HP-NoResAvail-xHostPoolNamex'
    displayName: '${AlertNamePrefix}-HostPool-No Resources Available (xHostPoolNamex)'
    description: AlertDescriptionHeader
    severity: 1
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    overrideQueryTimeRange: 'P2D'
    criteria: {
      allOf: [
        {
          query: 'WVDConnections \n| where TimeGenerated > ago (15m) \n| where _ResourceId contains "xHostPoolNamex" \n| project-away TenantId,SourceSystem  \n| summarize arg_max(TimeGenerated, *), StartTime =  min(iff(State== \'Started\', TimeGenerated , datetime(null) )), ConnectTime = min(iff(State== \'Connected\', TimeGenerated , datetime(null) ))   by CorrelationId  \n| join kind=leftouter (WVDErrors\n    |summarize Errors=makelist(pack(\'Code\', Code, \'CodeSymbolic\', CodeSymbolic, \'Time\', TimeGenerated, \'Message\', Message ,\'ServiceError\', ServiceError, \'Source\', Source)) by CorrelationId  \n    ) on CorrelationId\n| join kind=leftouter (WVDCheckpoints\n    | summarize Checkpoints=makelist(pack(\'Time\', TimeGenerated, \'Name\', Name, \'Parameters\', Parameters, \'Source\', Source)) by CorrelationId  \n    | mv-apply Checkpoints on (  \n        order by todatetime(Checkpoints[\'Time\']) asc\n        | summarize Checkpoints=makelist(Checkpoints)\n        )\n    ) on CorrelationId  \n| project-away CorrelationId1, CorrelationId2  \n| order by TimeGenerated desc\n| where Errors[0].CodeSymbolic == "ConnectionFailedNoHealthyRdshAvailable"\n\n'
          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'UserName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'SessionHostName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          operator: 'GreaterThanOrEqual'
          threshold: 1
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
  {
    name: '${AlertNamePrefix}-HP-DiscUser24Hrs-xHostPoolNamex'
    displayName: '${AlertNamePrefix}-HostPool-Disconnected User over 24 Hours (xHostPoolNamex)'
    description: AlertDescriptionHeader
    severity: 2
    evaluationFrequency: 'PT1H'
    windowSize: 'PT1H'
    overrideQueryTimeRange: 'P2D'
    criteria: {
      allOf: [
        {
          query: '// Session duration \n// Lists users by session duration in the last 24 hours. \n// The "State" provides information on the connection stage of an activity.\n// The delta between "Connected" and "Completed" provides the connection time for a specific connection.\nWVDConnections \n| where TimeGenerated > ago(24h) \n| where State == "Connected" \n| where _ResourceId contains "xHostPoolNamex" \n| project CorrelationId , UserName, ConnectionType, StartTime=TimeGenerated, SessionHostName\n| join (WVDConnections  \n    | where State == "Completed"  \n    | project EndTime=TimeGenerated, CorrelationId)  \n    on CorrelationId  \n| project Duration = EndTime - StartTime, ConnectionType, UserName, SessionHostName\n| where Duration >= timespan(24:00:00)\n| sort by Duration desc'
          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'UserName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'SessionHostName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          operator: 'GreaterThanOrEqual'
          threshold: 1
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
  {
    name: '${AlertNamePrefix}-HP-DiscUser72Hrs-xHostPoolNamex'
    displayName: '${AlertNamePrefix}-HostPool-Disconnected User over 72 Hours (xHostPoolNamex)'
    description: AlertDescriptionHeader
    severity: 1
    evaluationFrequency: 'PT1H'
    windowSize: 'PT1H'
    overrideQueryTimeRange: 'P2D'
    criteria: {
      allOf: [
        {
          query: '// Session duration \n// Lists users by session duration in the last 24 hours. \n// The "State" provides information on the connection stage of an activity.\n// The delta between "Connected" and "Completed" provides the connection time for a specific connection.\nWVDConnections \n| where TimeGenerated > ago(24h) \n| where State == "Connected" \n| where _ResourceId contains "xHostPoolNamex"  \n| project CorrelationId , UserName, ConnectionType, StartTime=TimeGenerated, SessionHostName\n| join (WVDConnections  \n    | where State == "Completed"  \n    | project EndTime=TimeGenerated, CorrelationId)  \n    on CorrelationId  \n| project Duration = EndTime - StartTime, ConnectionType, UserName, SessionHostName\n| where Duration >= timespan(72:00:00)\n| sort by Duration desc'
          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'UserName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'SessionHostName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          operator: 'GreaterThanOrEqual'
          threshold: 1
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
  {
    name: '${AlertNamePrefix}-HP-VM-LocDskFree10Prcnt-xHostPoolNamex'
    displayName: '${AlertNamePrefix}-HostPool-VM-Local Disk Free Space 10 Percent (xHostPoolNamex)'
    description: AlertDescriptionHeader
    severity: 2
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    overrideQueryTimeRange: 'P2D'
    criteria: {
      allOf: [
        {
          query: '''
          Perf
          | where TimeGenerated > ago(15m)
          | where ObjectName == "LogicalDisk" and CounterName == "% Free Space"
          | where InstanceName !contains "D:"
          | where InstanceName  !contains "_Total"| where CounterValue <= 10.00
          | parse _ResourceId with "/subscriptions/" subscription "/resourcegroups/" ResourceGroup "/providers/microsoft.compute/virtualmachines/" ComputerName
          | project ComputerName, CounterValue, subscription, ResourceGroup, TimeGenerated
          | join kind = leftouter
          (
              WVDAgentHealthStatus
              | where TimeGenerated > ago(15m)
              | where _ResourceId contains "xHostPoolNamex"
              | parse _ResourceId with "/subscriptions/" subscriptionAgentHealth "/resourcegroups/" ResourceGroupAgentHealth "/providers/microsoft.desktopvirtualization/hostpools/" HostPool
              | parse SessionHostResourceId with "/subscriptions/" VMsubscription "/resourceGroups/" VMresourceGroup "/providers/Microsoft.Compute/virtualMachines/" ComputerName
              | project VMresourceGroup, ComputerName, HostPool
              ) on ComputerName
          '''
          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'ComputerName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'VMresourceGroup'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'HostPool'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          operator: 'GreaterThanOrEqual'
          threshold: 1
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
  {
    name: '${AlertNamePrefix}-HP-VM-LocDskFree5Prcnt-xHostPoolNamex'
    displayName: '${AlertNamePrefix}-HostPool-VM-Local Disk Free Space 5 Percent (xHostPoolNamex)'
    description: AlertDescriptionHeader
    severity: 1
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    overrideQueryTimeRange: 'P2D'
    criteria: {
      allOf: [
        {
          query: '''
          Perf
          | where TimeGenerated > ago(15m)
          | where ObjectName == "LogicalDisk" and CounterName == "% Free Space"
          | where InstanceName !contains "D:"
          | where InstanceName  !contains "_Total"| where CounterValue <= 5.00
          | parse _ResourceId with "/subscriptions/" subscription "/resourcegroups/" ResourceGroup "/providers/microsoft.compute/virtualmachines/" ComputerName
          | project ComputerName, CounterValue, subscription, ResourceGroup, TimeGenerated
          | join kind = leftouter
          (
              WVDAgentHealthStatus
              | where TimeGenerated > ago(15m)
              | where _ResourceId contains "xHostPoolNamex"
              | parse _ResourceId with "/subscriptions/" subscriptionAgentHealth "/resourcegroups/" ResourceGroupAgentHealth "/providers/microsoft.desktopvirtualization/hostpools/" HostPool
              | parse SessionHostResourceId with "/subscriptions/" VMsubscription "/resourceGroups/" VMresourceGroup "/providers/Microsoft.Compute/virtualMachines/" ComputerName
              | project VMresourceGroup, ComputerName, HostPool
              ) on ComputerName
          '''
          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'ComputerName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'VMresourceGroup'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'HostPool'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          operator: 'GreaterThanOrEqual'
          threshold: 1
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
  {
    name: '${AlertNamePrefix}-HP-VM-FSLgxProf5PrcntFree-xHostPoolNamex'
    displayName: '${AlertNamePrefix}-HostPool-VM-FSLogix Profile Less Than 5% Free Space (xHostPoolNamex)'
    description: AlertDescriptionHeader
    severity: 2
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    overrideQueryTimeRange: 'P2D'
    criteria: {
      allOf: [
        {
          query: 'Event\n| where EventLog == "Microsoft-FSLogix-Apps/Admin"\n| where EventLevelName == "Warning"\n| where EventID == 34\n| where _ResourceId contains "xHostPoolNamex"\n| parse _ResourceId with "/subscriptions/" subscription "/resourcegroups/" ResourceGroup "/providers/microsoft.compute/virtualmachines/" ComputerName\n| project ComputerName, RenderedDescription, subscription, ResourceGroup, TimeGenerated\n| join kind = leftouter\n    (\n    WVDAgentHealthStatus\n   // | where TimeGenerated > ago(15m)\n    | parse _ResourceId with "/subscriptions/" subscriptionAgentHealth "/resourcegroups/" ResourceGroupAgentHealth "/providers/microsoft.desktopvirtualization/hostpools/" HostPool\n    | parse SessionHostResourceId with "/subscriptions/" VMsubscription "/resourceGroups/" VMresourceGroup "/providers/Microsoft.Compute/virtualMachines/" ComputerName\n    | project VMresourceGroup, ComputerName, HostPool\n    )\n    on ComputerName\n\n'
          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'ComputerName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'RenderedDescription'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'VMresourceGroup'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'HostPool'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          operator: 'GreaterThanOrEqual'
          threshold: 1
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
  {
    name: '${AlertNamePrefix}-HP-VM-FSLgxProf2PrcntFree-xHostPoolNamex'
    displayName: '${AlertNamePrefix}-HostPool-VM-FSLogix Profile Less Than 2% Free Space (xHostPoolNamex)'
    description: AlertDescriptionHeader
    severity: 1
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    overrideQueryTimeRange: 'P2D'
    criteria: {
      allOf: [
        {
          query: 'Event\n| where EventLog == "Microsoft-FSLogix-Apps/Admin"\n| where EventLevelName == "Error"\n| where EventID == 33\n| where _ResourceId contains "xHostPoolNamex"\n| parse _ResourceId with "/subscriptions/" subscription "/resourcegroups/" ResourceGroup "/providers/microsoft.compute/virtualmachines/" ComputerName\n| project ComputerName, RenderedDescription, subscription, ResourceGroup, TimeGenerated\n| join kind = leftouter\n    (\n    WVDAgentHealthStatus\n   // | where TimeGenerated > ago(15m)\n    | parse _ResourceId with "/subscriptions/" subscriptionAgentHealth "/resourcegroups/" ResourceGroupAgentHealth "/providers/microsoft.desktopvirtualization/hostpools/" HostPool\n    | parse SessionHostResourceId with "/subscriptions/" VMsubscription "/resourceGroups/" VMresourceGroup "/providers/Microsoft.Compute/virtualMachines/" ComputerName\n    | project VMresourceGroup, ComputerName, HostPool\n    )\n    on ComputerName\n\n'
          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'ComputerName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'RenderedDescription'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'VMresourceGroup'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'HostPool'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          operator: 'GreaterThanOrEqual'
          threshold: 1
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
  {
    name: '${AlertNamePrefix}-HP-VM-FSLgxProf-NetwrkIssue-xHostPoolNamex'
    displayName: '${AlertNamePrefix}-HostPool-VM-FSLogix Profile Failed due to Network Issue (xHostPoolNamex)'
    description: AlertDescriptionHeader
    severity: 1
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    overrideQueryTimeRange: 'P2D'
    criteria: {
      allOf: [
        {
          query: 'Event\n| where EventLog == "Microsoft-FSLogix-Apps/Admin"\n| where EventLevelName == "Error"\n| where EventID == 43\n| where _ResourceId contains "xHostPoolNamex"\n| parse _ResourceId with "/subscriptions/" subscription "/resourcegroups/" ResourceGroup "/providers/microsoft.compute/virtualmachines/" ComputerName\n| project ComputerName, RenderedDescription, subscription, ResourceGroup, TimeGenerated\n| join kind = leftouter\n    (\n    WVDAgentHealthStatus\n   // | where TimeGenerated > ago(15m)\n    | parse _ResourceId with "/subscriptions/" subscriptionAgentHealth "/resourcegroups/" ResourceGroupAgentHealth "/providers/microsoft.desktopvirtualization/hostpools/" HostPool\n    | parse SessionHostResourceId with "/subscriptions/" VMsubscription "/resourceGroups/" VMresourceGroup "/providers/Microsoft.Compute/virtualMachines/" ComputerName\n    | project VMresourceGroup, ComputerName, HostPool\n    )\n    on ComputerName\n\n'

          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'ComputerName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'RenderedDescription'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'VMresourceGroup'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'HostPool'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          operator: 'GreaterThanOrEqual'
          threshold: 1
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
  {
    name: '${AlertNamePrefix}-HP-VM-FSLgxProf-FailAttVHD-xHostPoolNamex'
    displayName: '${AlertNamePrefix}-HostPool-VM-FSLogix Profile Disk Failed to Attach (xHostPoolNamex)'
    description: AlertDescriptionHeader
    severity: 1
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    overrideQueryTimeRange: 'P2D'
    criteria: {
      allOf: [
        {
          query: 'Event\n| where EventLog == "Microsoft-FSLogix-Apps/Admin"\n| where EventLevelName == "Error"\n| where EventID == 52 or EventID == 40\n| where _ResourceId contains "xHostPoolNamex"\n| parse _ResourceId with "/subscriptions/" subscription "/resourcegroups/" ResourceGroup "/providers/microsoft.compute/virtualmachines/" ComputerName\n| project ComputerName, RenderedDescription, subscription, ResourceGroup, TimeGenerated\n| join kind = leftouter\n    (\n    WVDAgentHealthStatus\n   // | where TimeGenerated > ago(15m)\n    | parse _ResourceId with "/subscriptions/" subscriptionAgentHealth "/resourcegroups/" ResourceGroupAgentHealth "/providers/microsoft.desktopvirtualization/hostpools/" HostPool\n    | parse SessionHostResourceId with "/subscriptions/" VMsubscription "/resourceGroups/" VMresourceGroup "/providers/Microsoft.Compute/virtualMachines/" ComputerName\n    | project VMresourceGroup, ComputerName, HostPool\n    )\n    on ComputerName\n\n'
          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'ComputerName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'RenderedDescription'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'VMresourceGroup'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'HostPool'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          operator: 'GreaterThanOrEqual'
          threshold: 1
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
  {
    name: '${AlertNamePrefix}-HP-VM-FSLgxProf-SvcDisabled-xHostPoolNamex'
    displayName: '${AlertNamePrefix}-HostPool-VM-FSLogix Profile Service Disabled (xHostPoolNamex)'
    description: AlertDescriptionHeader
    severity: 1
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    overrideQueryTimeRange: 'P2D'
    criteria: {
      allOf: [
        {
          query: 'Event\n| where EventLog == "Microsoft-FSLogix-Apps/Admin"\n| where EventLevelName == "Warning"\n| where EventID == 60\n| where _ResourceId contains "xHostPoolNamex"\n| parse _ResourceId with "/subscriptions/" subscription "/resourcegroups/" ResourceGroup "/providers/microsoft.compute/virtualmachines/" ComputerName\n| project ComputerName, RenderedDescription, subscription, ResourceGroup, TimeGenerated\n| join kind = leftouter\n    (\n    WVDAgentHealthStatus\n   // | where TimeGenerated > ago(15m)\n    | parse _ResourceId with "/subscriptions/" subscriptionAgentHealth "/resourcegroups/" ResourceGroupAgentHealth "/providers/microsoft.desktopvirtualization/hostpools/" HostPool\n    | parse SessionHostResourceId with "/subscriptions/" VMsubscription "/resourceGroups/" VMresourceGroup "/providers/Microsoft.Compute/virtualMachines/" ComputerName\n    | project VMresourceGroup, ComputerName, HostPool\n    )\n    on ComputerName\n\n'
          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'ComputerName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'RenderedDescription'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'VMresourceGroup'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'HostPool'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          operator: 'GreaterThanOrEqual'
          threshold: 1
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
  {
    name: '${AlertNamePrefix}-HP-VM-FSLgxProf-DskCompFailed-xHostPoolNamex'
    displayName: '${AlertNamePrefix}-HostPool-VM-FSLogix Profile Disk Compaction Failed (xHostPoolNamex)'
    description: AlertDescriptionHeader
    severity: 2
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    overrideQueryTimeRange: 'P2D'
    criteria: {
      allOf: [
        {
          query: 'Event\n| where EventLog == "Microsoft-FSLogix-Apps/Admin"\n| where EventLevelName == "Error"\n| where EventID == 62 or EventID == 63\n| where _ResourceId contains "xHostPoolNamex"\n| parse _ResourceId with "/subscriptions/" subscription "/resourcegroups/" ResourceGroup "/providers/microsoft.compute/virtualmachines/" ComputerName\n| project ComputerName, RenderedDescription, subscription, ResourceGroup, TimeGenerated\n| join kind = leftouter\n    (\n    WVDAgentHealthStatus\n   // | where TimeGenerated > ago(15m)\n    | parse _ResourceId with "/subscriptions/" subscriptionAgentHealth "/resourcegroups/" ResourceGroupAgentHealth "/providers/microsoft.desktopvirtualization/hostpools/" HostPool\n    | parse SessionHostResourceId with "/subscriptions/" VMsubscription "/resourceGroups/" VMresourceGroup "/providers/Microsoft.Compute/virtualMachines/" ComputerName\n    | project VMresourceGroup, ComputerName, HostPool\n    )\n    on ComputerName\n\n'
          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'ComputerName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'RenderedDescription'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'VMresourceGroup'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'HostPool'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          operator: 'GreaterThanOrEqual'
          threshold: 1
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
  {
    name: '${AlertNamePrefix}-HP-VM-FSLgxProf-DskInUse-xHostPoolNamex'
    displayName: '${AlertNamePrefix}-HostPool-VM-FSLogix Profile Disk Attached to another VM (xHostPoolNamex)'
    description: AlertDescriptionHeader
    severity: 2
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    overrideQueryTimeRange: 'P2D'
    criteria: {
      allOf: [
        {
          query: 'Event\n| where EventLog == "Microsoft-FSLogix-Apps/Operational"\n| where EventLevelName == "Warning"\n| where EventID == 51\n| where _ResourceId contains "xHostPoolNamex"\n| parse _ResourceId with "/subscriptions/" subscription "/resourcegroups/" ResourceGroup "/providers/microsoft.compute/virtualmachines/" ComputerName\n| project ComputerName, RenderedDescription, subscription, ResourceGroup, TimeGenerated\n| join kind = leftouter\n    (\n    WVDAgentHealthStatus\n   // | where TimeGenerated > ago(15m)\n    | parse _ResourceId with "/subscriptions/" subscriptionAgentHealth "/resourcegroups/" ResourceGroupAgentHealth "/providers/microsoft.desktopvirtualization/hostpools/" HostPool\n    | parse SessionHostResourceId with "/subscriptions/" VMsubscription "/resourceGroups/" VMresourceGroup "/providers/Microsoft.Compute/virtualMachines/" ComputerName\n    | project VMresourceGroup, ComputerName, HostPool\n    )\n    on ComputerName\n\n'
          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'ComputerName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'RenderedDescription'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'VMresourceGroup'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'HostPool'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          operator: 'GreaterThanOrEqual'
          threshold: 1
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
  {
    name: '${AlertNamePrefix}-HP-VM-HlthChkFailure-xHostPoolNamex'
    displayName: '${AlertNamePrefix}-HostPool-VM-Health Check Failure (xHostPoolNamex)'
    description: '${AlertDescriptionHeader}VM is available for use but one of the dependent resources is in a failed state for hostpool xHostPoolNamex'
    severity: 1
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    overrideQueryTimeRange: 'P2D'
    criteria: {
      allOf: [
        {
          query: '// HealthChecks of SessionHost \n// Renders a summary of SessionHost health status. \nlet MapToDesc = (idx: long) {\n    case(idx == 0, "DomainJoin",\n    idx == 1, "DomainTrust",\n    idx == 2, "FSLogix",\n    idx == 3, "SxSStack",\n    idx == 4, "URLCheck",\n    idx == 5, "GenevaAgent",\n    idx == 6, "DomainReachable",\n    idx == 7, "WebRTCRedirector",\n    idx == 8, "SxSStackEncryption",\n    idx == 9, "IMDSReachable",\n    idx == 10, "MSIXPackageStaging",\n    "InvalidIndex")\n};\nWVDAgentHealthStatus\n| where TimeGenerated > ago(10m)\n| where Status != \'Available\'\n| where AllowNewSessions = True\n| extend CheckFailed = parse_json(SessionHostHealthCheckResult)\n| mv-expand CheckFailed\n| where CheckFailed.AdditionalFailureDetails.ErrorCode != 0\n| extend HealthCheckName = tolong(CheckFailed.HealthCheckName)\n| extend HealthCheckResult = tolong(CheckFailed.HealthCheckResult)\n| extend HealthCheckDesc = MapToDesc(HealthCheckName)\n| where HealthCheckDesc != \'InvalidIndex\'\n| where _ResourceId contains "xHostPoolNamex"\n| parse _ResourceId with "/subscriptions/" subscription "/resourcegroups/" HostPoolResourceGroup "/providers/microsoft.desktopvirtualization/hostpools/" HostPool\n| parse SessionHostResourceId with "/subscriptions/" HostSubscription "/resourceGroups/" SessionHostRG " /providers/Microsoft.Compute/virtualMachines/" SessionHostName\n'
          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'SessionHostName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'HealthCheckDesc'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'HostPool'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'SessionHostRG'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          operator: 'GreaterThanOrEqual'
          threshold: 1
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
]

var LogAlertsStorage = [
  {// Based on Runbook script Output to LAW
    name: '${AlertNamePrefix}-StorLowSpaceAzFile-15PrcntRem'
    displayName: '${AlertNamePrefix}-Storage-Low Space on Azure File Share-15% Remaining'
    description: '${AlertDescriptionHeader}This alert is based on the Action Account and Runbook that populates the Log Analytics specificed with the AVD Metrics Deployment Solution.\nNOTE: The Runbook will FAIL if Networking for the storage account has anything other than "Enabled from all networks"\n-->Last Number in the string is the Percentage Remaining for the Share.\nOutput: ResultsDescription\nStorageType,Subscription,ResourceGroup,StorageAccount,ShareName,Quota,GBUsed,PercentRemaining'
    severity: 2
    evaluationFrequency: 'PT10M'
    windowSize: 'PT1H'
    overrideQueryTimeRange: 'P2D'
    criteria: {
      allOf: [
        {
          query: '''
          AzureDiagnostics 
          | where Category has "JobStreams" and StreamType_s == "Output" and RunbookName_s == "AvdStorageLogData"
          | sort by TimeGenerated
          //  StorageType / Subscription / RG / StorAcct / Share / Quota / GB Used / %Available
          | extend StorageType=split(ResultDescription, ',')[0]
          | extend Subscription=split(ResultDescription, ',')[1]
          | extend ResourceGroup=split(ResultDescription, ',')[2]
          | extend StorageAccount=split(ResultDescription, ',')[3]
          | extend Share=split(ResultDescription, ',')[4]
          | extend GBShareQuota=split(ResultDescription, ',')[5]
          | extend GBUsed=split(ResultDescription, ',')[6]
          | extend PercentAvailable=split(ResultDescription, ',')[7]
          | where PercentAvailable <= 15.00 and PercentAvailable < 5.00          
           '''
          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'ResultDescription'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          resourceIdColumng: '_ResourceId'
          operator: 'GreaterThanOrEqual'
          threshold: 1
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
  {// Based on Runbook script Output to LAW
    name: '${AlertNamePrefix}-StorLowSpaceAzFile-5PrcntRem'
    displayName: '${AlertNamePrefix}-Storage-Low Space on Azure File Share-5% Remaining'
    description: '${AlertDescriptionHeader}This alert is based on the Action Account and Runbook that populates the Log Analytics specificed with the AVD Metrics Deployment Solution.\nNOTE: The Runbook will FAIL if Networking for the storage account has anything other than "Enabled from all networks"\n-->Last Number in the string is the Percentage Remaining for the Share.\nOutput: ResultsDescription\nStorageType,Subscription,ResourceGroup,StorageAccount,ShareName,Quota,GBUsed,PercentRemaining'
    severity: 1
    evaluationFrequency: 'PT10M'
    windowSize: 'PT1H'
    overrideQueryTimeRange: 'P2D'
    criteria: {
      allOf: [
        {
          query: '''
          AzureDiagnostics 
          | where Category has "JobStreams" and StreamType_s == "Output" and RunbookName_s == "AvdStorageLogData"
          | sort by TimeGenerated
          //  StorageType / Subscription / RG / StorAcct / Share / Quota / GB Used / %Available
          | extend StorageType=split(ResultDescription, ',')[0]
          | extend Subscription=split(ResultDescription, ',')[1]
          | extend ResourceGroup=split(ResultDescription, ',')[2]
          | extend StorageAccount=split(ResultDescription, ',')[3]
          | extend Share=split(ResultDescription, ',')[4]
          | extend GBShareQuota=split(ResultDescription, ',')[5]
          | extend GBUsed=split(ResultDescription, ',')[6]
          | extend PercentAvailable=split(ResultDescription, ',')[7]
          | where PercentAvailable <= 5.00          
           '''
          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'ResultDescription'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          resourceIdColumng: '_ResourceId'
          operator: 'GreaterThanOrEqual'
          threshold: 1
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
]
var MetricAlerts = {
  storageAccounts: [
    {
      name: '${AlertNamePrefix}-StorAcct-Over-50msLatency'
      displayName: '${AlertNamePrefix}-Storage-Over 50ms Latency for Storage Acct'
      description: '${AlertDescriptionHeader}\nThis could indicate a lag or poor performance for user Profiles or Apps using MSIX App Attach.\nThis alert is specific to the Storage Account itself and does not include network latency.\nFor additional details on troubleshooting see:\n"https://learn.microsoft.com/en-us/azure/storage/files/storage-troubleshooting-files-performance#very-high-latency-for-requests"'
      severity: 2
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      criteria: {
        allOf: [
          {
            threshold: 50
            name: 'Metric1'
            metricName: 'SuccessServerLatency'
            operator: 'GreaterThan'
            timeAggregation: 'Average'
            criterionType: 'StaticThresholdCriterion'
          }
        ]
        'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      }
      targetResourceType: 'Microsoft.Storage/storageAccounts'
    }
    {
      name: '${AlertNamePrefix}--StorAcct-Over-100msLatency'
      displayName: '${AlertNamePrefix}-Storage-Over 100ms Latency for Storage Acct'
      description: '${AlertDescriptionHeader}\nThis could indicate a lag or poor performance for user Profiles or Apps using MSIX App Attach.\nThis alert is specific to the Storage Account itself and does not include network latency.\nFor additional details on troubleshooting see:\n"https://learn.microsoft.com/en-us/azure/storage/files/storage-troubleshooting-files-performance#very-high-latency-for-requests"'
      severity: 1
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      criteria: {
        allOf: [
          {
            threshold: 100
            name: 'Metric1'
            metricName: 'SuccessServerLatency'
            operator: 'GreaterThan'
            timeAggregation: 'Average'
            criterionType: 'StaticThresholdCriterion'
          }
        ]
        'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      }
      targetResourceType: 'Microsoft.Storage/storageAccounts'
    }
    {
      name: '${AlertNamePrefix}-StorAcct-Over-50msLatencyClnt-Stor'
      displayName: '${AlertNamePrefix}-Storage-Over 50ms Latency Between Client-Storage'
      description: '${AlertDescriptionHeader}\nThis could indicate a lag or poor performance for user Profiles or Apps using MSIX App Attach.\nThis is a total latency from end to end between the Host VM and Storage to include network.\nFor additional details on troubleshooting see:\n"https://learn.microsoft.com/en-us/azure/storage/files/storage-troubleshooting-files-performance#very-high-latency-for-requests"'
      severity: 2
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      criteria: {
        allOf: [
          {
            threshold: 50
            name: 'Metric1'
            metricName: 'SuccessE2ELatency'
            operator: 'GreaterThan'
            timeAggregation: 'Average'
            criterionType: 'StaticThresholdCriterion'
          }
        ]
        'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      }
      targetResourceType: 'Microsoft.Storage/storageAccounts'
    }
    {
      name: '${AlertNamePrefix}-StorAcct-Over-100msLatencyClnt-Stor'
      displayName: '${AlertNamePrefix}-Storage-Over 100ms Latency Between Client-Storage'
      description: '${AlertDescriptionHeader}\nThis could indicate a lag or poor performance for user Profiles or Apps using MSIX App Attach.\nThis is a total latency from end to end between the Host VM and Storage to include network.\nFor additional details on troubleshooting see:\n"https://learn.microsoft.com/en-us/azure/storage/files/storage-troubleshooting-files-performance#very-high-latency-for-requests"'
      severity: 1
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      criteria: {
        allOf: [
          {
            threshold: 100
            name: 'Metric1'
            metricName: 'SuccessE2ELatency'
            operator: 'GreaterThan'
            timeAggregation: 'Average'
            criterionType: 'StaticThresholdCriterion'
          }
        ]
        'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      }
      targetResourceType: 'Microsoft.Storage/storageAccounts'
    }
    {
      name: '${AlertNamePrefix}-StorAzFilesAvailBlw-99-Prcnt'
      displayName: '${AlertNamePrefix}-Storage-Azure Files Availability'
      description: '${AlertDescriptionHeader}\nThis could indicate storage is unavailable for user Profiles or Apps using MSIX App Attach.'
      severity: 1
      evaluationFrequency: 'PT5M'
      windowSize: 'PT5M'
      criteria: {
        allOf: [
          {
            threshold: 99
            name: 'Metric1'
            metricName: 'Availability'
            operator: 'LessThanOrEqual'
            timeAggregation: 'Average'
            criterionType: 'StaticThresholdCriterion'
          }
        ]
        'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      }
      targetResourceType: 'Microsoft.Storage/storageAccounts'
    }
  ]
  fileShares: [
    {
      name: '${AlertNamePrefix}-StorPossThrottlingHighIOPs'
      displayName: '${AlertNamePrefix}-Storage-Possible Throttling Due to High IOPs'
      description: '${AlertDescriptionHeader}\nThis indicates you may be maxing out the allowed IOPs.\nhttps://docs.microsoft.com/en-us/azure/storage/files/storage-troubleshooting-files-performance#how-to-create-an-alert-if-a-file-share-is-throttled'
      severity: 2
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      criteria: {
        allOf: [
          {
            threshold: 1
            name: 'Metric1'
            metricName: 'Transactions'
            dimensions: [
              {
                name: 'ResponseType'
                operator: 'Include'
                values: [
                  'SuccessWithThrottling'
                  'SuccessWithShareIopsThrottling'
                  'ClientShareIopsThrottlingError'
                ]
              }
              {
                name: 'FileShare'
                operator: 'Include'
                values: [
                  'SuccessWithShareEgressThrottling'
                  'SuccessWithShareIngressThrottling'
                  'SuccessWithShareIopsThrottling'
                  'ClientShareEgressThrottlingError'
                  'ClientShareIngressThrottlingError'
                  'ClientShareIopsThrottlingError'
                ]
              }
            ]
            operator: 'GreaterThanOrEqual'
            timeAggregation: 'Total'
            criterionType: 'StaticThresholdCriterion'
          }
        ]
        'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      }
      targetResourceType: 'Microsoft.Storage/storageAccounts/fileServices'
    }
  ]
  anf: [
    {
      name: '${AlertNamePrefix}-StorLowSpcANF-15-PrcntRem'
      displayName: '${AlertNamePrefix}-Storage-Low Space on ANF Share-15% Remaining'
      description: AlertDescriptionHeader
      severity: 2
      evaluationFrequency: 'PT1H'
      windowSize: 'PT1H'
      criteria: {
        allOf: [
          {
            threshold: 85
            name: 'Metric1'
            metricNamespace: 'microsoft.netapp/netappaccounts/capacitypools/volumes'
            metricName: 'VolumeConsumedSizePercentage'
            operator: 'GreaterThanOrEqual'
            timeAggregation: 'Average'
            criterionType: 'StaticThresholdCriterion'
          }
        ]
        'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      }
      targetResourceType: 'Microsoft.NetApp/netAppAccounts/capacityPools/volumes'
    }
    {
      name: '${AlertNamePrefix}-StorLowSpcANF-5-PrcntRem'
      displayName: '${AlertNamePrefix}-Storage-Low Space on ANF Share-5% Remaining'
      description: AlertDescriptionHeader
      severity: 1
      evaluationFrequency: 'PT1H'
      windowSize: 'PT1H'
      criteria: {
        allOf: [
          {
            threshold: 95
            name: 'Metric1'
            metricNamespace: 'microsoft.netapp/netappaccounts/capacitypools/volumes'
            metricName: 'VolumeConsumedSizePercentage'
            operator: 'GreaterThanOrEqual'
            timeAggregation: 'Average'
            criterionType: 'StaticThresholdCriterion'
          }
        ]
        'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      }
      targetResourceType: 'Microsoft.NetApp/netAppAccounts/capacityPools/volumes'
    }
  ]
  virtualMachines: [
    {
      name: '${AlertNamePrefix}-HP-VM-HighCPU-85-Prcnt-xHostPoolNamex'
      displayName: '${AlertNamePrefix}-HostPool-VM-High CPU 85% (xHostPoolNamex)'
      description: AlertDescriptionHeader
      severity: 2
      evaluationFrequency: 'PT1M'
      windowSize: 'PT5M'
      criteria: {
        allOf: [
          {
            threshold: 85
            name: 'Metric1'
            metricNamespace: 'microsoft.compute/virtualmachines'
            metricName: 'Percentage CPU'
            operator: 'GreaterThan'
            timeAggregation: 'Average'
            criterionType: 'StaticThresholdCriterion'
          }
        ]
        'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      }
      targetResourceType: 'microsoft.compute/virtualmachines'
    }
    {
      name: '${AlertNamePrefix}-HP-VM-HighCPU-95-Prcnt-xHostPoolNamex'
      displayName: '${AlertNamePrefix}-HostPool-VM-High CPU 95% (xHostPoolNamex)'
      description: AlertDescriptionHeader
      severity: 1
      evaluationFrequency: 'PT1M'
      windowSize: 'PT5M'
      criteria: {
        allOf: [
          {
            threshold: 95
            name: 'Metric1'
            metricNamespace: 'microsoft.compute/virtualmachines'
            metricName: 'Percentage CPU'
            operator: 'GreaterThan'
            timeAggregation: 'Average'
            criterionType: 'StaticThresholdCriterion'
          }
        ]
        'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      }
      targetResourceType: 'microsoft.compute/virtualmachines'
    }
    {
      name: '${AlertNamePrefix}-HP-VM-AvailMemLess-2GB-xHostPoolNamex'
      displayName: '${AlertNamePrefix}-HostPool-VM-Available Memory Less Than 2GB (xHostPoolNamex)'
      description: AlertDescriptionHeader
      severity: 2
      evaluationFrequency: 'PT1M'
      windowSize: 'PT5M'
      criteria: {
        allOf: [
          {
            threshold: 2147483648
            name: 'Metric1'
            metricNamespace: 'microsoft.compute/virtualmachines'
            metricName: 'Available Memory Bytes'
            operator: 'LessThanOrEqual'
            timeAggregation: 'Average'
            criterionType: 'StaticThresholdCriterion'
          }
        ]
        'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      }
      targetResourceType: 'microsoft.compute/virtualmachines'
    }
    {
      name: '${AlertNamePrefix}-HP-VM-AvailMemLess-1GB-xHostPoolNamex'
      displayName: '${AlertNamePrefix}-HostPool-VM-Available Memory Less Than 1GB (xHostPoolNamex)'
      description: AlertDescriptionHeader
      severity: 1
      evaluationFrequency: 'PT1M'
      windowSize: 'PT5M'
      criteria: {
        allOf: [
          {
            threshold: 1073741824
            name: 'Metric1'
            metricNamespace: 'microsoft.compute/virtualmachines'
            metricName: 'Available Memory Bytes'
            operator: 'LessThanOrEqual'
            timeAggregation: 'Average'
            criterionType: 'StaticThresholdCriterion'
          }
        ]
        'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      }
      targetResourceType: 'microsoft.compute/virtualmachines'
    }
  ]
  // Commenting out below until custom metrics are available in US Gov Cloud
  /* avdCustomMetrics: [
    {
      name: '${AlertNamePrefix}-HostPool-UsageAbove80percent'
      severity: 2
      evaluationFrequency: 'PT5M'
      windowSize: 'PT5M'
      criteria: {
        allOf: [
          {
            threshold: 80
            name: 'Metric1'
            metricNamespace: 'avd'
            metricName: 'Session Load (%)'
            operator: 'GreaterThanOrEqual'
            timeAggregation: 'Count'
            criterionType: 'StaticThresholdCriterion'
          }
        ]
        'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      }
      targetResourceType: 'Microsoft.OperationalInsights/workspaces'
    }
  ] */
}

var LogAlertsSvcHealth = [
  {
    name: '${AlertNamePrefix}-SerivceHealth-ServiceIssue'
    displayName: '${AlertNamePrefix}-SerivceHealth-Serivice Issue'
    description: AlertDescriptionHeader
    anyof: [
      {
        field: 'properties.incidentType'
        equals: 'Incident'
      }
    ]
  }
  {
    name: '${AlertNamePrefix}-SerivceHealth-PlannedMaintenance'
    displayName: '${AlertNamePrefix}-SerivceHealth-Planned Maintenance'
    description: AlertDescriptionHeader
    anyOf: [
      {
        field: 'properties.incidentType'
        equals: 'Maintenance'
      }
    ]
  }
  {
    name: '${AlertNamePrefix}-SerivceHealth-HealthAdvisory'
    displayName: '${AlertNamePrefix}-SerivceHealth-HealthAdvisory'
    description: AlertDescriptionHeader
    anyOf: [
      {
        field: 'properties.incidentType'
        equals: 'Informational'
      }
      {
        field: 'properties.incidentType'
        equals: 'ActionRequired'
      }
    ]
  }
  {
    name: '${AlertNamePrefix}-SerivceHealth-Security'
    displayName: '${AlertNamePrefix}-SerivceHealth-Security'
    description: AlertDescriptionHeader
    anyOf: [
      {
        field: 'properties.incidentType'
        equals: 'Security'
      }
    ]
  }
]
var varJobScheduleParamsHostPool = {
    CloudEnvironment: CloudEnvironment
    SubscriptionId: SubscriptionId
  }
// fixes issue with array not being in JSON format
var varStorAcctResIDsString = StorageAccountResourceIds
var varJobScheduleParamsAzFiles = {
    CloudEnvironment: CloudEnvironment
    StorageAccountResourceIDs: string(varStorAcctResIDsString)
}

var SubscriptionId = subscription().subscriptionId
var varScheduleName = 'AVD_Chk-'
var AVDResIDsString = string(HostPools)
var HostPoolsAsString = replace(replace(AVDResIDsString, '[', ''), ']', '')
var varTimeZone = varTimeZones[Location]
var varTimeZones = {
  australiacentral: 'AUS Eastern Standard Time'
  australiacentral2: 'AUS Eastern Standard Time'
  australiaeast: 'AUS Eastern Standard Time'
  australiasoutheast: 'AUS Eastern Standard Time'
  brazilsouth: 'E. South America Standard Time'
  brazilsoutheast: 'E. South America Standard Time'
  canadacentral: 'Eastern Standard Time'
  canadaeast: 'Eastern Standard Time'
  centralindia: 'India Standard Time'
  centralus: 'Central Standard Time'
  chinaeast: 'China Standard Time'
  chinaeast2: 'China Standard Time'
  chinanorth: 'China Standard Time'
  chinanorth2: 'China Standard Time'
  eastasia: 'China Standard Time'
  eastus: 'Eastern Standard Time'
  eastus2: 'Eastern Standard Time'
  francecentral: 'Central Europe Standard Time'
  francesouth: 'Central Europe Standard Time'
  germanynorth: 'Central Europe Standard Time'
  germanywestcentral: 'Central Europe Standard Time'
  japaneast: 'Tokyo Standard Time'
  japanwest: 'Tokyo Standard Time'
  jioindiacentral: 'India Standard Time'
  jioindiawest: 'India Standard Time'
  koreacentral: 'Korea Standard Time'
  koreasouth: 'Korea Standard Time'
  northcentralus: 'Central Standard Time'
  northeurope: 'GMT Standard Time'
  norwayeast: 'Central Europe Standard Time'
  norwaywest: 'Central Europe Standard Time'
  southafricanorth: 'South Africa Standard Time'
  southafricawest: 'South Africa Standard Time'
  southcentralus: 'Central Standard Time'
  southindia: 'India Standard Time'
  southeastasia: 'Singapore Standard Time'
  swedencentral: 'Central Europe Standard Time'
  switzerlandnorth: 'Central Europe Standard Time'
  switzerlandwest: 'Central Europe Standard Time'
  uaecentral: 'Arabian Standard Time'
  uaenorth: 'Arabian Standard Time'
  uksouth: 'GMT Standard Time'
  ukwest: 'GMT Standard Time'
  usdodcentral: 'Central Standard Time'
  usdodeast: 'Eastern Standard Time'
  usgovarizona: 'Mountain Standard Time'
  usgoviowa: 'Central Standard Time'
  usgovtexas: 'Central Standard Time'
  usgovvirginia: 'Eastern Standard Time'
  westcentralus: 'Mountain Standard Time'
  westeurope: 'Central Europe Standard Time'
  westindia: 'India Standard Time'
  westus: 'Pacific Standard Time'
  westus2: 'Pacific Standard Time'
  westus3: 'Mountain Standard Time'
}

// =========== //
// Deployments //
// =========== //

// AVD Shared Services Resource Group
module resourceGroupAVDMetricsCreate '../../../../carml/1.3.0/Microsoft.Resources/resourceGroups/deploy.bicep' = if (ResourceGroupCreate) {
  name: ResourceGroupName
  params: {
    name: ResourceGroupName
    location: Location
    enableDefaultTelemetry: false
    tags: contains(Tags, 'Microsoft.Resources/resourceGroups') ? Tags['Microsoft.Resources/resourceGroups'] : {}
  }
}

resource resourceGroupAVDMetricsExisting 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  name: ResourceGroupName
}

module identityUserManaged '../../../../carml/1.3.0/Microsoft.ManagedIdentity/userAssignedIdentities/deploy.bicep' = {
  name: 'carml_UserMgId_${UsrManagedIdentityName}'
  scope: resourceGroup(ResourceGroupCreate ? resourceGroupAVDMetricsCreate.name : resourceGroupAVDMetricsExisting.name)
  params: {
    location: Location
    name: UsrManagedIdentityName
    enableDefaultTelemetry: false
    tags: contains(Tags, 'Microsoft.ManagedIdentity/userAssignedIdentities') ? Tags['Microsoft.ManagedIdentity/userAssignedIdentities'] : {}
  }
  dependsOn: ResourceGroupCreate ? [ resourceGroupAVDMetricsCreate ] : [ resourceGroupAVDMetricsExisting ]
}

module deploymentScript_HP2VM '../../../../carml/1.3.0/Microsoft.Resources/deploymentScripts/deploy.bicep' = {
  name: 'carml_ds-PS-GetHostPoolVMAssociation'
  scope: resourceGroup(ResourceGroupName)
  params: {
    enableDefaultTelemetry: false
    arguments: '-AVDResourceIDs ${HostPoolsAsString}'
    azPowerShellVersion: '7.1'
    name: 'ds_GetHostPoolVMAssociation'
    primaryScriptUri: '${_ArtifactsLocation}dsHostPoolVMMap.ps1${_ArtifactsLocationSasToken}'
    userAssignedIdentities: {
      '${identityUserManaged.outputs.resourceId}': {}
    }
    kind: 'AzurePowerShell'
    location: Location
    timeout: 'PT2H'
    cleanupPreference: 'OnExpiration'
    retentionInterval: 'P1D'
  }
}

// Deploy new automation account
module automationAccount '../../../../carml/1.3.0/Microsoft.Automation/automationAccounts/deploy.bicep' = {
  name: 'carml_AutomtnAcct-${AutomationAccountName}'
  scope: resourceGroup(ResourceGroupName)
  params: {
    diagnosticLogCategoriesToEnable: [
      'JobLogs'
      'JobStreams'
    ]
    enableDefaultTelemetry: false
    diagnosticLogsRetentionInDays: 30
    diagnosticWorkspaceId: LogAnalyticsWorkspaceResourceId
    name: AutomationAccountName
    jobSchedules: !empty(StorageAccountResourceIds) ? [
      {
        parameters: varJobScheduleParamsHostPool
        runbookName: RunbookNameGetHostPool
        scheduleName: '${varScheduleName}HostPool-0'
      }
      {
        parameters: varJobScheduleParamsHostPool
        runbookName: RunbookNameGetHostPool
        scheduleName: '${varScheduleName}HostPool-1'
      }
      {
        parameters: varJobScheduleParamsHostPool
        runbookName: RunbookNameGetHostPool
        scheduleName: '${varScheduleName}HostPool-2'
      }
      {
        parameters: varJobScheduleParamsHostPool
        runbookName: RunbookNameGetHostPool
        scheduleName: '${varScheduleName}HostPool-3'
      }
      {
        parameters:  varJobScheduleParamsAzFiles
        runbookName: RunbookNameGetStorage
        scheduleName: '${varScheduleName}AzFilesStor-0'
      }
      {
        parameters: varJobScheduleParamsAzFiles
        runbookName: RunbookNameGetStorage
        scheduleName: '${varScheduleName}AzFilesStor-1'
      }
      {
        parameters: varJobScheduleParamsAzFiles
        runbookName: RunbookNameGetStorage
        scheduleName: '${varScheduleName}AzFilesStor-2'
      }
      {
        parameters: varJobScheduleParamsAzFiles
        runbookName: RunbookNameGetStorage
        scheduleName: '${varScheduleName}AzFilesStor-3'
      }
    ] :[
      {
        parameters: varJobScheduleParamsHostPool
        runbookName: RunbookNameGetHostPool
        scheduleName: '${varScheduleName}HostPool-0'
      }
      {
        parameters: varJobScheduleParamsHostPool
        runbookName: RunbookNameGetHostPool
        scheduleName: '${varScheduleName}HostPool-1'
      }
      {
        parameters: varJobScheduleParamsHostPool
        runbookName: RunbookNameGetHostPool
        scheduleName: '${varScheduleName}HostPool-2'
      }
      {
        parameters: varJobScheduleParamsHostPool
        runbookName: RunbookNameGetHostPool
        scheduleName: '${varScheduleName}HostPool-3'
      }
    ]
    location: Location
    runbooks: !empty(StorageAccountResourceIds) ? [
      {
        name: RunbookNameGetHostPool
        description: 'AVD Metrics Runbook for collecting related Host Pool statistics to store in Log Analytics for specified Alert Queries'
        type: 'PowerShell'
        uri: '${_ArtifactsLocation}${RunbookScriptGetHostPool}'
        version: '1.0.0.0'
      }
      {
        name: RunbookNameGetStorage
        description: 'AVD Metrics Runbook for collecting related Azure Files storage statistics to store in Log Analytics for specified Alert Queries'
        type: 'PowerShell'
        uri: '${_ArtifactsLocation}${RunbookScriptGetStorage}'
        version: '1.0.0.0'
      }
    ] : [
      {
        name: RunbookNameGetHostPool
        description: 'AVD Metrics Runbook for collecting related Host Pool statistics to store in Log Analytics for specified Alert Queries'
        type: 'PowerShell'
        uri: '${_ArtifactsLocation}${RunbookScriptGetHostPool}'
        version: '1.0.0.0'
      }
    ]
    schedules: !empty(StorageAccountResourceIds) ? [
      {
        name: '${varScheduleName}HostPool-0'
        frequency: 'Hour'
        interval: 1
        startTime: dateTimeAdd(time, 'PT15M')
        TimeZone: varTimeZone
        advancedSchedule: {}
      }
      {
        name: '${varScheduleName}HostPool-1'
        frequency: 'Hour'
        interval: 1
        startTime: dateTimeAdd(time, 'PT30M')
        TimeZone: varTimeZone
        advancedSchedule: {}
      }
      {
        name: '${varScheduleName}HostPool-2'
        frequency: 'Hour'
        interval: 1
        startTime: dateTimeAdd(time, 'PT45M')
        TimeZone: varTimeZone
        advancedSchedule: {}
      }
      {
        name: '${varScheduleName}HostPool-3'
        frequency: 'Hour'
        interval: 1
        startTime: dateTimeAdd(time, 'PT60M')
        TimeZone: varTimeZone
        advancedSchedule: {}
      }
      {
        name: '${varScheduleName}AzFilesStor-0'
        frequency: 'Hour'
        interval: 1
        startTime: dateTimeAdd(time, 'PT15M')
        TimeZone: varTimeZone
        advancedSchedule: {}
      }
      {
        name: '${varScheduleName}AzFilesStor-1'
        frequency: 'Hour'
        interval: 1
        startTime: dateTimeAdd(time, 'PT30M')
        TimeZone: varTimeZone
        advancedSchedule: {}
      }
      {
        name: '${varScheduleName}AzFilesStor-2'
        frequency: 'Hour'
        interval: 1
        startTime: dateTimeAdd(time, 'PT45M')
        TimeZone: varTimeZone
        advancedSchedule: {}
      }
      {
        name: '${varScheduleName}AzFilesStor-3'
        frequency: 'Hour'
        interval: 1
        startTime: dateTimeAdd(time, 'PT60M')
        TimeZone: varTimeZone
        advancedSchedule: {}
      }
    ] :[
      {
        name: '${varScheduleName}HostPool-0'
        frequency: 'Hour'
        interval: 1
        startTime: dateTimeAdd(time, 'PT15M')
        TimeZone: varTimeZone
        advancedSchedule: {}
      }
      {
        name: '${varScheduleName}HostPool-1'
        frequency: 'Hour'
        interval: 1
        startTime: dateTimeAdd(time, 'PT30M')
        TimeZone: varTimeZone
        advancedSchedule: {}
      }
      {
        name: '${varScheduleName}HostPool-2'
        frequency: 'Hour'
        interval: 1
        startTime: dateTimeAdd(time, 'PT45M')
        TimeZone: varTimeZone
        advancedSchedule: {}
      }
      {
        name: '${varScheduleName}HostPool-3'
        frequency: 'Hour'
        interval: 1
        startTime: dateTimeAdd(time, 'PT60M')
        TimeZone: varTimeZone
        advancedSchedule: {}
      }
    ]
    skuName: 'Free'
    tags: contains(Tags, 'Microsoft.Automation/automationAccounts') ? Tags['Microsoft.Automation/automationAccounts'] : {}
    systemAssignedIdentity: true
  }
  dependsOn: ResourceGroupCreate ? [resourceGroupAVDMetricsCreate] : [resourceGroupAVDMetricsExisting]
}

module roleAssignment_UsrIdDesktopRead '../../../../carml/1.3.0/Microsoft.Authorization/roleAssignments/subscription/deploy.bicep' = [for HostPoolId in HostPoolSubIds: {
  name: 'carml_UsrID-DS_${guid(HostPoolId)}'
  scope: subscription(HostPoolId)
  params: {
    location: Location
    enableDefaultTelemetry: false
    principalId: identityUserManaged.outputs.principalId
    roleDefinitionIdOrName: 'Desktop Virtualization Reader'
    principalType: 'ServicePrincipal'
    subscriptionId: HostPoolId
  }
  dependsOn: [
    identityUserManaged
  ]
}]

module roleAssignment_AutoAcctDesktopRead '../../../../carml/1.3.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = [for RG in DesktopReadRoleRGs: {
  scope: resourceGroup(RG)
  name: 'carml_DsktpRead_${RG}'
  params: {
    enableDefaultTelemetry: false
    principalId: automationAccount.outputs.systemAssignedPrincipalId
    roleDefinitionIdOrName: 'Desktop Virtualization Reader'
    principalType: 'ServicePrincipal'
    resourceGroupName: RG
  }
  dependsOn: [
    automationAccount
  ]
}]

module roleAssignment_LogAnalytics '../../../../carml/1.3.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = {
  scope: resourceGroup(split(LogAnalyticsWorkspaceResourceId, '/')[2], split(LogAnalyticsWorkspaceResourceId, '/')[4])
  name: 'carml_LogContrib_${split(LogAnalyticsWorkspaceResourceId, '/')[4]}'
  params: {
    enableDefaultTelemetry: false
    principalId: automationAccount.outputs.systemAssignedPrincipalId
    roleDefinitionIdOrName: '/providers/Microsoft.Authorization/roleDefinitions/${RoleAssignments.LogAnalyticsContributor.GUID}'
    principalType: 'ServicePrincipal'
    resourceGroupName: split(LogAnalyticsWorkspaceResourceId, '/')[4]
  }
  dependsOn: [
    automationAccount
  ]
}

module roleAssignment_Storage '../../../../carml/1.3.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = [for StorAcctRG in StorAcctRGs: {
  scope: resourceGroup(StorAcctRG)
  name: 'carml_StorAcctContrib_${StorAcctRG}'
  params: {
    enableDefaultTelemetry: false
    principalId: automationAccount.outputs.systemAssignedPrincipalId
    roleDefinitionIdOrName: '/providers/Microsoft.Authorization/roleDefinitions/${RoleAssignments.StoreAcctContrib.GUID}'
    principalType: 'ServicePrincipal'
    resourceGroupName: StorAcctRG
  }
  dependsOn: [
    automationAccount
  ]
}]

module metricsResources './modules/metricsResources.bicep' = {
  name: 'linked_MonitoringResourcesDeployment'
  scope: resourceGroup(ResourceGroupCreate ? resourceGroupAVDMetricsCreate.name : resourceGroupAVDMetricsExisting.name)
  params: {
    DistributionGroup: DistributionGroup
    HostPools: HostPools
    HostPoolInfo: deploymentScript_HP2VM.outputs.outputs.HostPoolInfo
    Location: Location
    LogAnalyticsWorkspaceResourceId: LogAnalyticsWorkspaceResourceId
    LogAlertsHostPool: LogAlertsHostPool
    LogAlertsStorage: LogAlertsStorage
    LogAlertsSvcHealth: LogAlertsSvcHealth
    MetricAlerts: MetricAlerts
    StorageAccountResourceIds: StorageAccountResourceIds
    ActionGroupName: ActionGroupName
    ANFVolumeResourceIds: ANFVolumeResourceIds
    Tags: Tags
  }
  dependsOn: [
    roleAssignment_AutoAcctDesktopRead
    roleAssignment_LogAnalytics
    roleAssignment_Storage
    roleAssignment_UsrIdDesktopRead
  ]
}
