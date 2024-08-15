<#
    Updates the AVD application display name.
#>
param (
    [string]$ResourceGroupName,
    [string]$ApplicationGroupName,
    [string]$Name,
    [string]$FriendlyName
)

# set parameters object
$parameters = @{
    ResourceGroupName = $ResourceGroupName
    ApplicationGroupName = $ApplicationGroupName
    Name = $Name
    FriendlyName = $FriendlyName
}
 
# update
#Update-AzWvdDesktop @parameters
Write-Host $parameters