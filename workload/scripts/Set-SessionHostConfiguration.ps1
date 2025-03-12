Param(
        [parameter(Mandatory = $false)]
        [string]
        $IdentityDomainName, 

        [parameter(Mandatory)]
        [string]
        $AmdVmSize, 

        [parameter(Mandatory)]
        [string]
        $IdentityServiceProvider,

        [parameter(Mandatory)]
        [string]
        $FSLogix,

        [parameter(Mandatory = $false)]
        [string]
        $FSLogixStorageAccountKey,

        [parameter(Mandatory = $false)]
        [string]
        $FSLogixFileShare,

        [parameter(Mandatory)]
        [string]
        $HostPoolRegistrationToken,    

        [parameter(Mandatory)]
        [string]
        $NvidiaVmSize

        # [parameter(Mandatory)]
        # [string]
        # $ScreenCaptureProtection
)

function New-Log {
        Param (
                [Parameter(Mandatory = $true, Position = 0)]
                [string] $Path
        )
    
        $date = Get-Date -UFormat "%Y-%m-%d %H-%M-%S"
        Set-Variable logFile -Scope Script
        $script:logFile = "$Script:Name-$date.log"
    
        if ((Test-Path $path ) -eq $false) {
                $null = New-Item -Path $path -ItemType directory
        }
    
        $script:Log = Join-Path $path $logfile
    
        Add-Content $script:Log "Date`t`t`tCategory`t`tDetails"
}

function Write-Log {
        Param (
                [Parameter(Mandatory = $false, Position = 0)]
                [ValidateSet("Info", "Warning", "Error")]
                $Category = 'Info',
                [Parameter(Mandatory = $true, Position = 1)]
                $Message
        )
    
        $Date = get-date
        $Content = "[$Date]`t$Category`t`t$Message`n" 
        Add-Content $Script:Log $content -ErrorAction Stop
        If ($Verbose) {
                Write-Verbose $Content
        }
        Else {
                Switch ($Category) {
                        'Info' { Write-Host $content }
                        'Error' { Write-Error $Content }
                        'Warning' { Write-Warning $Content }
                }
        }
}

function Get-WebFile {
        param(
                [parameter(Mandatory)]
                [string]$FileName,

                [parameter(Mandatory)]
                [string]$URL
        )
        $Counter = 0
        do {
                Invoke-WebRequest -Uri $URL -OutFile $FileName -ErrorAction 'SilentlyContinue'
                if ($Counter -gt 0) {
                        Start-Sleep -Seconds 30
                }
                $Counter++
        }
        until((Test-Path $FileName) -or $Counter -eq 9)
}

Function Set-RegistryValue {
        [CmdletBinding()]
        param (
                [Parameter()]
                [string]
                $Name,
                [Parameter()]
                [string]
                $Path,
                [Parameter()]
                [string]$PropertyType,
                [Parameter()]
                $Value
        )
        Begin {
                Write-Log -message "[Set-RegistryValue]: Setting Registry Value: $Name"
        }
        Process {
                # Create the registry Key(s) if necessary.
                If (!(Test-Path -Path $Path)) {
                        Write-Log -message "[Set-RegistryValue]: Creating Registry Key: $Path"
                        New-Item -Path $Path -Force | Out-Null
                }
                # Check for existing registry setting
                $RemoteValue = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
                If ($RemoteValue) {
                        # Get current Value
                        $CurrentValue = Get-ItemPropertyValue -Path $Path -Name $Name
                        Write-Log -message "[Set-RegistryValue]: Current Value of $($Path)\$($Name) : $CurrentValue"
                        If ($Value -ne $CurrentValue) {
                                Write-Log -message "[Set-RegistryValue]: Setting Value of $($Path)\$($Name) : $Value"
                                Set-ItemProperty -Path $Path -Name $Name -Value $Value -Force | Out-Null
                        }
                        Else {
                                Write-Log -message "[Set-RegistryValue]: Value of $($Path)\$($Name) is already set to $Value"
                        }           
                }
                Else {
                        Write-Log -message "[Set-RegistryValue]: Setting Value of $($Path)\$($Name) : $Value"
                        New-ItemProperty -Path $Path -Name $Name -PropertyType $PropertyType -Value $Value -Force | Out-Null
                }
                Start-Sleep -Milliseconds 500
        }
        End {
        }
}

