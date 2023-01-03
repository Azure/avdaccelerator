##############################################################
#  Enable Screen Capture Protection
##############################################################
# https://docs.microsoft.com/en-us/azure/virtual-desktop/screen-capture-protection

try {

    $Setting = [PSCustomObject]@{
        Name = 'fEnableScreenCaptureProtect'
        Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
        PropertyType = 'DWord'
        Value = 1
    }

    Write-Host "Enable Screen Capture Protection: Begin"

    # Create registry key(s) if necessary
    if(!(Test-Path -Path $Setting.Path))
    {
        New-Item -Path $Setting.Path -Force
        Write-Host "Added registry key: $($Setting.Path)"
    }

    # Checks for existing registry setting
    $Value = Get-ItemProperty -Path $Setting.Path -Name $Setting.Name -ErrorAction 'SilentlyContinue'
    
    # Set output value for Write-Host
    $Output = 'Path: ' + $Setting.Path + ', Name: ' + $Setting.Name + ', PropertyType: ' + $Setting.PropertyType + ', Value: ' + $Setting.Value
    
    # Creates the registry setting when it does not exist
    if(!$Value)
    {
        New-ItemProperty -Path $Setting.Path -Name $Setting.Name -PropertyType $Setting.PropertyType -Value $Setting.Value -Force
        Write-Host "Added registry setting: $Output"
    }
    # Updates the registry setting when it already exists
    elseif($Value.$($Setting.Name) -ne $Setting.Value)
    {
        Set-ItemProperty -Path $Setting.Path -Name $Setting.Name -Value $Setting.Value -Force
        Write-Host "Updated registry setting: $Output"
    }
    # Writes output when registry setting has the correct value
    else 
    {
        Write-Host "Registry setting exists with correct value: $Output"   
    }

    Write-Host "Enable Screen Capture Protection: Complete"
}
catch 
{
    Write-Host $_.Exception
    throw
}