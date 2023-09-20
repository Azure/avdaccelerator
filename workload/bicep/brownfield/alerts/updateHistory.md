# Update History

[Home](./readme.md) | [PostDeployment](./postDeploy.md) | [How to Change Thresholds](./changeAlertThreshold.md) | [Alert Reference](./alertReference.md) | [Excel List of Alert Rules](./references/alerts.xlsx)

## 8/10/23 - Fix - Deployment Name too long and Critical Updates Missing failure (V2.1.2)

- c_AVD-HP-VM-MissingCriticalUpdates deployment would fail due to search syntax incorrectly defined
- c_AVD-StorAcct-Over-100msLatencyClnt-Stor deployment name was still too long depencing on the name of the storage account appended
- Additonal Alert names truncated to avoid deployment name length being over 64 characters
(Trying to avoid logic to use GUIDs for clarity during deployment)

## 8/10/23 - Fix - Deployment Name too long Host Pool Alerts (V2.1.1)

- Added logic to truncate Host Pool name when deploying Host Pool specific alerts to last 25 characters to prevent deployment name over allowed 64 characters
- Ensured Actual Host Pool Name is in Description Name for related alerts.

## 7/17/23 - Fixes - Remove Deployment Script (v2.1.0)

- Removed Identity and Deployment script for VM to Host Pool mapping
    - should fix API limit issue #392
    - should fix issue 379 regarding use of Private Endpoints on host pools given no Deployment Script Container used
- Updated Custom UI to now have flag for mapping VM RG to HostPool(s) or use single RG for VMs and AVD resources
- Fix typo on alert StorAzFilesAvailBlw-99-Prcnt for windowsSize (55M vs 5M) which would fail deployment (Issue 425)
- Reverted Custom UI for Log Analytics Selection back to type which allows cross subscription selection (Was API now Resource Selection component)
- New Option for allowing All Alerts to Auto-Resolve
- Environment (Production, Dev, Test) letter now at the end of the alert names
- Added Current Version to Alerts Readme Summary section for awareness and easier tracking

## 7/10/23 - Additional Alerts Added and Minor fixes (v2.0.2)

These have been added and as usual deployed 'disabled' and duplicated for each Host Pool.
- New Alert: Sev1 Personal Host Pool VM assigned but AVD Agent reporting unhealthy (Log Query)
- New Alert: Sev1 Critical Updates Mising on VM (Log Query)
- New Alert: Sev3 User Connection Failed (Log Query)
- New Alert: Sev1 OS Disk Average Consumed Bandwidth at or over 95% (Metric)
- New Alert: Sev2 OS Disk Average Consumed Bandwidth at or over 85% (Metric)

Deployment names truncated to prevent deployment failures for names over 64 characters
- mainly noted the Storage Latency alerts were impacted when the storage account name was long

Fixed Single Selection Issue
- Form UI would put single selections for Host Pool and VM RGs as string versus array value(s) 
- Added Default value for those sections with "[]"

Deployment Script (dsHostPoolVMMap.ps1) added error handling (try catch)


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
