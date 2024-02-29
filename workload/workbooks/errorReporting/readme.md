# Azure Virtual Desktop Error Reporting

The purpose of this workbook is to provide breakdowns of errors within AVD. 

## Requirements

AVD Insights to be configured and collecting data to Log Analytics.

## Reporting Breakdowns

### Reports by Single Error

The single error tab provides breakdowns of a single Code Symbolic error. It provides it by Gateway Regions, Users, Hostpools and Session Hosts.

It also provides a simple percentage of how much the selected error represents against all errors. Example: Shortpathnetwork drop represents 28% of all errors.

### Report by multiple Errors  

The report by multiple errors tab provides the ability to select 1 or all Code Symbolic errors. Then provides top nested results by Gateway Region, Users, Hostpools and Sessionhosts. It provides the top 10 to 50 by sessions and then the top five Code Symbolic errors, of the selected errors.

From there, you can select any error, this will load graphs to the right. The graphs are top 5 user or hostpool from the last week. Top 5 users or hostpools from the prior week. As well as area charts of all users or hostpools with the selected error from the last week and week prior.