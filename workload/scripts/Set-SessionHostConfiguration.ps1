Param(
[parameter(Mandatory=$false)]
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
$Fslogix,

[parameter(Mandatory=$false)]
[string]
$FslogixFileShare,

[parameter(Mandatory=$false)]
[string]
$fslogixStorageFqdn,

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

##############################################################
#  Functions
##############################################################
function Write-Log {
param(
        [parameter(Mandatory)]
        [string]$Message,

        [parameter(Mandatory)]
        [string]$Type
)
$Path = 'C:\Windows\Temp\AVDSessionHostConfig.log'
if (!(Test-Path -Path $Path)) {
        New-Item -Path 'C:\' -Name 'AVDSessionHostConfig.log' | Out-Null
}
$Timestamp = Get-Date -Format 'MM/dd/yyyy HH:mm:ss.ff'
$Entry = '[' + $Timestamp + '] [' + $Type + '] ' + $Message
$Entry | Out-File -FilePath $Path -Append
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

$ErrorActionPreference = 'Stop'

try {

        ##############################################################
        #  Run the Virtual Desktop Optimization Tool (VDOT)
        ##############################################################
        # https://github.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool
        {
                # Download VDOT
                $URL = 'https://github.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/archive/refs/heads/main.zip'
                $ZIP = 'VDOT.zip'
                Invoke-WebRequest -Uri $URL -OutFile $ZIP

                # Extract VDOT from ZIP archive
                Expand-Archive -LiteralPath $ZIP -Force

                # Fix to disable AppX Packages
                # As of 2/8/22, all AppX Packages are enabled by default
                $Files = (Get-ChildItem -Path .\VDOT\Virtual-Desktop-Optimization-Tool-main -File -Recurse -Filter "AppxPackages.json").FullName
                foreach ($File in $Files) {
                        $Content = Get-Content -Path $File
                        $Settings = $Content | ConvertFrom-Json
                        $NewSettings = @()
                        foreach ($Setting in $Settings) {
                                $NewSettings += [pscustomobject][ordered]@{
                                        AppxPackage = $Setting.AppxPackage
                                        VDIState    = 'Disabled'
                                        URL         = $Setting.URL
                                        Description = $Setting.Description
                                }
                        }

                        $JSON = $NewSettings | ConvertTo-Json
                        $JSON | Out-File -FilePath $File -Force
                }

                # Run VDOT
                & .\VDOT\Virtual-Desktop-Optimization-Tool-main\Windows_VDOT.ps1 -Optimizations 'All' -AdvancedOptimizations 'Edge', 'RemoveLegacyIE' -AcceptEULA

                Write-Log -Message 'Optimized the operating system using VDOT' -Type 'INFO'
        }    

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
                                Value        = $FslogixFileShare
                        },
                        [PSCustomObject]@{
                                Name         = 'VolumeType'
                                Path         = 'HKLM:\SOFTWARE\FSLogix\Profiles'
                                PropertyType = 'MultiString'
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
        }
        if ($IdentityServiceProvider -eq "EntraID" -and $Fslogix -eq 'true') {
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
                                Value        = $fslogixStorageFqdn
                        }

                )
        }

        ##############################################################
        #  Add Microsoft Entra ID Join Setting
        ##############################################################
        if ($IdentityServiceProvider -eq "EntraID") {
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
                # Create registry key(s) if necessary
                if (!(Test-Path -Path $Setting.Path)) {
                        New-Item -Path $Setting.Path -Force
                }

                # Checks for existing registry setting
                $Value = Get-ItemProperty -Path $Setting.Path -Name $Setting.Name -ErrorAction 'SilentlyContinue'
                $LogOutputValue = 'Path: ' + $Setting.Path + ', Name: ' + $Setting.Name + ', PropertyType: ' + $Setting.PropertyType + ', Value: ' + $Setting.Value

                # Creates the registry setting when it does not exist
                if (!$Value) {
                        New-ItemProperty -Path $Setting.Path -Name $Setting.Name -PropertyType $Setting.PropertyType -Value $Setting.Value -Force
                        Write-Log -Message "Added registry setting: $LogOutputValue" -Type 'INFO'
                }
                # Updates the registry setting when it already exists
                elseif ($Value.$($Setting.Name) -ne $Setting.Value) {
                        Set-ItemProperty -Path $Setting.Path -Name $Setting.Name -Value $Setting.Value -Force
                        Write-Log -Message "Updated registry setting: $LogOutputValue" -Type 'INFO'
                }
                # Writes log output when registry setting has the correct value
                else {
                        Write-Log -Message "Registry setting exists with correct value: $LogOutputValue" -Type 'INFO'    
                }
                Start-Sleep -Seconds 1
        }


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
                Write-Log -Message 'Enabled Defender exlusions for FSLogix paths' -Type 'INFO'

                $Processes = @(
                        "%ProgramFiles%\FSLogix\Apps\frxccd.exe",
                        "%ProgramFiles%\FSLogix\Apps\frxccds.exe",
                        "%ProgramFiles%\FSLogix\Apps\frxsvc.exe"
                )

                foreach ($Process in $Processes) {
                        Add-MpPreference -ExclusionProcess $Process
                }
                Write-Log -Message 'Enabled Defender exlusions for FSLogix processes' -Type 'INFO'
        }


        ##############################################################
        #  Install the AVD Agent
        ##############################################################
        # Disabling this method for installing the AVD agent until EntraID Join can completed successfully
        $BootInstaller = 'AVD-Bootloader.msi'
        Get-WebFile -FileName $BootInstaller -URL 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH'
        Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $BootInstaller /quiet /qn /norestart /passive" -Wait -Passthru
        Write-Log -Message 'Installed AVD Bootloader' -Type 'INFO'
        Start-Sleep -Seconds 5

        $AgentInstaller = 'AVD-Agent.msi'
        Get-WebFile -FileName $AgentInstaller -URL 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv'
        Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $AgentInstaller /quiet /qn /norestart /passive REGISTRATIONTOKEN=$HostPoolRegistrationToken" -Wait -PassThru
        Write-Log -Message 'Installed AVD Agent' -Type 'INFO'
        Start-Sleep -Seconds 5

        ##############################################################
        #  Install Slack Machine-wide
        ##############################################################
	$SlackInstaller = 'Slack-Installer.msi'
        Get-WebFile -FileName $SlackInstaller -URL 'https://slack.com/ssb/download-win64-msi'
        Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $SlackInstaller /quiet /qn /norestart /passive" -Wait -PassThru
        Write-Log -Message 'Installed Slack' -Type 'INFO'
        Start-Sleep -Seconds 5

	##############################################################
        #  Install Zoom Desktop App
        ##############################################################
        $ZoomInstaller = 'ZoomInstaller.msi'
        Get-WebFile -FileName $ZoomInstaller -URL 'https://aka.ms/win32-x64-user-stable'
        Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $VSCodeInstaller /quiet /qn /norestart /passive" -Wait -PassThru
        Write-Log -Message 'Installed Visual Studio Code' -Type 'INFO'
        Start-Sleep -Seconds 5

        ##############################################################
        #  Install GitHub Desktop App
        ##############################################################
        $GitHubDesktopInstaller = 'GitHubDesktopInstaller.msi'
        Get-WebFile -FileName $GitHubDesktopInstaller -URL 'https://central.github.com/deployments/desktop/desktop/latest/win32'
        Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $GitHubDesktopInstaller /quiet /qn /norestart /passive" -Wait -PassThru
        Write-Log -Message 'Installed GitHub Desktop' -Type 'INFO'
        Start-Sleep -Seconds 5

        ##############################################################
        #  Install Adobe Creative Cloud
        ##############################################################
        $AdobeCCInstaller = 'Creative_Cloud_Set-Up.msi'
        Get-WebFile -FileName $AdobeCCInstaller -URL 'https://creativecloud.adobe.com/apps/download/creative-cloud'
        Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $AdobeCCInstaller /quiet /qn /norestart /passive" -Wait -PassThru
        Write-Log -Message 'Installed Adobe Creative Cloud' -Type 'INFO'
        Start-Sleep -Seconds 5

        ##############################################################
        #  Install EndNote Desktop App
        ##############################################################
        $EndNoteInstaller = 'EndNoteInstaller.msi'
        Get-WebFile -FileName $EndNoteInstaller -URL 'https://support.clarivate.com/Endnote/s/article/Download-EndNote?language=en_US'
        Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $EndNoteInstaller /quiet /qn /norestart /passive" -Wait -PassThru
        Write-Log -Message 'Installed EndNote' -Type 'INFO'
        Start-Sleep -Seconds 5

        ##############################################################
        #  Install Zotero
        ##############################################################
        $ZoteroInstaller = 'Zotero-Setup.exe'
        Get-WebFile -FileName $ZoteroInstaller -URL 'https://www.zotero.org/download/client/dl?channel=release&platform=win32'
        Start-Process -FilePath $ZoteroInstaller -ArgumentList "/S" -Wait -PassThru
        Write-Log -Message 'Installed Zotero' -Type 'INFO'
        Start-Sleep -Seconds 5

        ##############################################################
        #  Install BoxDrive
        ##############################################################
        $BoxDriveInstaller = 'BoxDrive.msi'
        Get-WebFile -FileName $BoxDriveInstaller -URL 'https://e3.boxcdn.net/box-installers/desktop/releases/win/Box-x64.msi'
        Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $BoxDriveInstaller /quiet /qn /norestart /passive" -Wait -PassThru
        Write-Log -Message 'Installed Box Drive' -Type 'INFO'
        Start-Sleep -Seconds 5

        ##############################################################
        #  Install FireFox
        ##############################################################
        $FirefoxInstaller = 'FirefoxInstaller.msi'
        Get-WebFile -FileName $FirefoxInstaller -URL 'https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-US'
        Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $FirefoxInstaller /quiet /qn /norestart /passive" -Wait -PassThru
        Write-Log -Message 'Installed Firefox' -Type 'INFO'
        Start-Sleep -Seconds 5

        ##############################################################
        #  Install Chrome
        ##############################################################

        $ChromeInstaller = 'ChromeInstaller.msi'
        Get-WebFile -FileName $ChromeInstaller -URL 'https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B7FFD4799-4EBC-E6EA-19CB-E6EAF684910B%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dtrue%26ap%3Dx64-stable-statsdef_0%26brand%3DGCGW/dl/chrome/install/googlechromestandaloneenterprise64.msi'
        Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $ChromeInstaller /quiet /qn /norestart /passive" -Wait -PassThru
        Start-Sleep -Seconds 5

        # Remove the desktop shortcut
        $desktopPath = [Environment]::GetFolderPath("CommonDesktopDirectory")
        $shortcutName = "Google Chrome.lnk"
        $shortcutPath = Join-Path $desktopPath $shortcutName

        if (Test-Path $shortcutPath) {
            Remove-Item $shortcutPath -Force
            Write-Log -Message "Desktop shortcut removed successfully." -Type 'INFO'
        } else {
            Write-Log -Message "Desktop shortcut not found." -Type 'INFO'
        }


        ##############################################################
        #  Restart VM
        ##############################################################
        if ($IdentityServiceProvider -eq "EntraID" -and $AmdVmSize -eq 'false' -and $NvidiaVmSize -eq 'false') {
                Start-Process -FilePath 'shutdown' -ArgumentList '/r /t 30'
        }
        }
        catch {
        Write-Log -Message $_ -Type 'ERROR'
        throw
        }
