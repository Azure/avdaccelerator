# Update History

[Home](./readme.md) | [PostDeployment](./postDeploy.md) | [How to Change Thresholds](./changeAlertThreshold.md) | [Alert Reference](./alertReference.md) | [Excel List of Alert Rules](./references/alerts.xlsx)

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
