# Update History

[Home](./readme.md) | [PostDeployment](./postDeploy.md) | [How to Change Thresholds](./changeAlertThreshold.md) | [Alert Reference](./alertReference.md) | [Excel List of Alert Rules](./references/alerts.xlsx)

## 7/1/23 - Additional Alerts Added and Minor fixes (v2.0.2)

These have been added and as usual deployed 'disabled' and duplicated for each Host Pool.
- New Alert: Sev1 Personal Host Pool VM assigned but AVD Agent reporting unhealthy (Log Query)
- New Alert: Sev1 Critical Updates Mising on VM (Log Query)
- New Alert: Sev3 User Connection Failed (Log Query)
- New Alert: Sev1 OS Disk Average Consumed Bandwidth at or over 95% (Metric)
- New Alert: Sev2 OS Disk Average Consumed Bandwidth at or over 85% (Metric)

Deployment names truncated to prevent deployment failures for names over 64 characters
- mainly noted the Storage Latency alerts were impacted when the storage account name was long




## 4/27/23 - Initial AVD Accelerator Release (v2.0.1)

- Initial release in AVD Accelerator to include use of carml 1.3.0
- Added UI Definition for ease of deployment vs running scripts  
- All VM alerts are now revised to create multiple alerts per Host Pool, thus allowing separate groups to be alerted for specific host pool VM resources and their health (you will still need to manually add, create and adjust Alert Rules)
- Corrected queries for "Profile Disk n% full" as these would potentially never fire or alert from [version 1.x](https://github.com/JCoreMS/AVDAlerts)

```sql
prefix-VM-FSLogix Profile Less Than 2% Free Space  
| where EventLevelName == "Error"  
| where EventID == 33  

prefix-VM-FSLogix Profile Less Than 5% Free Space
| where EventLevelName == "Warning"
| where EventID == 34
```
