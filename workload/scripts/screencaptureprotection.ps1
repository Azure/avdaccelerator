
$WinstationsKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations'

if(Test-Path $WinstationsKey){
    New-ItemProperty -Path $WinstationsKey -Name 'fEnableScreenCaptureProtect' -ErrorAction:SilentlyContinue -PropertyType:dword -Value 1 -Force
}