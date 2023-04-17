# Azure Cost Optimization

The _'Azure Cost Optimization workbook Workbook'_ centralize Cost Optimization in Azure environments.

The main purposes of this Workbook are:
* Cost saving.
* Prevent mistakes and misconfiguration.
* Operation simplification.

![image](../../docs/images/costOptimizationWorkbook/CostOptimizationWorkbook.png)

[Cost Optimization workbook](https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/workbooks/costOptimizationWorkbook/costOptimization.workbook)

## Type of resources covered:

* Resources distribution per region.
* Tagged vs Untagged Resource Groups.
* Windows VMs and VM scale sets without Azure Hybrid Benefit enabled.
* Azure SQL Databases not using Hybrid Benefit.
* Azure SQL Managed Instances not using Hybrid Benefit.
* Virtual Machines in a Stopped State.
* Virtual Machine Performance.
* Disks.
* Network Interfaces.
* Public IPs.
* Resource Groups.
* Network Security Groups (NSGs).
* Availability Set.

## How to use it?

Importing this Workbook to your Azure environment.

Follow this steps:

* Login to [Azure Portal](https://portal.azure.com/) <img src="../../docs/icons/azure.png" width="20" height="20">
* Go to _'Azure Workbooks'_

![Cost optimization workbook 1](../../docs/images/costOptimizationWorkbook/costoptworkbook1.png)

* Click on _'+ Create'_

![Create monitoring workbook](../../docs/images/costOptimizationWorkbook/createworkbook.png)

* Click on _'+ New'_

![New monitoring workbook](../../docs/images/costOptimizationWorkbook/newworkbook.png)

* Open the Advanced Editor using the _'</>'_ button on the toolbar

![Edit monitoring workbook](../../docs/images/costOptimizationWorkbook/editworkbook.png)

* Select the _'Gallery Template'_ (step 1)
* Replace the JSON in the gallery template to the [Cost Optimization workbook](https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/workbooks/costOptimizationWorkbook/costOptimization.workbook) (step 2)
* Click _'Apply'_ (step 3)

![Apply monitoring workbook](../../docs/images/costOptimizationWorkbook/applyworkbook.png)

* Click in the ‘Save’ button on the toolbar

![Save monitoring workbook](../../docs/images/costOptimizationWorkbook/saveworkbook.png)

* Select a name and where to save the Workbook:

* Title: _'Cost Optimization workbook'_
* Subscription: _Subscription Name_
* Resource group: _Resource Group Name_
* Location: _Region_
* Click _'Save'_
  
The Workbook is ready to use!

* From Azure portal search for _'Monitor'_
* Click on _'Cost Optimization workbook'_ Workbook.

![Monitoring workbook](../../docs/images/costOptimizationWorkbook/monitorworkbook.png)

Start using the Workbook and review your Cost Optimization workbook.
Filter by specific subscription is optional.

![Cost optimization workbook](../../docs/images/costOptimizationWorkbook/CostOptimizationWorkbook.png)
