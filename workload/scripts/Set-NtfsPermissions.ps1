param 
(       
    [Parameter(Mandatory = $false)]
    [string]$AdminGroupNames,

    [Parameter(Mandatory = $true)]
    [String]$Shares,

    [Parameter(Mandatory = $false)]
    [string]$ShardAzureFilesStorage,
    
    [Parameter(Mandatory = $false)]
    [String]$DomainAccountType = "ComputerAccount",

    [Parameter(Mandatory = $true)]
    [String]$DomainJoinUserPwd,

    [Parameter(Mandatory = $true)]
    [String]$DomainJoinUserPrincipalName,

    [Parameter(Mandatory = $false)]
    [ValidateSet("AES256", "RC4")]
    [String]$KerberosEncryptionType,

    [Parameter(Mandatory = $false)]
    [String]$NetAppServers,

    [Parameter(Mandatory = $false)]
    [String]$OuPath,

    [Parameter(Mandatory = $false)]
    [string]$ResourceManagerUri,

    [Parameter(Mandatory = $false)]
    [String]$StorageAccountPrefix,

    [Parameter(Mandatory = $false)]
    [String]$StorageAccountResourceGroupName,

    [Parameter(Mandatory = $false)]
    [String]$StorageCount,

    [Parameter(Mandatory = $false)]
    [String]$StorageIndex,

    [Parameter(Mandatory = $true)]
    [String]$StorageSolution,

    [Parameter(Mandatory = $false)]
    [String]$StorageSuffix,

    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $false)]
    [String]$UserGroupNames,

    [Parameter(Mandatory = $false)]
    [string]$UserAssignedIdentityClientId
)

$ErrorActionPreference = 'Stop'
$WarningPreference = 'SilentlyContinue'

[string]$Script:LogDir = "C:\WindowsAzure\Logs\RunCommands"
[string]$Script:Name = 'Set-NTFSPermissions'

Function ConvertFrom-JsonString {
    [CmdletBinding()]
    param (
        [string]$JsonString,
        [string]$Name,
        [switch]$SensitiveValues      
    )
    If ($JsonString -ne '[]' -and $JsonString -ne $null) {
        [array]$Array = $JsonString.replace('\"', '"') | ConvertFrom-Json
        If ($Array.Length -gt 0) {
            If ($SensitiveValues) { Write-Log -message "Array '$Name' has $($Array.Length) members" } Else { Write-Log -message "$($Name): '$($Array -join "', '")'" }
            Return $Array
        }
        Else {
            Return $null
        }            
    }
    Else {
        Return $null
    }    
}

Function Get-FullyQualifiedGroupName {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$GroupDisplayName,
        [pscredential]$Credential
    )
    $Group = $null
    $Group = Get-ADGroup -Filter "Name -eq '$groupDisplayName'" -Credential $Credential    
    If ($null -ne $Group) {
        # Extract the domain components from the distinguished name
        $domainComponents = ($group.DistinguishedName -split ',') | Where-Object { $_ -like 'DC=*' }
        # Construct the domain name
        $domainName = ($domainComponents -replace 'DC=', '') -join '.'
        # Get the domain information
        $domain = Get-ADDomain -Identity $domainName
        # Get the NetBIOS name
        $netbiosName = $domain.NetBIOSName
        # Combine NetBIOS name and group name
        $GroupName = "$netbiosName\$($group.SamAccountName)"
        Return $GroupName
    }
    Return $null
}

