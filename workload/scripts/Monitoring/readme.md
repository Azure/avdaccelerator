# Steps to migrate Log Analytics agent (also known as MMA and OMS) to Azure Monitor Agent (AMA)

# As a reference lease review  [Monitoring Agent Migration WorkFlow](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-migration-tools?tabs=portal-1)

## The main purposes of the scripts are:

## How to use it?

* 01_MMA_Report.ps1- is to gather current AVD hosts wich have been monitored via MMA agent and export it to csv file
* Review the report to confirm the list of VMs with MMA agent
* 02_MMA_Extention_remove.ps1 that script will reference the csv report and remove MMA agent