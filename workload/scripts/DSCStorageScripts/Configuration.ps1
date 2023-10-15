<#
    .SYNOPSIS
        A DSC configuration file for domain joining storage account

    .DESCRIPTION
        This script will be run on a domain joined session host under domain admin credentials.
#>

param
(    
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $StorageAccountName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $StorageAccountRG,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $ShareName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $DomainName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $CustomOuPath,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $IdentityServiceProvider,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $AzureCloudEnvironment,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $SubscriptionId,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $ClientId,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$SecurityPrincipalName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $OUName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $StoragePurpose,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $DomainAdminUserName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $StorageAccountFqdn,
	
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $DomainAdminUserPassword
)


Configuration DomainJoinFileShare
{
    param
    (    
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $StorageAccountName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $StorageAccountRG,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $ShareName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $DomainName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $CustomOuPath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $IdentityServiceProvider,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $AzureCloudEnvironment,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $SubscriptionId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $ClientId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$SecurityPrincipalName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $OUName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $StoragePurpose,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $DomainAdminUserName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $StorageAccountFqdn,
	
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $DomainAdminUserPassword
    )
    
    # Import the module that contains the File resource.
    Import-DscResource -ModuleName PsDesiredStateConfiguration
    $secStringPassword = ConvertTo-SecureString $DomainAdminUserPassword -AsPlainText -Force
    $DomainAdminCred = New-Object System.Management.Automation.PSCredential ($DomainAdminUserName, $secStringPassword)

    $ErrorActionPreference = 'Stop'
    
    $ScriptPath = [system.io.path]::GetDirectoryName($PSCommandPath)
    . (Join-Path $ScriptPath "Logger.ps1")
    
    Node localhost
    {
        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
            ConfigurationMode  = "ApplyOnly"
            DebugMode          = "All" 
        }

        Script DomainJoinStorage {
            # TestScript runs first and if it returns false, then SetScript runs
            GetScript            = {
                return @{'Result' = '' }
            }
            SetScript            = {
                . (Join-Path $using:ScriptPath "Logger.ps1")
                try {
                    Write-Log "DSC DomainJoinStorage SetScript Domain joining storage account $Using:StorageAccountName"
                    & "$using:ScriptPath\Script-DomainJoinStorage.ps1" -StorageAccountName $Using:StorageAccountName -StorageAccountRG $Using:StorageAccountRG -SubscriptionId $Using:SubscriptionId -ClientId $Using:ClientId -SecurityPrincipalName $Using:SecurityPrincipalName -ShareName $Using:ShareName -DomainName $Using:DomainName -IdentityServiceProvider $Using:IdentityServiceProvider -AzureCloudEnvironment $Using:AzureCloudEnvironment -CustomOuPath $Using:CustomOuPath -OUName $Using:OUName -StoragePurpose $Using:StoragePurpose -StorageAccountFqdn $Using:StorageAccountFqdn

                    Write-Log "Successfully domain joined and/or NTFS permission set on Storage account"
                }
                catch {
                    $ErrMsg = $PSItem | Format-List -Force | Out-String
                    Write-Log -Err $ErrMsg
                    throw [System.Exception]::new("Some error occurred in DSC DomainJoinStorage SetScript: $ErrMsg", $PSItem.Exception)
                }
            }
            TestScript           = {
                . (Join-Path $using:ScriptPath "Logger.ps1")

                try {
                    Write-Log "DSC DomainJoinStorage TestScript checking if storage account $Using:StorageAccountName is domain joined."
                    $ADModule = Get-Module -Name ActiveDirectory
                    if (-not $ADModule) {
                        return $False
                    }
                    else {
                        Import-Module activedirectory
                        $IsStorageAccountDomainJoined = Get-ADObject -Filter 'ObjectClass -eq "Computer"' | Where-Object { $_.Name -eq $Using:StorageAccountName }
                        if ($IsStorageAccountDomainJoined) {
                            Write-Log "Storage account $Using:StorageAccountName is already domain joined."
                            return $True
                        }
                        else {
                            Write-Log "Storage account $Using:StorageAccount is not domain joined."
                            return $False
                        }
                    }
                }
                catch {
                    $ErrMsg = $PSItem | Format-List -Force | Out-String
                    Write-Log -Err $ErrMsg
                    throw [System.Exception]::new("Some error occurred in DSC DomainJoinStorage TestScript: $ErrMsg", $PSItem.Exception)
                }
            }
		
            PsDscRunAsCredential = $DomainAdminCred
        }
    }
}

$config = @{
    AllNodes = @(
        @{
            NodeName                    = 'localhost';
            PSDscAllowPlainTextPassword = $true
            PsDscAllowDomainUser        = $true
        }
    )
}

DomainJoinFileShare -ConfigurationData $config -StorageAccountName $StorageAccountName -StorageAccountRG $StorageAccountRG -SubscriptionId $SubscriptionId -ShareName $ShareName -DomainName $DomainName -IdentityServiceProvider $IdentityServiceProvider -AzureCloudEnvironment $AzureCloudEnvironment -CustomOuPath $CustomOuPath -OUName $OUName -DomainAdminUserName $DomainAdminUserName -DomainAdminUserPassword $DomainAdminUserPassword -ClientId $ClientId -SecurityPrincipalName $SecurityPrincipalName -StoragePurpose $StoragePurpose -StorageAccountFqdn $StorageAccountFqdn -Verbose;