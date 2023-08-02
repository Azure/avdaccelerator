##############################################################
#  Clean up resource group deployments
##############################################################

[CmdletBinding(SupportsShouldProcess)]
param(
	[Parameter(Mandatory)]
	[string]$subscriptionId,

	[Parameter(Mandatory)]
	[string]$resourceGroupName
)

$ErrorActionPreference = 'Stop'

# Select subscription
Write-Output "Selecting subscription Subscription $subscriptionId."
Select-AzSubscription -subscriptionid $subscriptionId

# Get resource group succeeded deployments
Write-Output "Getting $resourceGroupName succeeded deployments"
$resourceGroupDeployments = Get-AzResourceGroupDeployment -ResourceGroupName rg-avd-m002-dev-usw3-pool-compute | Where-Object ProvisioningState -EQ 'Succeeded'

# Delete resource group deployments
Write-Output "Deleting succeded deployments on $resourceGroupName"
foreach ($resourceGroupDeployment in $resourceGroupDeployments) {
    Remove-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -Name $resourceGroupDeployment.DeploymentName
}