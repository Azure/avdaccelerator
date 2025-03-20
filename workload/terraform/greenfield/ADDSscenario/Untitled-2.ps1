try {
    Set-AzContext -Subscription $subscriptionId -Tenant $tenantId -ErrorAction Stop
    Write-Host "Azure context set successfully!"
} catch {
    Write-Error "Failed to set Azure context: $($_.Exception.Message)"
    Write-Host "Stopping execution due to the error."
        exit 1
}

Write-Host "Azure context set successfully!"
Write-Host "Continuing with the rest of the script..."

$ResourceGroups = Get-AzResourceGroup
foreach ($resourceGroup in $resourceGroups) {
    $resourceGroupName = $resourceGroup.ResourceGroupName
    Write-Output "Checking resource group: $resourceGroupName ..."
    # Get the tags of the resource group
    $tags = (Get-AzResourceGroup -Name $resourceGroupName).Tags
# Check if the 'keep' tag exists and its value is 'true'
    if ($tags -and $tags.ContainsKey('keep') -and $tags['keep'] -eq 'true') {
        Write-Output "Resource group: $resourceGroupName is marked to keep. Skipping deletion."
        }
    else {
        Write-Output "Tag 'keep' with value 'true' was not found in resource group: $resourceGroupName. It will be deleted."
        # Delete the resource group
        Write-Output "Deleting resource group: $resourceGroupName"
        try {
        Remove-AzResourceGroup -Name $resourceGroupName -Force -Confirm:$false -AsJob
        Write-Output "Resource group deletion initiated successfully"
        }
        catch {
            Write-Error "Failed to delete resource group: $resourceGroupName. Error: $_"
        }
    }
}


$ResourceGroupName = "avd-ad-rg" # Replace with the resource group of your virtual network
$VNetName = "avd1-vnet"           # Name of the virtual network

# Get all peerings of the virtual network
$peerings = Get-AzVirtualNetworkPeering -ResourceGroupName $ResourceGroupName -VirtualNetworkName $VNetName

# Loop through each peering and delete it
foreach ($peering in $peerings) {
    Remove-AzVirtualNetworkPeering -Name $peering.Name -ResourceGroupName $ResourceGroupName -VirtualNetworkName $VNetName -Force
    Write-Host "Deleted peering:" $peering.Name
}

Write-Host "All peerings for the virtual network '$VNetName' have been deleted."

#Delete role assignment
# First, get the role assignment to confirm you're removing the correct one
Get-AzRoleAssignment -RoleDefinitionName "Desktop Virtualization Power On Off Contributor" | Format-Table DisplayName, SignInName, RoleDefinitionName, Scope

#Get subscription ID from context
$subscriptionId = (Get-AzContext).Subscription.Id
$principalId = "9cdead84-a844-4324-93f2-b2e6bb768d07"
$scope = "/subscriptions/$subscriptionId"

Remove-AzRoleAssignment -RoleDefinitionName "Desktop Virtualization Power On Off Contributor" -Scope $scope -ObjectId $principalId



# Then remove the specific role assignment
# If there are multiple assignments, you need to specify additional parameters to target the exact one
Remove-AzRoleAssignment -RoleDefinitionName "Desktop Virtualization Power On Off Contributor" -Scope "/subscriptions/d12d19a9-0636-4951-90a4-339158fd57d8"
