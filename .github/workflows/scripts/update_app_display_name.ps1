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
    ResourceGroupName = $ResourceGroupName.ToLower()
    ApplicationGroupName = $ApplicationGroupName.ToLower()
    Name = $Name
    FriendlyName = $FriendlyName
}

# update
Update-AzWvdDesktop @parameters
#Write-Host $parameters