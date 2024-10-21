# Purpose: 
# Configure VM for App Attach package creation. Installs MSIX App Attach Windows Store based application, MSIX Tools Driver, and sets recommended registry settings.

<#
Updates:
 8/28/2023  (JCore) - Updated from original to remove Drive Mapping, add latest package versions, create desktop shortcuts and remove startup for Windows and Edge.
 10/21/2024 (JCore) - Removed PSFTooling as it's now included in MSIX Tools, added download and install for the MSIX Tools Driver ahead of time, updated URL and 
                      version for MSIX Tools install. Changed Install from Add-AppPackage to Add-AppxProvisionedPackage.
#>

Param(

    [parameter(Mandatory)]
    [string]$VMUserName,

    [parameter(Mandatory)]
    [String]$VMUserPassword,

    [parameter(Mandatory)]
    [string]$PostDeployScriptURI
)

# URLs for MSIX and PsfTooling packages
# version 1.2023.319.0
$MSIXPackageURL = "https://download.microsoft.com/download/e/2/e/e2e923b2-7a3a-4730-969d-ab37001fbb5e/MSIXPackagingtoolv1.2024.405.0.msixbundle"
# $PsfToolPackageURL = "https://www.tmurgent.com/AppV/Tools/PsfTooling/PsfTooling-6.3.0.0-x64.msix"

$AppAttachInstallFolder = "Microsoft.MSIXPackagingTool_1.2024.405.0_x64__8wekyb3d8bbwe"
# $PsfToolInstallFolder = "PsfTooling_6.3.0.0_x64__4y3s55xckzt36"

$MSIXToolsDriver = "Msix.PackagingTool.Driver~~~~0.0.1.0"

# Create Log file for output and troublehsooting
$Log = "C:\PostConfig.log"
New-Item $Log
Get-Date | Out-file $Log

$Username = $ENV:COMPUTERNAME + '\' + $VMUserName
$Password = ConvertTo-SecureString -String $VMUserPassword -AsPlainText -Force
[pscredential]$VMCredential = New-Object System.Management.Automation.PSCredential ($Username, $Password)

$Username | Out-File $Log -Append

$Error.Clear()

