param(
    [Parameter(Mandatory)]
    [string]$storageAccountName,

    [Parameter(Mandatory)]
    [string]$identityDomainName
)

reg.exe add 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\domain_realm' /v $identityDomainName /d $storageAccountName.file.core.windows.net

reg.exe add 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters' /v CloudKerberosTicketRetrievalEnabled /t REG_DWORD /d 1