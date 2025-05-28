param (
    [string]$DomainJoinPassword,
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
Set-NetFirewallProfile -Profile 'Domain', 'Public', 'Private' -Enabled 'False' | Out-Null
Write-Host 'Turned off Windows firewall.'

# Set UNC path for Azure Files file share
$FilesSuffix = '.file.' + $StorageSuffix
$FileShare = '\\' + $StorageAccountName + $FilesSuffix + '\' + $ShareName

# Set the drive letter for the share based on the storage purpose
$DriveLetter = switch ($StoragePurpose) {
    'AppAttach' { 'X:' }
    'Fslogix' { 'Y:' }
    Default { 'Z:' }
}

# Domain join Azure Files for domain services scenarios
if ($IdentityServiceProvider -like '*DS') {
    Write-Host 'Installing the RSAT-AD-PowerShell feature.'
    $RsatInstalled = (Get-WindowsFeature -Name 'RSAT-AD-PowerShell').Installed
    if (!$RsatInstalled){
        Install-WindowsFeature -Name 'RSAT-AD-PowerShell' | Out-Null
        Write-Host 'Installed the RSAT-AD-PowerShell feature.'
    } else {
        Write-Host 'RSAT-AD-PowerShell is already installed.'
    }

	Write-Host 'Forcing group policy updates.'
	Start-Process -FilePath 'gpupdate.exe' -ArgumentList '/force /wait:0' -Wait -NoNewWindow | Out-Null
    Write-Host 'Forced group policy updates.'

    # Wait for 1 minute to ensure domain policies are applied
    # This is necessary to ensure that the RSAT tools are available and the domain is ready for further operations
	Write-Host 'Waiting for domain policies to be applied (1 minute)'
	Start-Sleep -Seconds 60
    Write-Host 'Waited for domain policies to be applied.'

    # Create Domain credential
    $SecureDomainJoinPassword = ConvertTo-SecureString -String $DomainJoinPassword -AsPlainText -Force
    [pscredential]$DomainCredential = New-Object System.Management.Automation.PSCredential ($DomainJoinUserName, $SecureDomainJoinPassword)

    # Get Domain information
    Write-Host 'Getting domain information.'
    $Domain = Get-ADDomain -Credential $DomainCredential -Current 'LocalComputer'
    Write-Host 'Collected domain information.'

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
        Write-Host 'Checking Kerberos key for Azure Storage Account.'
        $KerberosKey = ((Invoke-RestMethod `
            -Headers $AzureManagementHeader `
            -Method 'POST' `
            -Uri $($ResourceManagerUriFixed + '/subscriptions/' + $SubscriptionId + '/resourceGroups/' + $StorageAccountResourceGroupName + '/providers/Microsoft.Storage/storageAccounts/' + $StorageAccountName + '/listKeys?api-version=2023-05-01&$expand=kerb')).keys | Where-Object { $_.Keyname -contains 'kerb1' }).Value


        if (!$KerberosKey) 
        {
            Write-Host 'Kerberos key does not exist. Creating a new Kerberos key for Azure Storage Account.'
            Invoke-RestMethod `
                -Body (@{keyName = 'kerb1' } | ConvertTo-Json) `
                -Headers $AzureManagementHeader `
                -Method 'POST' `
                -Uri $($ResourceManagerUriFixed + '/subscriptions/' + $SubscriptionId + '/resourceGroups/' + $StorageAccountResourceGroupName + '/providers/Microsoft.Storage/storageAccounts/' + $StorageAccountName + '/regenerateKey?api-version=2023-05-01')
            Write-Host 'Created Kerberos key for Azure Storage Account.'

            Write-Host 'Getting Kerberos key for Azure Storage Account.'
            $Key = ((Invoke-RestMethod `
                -Headers $AzureManagementHeader `
                -Method 'POST' `
                -Uri $($ResourceManagerUriFixed + '/subscriptions/' + $SubscriptionId + '/resourceGroups/' + $StorageAccountResourceGroupName + '/providers/Microsoft.Storage/storageAccounts/' + $StorageAccountName + '/listKeys?api-version=2023-05-01&$expand=kerb')).keys | Where-Object { $_.Keyname -contains 'kerb1' }).Value
            Write-Host 'Collected Kerberos key for Azure Storage Account.'

        } 
        else 
        {
            Write-Host 'Kerberos key already exists. Collected Kerberos key for Azure Storage Account.'
            $Key = $KerberosKey
        }

        # Creates a password for the Azure Storage Account in AD using the Kerberos key
        $ComputerPassword = ConvertTo-SecureString -String $Key.Replace("'","") -AsPlainText -Force

        # Create the SPN value for the Azure Storage Account; attribute for computer object in AD 
        $SPN = 'cifs/' + $StorageAccountName + $FilesSuffix

        # Create the Description value for the Azure Storage Account; attribute for computer object in AD 
        $Description = "Computer account object for Azure storage account $($StorageAccountName)."

        # Create the AD computer object for the Azure Storage Account
        Write-Host 'Checking AD computer object for Azure Storage Account.'
        $Computer = Get-ADComputer -Credential $DomainCredential -Filter {Name -eq $StorageAccountName}
        if($Computer){
            Write-Host 'Removing AD computer object for Azure Storage Account.'
            Remove-ADComputer -Credential $DomainCredential -Identity $StorageAccountName -Confirm:$false
            Write-Host 'Removed AD computer object for Azure Storage Account.'
        } else {
            Write-Host 'AD computer object for Azure Storage Account does not exist.'
        }
        Write-Host 'Creating AD computer object for Azure Storage Account.'
        $Parameters = @{
            Credential = $DomainCredential
            Name       = $StorageAccountName
            ServicePrincipalNames = $SPN
            AccountPassword = $ComputerPassword
            Description = $Description
            PassThru   = $true
        }
        if ($OrganizationalUnitPath) {$Parameters += @{Path = $OrganizationalUnitPath}}
        $ComputerObject = New-ADComputer @Parameters
        Write-Host 'Created AD computer object for Azure Storage Account.'

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

        Write-Host 'Domain joining the Azure Storage Account.'
        Invoke-RestMethod `
            -Body $Body `
            -Headers $AzureManagementHeader `
            -Method 'PATCH' `
            -Uri $($ResourceManagerUriFixed + '/subscriptions/' + $SubscriptionId + '/resourceGroups/' + $StorageAccountResourceGroupName + '/providers/Microsoft.Storage/storageAccounts/' + $StorageAccountName + '?api-version=2023-05-01')
        Write-Host 'Domain joined the Azure Storage Account.'

        if ($KerberosEncryption -eq 'AES256') {
            # Set the Kerberos encryption on the computer object
            Write-Host 'Setting Kerberos encryption to AES256 on the computer object for the Azure Storage Account.'
            $DistinguishedName = (Get-ADComputer -Credential $DomainCredential -Filter {Name -eq $StorageAccountName}).DistinguishedName
            Set-ADComputer -Credential $DomainCredential -Identity $DistinguishedName -KerberosEncryptionType 'AES256' | Out-Null
            Write-Host 'Set the Kerberos encryption to AES256 on the computer object for the Azure Storage Account.'

            # Reset the Kerberos key on the Storage Account
            Write-Host 'Regenerating the Kerberos key on the Azure Storage Account.'
            Invoke-RestMethod `
                -Body (@{keyName = 'kerb1' } | ConvertTo-Json) `
                -Headers $AzureManagementHeader `
                -Method 'POST' `
                -Uri $($ResourceManagerUriFixed + '/subscriptions/' + $SubscriptionId + '/resourceGroups/' + $StorageAccountResourceGroupName + '/providers/Microsoft.Storage/storageAccounts/' + $StorageAccountName + '/regenerateKey?api-version=2023-05-01')
            Write-Host 'Regenerated the Kerberos key on the Azure Storage Account.'

            Write-Host 'Getting the new Kerberos key for the Azure Storage Account.'
            $Key = ((Invoke-RestMethod `
                -Headers $AzureManagementHeader `
                -Method 'POST' `
                -Uri $($ResourceManagerUriFixed + '/subscriptions/' + $SubscriptionId + '/resourceGroups/' + $StorageAccountResourceGroupName + '/providers/Microsoft.Storage/storageAccounts/' + $StorageAccountName + '/listKeys?api-version=2023-05-01&$expand=kerb')).keys | Where-Object { $_.Keyname -contains 'kerb1' }).Value
            Write-Host 'Collected the new Kerberos key for the Azure Storage Account.'

            # Update the password on the computer object with the new Kerberos key on the Storage Account
            Write-Host 'Updating the password on the computer object with the new Kerberos key for the Azure Storage Account.'
            $NewPassword = ConvertTo-SecureString -String $Key -AsPlainText -Force
            Set-ADAccountPassword -Credential $DomainCredential -Identity $DistinguishedName -Reset -NewPassword $NewPassword | Out-Null
            Write-Host 'Updated the password on the computer object with the new Kerberos key for the Azure Storage Account.'
        } else {
            Write-Host 'Kerberos encryption is set to the default, RC4. Skipping Kerberos encryption for AES256.'
        }
    }

    # Create a PowerShell session configuration for the Azure Storage Account
    Write-Host 'Creating PowerShell session configuration.'
    Register-PSSessionConfiguration -Name $StorageAccountName -RunAsCredential $DomainCredential -Force
    Write-Host 'Created PowerShell session configuration.'

    # Map the Azure Files file share to the drive letter and set NTFS permissions
    Write-Host "Mapping the Azure Files file share to drive letter $DriveLetter and setting NTFS permissions for domain services scenarios."
    Invoke-Command -ArgumentList "$DriveLetter", "$FileShare", "$Group" -ComputerName $env:COMPUTERNAME -ConfigurationName $StorageAccountName -Credential $DomainCredential -ScriptBlock {
        param ($DriveLetter, $FileShare, $Group)
        Start-Process -FilePath 'net.exe' -ArgumentList "use $DriveLetter $FileShare" -Wait -NoNewWindow | Out-Null
        Start-Process -FilePath 'icacls.exe' -ArgumentList "$DriveLetter /grant `"$($Group):(M)`"" -Wait -NoNewWindow | Out-Null
        Start-Process -FilePath 'icacls.exe' -ArgumentList "$DriveLetter /grant `"Creator Owner:(OI)(CI)(IO)(M)`"" -Wait -NoNewWindow | Out-Null
        Start-Process -FilePath 'icacls.exe' -ArgumentList "$DriveLetter /remove `"Authenticated Users`"" -Wait -NoNewWindow | Out-Null
        Start-Process -FilePath 'icacls.exe' -ArgumentList "$DriveLetter /remove `"Builtin\Users`"" -Wait -NoNewWindow | Out-Null
        Start-Process -FilePath 'net.exe' -ArgumentList "use Z: /delete" -Wait -NoNewWindow | Out-Null
    }
    Write-Host 'Mapped the Azure Files file share and set NTFS permissions for domain services scenarios.'
} else {
    # If not using domain services, map the Azure Files file share to the drive letter and set NTFS permissions
    Write-Host "Mapping the Azure Files file share to drive letter $DriveLetter and setting NTFS permissions for Entra ID scenarios."
    Start-Process -FilePath 'net.exe' -ArgumentList "use $DriveLetter $FileShare" -Wait -NoNewWindow | Out-Null
    Start-Process -FilePath 'icacls.exe' -ArgumentList "$DriveLetter /grant `"Creator Owner:(OI)(CI)(IO)(M)`"" -Wait -NoNewWindow | Out-Null
    Start-Process -FilePath 'icacls.exe' -ArgumentList "$DriveLetter /inheritance:r" -Wait -NoNewWindow | Out-Null
    Start-Process -FilePath 'icacls.exe' -ArgumentList "$DriveLetter /remove `"Builtin\Administrators`"" -Wait -NoNewWindow | Out-Null
    Start-Process -FilePath 'icacls.exe' -ArgumentList "$DriveLetter /remove `"Builtin\Users`"" -Wait -NoNewWindow | Out-Null
    Start-Process -FilePath 'net.exe' -ArgumentList "use Z: /delete" -Wait -NoNewWindow | Out-Null
    Write-Host 'Mapped the Azure Files file share and set NTFS permissions for Entra ID scenarios.'
}