$ErrorActionPreference = 'Stop'
$Script:Name = 'Set-SessionHostConfiguration'
New-Log -Path (Join-Path -Path $env:SystemRoot -ChildPath 'Logs')
try {

        ##############################################################
        #  Add Recommended AVD Settings
        ##############################################################
        $Settings = @(

                # Disable Automatic Updates: https://docs.microsoft.com/en-us/azure/virtual-desktop/set-up-customize-master-image#disable-automatic-updates
                [PSCustomObject]@{
                        Name         = 'NoAutoUpdate'
                        Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
                        PropertyType = 'DWord'
                        Value        = 1
                },

                # Enable Time Zone Redirection: https://docs.microsoft.com/en-us/azure/virtual-desktop/set-up-customize-master-image#set-up-time-zone-redirection
                [PSCustomObject]@{
                        Name         = 'fEnableTimeZoneRedirection'
                        Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
                        PropertyType = 'DWord'
                        Value        = 1
                }
        )

        ##############################################################
        #  Add GPU Settings
        ##############################################################
        # This setting applies to the VM Size's recommended for AVD with a GPU
        if ($AmdVmSize -eq 'true' -or $NvidiaVmSize -eq 'true') {
                $Settings += @(

                        # Configure GPU-accelerated app rendering: https://docs.microsoft.com/en-us/azure/virtual-desktop/configure-vm-gpu#configure-gpu-accelerated-app-rendering
                        [PSCustomObject]@{
                                Name         = 'bEnumerateHWBeforeSW'
                                Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
                                PropertyType = 'DWord'
                                Value        = 1
                        },
                        # Configure fullscreen video encoding: https://docs.microsoft.com/en-us/azure/virtual-desktop/configure-vm-gpu#configure-fullscreen-video-encoding
                        [PSCustomObject]@{
                                Name         = 'AVC444ModePreferred'
                                Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
                                PropertyType = 'DWord'
                                Value        = 1
                        },
                        [PSCustomObject]@{
                                Name         = 'KeepAliveEnable'
                                Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
                                PropertyType = 'DWord'
                                Value        = 1
                        },
                        [PSCustomObject]@{
                                Name         = 'KeepAliveInterval'
                                Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
                                PropertyType = 'DWord'
                                Value        = 1
                        },
                        [PSCustomObject]@{
                                Name         = 'MinEncryptionLevel'
                                Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
                                PropertyType = 'DWord'
                                Value        = 3
                        },
                        [PSCustomObject]@{
                                Name         = 'AVCHardwareEncodePreferred'
                                Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
                                PropertyType = 'DWord'
                                Value        = 1
                        }
                )
        }
        # This setting applies only to VM Size's recommended for AVD with a Nvidia GPU
        if ($NvidiaVmSize -eq 'true') {
                $Settings += @(

                        # Configure GPU-accelerated frame encoding: https://docs.microsoft.com/en-us/azure/virtual-desktop/configure-vm-gpu#configure-gpu-accelerated-frame-encoding
                        [PSCustomObject]@{
                                Name         = 'AVChardwareEncodePreferred'
                                Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
                                PropertyType = 'DWord'
                                Value        = 1
                        }
                )
        }

        # ##############################################################
        # #  Add Screen Capture Protection Setting
        # ##############################################################
        # if ($ScreenCaptureProtection -eq 'true') {
        #         $Settings += @(

        #                 # Enable Screen Capture Protection: https://docs.microsoft.com/en-us/azure/virtual-desktop/screen-capture-protection
        #                 [PSCustomObject]@{
        #                         Name         = 'fEnableScreenCaptureProtect'
        #                         Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
        #                         PropertyType = 'DWord'
        #                         Value        = 1
        #                 }
        #         )
        # }

        ##############################################################
        #  Add Fslogix Settings
        ##############################################################
        if ($Fslogix -eq 'true') {
                $FSLogixStorageFQDN = $FSLogixFileShare.Split('\')[2]                
                $Settings += @(
                        # Enables Fslogix profile containers: https://docs.microsoft.com/en-us/fslogix/profile-container-configuration-reference#enabled
                        [PSCustomObject]@{
                                Name         = 'Enabled'
                                Path         = 'HKLM:\SOFTWARE\Fslogix\Profiles'
                                PropertyType = 'DWord'
                                Value        = 1
                        },
                        # Deletes a local profile if it exists and matches the profile being loaded from VHD: https://docs.microsoft.com/en-us/fslogix/profile-container-configuration-reference#deletelocalprofilewhenvhdshouldapply
                        [PSCustomObject]@{
                                Name         = 'DeleteLocalProfileWhenVHDShouldApply'
                                Path         = 'HKLM:\SOFTWARE\FSLogix\Profiles'
                                PropertyType = 'DWord'
                                Value        = 1
                        },
                        # The folder created in the Fslogix fileshare will begin with the username instead of the SID: https://docs.microsoft.com/en-us/fslogix/profile-container-configuration-reference#flipflopprofiledirectoryname
                        [PSCustomObject]@{
                                Name         = 'FlipFlopProfileDirectoryName'
                                Path         = 'HKLM:\SOFTWARE\FSLogix\Profiles'
                                PropertyType = 'DWord'
                                Value        = 1
                        },
                        # # Loads FRXShell if there's a failure attaching to, or using an existing profile VHD(X): https://docs.microsoft.com/en-us/fslogix/profile-container-configuration-reference#preventloginwithfailure
                        # [PSCustomObject]@{
                        #         Name         = 'PreventLoginWithFailure'
                        #         Path         = 'HKLM:\SOFTWARE\FSLogix\Profiles'
                        #         PropertyType = 'DWord'
                        #         Value        = 1
                        # },
                        # # Loads FRXShell if it's determined a temp profile has been created: https://docs.microsoft.com/en-us/fslogix/profile-container-configuration-reference#preventloginwithtempprofile
                        # [PSCustomObject]@{
                        #         Name         = 'PreventLoginWithTempProfile'
                        #         Path         = 'HKLM:\SOFTWARE\FSLogix\Profiles'
                        #         PropertyType = 'DWord'
                        #         Value        = 1
                        # },
                        # List of file system locations to search for the user's profile VHD(X) file: https://docs.microsoft.com/en-us/fslogix/profile-container-configuration-reference#vhdlocations
                        [PSCustomObject]@{
                                Name         = 'VHDLocations'
                                Path         = 'HKLM:\SOFTWARE\FSLogix\Profiles'
                                PropertyType = 'MultiString'
                                Value        = $FSLogixFileShare
                        },
                        [PSCustomObject]@{
                                Name         = 'VolumeType'
                                Path         = 'HKLM:\SOFTWARE\FSLogix\Profiles'
                                PropertyType = 'String'
                                Value        = 'vhdx'
                        },
                        [PSCustomObject]@{
                                Name         = 'LockedRetryCount'
                                Path         = 'HKLM:\SOFTWARE\FSLogix\Profiles'
                                PropertyType = 'DWord'
                                Value        = 3
                        },
                        [PSCustomObject]@{
                                Name         = 'LockedRetryInterval'
                                Path         = 'HKLM:\SOFTWARE\FSLogix\Profiles'
                                PropertyType = 'DWord'
                                Value        = 15
                        },
                        [PSCustomObject]@{
                                Name         = 'ReAttachIntervalSeconds'
                                Path         = 'HKLM:\SOFTWARE\FSLogix\Profiles'
                                PropertyType = 'DWord'
                                Value        = 15
                        },
                        [PSCustomObject]@{
                                Name         = 'ReAttachRetryCount'
                                Path         = 'HKLM:\SOFTWARE\FSLogix\Profiles'
                                PropertyType = 'DWord'
                                Value        = 3
                        }
                )
                if ($IdentityServiceProvider -eq "EntraIDKerberos" -and $Fslogix -eq 'true') {
                        $Settings += @(
                                [PSCustomObject]@{
                                        Name         = 'CloudKerberosTicketRetrievalEnabled'
                                        Path         = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters'
                                        PropertyType = 'DWord'
                                        Value        = 1
                                },
                                [PSCustomObject]@{
                                        Name         = 'LoadCredKeyFromProfile'
                                        Path         = 'HKLM:\Software\Policies\Microsoft\AzureADAccount'
                                        PropertyType = 'DWord'
                                        Value        = 1
                                },
                                [PSCustomObject]@{
                                        Name         = $IdentityDomainName
                                        Path         = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\domain_realm'
                                        PropertyType = 'String'
                                        Value        = $FSLogixStorageFQDN
                                }

                        )
                }
                If ($FsLogixStorageAccountKey -ne '') {                
                        $SAName = $FSLogixStorageFQDN.Split('.')[0]
                        Write-Log -Message "Adding Local Storage Account Key for '$FSLogixStorageFQDN' to Credential Manager" -Category 'Info'
                        $CMDKey = Start-Process -FilePath 'cmdkey.exe' -ArgumentList "/add:$FSLogixStorageFQDN /user:localhost\$SAName /pass:$FSLogixStorageAccountKey" -Wait -PassThru
                        If ($CMDKey.ExitCode -ne 0) {
                                Write-Log -Message "CMDKey Failed with '$($CMDKey.ExitCode)'. Failed to add Local Storage Account Key for '$FSLogixStorageFQDN' to Credential Manager" -Category 'Error'
                        }
                        Else {
                                Write-Log -Message "Successfully added Local Storage Account Key for '$FSLogixStorageFQDN' to Credential Manager" -Category 'Info'
                        }
                        $Settings += @(
                                # Attach the users VHD(x) as the computer: https://learn.microsoft.com/en-us/fslogix/reference-configuration-settings?tabs=profiles#accessnetworkascomputerobject
                                [PSCustomObject]@{
                                        Name         = 'AccessNetworkAsComputerObject'
                                        Path         = 'HKLM:\SOFTWARE\FSLogix\Profiles'
                                        PropertyType = 'DWord'
                                        Value        = 1
                                }                                
                        )
                        $Settings += @(
                                # Disable Roaming the Recycle Bin because it corrupts. https://learn.microsoft.com/en-us/fslogix/reference-configuration-settings?tabs=profiles#roamrecyclebin
                                [PSCustomObject]@{
                                        Name         = 'RoamRecycleBin'
                                        Path         = 'HKLM:\SOFTWARE\FSLogix\Apps'
                                        PropertyType = 'DWord'
                                        Value        = 0
                                }
                        )
                        # Disable the Recycle Bin
                        Reg LOAD HKLM\DefaultUser "$env:SystemDrive\Users\Default User\NtUser.dat"
                        Set-RegistryValue -Path 'HKLM:\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name NoRecycleFiles -PropertyType DWord -Value 1
                        Write-Log -Message "Unloading default user hive."
                        $null = cmd /c REG UNLOAD "HKLM\DefaultUser" '2>&1'
                }
                $LocalAdministrator = (Get-LocalUser | Where-Object { $_.SID -like '*-500' }).Name
                $LocalGroups = 'FSLogix Profile Exclude List', 'FSLogix ODFC Exclude List'
                ForEach ($Group in $LocalGroups) {
                        If (-not (Get-LocalGroupMember -Group $Group | Where-Object { $_.Name -like "*$LocalAdministrator" })) {
                                Add-LocalGroupMember -Group $Group -Member $LocalAdministrator
                        }
                }
        }

        ##############################################################
        #  Add Microsoft Entra ID Join Setting
        ##############################################################
        if ($IdentityServiceProvider -match "EntraID") {
                $Settings += @(

                        # Enable PKU2U: https://docs.microsoft.com/en-us/azure/virtual-desktop/troubleshoot-azure-ad-connections#windows-desktop-client
                        [PSCustomObject]@{
                                Name         = 'AllowOnlineID'
                                Path         = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\pku2u'
                                PropertyType = 'DWord'
                                Value        = 1
                        }
                )
        }

        # Set registry settings
        foreach ($Setting in $Settings) {
                Set-RegistryValue -Name $Setting.Name -Path $Setting.Path -PropertyType $Setting.PropertyType -Value $Setting.Value -Verbose
        }

        # Resize OS Disk
        Write-Log -message "Resizing OS Disk"
        $driveLetter = $env:SystemDrive.Substring(0, 1)
        $size = Get-PartitionSupportedSize -DriveLetter $driveLetter
        Resize-Partition -DriveLetter $driveLetter -Size $size.SizeMax
        Write-Log -message "OS Disk Resized"

        ##############################################################
        # Add Defender Exclusions for FSLogix 
        ##############################################################
        # https://docs.microsoft.com/en-us/azure/architecture/example-scenario/wvd/windows-virtual-desktop-fslogix#antivirus-exclusions
        if ($Fslogix -eq 'true') {

                $Files = @(
                        "%ProgramFiles%\FSLogix\Apps\frxdrv.sys",
                        "%ProgramFiles%\FSLogix\Apps\frxdrvvt.sys",
                        "%ProgramFiles%\FSLogix\Apps\frxccd.sys",
                        "%TEMP%\*.VHD",
                        "%TEMP%\*.VHDX",
                        "%Windir%\TEMP\*.VHD",
                        "%Windir%\TEMP\*.VHDX"
                        "$FslogixFileShareName\*.VHD"
                        "$FslogixFileShareName\*.VHDX"
                )

                foreach ($File in $Files) {
                        Add-MpPreference -ExclusionPath $File
                }
                Write-Log -Message 'Enabled Defender exlusions for FSLogix paths' -Category 'Info'

                $Processes = @(
                        "%ProgramFiles%\FSLogix\Apps\frxccd.exe",
                        "%ProgramFiles%\FSLogix\Apps\frxccds.exe",
                        "%ProgramFiles%\FSLogix\Apps\frxsvc.exe"
                )

                foreach ($Process in $Processes) {
                        Add-MpPreference -ExclusionProcess $Process
                }
                Write-Log -Message 'Enabled Defender exlusions for FSLogix processes' -Category 'Info'
        }


        ##############################################################
        #  Install the AVD Agent
        ##############################################################
        $BootInstaller = 'AVD-Bootloader.msi'
        Get-WebFile -FileName $BootInstaller -URL 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH'
        Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $BootInstaller /quiet /qn /norestart /passive" -Wait -Passthru
        Write-Log -Message 'Installed AVD Bootloader' -Category 'Info'
        Start-Sleep -Seconds 5

        $AgentInstaller = 'AVD-Agent.msi'
        Get-WebFile -FileName $AgentInstaller -URL 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv'
        Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $AgentInstaller /quiet /qn /norestart /passive REGISTRATIONTOKEN=$HostPoolRegistrationToken" -Wait -PassThru
        Write-Log -Message 'Installed AVD Agent' -Category 'Info'
        Start-Sleep -Seconds 5

        ##############################################################
        #  Restart VM
        ##############################################################
        if ($IdentityServiceProvider -eq "EntraIDKerberos" -and $AmdVmSize -eq 'false' -and $NvidiaVmSize -eq 'false') {
                Start-Process -FilePath 'shutdown' -ArgumentList '/r /t 30'
        }
}
catch {
        Write-Log -Message $_ -Category 'Error'
        throw
}