# Alert Reference

[Home](./readme.md) | [PostDeployment](./postDeploy.md) | [How to Change Thresholds](./changeAlertThreshold.md) | [Excel List of Alert Rules](./references/alerts.xlsx) | [Update History](./updateHistory.md)

## Log Analytics Query Based Alerts

The following are the Alert Queries and Metrics utilized in the solution and common for monitoring and AVD environment.  

### AVD-HostPool-Capacity-XXPercent

This query is also based on the output of the Runbook for AVD Host Pool information that is the AzureDiagnostics table.

```k
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
| where HostPoolPercentLoad >= 85  //value to use for percentage       
```

### AVD-HostPool-Disconnected User over XX Hours

Simply replace the 24h reference in the 2 locations noted below.  

```k
// Session duration 
// Lists users by session duration in the last 24 hours. 
// The "State" provides information on the connection stage of an activity.
// The delta between "Connected" and "Completed" provides the connection time for a specific connection.
WVDConnections 
| where TimeGenerated > ago(24h) 
| where State == "Connected"  
| project
    CorrelationId,
    UserName,
    ConnectionType,
    StartTime=TimeGenerated,
    SessionHostName
| join (WVDConnections  
    | where State == "Completed"  
    | project EndTime=TimeGenerated, CorrelationId)  
    on CorrelationId  
| project Duration = EndTime - StartTime, ConnectionType, UserName, SessionHostName
| where Duration >= timespan(24:00:00)
| sort by Duration desc
```

### AVD-HostPool-No Resources Available

```k
WVDConnections 
| where TimeGenerated > ago (15m) 
| project-away TenantId, SourceSystem  
| summarize
    arg_max(TimeGenerated, *),
    StartTime =  min(iff(State == 'Started', TimeGenerated, datetime(null))),
    ConnectTime = min(iff(State == 'Connected', TimeGenerated, datetime(null)))
    by CorrelationId  
| join kind=leftouter (WVDErrors
    | summarize Errors=makelist(pack('Code', Code, 'CodeSymbolic', CodeSymbolic, 'Time', TimeGenerated, 'Message', Message, 'ServiceError', ServiceError, 'Source', Source)) by CorrelationId  
    )
    on CorrelationId
| join kind=leftouter (WVDCheckpoints
    | summarize Checkpoints=makelist(pack('Time', TimeGenerated, 'Name', Name, 'Parameters', Parameters, 'Source', Source)) by CorrelationId  
    | mv-apply Checkpoints on (  
        order by todatetime(Checkpoints['Time']) asc
        | summarize Checkpoints=makelist(Checkpoints)
        )
    )
    on CorrelationId  
| project-away CorrelationId1, CorrelationId2  
| order by TimeGenerated desc
| where Errors[0].CodeSymbolic == "ConnectionFailedNoHealthyRdshAvailable"
```

### AVD-Storage-Low Space on Azure File Share-XX% Remaining

This query is also based on the output of the Runbook for Azure Files and ANF Storage information that is the AzureDiagnostics table.

```k
AzureDiagnostics 
| where Category has "JobStreams"
    and StreamType_s == "Output"
    and RunbookName_s == "AvdStorageLogData"
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
```

### AVD-VM-FSLogix Profile Specific Events

| FSLogix Issue  |  Event ID(s) |
|----------------|-----------   |
| Profile Space Low - less than 5%  |  33  |
| Profile Space Low - less than 2%  |  34  |
| Profile Network Issue             |  43  |
| Profile Failed VHD Attach         |  40 or 52 |
| FSLogix Service Disabled          |  60  |
| FSLogix Disk Compaction Failed    |  62 or 63 |

Query example in which you would simply change the event ID number.  For those that involve 2 Event IDs you can change the last line to include those via something like...  
'|where EventID == 40 or EventID == 52'  

```k
Event
| where EventLog == "Microsoft-FSLogix-Apps/Admin"
| where EventLevelName == "Error"
| where EventID == 33
```

### AVD-VM-Local Disk Free Space XX% Remaining

```k
Perf
| where TimeGenerated > ago(15m)
| where ObjectName == "LogicalDisk" and CounterName == "% Free Space"
| where InstanceName !contains "D:"
| where InstanceName !contains "_Total"
| where CounterValue <= 10.00
```

## Metric based Alerts

The following are typical metric based alerts that are commonly used in monitoring AVD. For those with 2 values or a range, the intent is to create 2 alerts that may reflect a warning versus a more critical event.  While the proposed values are recommended, it is highly dependant on your environment.  

| Alert Item                                        | Resource Target   |   Metric             |    Time Aggregation  |
|-----------------                                  |------------------ |------------          |-------------         |
| AVD-Storage-Over 50 to 100ms Latency for Storage Acct | Storage Account | SuccessServerLatency  | Average over 15 minutes over 50 to 100ms |
| AVD-Storage-Over 50 to 100ms Latency Between Client-Storage | Storage Account | SuccessE2ELatency  | Average over 15 minutes  |
| AVD-Storage-Azure Files Availability  | Storage Account | Availability  | Anything less than 99%  |
| AVD-Storage-Possible Throttling Due to High IOPs :one:  | Storage Account | Transactions | Average over 15 minutes |
| AVD-Storage-Low Space on ANF Share-95 to 85 Percent Remaining | Azure NetApp Volume | VolumeConsumedSizePercentage | Average over 1 hour |
| AVD-VM-High CPU 85 to 95 Percent | Virtual Machine | Percentage CPU  | Average over 5 minutes |
| AVD-VM-Available Memory Less Than 2GB or 1GB  | Virtual Machine | Available Memory Bytes | Average over 5 minutes |

:one:
For the Azure Files Possible Throttling alert you will also need to include specific dimensions and values. These values will not show in the drop down if they have never been triggered. Thus you will need to manually create them based on the below names and values.  

- name: 'ResponseType'  (For Standard File Shares SKU)
- values:  
    - 'SuccessWithThrottling'
    - 'SuccessWithShareIopsThrottling'
    - 'ClientShareIopsThrottlingError'

- name: 'FileShare'  (For Premium File Shares SKU)
- values:
    - 'SuccessWithShareEgressThrottling'
    - 'SuccessWithShareIngressThrottling'
    - 'SuccessWithShareIopsThrottling'
    - 'ClientShareEgressThrottlingError'
    - 'ClientShareIngressThrottlingError'
    - 'ClientShareIopsThrottlingError'

Reference: [Troubleshooting Azure Files Performance](https://docs.microsoft.com/azure/storage/files/storage-troubleshooting-files-performance#how-to-create-an-alert-if-a-file-share-is-throttled)