param(
    [string]$ResourceGroupName,
    [string]$ResourceManagerUri,
    [string]$UserAssignedIdentityClientId,
    [string]$VirtualMachineResourceId
)

# Fix the resource manager URI since only AzureCloud contains a trailing slash
$ResourceManagerUriFixed = if($ResourceManagerUri[-1] -eq '/'){$ResourceManagerUri.Substring(0,$ResourceManagerUri.Length - 1)} else {$ResourceManagerUri}

# Get an access token for Azure resources
$AzureManagementAccessToken = (Invoke-RestMethod `
    -Headers @{Metadata="true"} `
    -Uri $('http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=' + $ResourceManagerUriFixed + '&client_id=' + $UserAssignedIdentityClientId)).access_token

# Set header for Azure Management API
$AzureManagementHeader = @{
    'Content-Type'='application/json'
    'Authorization'='Bearer ' + $AzureManagementAccessToken
}

Start-Sleep -Seconds 30

# Use the access token to delete the virtual machine
Invoke-RestMethod `
    -Headers $AzureManagementHeader `
    -Method 'Delete' `
    -Uri $($ResourceManagerUriFixed + $VirtualMachineResourceId + '?forceDeletion=true&api-version=2024-07-01') | Out-Null