function Update-ACL {
    Param (
        [Parameter(Mandatory = $false)]
        [Array]$AdminGroups,
        [Parameter(Mandatory = $true)]
        [pscredential]$Credential,
        [Parameter(Mandatory = $true)]
        [String]$FileShare,
        [Parameter(Mandatory = $true)]
        [Array]$UserGroups
    )
    # Map Drive
    Write-Log -message "[Update-ACL]: Mapping Drive to $FileShare"
    New-PSDrive -Name 'Z' -PSProvider 'FileSystem' -Root $FileShare -Credential $Credential | Out-Null
    # Set recommended NTFS permissions on the file share
    Write-Log -message "[Update-ACL]: Getting Existing ACL for $FileShare"
    $ACL = Get-Acl -Path 'Z:'
    $CreatorOwner = [System.Security.Principal.Ntaccount]("Creator Owner")
    Write-Log -message "[Update-ACL]: Purging Existing Access Control Entries for 'Creater Owner' from ACL"
    $ACL.PurgeAccessRules($CreatorOwner)
    $AuthenticatedUsers = [System.Security.Principal.Ntaccount]("Authenticated Users")
    Write-Log -message "[Update-ACL]: Purging Existing Access Control Entries for 'Authenticated Users' from ACL"
    $ACL.PurgeAccessRules($AuthenticatedUsers)
    $Users = [System.Security.Principal.Ntaccount]("Users")
    Write-Log -message "[Update-ACL]: Purging Existing Access Control Entries for 'Users' from ACL"
    $ACL.PurgeAccessRules($Users)
    If ($AdminGroups.Count -gt 0) {
        ForEach ($Group in $AdminGroups) {
            Write-Log -message "[Update-ACL]: Adding ACE '$($Group):Full Control' to ACL."
            $Ntaccount = [System.Security.Principal.Ntaccount]("$Group")
            $ACE = ([System.Security.AccessControl.FileSystemAccessRule]::new("$Ntaccount", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"))
            $ACL.SetAccessRule($ACE)
        }
    }

    ForEach ($Group in $UserGroups) {
        Write-Log -message "[Update-ACL]: Adding ACE '$($Group):Modify (This Folder Only)' to ACL."
        $Ntaccount = [System.Security.Principal.Ntaccount]("$Group")
        $ACE = ([System.Security.AccessControl.FileSystemAccessRule]::new("$Ntaccount", "Modify", "None", "None", "Allow"))
        $ACL.SetAccessRule($ACE)
    }

    Write-Log -message "[Update-ACL]: Adding ACE 'Creator Owner:Modify (Subfolder and Files Only)' to ACL."
    $ACE = ([System.Security.AccessControl.FileSystemAccessRule]::new("$CreatorOwner", "Modify", "ContainerInherit,ObjectInherit", "InheritOnly", "Allow"))
    $ACL.SetAccessRule($ACE)
    Write-Log -message "[Update-ACL]: Applying the following ACL to $($FileShare):"
    Write-Log -message "$($ACL.access | Format-Table | Out-String)"
    $ACL | Set-Acl -Path 'Z:' | Out-Null
    Start-Sleep -Seconds 5 | Out-Null
    $ACL = Get-Acl -Path 'Z:'
    Write-Log -message "[Update-ACL]: Current ACL of $($FileShare):"
    Write-Log -message "$($ACL.access | Format-Table | Out-String)"
    # Unmount file share
    Write-Log -message "[Update-ACL]: Unmapping Drive from $FileShare"
    Remove-PSDrive -Name 'Z' -PSProvider 'FileSystem' -Force | Out-Null
    Start-Sleep -Seconds 5 | Out-Null
}

function New-Log {
    <#
    .SYNOPSIS
    Sets default log file and stores in a script accessible variable $script:Log
    Log File name "packageExecution_$date.log"

    .PARAMETER Path
    Path to the log file

    .EXAMPLE
    New-Log c:\Windows\Logs
    Create a new log file in c:\Windows\Logs
    #>

    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Path
    )

    # Create central log file with given date

    $date = Get-Date -UFormat "%Y-%m-%d %H-%M-%S"
    Set-Variable logFile -Scope Script
    $script:logFile = "$Script:Name-$date.log"

    if ((Test-Path $path ) -eq $false) {
        $null = New-Item -Path $path -type directory
    }

    $script:Log = Join-Path $path $logfile

    Add-Content $script:Log "Date`t`t`tCategory`t`tDetails"
}

function Write-Log {

    <#
    .SYNOPSIS
    Creates a log file and stores logs based on categories with tab seperation

    .PARAMETER category
    Category to put into the trace

    .PARAMETER message
    Message to be loged

    .EXAMPLE
    Log 'Info' 'Message'

    #>

    Param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateSet("Info", "Warning", "Error")]
        $category = 'Info',
        [Parameter(Mandatory = $true, Position = 1)]
        $message
    )

    $date = get-date
    $content = "[$date]`t$category`t`t$message" 
    Add-Content $Script:Log $content -ErrorAction Stop
}

