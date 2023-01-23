##############################################################
#  Enable RDP Short Path
##############################################################

try {
    $Settings = @(            
        # Enable RDP Shortpath for managed networks: https://docs.microsoft.com/en-us/azure/virtual-desktop/shortpath#configure-rdp-shortpath-for-managed-networks
        [PSCustomObject]@{
            Name = 'fUseUdpPortRedirector'
            Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations'
            PropertyType = 'DWord'
            Value = 1
        },

        # Enable the port for RDP Shortpath for managed networks: https://docs.microsoft.com/en-us/azure/virtual-desktop/shortpath#configure-rdp-shortpath-for-managed-networks
        [PSCustomObject]@{
            Name = 'UdpPortNumber'
            Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations'
            PropertyType = 'DWord'
            Value = 3390
        }
    )

    Write-Host "Enable RDP Short Path: Begin"
    foreach($Setting in $Settings)
    {
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
    }

    New-NetFirewallRule `
        -DisplayName 'Remote Desktop - Shortpath (UDP-In)' `
        -Action 'Allow' `
        -Description 'Inbound rule for the Remote Desktop service to allow RDP traffic. [UDP 3390]' `
        -Group '@FirewallAPI.dll,-28752' `
        -Name 'RemoteDesktop-UserMode-In-Shortpath-UDP' `
        -PolicyStore 'PersistentStore' `
        -Profile 'Domain, Private' `
        -Service 'TermService' `
        -Protocol 'udp' `
        -LocalPort 3390 `
        -Program '%SystemRoot%\system32\svchost.exe' `
        -Enabled:True

    Write-Host "Enable RDP Short Path: Complete"
}
catch {
    Write-Host $_.Exception
    throw
}