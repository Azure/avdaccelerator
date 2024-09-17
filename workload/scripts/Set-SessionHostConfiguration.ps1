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

function Write-TimestampedMessage {
param(
        [string]$Message
        [string]$Type="INFO"
)
$timestampp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "$timestamp - $Message"
}

function Get-WebFile {
param (
        [string]$FileName,  # The name of the file to save
        [string]$URL        # The URL to download the file from
)

Write-TimestampedMessage "Downloading $FileName from $URL"

try{
        Invoke-WebRequest -Uri $URL -OutFile $FileName
        Write-TimestampedMessage "Downloaded $FileName successfully."
}
catch{
          Write-TimestampedMessage "Failed to download $FileName from $URL. Error: $_"
          throw "Download failed for $FileName."
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

function Disable-BoxDriveStartup {
Write-TimestampedMessage "Disabling Box Drive from running at startup"
    
$regContent = @"
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run]
"Box"=-
"@

    $regFilePath = "$env:TEMP\remove_box.reg"
    Set-Content -Path $regFilePath -Value $regContent
    Start-Process regedit.exe -ArgumentList "/s $regFilePath" -Wait
    Remove-Item -Path $regFilePath

    Write-TimestampedMessage "Box Drive startup entry removed successfully"
}

function Install-Font {
        param (
            [string]$fontFile
        )
        
        $FONTS_FOLDER = "C:\Windows\Fonts"
        $FONTS_REG_KEY = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
        
        $fontName = [System.IO.Path]::GetFileNameWithoutExtension($fontFile)
        $fontExtension = [System.IO.Path]::GetExtension($fontFile)
        
        # Copy the font to the Fonts folder
        Copy-Item $fontFile $FONTS_FOLDER
    
        # Add the font to the registry
        $regName = "$fontName (TrueType)"
        $regValue = [System.IO.Path]::GetFileName($fontFile)
        New-ItemProperty -Path $FONTS_REG_KEY -Name $regName -Value $regValue -PropertyType String -Force
        
        Write-Log -Message "Installed font: $fontName" -Type 'INFO'
    }    

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

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
                        # JWI:  Comment out to to AntiMalware ext failing
                        #Add-MpPreference -ExclusionPath $File
                }
                Write-Log -Message 'Enabled Defender exlusions for FSLogix paths' -Type 'INFO'

                $Processes = @(
                        "%ProgramFiles%\FSLogix\Apps\frxccd.exe",
                        "%ProgramFiles%\FSLogix\Apps\frxccds.exe",
                        "%ProgramFiles%\FSLogix\Apps\frxsvc.exe"
                )

                foreach ($Process in $Processes) {
                        # JWI:  Comment out to to AntiMalware ext failing
                        #Add-MpPreference -ExclusionProcess $Process
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
        Write-TimestampedMessage "Downloading Slack Installer"
        Invoke-WebRequest -Uri 'https://slack.com/ssb/download-win64-msi' -OutFile 'SlackInstaller.msi'
        Write-TimestampedMessage "Downloaded Slack Installer"

        if (Test-Path 'SlackInstaller.msi') {
            Write-TimestampedMessage "Starting Slack Installation"    
            Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i SlackInstaller.msi /quiet /qn /norestart" -Wait
            Write-TimestampedMessage "Slack Installed Successfully" 
            Remove-Item -Path 'SlackInstaller.msi' -Force
        } else {
            Write-TimestampedMessage "Slack installer not found!" -ForegroundColor Red
        }


        #REMOVE DESKTOP SHORTCUTS
	      Write-TimestampedMessage "Start time for Removing Desktop Shortcut"
        $desktopPath = [Environment]::GetFolderPath("CommonDesktopDirectory")
        $shortcutName = "Slack.lnk"
        $shortcutPath = Join-Path $desktopPath $shortcutName

        if (Test-Path $shortcutPath) {
            Remove-Item $shortcutPath -Force
            Write-Host "Desktop shortcut removed successfully." -ForegroundColor Green
        } else {
            Write-Host "Desktop shortcut not found." -ForegroundColor Yellow
        }

        Write-TimestampedMessage "End Time for Removing Desktop Shortcut"

	      ##############################################################
        #  Install Zoom Desktop App
        ##############################################################
	      Write-TimestampedMessage "Downloading Zoom Installer"
        $ZoomInstaller = 'ZoomInstaller.msi'
        $URL = 'https://zoom.us/client/latest/ZoomInstallerFull.msi'
        Invoke-WebRequest -Uri $URL -OutFile $ZoomInstaller
	      Write-TimestampedMessage "Downloaded Zoom Installer"
        Write-TimestampedMessage "Starting Zoom Installation"
        Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $ZoomInstaller /quiet /qn /norestart DESKTOP_SHORTCUTS=0 SIGNIN=0" -Wait -PassThru
        Write-TimestampedMessage "Zoom Installed Successfully"
        Start-Sleep -Seconds 5
        Remove-Item -Path $ZoomInstaller -Force

        #REMOVE DESKTOP SHORTCUTS
	      Write-TimestampedMessage "Start time for Removing Desktop Shortcut"
        $desktopPath = [Environment]::GetFolderPath("CommonDesktopDirectory")
        $shortcutName = "Zoom Workplace.lnk"
        $shortcutPath = Join-Path $desktopPath $shortcutName

        if (Test-Path $shortcutPath) {
            Remove-Item $shortcutPath -Force
            Write-Host "Desktop shortcut removed successfully." -ForegroundColor Green
        } else {
            Write-Host "Desktop shortcut not found." -ForegroundColor Yellow
        }

        Write-TimestampedMessage "End Time for Removing Desktop Shortcut"

        ##############################################################
        #  Install GitHub Desktop App
        ##############################################################
        Write-TimestampedMessage "Start time for Removing Desktop Shortcut"

        $commonDesktopPath = [Environment]::GetFolderPath("CommonDesktopDirectory")
        $userDesktopPath = [Environment]::GetFolderPath("Desktop")
        $shortcutName = "GitHub Desktop.lnk"

        # Function to remove shortcut
        function Remove-Shortcut {
            param (
                [string]$path
            )

            $shortcutPath = Join-Path $path $shortcutName

            if (Test-Path $shortcutPath) {
                Remove-Item $shortcutPath -Force
                Write-Host "Desktop shortcut removed from $path successfully." -ForegroundColor Green
            } else {
                Write-Host "Desktop shortcut not found in $path." -ForegroundColor Yellow
            }
        }

        # Remove from common desktop
        Remove-Shortcut -path $commonDesktopPath

        # Remove from user desktop
        Remove-Shortcut -path $userDesktopPath

        ##############################################################
        #  Install EndNote Desktop App
        ##############################################################
        Write-TimestampedMessage "Downloading EndNote Installer"
        Invoke-WebRequest -Uri 'https://download.endnote.com/downloads/21/EN21Inst.msi' -OutFile 'EndNote.msi'
        Write-TimestampedMessage "Downloaded EndNote Installer"

	      if(Test-Path 'EndNote.msi'){
           Write-TimestampedMessage "Starting EndNote Installation"
           Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i EndNote.msi /quiet /qn /norestart" -Wait
           Write-TimestampedMessage "EndNote Installed Successfully"
           Remove-Item -Path 'EndNote.msi' -Force
        } else {
            Write-TimestampedMessage "EndNote installer not found!" -ForegroundColor Red
        }

        ##############################################################
        #  Install Zotero
        ##############################################################
        Write-TimestampedMessage "Downloading Zotero Installer"
        $ZoteroInstaller = 'Zotero-Setup.exe'
        Invoke-WebRequest -Uri 'https://www.zotero.org/download/client/dl?channel=release&platform=win-x64' -Outfile $ZoteroInstaller
        Write-TimestampedMessage "Downloaded Zotero Installer"
        Write-TimestampedMessage "Starting Zotero Installation"
        Start-Process -FilePath $ZoteroInstaller -ArgumentList "/S /norestart" -Wait -PassThru
        Write-TimestampedMessage "Zotero Installed Successfully"
        Start-Sleep -Seconds 5

        #REMOVE DESKTOP SHORTCUTS
        Write-TimestampedMessage "Start time for Removing Desktop Shortcut"
        $desktopPath = [Environment]::GetFolderPath("CommonDesktopDirectory")
        $shortcutName = "Zotero.lnk"
        $shortcutPath = Join-Path $desktopPath $shortcutName

        if (Test-Path $shortcutPath) {
            Remove-Item $shortcutPath -Force
            Write-Host "Desktop shortcut removed successfully." -ForegroundColor Green
        } else {
            Write-Host "Desktop shortcut not found." -ForegroundColor Yellow
        }

        Write-TimestampedMessage "End Time for Removing Desktop Shortcut"

        # REMOVE ZOTERO INSTALLER
        Write-TimestampedMessage "Removing Zotero Installer"

        if (Test-Path $ZoteroInstaller) {
            Remove-Item $ZoteroInstaller -Force
            Write-TimestampedMessage "Zotero Installer removed successfully."
        } else {
            Write-TimestampedMessage "Zotero Installer not found."
        }

        ##############################################################
        #  Install BoxDrive
        ##############################################################
        Write-TimestampedMessage "Downloading Box Drive Installer"
        Invoke-WebRequest -Uri 'https://e3.boxcdn.net/box-installers/desktop/releases/win/Box-x64.msi' -OutFile 'BoxDrive.msi'
        Write-TimestampedMessage "Downloaded Box Drive Installer"

        if (Test-Path 'BoxDrive.msi') {
            Write-TimestampedMessage "Starting Box Drive Installation"
            Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i BoxDrive.msi /quiet /qn /norestart" -Wait
            Write-TimestampedMessage "Box Drive Installed Successfully"
            Remove-Item -Path 'BoxDrive.msi' -Force
            Disable-BoxDriveStartup
	      } else {
            Write-TimestampedMessage "Box Drive installer not found!" -ForegroundColor Red
	      }

        ##############################################################
        #  Install FireFox
        ##############################################################
        Write-TimestampedMessage "Downloading Firefox Installer"
        $source = "https://download.mozilla.org/?product=firefox-esr-latest&os=win64&lang=en-US"
        $destination = "$env:TEMP\firefox.exe"
        Invoke-WebRequest -Uri $source -OutFile $destination
        Write-TimestampedMessage "Downloaded Firefox Installer"
        Write-TimestampedMessage "Starting Firefox Installation"
        Start-Process $destination -ArgumentList "/S" -Wait
        Remove-Item $destination -Force

        #REMOVE DESKTOP SHORTCUTS
        Write-TimestampedMessage "Start time for Removing Desktop Shortcut"
        $desktopPath = [Environment]::GetFolderPath("CommonDesktopDirectory")
        $shortcutName = "Firefox.lnk"
        $shortcutPath = Join-Path $desktopPath $shortcutName

        if (Test-Path $shortcutPath) {
            Remove-Item $shortcutPath -Force
            Write-Host "Desktop shortcut removed successfully." -ForegroundColor Green
        } else {
            Write-Host "Desktop shortcut not found." -ForegroundColor Yellow
        }

        Write-TimestampedMessage "End Time for Removing Desktop Shortcut"

        ##############################################################
        #  Install Visual Studio Code
        ##############################################################
        Write-TimestampedMessage "Installing Visual Studio Code"
        Start-Process -FilePath "winget" -ArgumentList "install --id Microsoft.VisualStudioCode -e --silent --accept-source-agreements" -Wait -NoNewWindow
        Write-TimestampedMessage "Visual Studio Code Installed Successfully"

        # ##############################################################
        # #  Install Slack Machine-wide
        # ##############################################################
        # $SlackInstaller = 'Slack-Installer.msi'
        # Get-WebFile -FileName $SlackInstaller -URL 'https://slack.com/ssb/download-win64-msi'
        # Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $SlackInstaller /quiet /qn /norestart DESKTOP_SHORTCUTS=0 SIGNIN=0" -Wait -PassThru
        # Write-Log -Message 'Installed Slack' -Type 'INFO'
        # Start-Sleep -Seconds 5
        # Remove-Item -Path $SlackInstaller -Force
        ##############################################################
        #  Install Slack Machine-wide
        ##############################################################
        $SlackInstaller = 'Slack-Installer.msi'
        Get-WebFile -FileName $SlackInstaller -URL 'https://slack.com/ssb/download-win64-msi'
        Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $SlackInstaller /quiet /qn /norestart DESKTOP_SHORTCUTS=0 SIGNIN=0" -Wait -PassThru
        Write-Log -Message 'Installed Slack' -Type 'INFO'
        Start-Sleep -Seconds 5
        Remove-Item -Path $SlackInstaller -Force

        #REMOVE DESKTOP SHORTCUTS
        $desktopPath = [Environment]::GetFolderPath("CommonDesktopDirectory")
        $shortcutName = "Slack.lnk"
        $shortcutPath = Join-Path $desktopPath $shortcutName

        if (Test-Path $shortcutPath) {
            Remove-Item $shortcutPath -Force
            Write-Host "Desktop shortcut removed successfully." -ForegroundColor Green
        } else {
            Write-Host "Desktop shortcut not found." -ForegroundColor Yellow
        }

	      ##############################################################
        # #  Install Zoom Desktop App
        # ##############################################################
        # $ZoomInstaller = 'ZoomInstaller.msi'
        # $URL = 'https://zoom.us/client/latest/ZoomInstallerFull.msi'
        # Invoke-WebRequest -Uri $URL -OutFile $ZoomInstaller
        # Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $ZoomInstaller /quiet /qn /norestart DESKTOP_SHORTCUTS=0 SIGNIN=0" -Wait -PassThru
        # Write-Host 'Installed Zoom' -ForegroundColor Green
        # Start-Sleep -Seconds 5
        # Remove-Item -Path $ZoomInstaller -Force

        #REMOVE DESKTOP SHORTCUTS
        $desktopPath = [Environment]::GetFolderPath("CommonDesktopDirectory")
        $shortcutName = "Zoom Workplace.lnk"
        $shortcutPath = Join-Path $desktopPath $shortcutName

        if (Test-Path $shortcutPath) {
            Remove-Item $shortcutPath -Force
            Write-Host "Desktop shortcut removed successfully." -ForegroundColor Green
        } else {
            Write-Host "Desktop shortcut not found." -ForegroundColor Yellow
        }

        ##############################################################
        #  Install GitHub Desktop App
        ##############################################################
        $GitHubDesktopInstaller = "https://central.github.com/deployments/desktop/desktop/latest/win32"
        Invoke-WebRequest -Uri $GitHubDesktopInstaller -OutFile "$env:TEMP\GitHubDesktopSetup.exe"
        Start-Process -FilePath "$env:TEMP\GitHubDesktopSetup.exe" -ArgumentList "/silent" -Wait -PassThru
        Write-Output 'Installed GitHub Desktop'
        Start-Sleep -Seconds 5

        #FIX ISSUE WITH GITHUB NOT SHOWING SHORTCUT IN START MENU
        $exePath = "C:\Users\*\AppData\Local\GitHubDesktop\GitHubDesktop.exe"  # Update with the correct path
        $shortcutName = "GitHub Desktop"
        $startMenuPath = "C:\Users\*\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
        $folderName = "GitHub, Inc"
        $folderPath = [System.IO.Path]::Combine($startMenuPath, $folderName)

        if (-not (Test-Path $folderPath)) {
            New-Item -Path $folderPath -ItemType Directory
        }

        $shortcutPath = [System.IO.Path]::Combine($folderPath, "$shortcutName.lnk")
        $WScriptShell = New-Object -ComObject WScript.Shell
        $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $exePath
        $shortcut.WorkingDirectory = [System.IO.Path]::GetDirectoryName($exePath)
        $shortcut.WindowStyle = 1
        $shortcut.Description = "Shortcut for $shortcutName"
        $shortcut.IconLocation = "C:\Users\*\AppData\Local\GitHubDesktop\GitHubDesktop.exe, 0"  # First try with 0
        $shortcut.Save()

        Write-Host "Shortcut for '$shortcutName' created successfully in '$folderPath' with the specified icon."

        ##############################################################
        #  Install EndNote Desktop App
        ##############################################################
        $EndNoteInstaller = 'EndNote.msi'
        Get-WebFile -FileName $EndNoteInstaller -URL 'https://download.endnote.com/downloads/21/EN21Inst.msi'
        Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $EndNoteInstaller /quiet /qn /norestart DESKTOP_SHORTCUTS=0 SIGNIN=0" -Wait -PassThru
        Write-Log -Message 'Installed EndNote' -Type 'INFO'
        Start-Sleep -Seconds 5
        Remove-Item -Path $EndNoteInstaller -Force

        ##############################################################
        #  Install Zotero
        ##############################################################
        $ZoteroInstaller = 'Zotero-Setup.exe'
        Invoke-WebRequest -Uri 'https://www.zotero.org/download/client/dl?channel=release&platform=win-x64' -Outfile $ZoteroInstaller
        Start-Process -FilePath $ZoteroInstaller -ArgumentList "/S /norestart" -Wait -PassThru
        Write-Output 'Installed Zotero'
        Start-Sleep -Seconds 5

        #REMOVE DESKTOP SHORTCUTS
        $desktopPath = [Environment]::GetFolderPath("CommonDesktopDirectory")
        $shortcutName = "Zotero.lnk"
        $shortcutPath = Join-Path $desktopPath $shortcutName

        if (Test-Path $shortcutPath) {
            Remove-Item $shortcutPath -Force
            Write-Host "Desktop shortcut removed successfully." -ForegroundColor Green
        } else {
            Write-Host "Desktop shortcut not found." -ForegroundColor Yellow
        }

        ##############################################################
        #  Install BoxDrive
        ##############################################################
        $BoxDriveInstaller = 'BoxDrive.msi'
        Get-WebFile -FileName $BoxDriveInstaller -URL 'https://e3.boxcdn.net/box-installers/desktop/releases/win/Box-x64.msi'
        Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $BoxDriveInstaller /quiet /qn /norestart DESKTOP_SHORTCUTS=0 SIGNIN=0" -Wait -PassThru
        Write-Log -Message 'Installed BoxDrive' -Type 'INFO'
        Start-Sleep -Seconds 5
        Remove-Item -Path $BoxDriveInstaller -Force
        Start-Sleep -Seconds 5

        #FIX ISSUE WITH BOX DRIVE RUNNING AT START
        # $regContent = @"
        # Windows Registry Editor Version 5.00

        # [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run]
        # "Box"=-
        # $regFilePath = "$env:TEMP\remove_box.reg"
        # Set-Content -Path $regFilePath -Value $regContent
        # Start-Process regedit.exe -ArgumentList "/s $regFilePath" -Wait
        # Remove-Item -Path $regFilePath

        #FIX BOX DRIVE ICON NOT SHOWING IN START MENU
        $exePath = "C:\Program Files\Box\Box\Box.exe"  # Update with the correct path
        $shortcutName = "Box Drive"
        $startMenuPath = "C:\Users\*\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
        $folderName = "Box Drive, Inc"
        $folderPath = [System.IO.Path]::Combine($startMenuPath, $folderName)

        if (-not (Test-Path $folderPath)) {
            New-Item -Path $folderPath -ItemType Directory
        }

        $shortcutPath = [System.IO.Path]::Combine($folderPath, "$shortcutName.lnk")
        $WScriptShell = New-Object -ComObject WScript.Shell
        $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $exePath
        $shortcut.WorkingDirectory = [System.IO.Path]::GetDirectoryName($exePath)
        $shortcut.WindowStyle = 1
        $shortcut.Description = "Shortcut for $shortcutName"
        $shortcut.IconLocation = "C:\Program Files\Box\Box\Box.exe, 0"  # First try with 0
        $shortcut.Save()

        Write-Host "Shortcut for '$shortcutName' created successfully in '$folderPath' with the specified icon."

        ##############################################################
        #  Install FireFox
        ##############################################################
        $source = "https://download.mozilla.org/?product=firefox-esr-latest&os=win64&lang=en-US"
        $destination = "$env:TEMP\firefox.exe"
        Invoke-WebRequest -Uri $source -OutFile $destination
        Start-Process $destination -ArgumentList "/S" -Wait
        Remove-Item $destination -Force

        #REMOVE DESKTOP SHORTCUTS
        $desktopPath = [Environment]::GetFolderPath("CommonDesktopDirectory")
        $shortcutName = "Firefox.lnk"
        $shortcutPath = Join-Path $desktopPath $shortcutName

        if (Test-Path $shortcutPath) {
            Remove-Item $shortcutPath -Force
            Write-Host "Desktop shortcut removed successfully." -ForegroundColor Green
        } else {
            Write-Host "Desktop shortcut not found." -ForegroundColor Yellow
        }

        ##############################################################
        #  Install Chrome
        ##############################################################

        $ChromeInstaller = 'ChromeInstaller.msi'
        Get-WebFile -FileName $ChromeInstaller -URL 'https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B7FFD4799-4EBC-E6EA-19CB-E6EAF684910B%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dtrue%26ap%3Dx64-stable-statsdef_0%26brand%3DGCGW/dl/chrome/install/googlechromestandaloneenterprise64.msi'
        Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $ChromeInstaller /quiet /qn /norestart /passive" -Wait -PassThru
        Write-Log -Message 'Installed Chrome' -Type 'INFO'
        Start-Sleep -Seconds 5

        #Remove the desktop shortcut
        $desktopPath = [Environment]::GetFolderPath("CommonDesktopDirectory")
        $shortcutName = "Google Chrome.lnk"
        $shortcutPath = Join-Path $desktopPath $shortcutName

        if (Test-Path $shortcutPath) {
            Remove-Item $shortcutPath -Force
            Write-Log -Message "Desktop shortcut removed successfully." -Type 'INFO'
        } else {
            Write-Log -Message "Desktop shortcut not found." -Type 'ERROR'
        }

        ##############################################################
	      # Install ActiveClient
        ##############################################################
        $baseUrl = "https://arpahsessionhostbaseline.blob.core.windows.net/public/ARPA-H/ActivClient-8.2.1.msi"
        $ActivClientInstaller = "ActivClient-8.2.1.msi"

        if ([Environment]::Is64BitOperatingSystem) {
            $programFilesPath = "$Env:ProgramFiles"
        } else {
            $programFilesPath = "$Env:ProgramFiles(x86)"
        }

        $installFolder = Join-Path $programFilesPath "ActivClient"

        if (-not (Test-Path $installFolder)) {
            New-Item -Path $installFolder -ItemType Directory
        }

        Write-TimestampedMessage "Downloading ActivClient Installer"
        Invoke-WebRequest -Uri $baseUrl -OutFile (Join-Path $installFolder $ActivClientInstaller)
        Write-TimestampedMessage "Downloaded ActivClient Installer"

        Write-TimestampedMessage "Starting ActivClient Installation"
        $installerPath = Join-Path $installFolder $ActivClientInstaller
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$installerPath`" /quiet /norestart" -Wait -PassThru
        Write-TimestampedMessage "ActivClient Installed Successfully"
        Start-Sleep -Seconds 5

        ##############################################################
        #  Install ARPA-H fonts
        ##############################################################
        $baseUrl = "https://arpahsessionhostbaseline.blob.core.windows.net/public/ARPA-H/Fonts/"
    
        # List of font URLs to download and install
        $fontUrls = @(
            "NewYork-Regular_4293932765.ttf",
            "NewYork-RegularItalic_871433785.ttf",
            "NewYork.ttf",
            "NewYorkItalic.ttf",
            "Poppins-Black_3008352512.ttf",
            "Poppins-BlackItalic_371123804.ttf",
            "Poppins-Bold_1019179171.ttf",
            "Poppins-BoldItalic_1803493887.ttf",
            "Poppins-ExtraBold_3421185964.ttf",
            "Poppins-ExtraBoldItalic_3500825864.ttf",
            "Poppins-ExtraLight_990443044.ttf",
            "Poppins-ExtraLightItalic_2096693632.ttf",
            "Poppins-Italic_2289676922.ttf",
            "Poppins-Light_4270612763.ttf",
            "Poppins-LightItalic_283490423.ttf",
            "Poppins-Medium_1896896901.ttf",
            "Poppins-MediumItalic_2763936481.ttf",
            "Poppins-Regular_2359647735.ttf",
            "Poppins-SemiBold_4006441525.ttf",
            "Poppins-SemiBoldItalic_4164016017.ttf",
            "Poppins-Thin_1094694325.ttf",
            "Poppins-ThinItalic_1893905169.ttf",
            "PublicSans-Thin_3884680131.ttf",
            "PublicSans-ThinItalic_2099296031.ttf",
            "RobotoMono-Italic_3840806306.ttf",
            "RobotoMono-Regular_1946149919.ttf",
            "SF-Arabic-Rounded.ttf",
            "SF-Arabic.ttf",
            "SF-Armenian-Rounded.ttf",
            "SF-Armenian.ttf",
            "SF-Compact-Italic.ttf",
            "SF-Compact.ttf",
            "SF-Georgian-Rounded.ttf",
            "SF-Georgian.ttf",
            "SF-Hebrew-Rounded.ttf",
            "SF-Hebrew.ttf",
            "SF-Pro-Italic.ttf",
            "SF-Pro.ttf",
            "SFCompact-Black_1927307385.ttf"
        )
        
        # Temporary directory to store downloaded fonts
        $tempDir = Join-Path $env:TEMP "FontInstall"
        New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
        
        foreach ($url in $fontUrls) {
            $fileName = [System.IO.Path]::GetFileName($url)
            $filePath = Join-Path $tempDir $fileName
            
            try {
                # Download the font
                Invoke-WebRequest -Uri "$($baseUrl)$($url)" -OutFile $filePath
                
                # Install the font
                Install-Font -fontFile $filePath
            }
            catch {
                Write-Log -Message "Failed to download or install font from $url. Error: $_" -Type 'ERROR'
            }
        }
        
        # Clean up temporary files
        Remove-Item -Path $tempDir -Recurse -Force
    


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