#Install NuGet and Hyper-V tools
"Installing NuGet Provider needed for Hyper-V module" | Out-File $Log -Append
Install-PackageProvider -Name NuGet -Force
If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Log -Append }
Else { "-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear() }

"Installing Hyper-V Windows Component needed to convert MSIX to VHD" | Out-File $Log -Append
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Log -Append }
Else { "-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear() }

"Installing Azure PowerShell Cmdlets" | Out-File $Log -Append
Install-Module -Name Az.Storage -Force
If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Log -Append }
Else { "-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear() }

# Disable Edge First Run
"Disable Edge First Run Experience via Registry" | Out-file $Log -Append
reg add HKLM\Software\Policies\Microsoft\Edge /v HideFirstRunExperience /t REG_DWORD /d 1 /f
If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Log -Append }
Else { "-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear() }

# Disable Content Delivery auto download apps that they want to promote to users:
"Disable Content Delivery auto download apps" | Out-File $Log -Append
reg add HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager /v PreInstalledAppsEnabled /t REG_DWORD /d 0 /f
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Debug /v ContentDeliveryAllowedOverride /t REG_DWORD /d 0x2 /f
If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Log -Append }
Else { "-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear() }

# Disable Windows Welcome Screen
"Disable Windows Welcome Screen via Registry" | Out-file $Log -Append
reg add HKEY_USERS\.DEFAULT\Software\Policies\Microsoft\Windows\CloudContent /v disablewindowsSpotlightwindowswelcomeExperience /t REG_DWORD /d 1 /f
reg add HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement /v ScoobeSystemSettingEnabled /t REG_DWORD /d 0 /f
reg add HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager /v SubscribedContent-310093Enabled /t REG_DWORD /d 0 /f
reg add HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager /v SubscribedContent-338389Enabled /t REG_DWORD /d 0 /f
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\OOBE /v DisablePrivacyExperience /t REG_DWORD /d 1 /f
If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Log -Append }
Else { "-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear() }

#Make Local MSIX Dir for tools
"Creating Directories" | Out-File $Log -Append
New-Item -Path "C:\MSIX" -ItemType Directory
New-Item -Path "C:\MSIX\Packages" -ItemType Directory
New-Item -Path "C:\MSIX\Scripts" -ItemType Directory
New-Item -Path "C:\MSIX\MSIXPackagingTool" -ItemType Directory
If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Log -Append }
Else { "-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear() }

# Downloads and extracts the MSIX Manager Tool
"Downloading and Extracting the MSIX Manager Command Line tool" | Out-File $Log -Append
Invoke-WebRequest -URI "https://aka.ms/msixmgr" -OutFile "C:\MSIX\MSIXmgrTool.zip"
Expand-Archive -Path "C:\MSIX\MSIXmgrTool.zip" -DestinationPath "C:\MSIX\msixmgr"
If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Log -Append }
Else { "-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear() }

# Download Script to convert MSIX to VHD
$ScriptURI = $PostDeployScriptURI + "ConvertMSIX2VHD.ps1"
"Downloading MSIX to VHD Script: $ScriptURI" | Out-File $Log -Append
Invoke-WebRequest -URI $ScriptURI -OutFile "C:\MSIX\Scripts\ConvertMSIX2VHD.ps1"
If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Log -Append }
Else { "-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear() }

# Configure NIC to Private (Dependency for PSRemoting)
"Set Network Adapter to Private Profile (req'd for PSRemoting)" | Out-file $Log -Append
Set-NetConnectionProfile -InterfaceAlias Ethernet -NetworkCategory Private
If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Log -Append }
Else { "-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear() }

# Download the MSIX Packaging Tool
"Downloading MSIX Packaging Tool" | Out-File $Log -Append
Invoke-WebRequest -Uri $MSIXPackageURL -OutFile "C:\MSIX\MsixPackagingTool.msixbundle"
If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Log -Append }
Else { "-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear() }

# Download the PFSTooling Tool - REMOVED / Now within MSIX Tools
<# "Downloading PSFTooling Tool" | Out-File $Log -Append
Invoke-WebRequest -URI $PsfToolPackageURL -OutFile "C:\MSIX\PsfTooling-x64.msix"
If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Log -Append }
Else { "-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear() }
#>
"Enabling PSRemoting" | Out-file $Log -Append
Enable-PSRemoting -Force
If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Log -Append }
Else { "-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear() }

Invoke-Command -ComputerName $ENV:COMPUTERNAME -Credential $VMCredential -ScriptBlock {
    # Installs the MSIX Packaging Tool
    "Installing MSIX Packaging Tool as $Using:VMUserName" | Out-File $Using:Log -Append
    Add-AppxProvisionedPackage -Path "C:\MSIX\MSIXPackagingTool.msixbundle" -SkipLicense | Out-Null
    If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Using:Log -Append }
    Else { "-----ERROR-----> $Error" | Out-File $Using:Log -Append; $Error.Clear() }
    
    "Installing MSIX Packaging Tool Driver" | Out-File $Using:Log -Append
    Add-WindowsCapability -Online -Name $Using:MSIXToolsDriver
    If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Using:Log -Append }
    Else { "-----ERROR-----> $Error" | Out-File $Using:Log -Append; $Error.Clear() }