try {
    
    New-Log -Path $Script:LogDir
    write-log -message "*** Parameter Values ***"

    # Convert Parameters passed as a JSON String to an array and remove any backslashes
    [array]$AdminGroupNames = ConvertFrom-JsonString -JsonString $AdminGroupNames -Name 'AdminGroupNames'
    [array]$Shares = ConvertFrom-JsonString -JsonString $Shares -Name 'Shares'
    [array]$UserGroupNames = ConvertFrom-JsonString -JsonString $UserGroupNames -Name 'UserGroupNames'

    # Check if the Active Directory module is installed
    $RsatInstalled = (Get-WindowsFeature -Name 'RSAT-AD-PowerShell').Installed
    if (!$RsatInstalled) {
        Install-WindowsFeature -Name 'RSAT-AD-PowerShell' | Out-Null
    }
    # Create Domain credential
    $DomainJoinUserName = $DomainJoinUserPrincipalName.Split('@')[0]
    $DomainPassword = ConvertTo-SecureString -String $DomainJoinUserPwd -AsPlainText -Force
    [pscredential]$DomainCredential = New-Object System.Management.Automation.PSCredential ($DomainJoinUserName, $DomainPassword)

    # Get Domain information
    $Domain = Get-ADDomain -Credential $DomainCredential -Current 'LocalComputer'
    Write-Log -message "Domain Information:"
    Write-Log -message "DistiguishedName: $($Domain.DistinguishedName)"
    Write-Log -message "DNSRoot: $($Domain.DNSRoot)"
    Write-Log -message "NetBIOSName: $($Domain.NetBIOSName)"

    # Get the SamAccountName for all the DisplayNames provided.
    if ($AdminGroupNames.Count -gt 0) {
        [array]$AdminGroups = @()
        Write-Log -message "Processing AdminGroupNames by searching AD for Groups with the provided display name and returning the SamAccountName"
        ForEach ($DisplayName in $AdminGroupNames) {
            Write-Log -message "Processing AdminGroupName: $DisplayName"
            $FullyQualifiedGroupName = $null
            $FullyQualifiedGroupName = Get-FullyQualifiedGroupName -GroupDisplayName $DisplayName -Credential $DomainCredential
            If ($null -ne $FullyQualifiedGroupName) {
                Write-Log -message "Found Group: $FullyQualifiedGroupName"
                $AdminGroups += $FullyQualifiedGroupName
            }
            Else {
                Write-Log -message "Admin Group not found in Active Directory"
            }            
        }
    }

    Write-Log -message "Processing UserGroupNames by searching AD for Groups with the provided display name and returning the SamAccountName"
    [array]$UserGroups = @()
    ForEach ($DisplayName in $UserGroupNames) {
        Write-Log -message "Processing UserGroupName: $DisplayName"
        $FullyQualifiedGroupName = $null
        $FullyQualifiedGroupName = Get-FullyQualifiedGroupName -GroupDisplayName $DisplayName -Credential $DomainCredential
        If ($null -ne $FullyQualifiedGroupName) {
            Write-Log -message "Found Group: $FullyQualifiedGroupName"
            $UserGroups += $FullyQualifiedGroupName
        }
        Else {
            Write-Log -message "User not found"
        }    
    }

    Switch ($StorageSolution) {
        'AzureFiles' {
            Write-Log -message "Processing Azure Files"
            # Convert strings to integers    
            [int]$StCount = $StorageCount.replace('\"', '"')
            [int]$StIndex = $StorageIndex.replace('\"', '"')
            Write-Log -message "Storage Account Count: $StCount"
            Write-Log -message "Storage Account Index: $StIndex"
            # Remove any escape characters from strings
            $OuPath = $OuPath.Replace('\"', '"')
            Write-Log -message "OU Path: $OuPath"
            $ResourceManagerUri = $ResourceManagerUri.Replace('\"', '"')
            Write-Log -message "ResourceManagerUri: $ResourceManagerUri"
            $StorageAccountPrefix = $StorageAccountPrefix.ToLower().replace('\"', '"')
            Write-Log -message "Storage Account Prefix: $StorageAccountPrefix"
            $StorageAccountResourceGroupName = $StorageAccountResourceGroupName.Replace('\"', '"')
            Write-Log -message "Storage Account Resource Group Name: $StorageAccountResourceGroupName"
            $SubscriptionId = $SubscriptionId.replace('\"', '"')
            Write-Log -message "Subscription Id: $SubscriptionId"            
            $UserAssignedIdentityClientId = $UserAssignedIdentityClientId.replace('\"', '"')
            Write-Log -message "User Assigned Identity Client Id: $UserAssignedIdentityClientId"
            # Set the suffix for the Azure Files
            $FilesSuffix = ".file.$($StorageSuffix.Replace('\"', '"'))"
            Write-Log -message "Files Suffix: $FilesSuffix"
            # Fix the resource manager URI since only AzureCloud contains a trailing slash
            $ResourceManagerUriFixed = if ($ResourceManagerUri[-1] -eq '/') { $ResourceManagerUri.Substring(0, $ResourceManagerUri.Length - 1) } else { $ResourceManagerUri }
            # Get an access token for Azure resources
            Write-Log -message "Getting an access token for Azure resources"
            $AzureManagementAccessToken = (Invoke-RestMethod `
                    -Headers @{Metadata = "true" } `
                    -Uri $('http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=' + $ResourceManagerUriFixed + '&client_id=' + $UserAssignedIdentityClientId)).access_token
            # Set header for Azure Management API
            $AzureManagementHeader = @{
                'Content-Type'  = 'application/json'
                'Authorization' = 'Bearer ' + $AzureManagementAccessToken
            }   
            for ($i = 0; $i -lt $StCount; $i++) {
                # Build the Storage Account Name and FQDN
                $StorageAccountName = $StorageAccountPrefix + ($i + $StIndex).ToString().PadLeft(2, '0')
                Write-Log -message "Processing Storage Account Name: $StorageAccountName"
                $FileServer = '\\' + $StorageAccountName + $FilesSuffix
                # Get the storage account key
                $StorageKey = (Invoke-RestMethod `
                        -Headers $AzureManagementHeader `
                        -Method 'POST' `
                        -Uri $($ResourceManagerUriFixed + '/subscriptions/' + $SubscriptionId + '/resourceGroups/' + $StorageAccountResourceGroupName + '/providers/Microsoft.Storage/storageAccounts/' + $StorageAccountName + '/listKeys?api-version=2023-05-01')).keys[0].value
                
                # Create credential for accessing the storage account
                Write-Log -message "Building Storage Key Credential"
                $StorageUsername = 'Azure\' + $StorageAccountName
                $StoragePassword = ConvertTo-SecureString -String "$($StorageKey)" -AsPlainText -Force
                [pscredential]$StorageKeyCredential = New-Object System.Management.Automation.PSCredential ($StorageUsername, $StoragePassword)
                Write-Log -message "Successfully Built Storage Key Credential"
                # Get / create kerberos key for Azure Storage Account
                Write-Log -message "Getting Kerberos Key for Azure Storage Account"
                $KerberosKey = ((Invoke-RestMethod `
                            -Headers $AzureManagementHeader `
                            -Method 'POST' `
                            -Uri $($ResourceManagerUriFixed + '/subscriptions/' + $SubscriptionId + '/resourceGroups/' + $StorageAccountResourceGroupName + '/providers/Microsoft.Storage/storageAccounts/' + $StorageAccountName + '/listKeys?api-version=2023-05-01&$expand=kerb')).keys | Where-Object { $_.Keyname -contains 'kerb1' }).Value
                
                if (!$KerberosKey) {
                    Write-Log -message "Kerberos Key not found, Generating a new key"
                    $null = Invoke-RestMethod `
                        -Body (@{keyName = 'kerb1' } | ConvertTo-Json) `
                        -Headers $AzureManagementHeader `
                        -Method 'POST' `
                        -Uri $($ResourceManagerUriFixed + '/subscriptions/' + $SubscriptionId + '/resourceGroups/' + $StorageAccountResourceGroupName + '/providers/Microsoft.Storage/storageAccounts/' + $StorageAccountName + '/regenerateKey?api-version=2023-05-01')
                    $Key = ((Invoke-RestMethod `
                                -Headers $AzureManagementHeader `
                                -Method 'POST' `
                                -Uri $($ResourceManagerUriFixed + '/subscriptions/' + $SubscriptionId + '/resourceGroups/' + $StorageAccountResourceGroupName + '/providers/Microsoft.Storage/storageAccounts/' + $StorageAccountName + '/listKeys?api-version=2023-05-01&$expand=kerb')).keys | Where-Object { $_.Keyname -contains 'kerb1' }).Value
                } 
                else {
                    Write-Log -message "Kerberos Key found"
                    $Key = $KerberosKey
                }
                # Creates a password for the Azure Storage Account in AD using the Kerberos key
                Write-Log -message "Creating a password for the Azure Storage Account in AD using the Kerberos key"
                $ComputerPassword = ConvertTo-SecureString -String $Key.Replace("'", "") -AsPlainText -Force  
                # Create the SPN value for the Azure Storage Account; attribute for computer object in AD
                Write-Log -message "Creating the SPN value for the Azure Storage Account" 
                $SPN = 'cifs/' + $StorageAccountName + $FilesSuffix
                # Create the Description value for the Azure Storage Account; attribute for computer object in AD 
                $Description = "Computer account object for Azure storage account $($StorageAccountName)."

                # Create the AD computer object for the Azure Storage Account
                Write-Log -message "Searching for existing computer account object for Azure Storage Account"
                $Computer = Get-ADComputer -Credential $DomainCredential -Filter { Name -eq $StorageAccountName }
                if ($Computer) {
                    Write-Log -message "Computer account object for Azure Storage Account found, removing the existing object"
                    Remove-ADComputer -Credential $DomainCredential -Identity $StorageAccountName -Confirm:$false
                }
                Else {
                    Write-Log -message "Computer account object for Azure Storage Account not found"
                }
                Write-Log -message "Creating the AD computer object for the Azure Storage Account"
                $ComputerObject = New-ADComputer -Credential $DomainCredential -Name $StorageAccountName -Path $OuPath -ServicePrincipalNames $SPN -AccountPassword $ComputerPassword -Description $Description -PassThru
                # Update the Azure Storage Account with the domain join 'INFO'
                Write-Log -message "Updating the Azure Storage Account with the domain join 'INFO'"
                $SamAccountName = switch ($KerberosEncryptionType) {
                    'AES256' { $StorageAccountName }
                    'RC4' { $ComputerObject.SamAccountName }
                }    
                $Body = (@{
                        properties = @{
                            azureFilesIdentityBasedAuthentication = @{
                                activeDirectoryProperties = @{
                                    accountType       = 'Computer'
                                    azureStorageSid   = $ComputerObject.SID.Value
                                    domainGuid        = $Domain.ObjectGUID.Guid
                                    domainName        = $Domain.DNSRoot
                                    domainSid         = $Domain.DomainSID.Value
                                    forestName        = $Domain.Forest
                                    netBiosDomainName = $Domain.NetBIOSName
                                    samAccountName    = $samAccountName
                                }
                                directoryServiceOptions   = 'AD'
                            }
                        }
                    } | ConvertTo-Json -Depth 6 -Compress)  

                $null = Invoke-RestMethod `
                    -Body $Body `
                    -Headers $AzureManagementHeader `
                    -Method 'PATCH' `
                    -Uri $($ResourceManagerUriFixed + '/subscriptions/' + $SubscriptionId + '/resourceGroups/' + $StorageAccountResourceGroupName + '/providers/Microsoft.Storage/storageAccounts/' + $StorageAccountName + '?api-version=2023-05-01')             
                
                # Enable AES256 encryption if selected
                if ($KerberosEncryptionType -eq 'AES256') {
                    Write-Log -message "Setting the Kerberos encryption to $KerberosEncryptionType the computer object"
                    # Set the Kerberos encryption on the computer object
                    $DistinguishedName = 'CN=' + $StorageAccountName + ',' + $OuPath
                    Set-ADComputer -Credential $DomainCredential -Identity $DistinguishedName -KerberosEncryptionType 'AES256' | Out-Null
                    
                    # Reset the Kerberos key on the Storage Account
                    Write-Log -message "Resetting the kerb1 key on the Storage Account"
                    $null = Invoke-RestMethod `
                        -Body (@{keyName = 'kerb1' } | ConvertTo-Json) `
                        -Headers $AzureManagementHeader `
                        -Method 'POST' `
                        -Uri $($ResourceManagerUriFixed + '/subscriptions/' + $SubscriptionId + '/resourceGroups/' + $StorageAccountResourceGroupName + '/providers/Microsoft.Storage/storageAccounts/' + $StorageAccountName + '/regenerateKey?api-version=2023-05-01')
                    
                    Write-Log -message "Resetting the kerb2 key on the Storage Account"
                    $null = Invoke-RestMethod `
                        -Body (@{keyName = 'kerb2' } | ConvertTo-Json) `
                        -Headers $AzureManagementHeader `
                        -Method 'POST' `
                        -Uri $($ResourceManagerUriFixed + '/subscriptions/' + $SubscriptionId + '/resourceGroups/' + $StorageAccountResourceGroupName + '/providers/Microsoft.Storage/storageAccounts/' + $StorageAccountName + '/regenerateKey?api-version=2023-05-01')

                    $Key = ((Invoke-RestMethod `
                                -Headers $AzureManagementHeader `
                                -Method 'POST' `
                                -Uri $($ResourceManagerUriFixed + '/subscriptions/' + $SubscriptionId + '/resourceGroups/' + $StorageAccountResourceGroupName + '/providers/Microsoft.Storage/storageAccounts/' + $StorageAccountName + '/listKeys?api-version=2023-05-01&$expand=kerb')).keys | Where-Object { $_.Keyname -contains 'kerb1' }).Value
                
                    # Update the password on the computer object with the new Kerberos key on the Storage Account
                    Write-Log -message "Updating the password on the computer object with the new Kerberos key (kerb1) on the Storage Account"
                    $NewPassword = ConvertTo-SecureString -String $Key -AsPlainText -Force
                    Set-ADAccountPassword -Credential $DomainCredential -Identity $DistinguishedName -Reset -NewPassword $NewPassword | Out-Null
                }
                if ($ShardAzureFilesStorage -eq 'true') {
                    foreach ($Share in $Shares) {
                        $FileShare = $FileServer + '\' + $Share
                        $UserGroup = $null
                        [array]$UserGroup += $UserGroups[$i]
                        Write-Log -message "Processing File Share: $FileShare with UserGroup = $($UserGroups[$i])"
                        if ($AdminGroups.Count -gt 0) {
                            Write-Log -message "Admin Groups provided, executing Update-ACL with Admin Groups"
                            Update-ACL -AdminGroups $AdminGroups -Credential $StorageKeyCredential -FileShare $FileShare -UserGroups $UserGroup
                        }
                        Else {
                            Write-Log -message "Admin Groups not provided, executing Update-ACL without Admin Groups"
                            Update-ACL -Credential $StorageKeyCredential -FileShare $FileShare -UserGroups $UserGroup
                        }
                    }
                }
                Else {
                    foreach ($Share in $Shares) {
                        $FileShare = $FileServer + '\' + $Share
                        Write-Log -message "Processing File Share: $FileShare"
                        if ($AdminGroups.Count -gt 0) {
                            Write-Log -message "Admin Groups provided, executing Update-ACL with Admin Groups"
                            Update-ACL -AdminGroups $AdminGroups -Credential $StorageKeyCredential -FileShare $FileShare -UserGroups $UserGroups
                        }
                        Else {
                            Write-Log -message "Admin Groups not provided, executing Update-ACL without Admin Groups"
                            Update-ACL -Credential $StorageKeyCredential -FileShare $FileShare -UserGroups $UserGroups
                        }
                    }
                }
            }
        }
        'AzureNetAppFiles' {
            Write-Log -message "Processing Azure NetApp Files"        

            [array]$NetAppServers = ConvertFrom-JsonString -JsonString $NetAppServers -Name 'NetAppServers'

            $ProfileShare = "\\$($NetAppServers[0])\$($Shares[0])"
            Write-Log -message "Processing Profile Share: $ProfileShare"
            if ($AdminGroups.Count -gt 0) {
                Write-Log -message "Admin Groups and UserGroups provided, executing Update-ACL with Admin Groups and UserGroups"
                Update-ACL -AdminGroups $AdminGroups -Credential $DomainCredential -FileShare $ProfileShare -UserGroups $UserGroups
            }
            Else {
                Write-Log -message "UserGroups provided, executing Update-ACL with UserGroups only"
                Update-ACL -Credential $DomainCredential -FileShare $ProfileShare -UserGroups $UserGroups
            }
            
            If ($NetAppServers.Count -gt 1 -and $Shares.Count -gt 1) {
                $OfficeShare = "\\" + $NetAppServers[1] + "\" + $Shares[1]
                Write-Log -message "Processing Office Share: $OfficeShare"
                If ($AdminGroups.Count -gt 0 -and $UserGroups.Count -gt 0) {
                    Write-Log -message "Admin Groups and UserGroups provided, executing Update-ACL with Admin Groups and UserGroups"
                    Update-ACL -AdminGroups $AdminGroups -Credential $DomainCredential -FileShare $OfficeShare -UserGroups $UserGroups
                }
                ElseIf ($AdminGroups.Count -gt 0 -and $UserGroups.Count -eq 0) {
                    Write-Log -message "Admin Groups provided, executing Update-ACL with Admin Groups only"
                    Update-ACL -AdminGroups $AdminGroups -Credential $DomainCredential -FileShare $OfficeShare
                }
                ElseIf ($AdminGroups.Count -eq 0 -and $UserGroups.Count -gt 0) {
                    Write-Log -message "UserGroups provided, executing Update-ACL with UserGroups only"
                    Update-ACL -Credential $DomainCredential -FileShare $OfficeShare -UserGroups $UserGroups
                }
                Else {
                    Write-Log -message "No Admin Groups or UserGroups provided, executing Update-ACL without Admin Groups or UserGroups"
                    Update-ACL -Credential $DomainCredential -FileShare $OfficeShare
                }
            }
        }
    } 
}
catch {
    throw
}