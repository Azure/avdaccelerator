$WinstationsKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations'

if(Test-Path $WinstationsKey){
    New-ItemProperty -Path $WinstationsKey -Name 'fUseUdpPortRedirector' -ErrorAction:SilentlyContinue -PropertyType:dword -Value 1 -Force
    New-ItemProperty -Path $WinstationsKey -Name 'UdpPortNumber' -ErrorAction:SilentlyContinue -PropertyType:dword -Value 3390 -Force
}

New-NetFirewallRule ` 
 -DisplayName 'Remote Desktop - Shortpath (UDP-In)' `
 -Action Allow `
 -Description 'Inbound rule for the Remote Desktop service to allow RDP traffic. [UDP 3390]' `
 -Group '@FirewallAPI.dll,-28752' `
 -Name 'RemoteDesktop-UserMode-In-Shortpath-UDP'  `
 -PolicyStore PersistentStore `
 -Profile Domain, Private `
 -Service TermService `
 -Protocol udp `
 -LocalPort 3390 `
 -Program '%SystemRoot%\system32\svchost.exe' 
 `-Enabled:True