<#
    # Downloads and installs the PFSTooling Tool - NOW INCLUDED IN MSIX TOOLS
    "Installing PSFTooling Tool as $Using:VMUserName" | Out-File $Using:Log -Append
    Add-AppPackage -Path "C:\MSIX\PsfTooling-x64.msix"
    If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Using:Log -Append }
    Else { "-----ERROR-----> $Error" | Out-File $Using:Log -Append; $Error.Clear() }
    
     # Map Drive for MSIX Share
    "Mapping MSIX Share to M:" | Out-File $Log -Append
    New-PSDrive -Name M -PSProvider FileSystem -Root $Using:FileShare -Credential $Using:StorageCredential -Persist
    # New-SmbGlobalMapping -RemotePath $FileShare -Credential $Credential -LocalPath 'M:'
    If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Using:Log -Append }
    Else { "-----ERROR-----> $Error" | Out-File $Using:Log -Append; $Error.Clear() } #>
   
}
# Disable PSRemoting after Invoke Command
"Disabling PSRemoting" | Out-file $Log -Append
Disable-PSRemoting -Force
If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Log -Append }
Else { "-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear() }

# Stops the Shell HW Detection service to prevent the format disk popup
"Stoping Plug and Play Service and setting to disabled" | Out-file $Log -Append
Stop-Service -Name ShellHWDetection -Force
set-service -Name ShellHWDetection -StartupType Disabled
If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Log -Append }
Else { "-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear() }

# Turn off auto updates
"Turn Off Auto Updates via Registry and Disable Scheduled Tasks" | Out-File $Log -Append
reg add HKLM\Software\Policies\Microsoft\WindowsStore /v AutoDownload /t REG_DWORD /d 0 /f
Schtasks /Change /Tn "\Microsoft\Windows\WindowsUpdate\Scheduled Start" /Disable
If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Log -Append }
Else { "-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear() }

"Set Network Adapter back to Public Profile" | Out-file $Log -Append
Set-NetConnectionProfile -InterfaceAlias Ethernet -NetworkCategory Public
If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Log -Append }
Else { "-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear() }

# Create and install Self-Signed Code Signing Certificate
"Creating Self Signed Code Signing Certificate" | Out-File $Log -Append
$Cert = New-SelfSignedCertificate -FriendlyName "MSIX App Attach Test CodeSigning" -CertStoreLocation Cert:\LocalMachine\My -Subject "MSIXAppAttachTest" -Type CodeSigningCert
If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Log -Append }
Else { "-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear() }

"Moving Cert from Personal to Trusted People Store on Local Machine" | Out-File $Log -Append
$Cert | Move-Item -Destination cert:\LocalMachine\TrustedPeople | Out-File $Log -Append
If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Log -Append }
Else { "-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear() }

# Create Desktop Shortcuts
"Creating Desktop Shortcuts" | Out-File $Log -Append
$DestinationPath = "C:\Users\Public\Desktop"
$AppAttach = "$DestinationPath\MSIX App Attach.lnk"
$AppAttachExe = "C:\Program Files\WindowsApps\$AppAttachInstallFolder\MsixPackageTool.exe"
# $PSFToolExe = "C:\Program Files\WindowsApps\$PsfToolInstallFolder\PsfTooling.exe"
# $PSFTool = "$DestinationPath\PSFTool.lnk"
$MSIXfldr = "$DestinationPath\MSIX Folder.lnk"
$MSIXfldrLoc = "C:\MSIX\"
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($AppAttach)
$Shortcut.TargetPath = $AppAttachExe
$Shortcut.Save()
# $WshShell = New-Object -comObject WScript.Shell
# $Shortcut = $WshShell.CreateShortcut($PSFTool)
# $Shortcut.TargetPath = $PSFToolExe
# $Shortcut.Save()
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($MSIXfldr)
$Shortcut.TargetPath = $MSIXfldrLoc
$Shortcut.Save()
If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Log -Append }
Else { "-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear() }

"Rebooting VM...." | Out-File $Log -Append
Restart-Computer -Force
If ($Error.Count -eq 0) { ".... COMPLETED!" | Out-File $Log -Append }
Else { "-----ERROR-----> $Error" | Out-File $Log -Append; $Error.Clear() }

"-------------------------- END SCRIPT RUN ------------------------" | Out-File $Log -Append
