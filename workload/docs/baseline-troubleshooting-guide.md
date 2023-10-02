# Troubleshooting Guide: Azure Virtual Desktop Landing Zone Accelerator

## Domain Join Failure

When encountering a domain join failure in Azure Virtual Desktop, you may receive an error message similar to the following:

"VM has reported a failure when processing extension 'DomainJoin' (publisher 'Microsoft.Compute' and type 'JsonADDomainExtension'). Error message: 'Exception(s) occurred while joining Domain 'email@domain.com''. More information on troubleshooting is available at [https://aka.ms/vmextensionwindowstroubleshoot](https://aka.ms/vmextensionwindowstroubleshoot). (Code: VMExtensionProvisioningError)."

Follow the steps below to troubleshoot and resolve the issue:

### Validate environment and account configuration

- **Check Configuration**: Review your Azure Virtual Desktop (AVD) virtual network configuration and ensure that DNS is properly configured and the virtual network is peered to the network Hub or Identity Services virtual network. When using AD DS or AAD DS commonly the virtual network will need to be setup with custom DNS servers settings that point to the domain controllers IPs.
    - Resources:
        - [Name resolution for resources in Azure virtual networks](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-name-resolution-for-vms-and-role-instances?tabs=redhat)

- **Credentials**: Verify that the domain join account credentials (username and password) provided in your AVD LZA configuration are accurate and have the necessary permissions to join devices to the domain. After deployment the credentials used by the automation are aved in the workload key vault.
    - Key vault naming: *kv-sec-<'DeploymentPrefix'>-<'Environment(test/dev/prod)'>-<'Location'>-<'UniqueString(2)'>*
    - Domain user name secret: *domainJoinUserName*
    - Dmain user password secret: *domainJoinUserPassword*

### Verify DNS and Network Connectivity

- **DNS Resolution**: Ensure that DNS resolution of the domain name is functioning correctly. Run an nslookup/Resolve-DnsName to the FQDN (Fully Qualified Domain Name) of your domain (i.e.: contoso.com) from the deployed temporary management VM or session hosts. If the name is not resolved, it indicates a DNS resolution problem.
    - Resources:
        - [nslookup](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/nslookup)
        - [Resolve-DnsName](https://learn.microsoft.com/en-us/powershell/module/dnsclient/resolve-dnsname?view=windowsserver2022-ps)

- **Domain controller connectivity**: ensure that the AV

### Check Domain Join Account

- **Account Lockout**: Verify that the domain join account is not locked due to multiple failed attempts. Unlock the account if necessary.

- **Password Expiry**: Ensure that the password for the domain joiner account has not expired. Reset the password if needed, and update it in your AVD configuration.

- **Multi Factor Authentication (MFA)**: The account used for the deployment and the Active Directory Domain Join account cannot have multi-factor authentication (MFA) enabled.

- **UPN Mismatch**: Confirm that the User Principal Name (UPN) of the domain joiner account matches the expected format (mail@domain.com)

## FSLogix Issues

After successful deployment and enabling roaming profiles with FSLogix, if FSLogix is not working as expected, follow these steps for troubleshooting:

### Validate configuration
- **Validate storage account configuration**: Review the storage account file share domain join status. If it appears as "Not Configured". If "Not Configured" first ensure domain join on the management virtual machine was successful as this is evidence that the domain join did not fail for usual reasons. 
- **If using private endpoints**: Ensure you are able to resolve to the created file share in the storage account from the management virtual machine. If unable to resolve, ensure DNS is correctly set up, including:

    - Private DNS Zones are correctly configured to the Identity Services virtual network
    - If using custom DNS, conditional forwarders should be configured.
