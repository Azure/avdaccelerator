param (
    [securestring]$DomainJoinPassword,
    [string]$DomainJoinUserName,
    [string]$IdentityServiceProvider,
    [string]$KerberosEncryption,
    [string]$OrganizationalUnitPath,
    [string]$ResourceManagerUri,
    [string]$SecurityPrincipalName,
    [string]$ShareName,
    [string]$StorageAccountName,
    [string]$StorageAccountResourceGroupName,
    [string]$StoragePurpose,
    [string]$StorageSuffix,
    [string]$SubscriptionId,
    [string]$UserAssignedIdentityClientId
)

$ErrorActionPreference = 'Stop'
$WarningPreference = 'SilentlyContinue'

Write-Host 'Turning off Windows firewall.'
Set-NetFirewallProfile -Profile 'Domain', 'Public', 'Private' -Enabled $false

# Set UNC path for Azure Files file share
$FilesSuffix = '.file.' + $StorageSuffix
$FileShare = '\\' + $StorageAccountName + $FilesSuffix + '\' + $ShareName

# Set the drive letter for the share based on the storage purpose
$DriveLetter = switch ($StoragePurpose) {
    'AppAttach' { 'X:' }
    'Fslogix' { 'Y:' }
    Default { 'Z:' }
}

# Get & set domain services for Azure Files
if ($IdentityServiceProvider -like '*DS') {
	Write-Host 'Forcing group policy updates'
	Start-Process -FilePath 'gpupdate.exe' -ArgumentList '/force /wait:0' -Wait -NoNewWindow | Out-Null

	Write-Host 'Waiting for domain policies to be applied (1 minute)'
	Start-Sleep -Seconds 60

    $RsatInstalled = (Get-WindowsFeature -Name 'RSAT-AD-PowerShell').Installed
    if (!$RsatInstalled){
        Install-WindowsFeature -Name 'RSAT-AD-PowerShell' | Out-Null
    }

    # Create Domain credential
    $SecureDomainJoinPassword = ConvertTo-SecureString -String $DomainJoinPassword -AsPlainText -Force
    [pscredential]$DomainCredential = New-Object System.Management.Automation.PSCredential ($DomainJoinUserName, $SecureDomainJoinPassword)

    # Get Domain information
    $Domain = Get-ADDomain -Credential $DomainCredential -Current 'LocalComputer'

    # Set domain principal with NetBios for ACLs assignment
    $Group = $Domain.NetBIOSName + '\' + $SecurityPrincipalName

    if ($IdentityServiceProvider -eq 'ADDS') {
        # Fix the resource manager URI since only AzureCloud contains a trailing slash
        $ResourceManagerUriFixed = if ($ResourceManagerUri[-1] -eq '/') { $ResourceManagerUri.Substring(0, $ResourceManagerUri.Length - 1) } else { $ResourceManagerUri }

        # Get an access token for Azure resources
        $AzureManagementAccessToken = (Invoke-RestMethod `
            -Headers @{Metadata = "true" } `
            -Uri $('http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=' + $ResourceManagerUriFixed + '&client_id=' + $UserAssignedIdentityClientId)).access_token

        # Set header for Azure Management API
        $AzureManagementHeader = @{
            'Content-Type'  = 'application/json'
            'Authorization' = 'Bearer ' + $AzureManagementAccessToken
        }

        # Get / create kerberos key for Azure Storage Account
        $KerberosKey = ((Invoke-RestMethod `
            -Headers $AzureManagementHeader `
            -Method 'POST' `
            -Uri $($ResourceManagerUriFixed + '/subscriptions/' + $SubscriptionId + '/resourceGroups/' + $StorageAccountResourceGroupName + '/providers/Microsoft.Storage/storageAccounts/' + $StorageAccountName + '/listKeys?api-version=2023-05-01&$expand=kerb')).keys | Where-Object { $_.Keyname -contains 'kerb1' }).Value

        if (!$KerberosKey) 
        {
            Invoke-RestMethod `
                -Body (@{keyName = 'kerb1' } | ConvertTo-Json) `
                -Headers $AzureManagementHeader `
                -Method 'POST' `
                -Uri $($ResourceManagerUriFixed + '/subscriptions/' + $SubscriptionId + '/resourceGroups/' + $StorageAccountResourceGroupName + '/providers/Microsoft.Storage/storageAccounts/' + $StorageAccountName + '/regenerateKey?api-version=2023-05-01')
            
            $Key = ((Invoke-RestMethod `
                -Headers $AzureManagementHeader `
                -Method 'POST' `
                -Uri $($ResourceManagerUriFixed + '/subscriptions/' + $SubscriptionId + '/resourceGroups/' + $StorageAccountResourceGroupName + '/providers/Microsoft.Storage/storageAccounts/' + $StorageAccountName + '/listKeys?api-version=2023-05-01&$expand=kerb')).keys | Where-Object { $_.Keyname -contains 'kerb1' }).Value
        } 
        else 
        {
            $Key = $KerberosKey
        }

        # Creates a password for the Azure Storage Account in AD using the Kerberos key
        $ComputerPassword = ConvertTo-SecureString -String $Key.Replace("'","") -AsPlainText -Force

        # Create the SPN value for the Azure Storage Account; attribute for computer object in AD 
        $SPN = 'cifs/' + $StorageAccountName + $FilesSuffix

        # Create the Description value for the Azure Storage Account; attribute for computer object in AD 
        $Description = "Computer account object for Azure storage account $($StorageAccountName)."

        # Create the AD computer object for the Azure Storage Account
        $Computer = Get-ADComputer -Credential $DomainCredential -Filter {Name -eq $StorageAccountName}
        if($Computer){
            Remove-ADComputer -Credential $DomainCredential -Identity $StorageAccountName -Confirm:$false
        }
        $ComputerObject = New-ADComputer -Credential $DomainCredential -Name $StorageAccountName -Path $OrganizationalUnitPath -ServicePrincipalNames $SPN -AccountPassword $ComputerPassword -Description $Description -PassThru

        $Body = (@{
            properties = @{
                azureFilesIdentityBasedAuthentication = @{
                    activeDirectoryProperties = @{
                        accountType = 'Computer'
                        azureStorageSid = $ComputerObject.SID.Value
                        domainGuid = $Domain.ObjectGUID.Guid
                        domainName = $Domain.DNSRoot
                        domainSid = $Domain.DomainSID.Value
                        forestName = $Domain.Forest
                        netBiosDomainName = $Domain.NetBIOSName
                        samAccountName = $StorageAccountName
                    }
                    directoryServiceOptions = 'AD'
                }
            }
        } | ConvertTo-Json -Depth 6 -Compress)

        Invoke-RestMethod `
            -Body $Body `
            -Headers $AzureManagementHeader `
            -Method 'PATCH' `
            -Uri $($ResourceManagerUriFixed + '/subscriptions/' + $SubscriptionId + '/resourceGroups/' + $StorageAccountResourceGroupName + '/providers/Microsoft.Storage/storageAccounts/' + $StorageAccountName + '?api-version=2023-05-01')

        if ($KerberosEncryption -eq 'AES256') {
            # Set the Kerberos encryption on the computer object
            $DistinguishedName = 'CN=' + $StorageAccountName + ',' + $OrganizationalUnitPath
            Set-ADComputer -Credential $DomainCredential -Identity $DistinguishedName -KerberosEncryptionType 'AES256' | Out-Null

            # Reset the Kerberos key on the Storage Account
            Invoke-RestMethod `
                -Body (@{keyName = 'kerb1' } | ConvertTo-Json) `
                -Headers $AzureManagementHeader `
                -Method 'POST' `
                -Uri $($ResourceManagerUriFixed + '/subscriptions/' + $SubscriptionId + '/resourceGroups/' + $StorageAccountResourceGroupName + '/providers/Microsoft.Storage/storageAccounts/' + $StorageAccountName + '/regenerateKey?api-version=2023-05-01')

            $Key = ((Invoke-RestMethod `
                -Headers $AzureManagementHeader `
                -Method 'POST' `
                -Uri $($ResourceManagerUriFixed + '/subscriptions/' + $SubscriptionId + '/resourceGroups/' + $StorageAccountResourceGroupName + '/providers/Microsoft.Storage/storageAccounts/' + $StorageAccountName + '/listKeys?api-version=2023-05-01&$expand=kerb')).keys | Where-Object { $_.Keyname -contains 'kerb1' }).Value

            # Update the password on the computer object with the new Kerberos key on the Storage Account
            $NewPassword = ConvertTo-SecureString -String $Key -AsPlainText -Force
            Set-ADAccountPassword -Credential $DomainCredential -Identity $DistinguishedName -Reset -NewPassword $NewPassword | Out-Null
        } 
    }

    Register-PSSessionConfiguration -Name $StorageAccountName -RunAsCredential $DomainCredential -Force

    Invoke-Command -ArgumentList "$DriveLetter", "$FileShare", "$Group" -ComputerName $env:COMPUTERNAME -ConfigurationName $StorageAccountName -Credential $DomainCredential -ScriptBlock {
        param ($DriveLetter, $FileShare, $Group)
        Start-Process -FilePath 'net.exe' -ArgumentList "use $DriveLetter $FileShare" -Wait -NoNewWindow | Out-Null
        Start-Process -FilePath 'icacls.exe' -ArgumentList "$DriveLetter /grant `"$($Group):(M)`"" -Wait -NoNewWindow | Out-Null
        Start-Process -FilePath 'icacls.exe' -ArgumentList "$DriveLetter /grant `"Creator Owner:(OI)(CI)(IO)(M)`"" -Wait -NoNewWindow | Out-Null
        Start-Process -FilePath 'icacls.exe' -ArgumentList "$DriveLetter /remove `"Authenticated Users`"" -Wait -NoNewWindow | Out-Null
        Start-Process -FilePath 'icacls.exe' -ArgumentList "$DriveLetter /remove `"Builtin\Users`"" -Wait -NoNewWindow | Out-Null
        Start-Process -FilePath 'net.exe' -ArgumentList "use Z: /delete" -Wait -NoNewWindow | Out-Null
    }
} else {
    Start-Process -FilePath 'net.exe' -ArgumentList "use $DriveLetter $FileShare" -Wait -NoNewWindow | Out-Null
    Start-Process -FilePath 'icacls.exe' -ArgumentList "$DriveLetter /grant `"Creator Owner:(OI)(CI)(IO)(M)`"" -Wait -NoNewWindow | Out-Null
    Start-Process -FilePath 'icacls.exe' -ArgumentList "$DriveLetter /inheritance:r" -Wait -NoNewWindow | Out-Null
    Start-Process -FilePath 'icacls.exe' -ArgumentList "$DriveLetter /remove `"Builtin\Administrators`"" -Wait -NoNewWindow | Out-Null
    Start-Process -FilePath 'icacls.exe' -ArgumentList "$DriveLetter /remove `"Builtin\Users`"" -Wait -NoNewWindow | Out-Null
    Start-Process -FilePath 'net.exe' -ArgumentList "use Z: /delete" -Wait -NoNewWindow | Out-Null
}

