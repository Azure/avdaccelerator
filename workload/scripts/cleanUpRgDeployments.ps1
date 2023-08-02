##############################################################
#  Clean up resource group deployments
##############################################################

[CmdletBinding(SupportsShouldProcess)]
param(
	[Parameter(Mandatory)]
	[string]$subscriptionId,

	[Parameter(Mandatory)]
	[string]$resourceGroupName,

	[Parameter(Mandatory)]
	[string]$clientId
)

# Get powershell modules
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name PowershellGet -MinimumVersion 2.2.4.1 -Force
Install-Module 'PSDscResources' -Force
Install-Module -Name Az.Accounts -Force
Install-Module -Name Az.Resources -Force
Import-Module -Name activedirectory -Force

# Connecting Azure account
Write-Log "Connecting to managed identity account"
Connect-AzAccount -Identity -AccountId $clientId

# Select subscription
Write-Output "Selecting subscription Subscription $subscriptionId."
Select-AzSubscription -subscriptionid $subscriptionId

# Get resource group succeeded deployments
Write-Output "Getting $resourceGroupName succeeded deployments"
$resourceGroupDeployments = Get-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName | Where-Object ProvisioningState -EQ 'Succeeded'

# Delete resource group deployments
Write-Output "Deleting succeded deployments on $resourceGroupName"
foreach ($resourceGroupDeployment in $resourceGroupDeployments) {
    Remove-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -Name $resourceGroupDeployment.DeploymentName
}