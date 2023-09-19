 
<#Author       : Jonathan Core
# Creation Date: 03-28-2022
# Usage        : Expand ALL MSIX packages in a folder to dynamic expanding VHD in subfolder


********************************************************************************
Date                         Version      Changes
------------------------------------------------------------------------
03/28/2022                     1.0        Intial Version
8/14/2023                      1.1        Change to VHD vs VHDx file output

*********************************************************************************

Folder Structure - 
Ensure you run the script from within the folder where your MSIX
Packages Reside and have extracted the MSIXMgr tool within that folder. The script
will call the x64 version and can be changed below if x86 is desired. It will then 
create a VHD_Files folder where the images are extracted. 
#>


$Packages = Get-ChildItem -Path "C:\MSIX\Packages\" -File *.msix
Write-Host "Extracting MSIX files to VHD...."

$VHDFolder = "C:\MSIX\VHD_Files"

if (!(Test-Path $VHDFolder))
{
write-host "-------> VHD_Files Subfolder being created." -ForegroundColor Yellow
New-Item -itemType Directory $VHDFolder
}
else
{
write-host "-------> VHD_Files Subfolder already exists, continuing..." -ForegroundColor Green
}

# write-host "-------> Stoping HW Shell Service temporarily. This will suppress format prompts as VHDs are mounted."  -ForegroundColor Green

# This prevents the format drive popup after each VHD is mounted, restarted at end of run
# Commented due to being disabled in image
# Stop-Service -Name ShellHWDetection  

Foreach($file in $Packages){
    Write-Host "-------> Working on:" $file.Name -ForegroundColor Green

    $pkgpath = $file.Name
    $VHDFile = $VHDFolder +"\"+$File.BaseName + ".vhd"


    #Create VHD file 
    New-VHD -SizeBytes 1GB -Path $VHDFile -Dynamic -Confirm:$false
    $vhdObject = Mount-VHD $VHDFile -Passthru
    $disk = Initialize-Disk -Passthru -Number $vhdObject.Number
    $partition = New-Partition -AssignDriveLetter -UseMaximumSize -DiskNumber $disk.Number
    Format-Volume -FileSystem NTFS -Confirm:$false -DriveLetter $partition.DriveLetter -Force

    $MSIXPath = $partition.driveletter+":\apps"
    ## $destination = $partition.driveletter + ":\" + $FileName

    #Extract package
    & "C:\MSIX\msixmgr\x64\msixmgr.exe" -Unpack -packagePath $pkgpath -destination $MSIXPath -applyacls

    #Disconnect VHD
    Dismount-VHD -Path $VHDFile
}

# write-host "-------> Starting HW Shell Service back up."  -ForegroundColor Green
# Start-Service -Name ShellHWDetection
Write-Host "Completed! Files are located in $VHDFolder" -ForegroundColor Green