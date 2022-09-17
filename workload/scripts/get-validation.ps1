param(
    
    [parameter(Mandatory)]
    [string]$Availability,

    [parameter(Mandatory)]
    [string]$DiskEncryption,

    [parameter(Mandatory)]
    [string]$DiskSku,

    [parameter(Mandatory)]
    [string]$DomainName,

    [parameter(Mandatory)]
    [string]$DomainServices,

    [parameter(Mandatory)]
    [string]$EphemeralOsDisk,

    [parameter(Mandatory)]
    [string]$ImageSku,

    [parameter(Mandatory)]
    [string]$KerberosEncryption,

    [parameter(Mandatory)]
    [string]$Location,

    [parameter(Mandatory)]
    [string]$PooledHostPool,

    [parameter(Mandatory)]
    [string]$RecoveryServices,

    [parameter(Mandatory)]
    [int]$SecurityPrincipalIdsCount,

    [parameter(Mandatory)]
    [int]$SecurityPrincipalNamesCount,

    [parameter(Mandatory)]
    [int]$SessionHostCount,

    [parameter(Mandatory)]
    [int]$SessionHostIndex,

    [parameter(Mandatory)]
    [string]$StartVmOnConnect,       

    [parameter(Mandatory)]
    [int]$StorageCount,

    [parameter(Mandatory)]
    [string]$StorageSolution,

    [parameter(Mandatory)]
    [string]$VmSize,

    [parameter(Mandatory)]
    [string]$VnetName,

    [parameter(Mandatory)]
    [string]$VnetResourceGroupName
)

$ErrorActionPreference = 'Stop'

function Test-AzureCoreQuota {
param(

    [Parameter(Mandatory)]
    [string]$Location,

    [Parameter(Mandatory)]
    [int]$RequestedCores,

    [Parameter(Mandatory)]
    [string]$VmSize

)

    $Family = (Get-AzComputeResourceSku -Location $Location | Where-Object {$_.Name -eq $VmSize}).Family
    $CpuData = Get-AzVMUsage -Location $Location | Where-Object {$_.Name.Value -eq $Family}
    $AvailableCores = $CpuData.Limit - $CpuData.CurrentValue
    $RequestedCores = $vCPUs * $SessionHostCount
    if($RequestedCores -gt $AvailableCores)
    {
        return $false
    }
    else 
    {
        return $true
    }
}

# Object for collecting output
$DeploymentScriptOutputs = @{}

# Info required for validation
$Sku = Get-AzComputeResourceSku -Location $Location | Where-Object {$_.ResourceType -eq 'virtualMachines' -and $_.Name -eq $VmSize}

############################################################################################
# Validations & Output
############################################################################################
# Accelerated Networking
$DeploymentScriptOutputs["acceleratedNetworking"] = ($Sku.capabilities | Where-Object {$_.name -eq 'AcceleratedNetworkingEnabled'}).value


# Availability Zone Validation
if($Availability -eq 'AvailabilityZones' -and $Sku.locationInfo.zones.count -lt 3)
{
    Write-Error -Exception 'INVALID AVAILABILITY: The selected VM Size does not support availability zones in this Azure location. https://docs.microsoft.com/en-us/azure/virtual-machines/windows/create-powershell-availability-zone'
} 


# AVD Object ID Output
# This cannot be supported until a user-assigned identity can run Get-AzADServicePrincipal with Azure permissions
# https://docs.microsoft.com/en-us/azure/virtual-desktop/start-virtual-machine-connect?tabs=azure-portal#assign-the-custom-role-with-the-azure-portal
<# if($StartVmOnConnect -eq 'true')
{
    $AvdObjectId = (Get-AzADServicePrincipal -ApplicationId '9cdead84-a844-4324-93f2-b2e6bb768d07').Id
}
$DeploymentScriptOutputs["avdObjectId"] = $AvdObjectId #>


# Azure NetApp Files Validation & Output
if($StorageSolution -eq "AzureNetAppFiles")
{
    $Vnet = Get-AzVirtualNetwork -Name $VnetName -ResourceGroupName $VnetResourceGroupName
    $DnsServers = "$($Vnet.DhcpOptions.DnsServers[0]),$($Vnet.DhcpOptions.DnsServers[1])"
    $SubnetId = ($Vnet.Subnets | Where-Object {$_.Delegations[0].ServiceName -eq "Microsoft.NetApp/volumes"}).Id
    if($null -eq $SubnetId -or $SubnetId -eq '')
    {
        Write-Error -Exception 'INVALID AZURE NETAPP FILES CONFIGURATION: A dedicated subnet must be delegated to the ANF resource provider.'
    }
    Install-Module -Name "Az.NetAppFiles" -Force
    $DeployAnfAd = "true"
    $Accounts = Get-AzResource -ResourceType "Microsoft.NetApp/netAppAccounts" | Where-Object {$_.Location -eq $Location}
    foreach($Account in $Accounts)
    {
        $AD = Get-AzNetAppFilesActiveDirectory -ResourceGroupName $Account.ResourceGroupName -AccountName $Account.Name
        if($AD.ActiveDirectoryId){$DeployAnfAd = 'false'}
    }
    $DeploymentScriptOutputs["anfDnsServers"] = $DnsServers
    $DeploymentScriptOutputs["anfSubnetId"] = $SubnetId
    $DeploymentScriptOutputs["anfActiveDirectory"] = $DeployAnfAd
}
else 
{
    $DeploymentScriptOutputs["anfDnsServers"] = 'NotApplicable'
    $DeploymentScriptOutputs["anfSubnetId"] = 'NotApplicable'
    $DeploymentScriptOutputs["anfActiveDirectory"] = 'false'   
}


# Disk SKU validation
if($DiskSku -like "Premium*" -and ($Sku.capabilities | Where-Object {$_.name -eq 'PremiumIO'}).value -eq $false)
{
    Write-Error -Exception 'INVALID DISK SKU: The selected VM Size does not support the Premium SKU for managed disks.'
}


# DNS Forwarders
# This information is used to support Azure Private Link and only used when Private Endpoints are selected for the FSLogix storage.
[array]$DnsForwarders = (Get-AzVirtualNetwork -Name $VnetName -ResourceGroupName $VnetResourceGroupName).DhcpOptions.DnsServers
$DeploymentScriptOutputs["dnsForwarders"] = $DnsForwarders


# DNS Server Size
# This information is used to support Azure Private Link and only used when Private Endpoints are selected for the FSLogix storage.
$Tests = @()
$DnsServerSizes = (Get-AzVMSize -Location $Location | Where-Object {$_.Name -match "Standard_D[0-9]s_v[3-9]" -and $_.NumberOfCores -eq 2}).Name
foreach($DnsServerSize in $DnsServerSizes)
{
    $Tests += Test-AzureCoreQuota -Location $Location -RequestedCores 2 -VmSize $DnsServerSize
}
$Index = [array]::indexof($Tests,$true)
if($Index -eq -1)
{
    Write-Error -Exception 'INSUFFICIENT CORE QUOTA: The selected VM Family does not have adequate core quota in the selected location.'
}
$DeploymentScriptOutputs["dnsServerSize"] = $DnsServerSizes[$Index]


# Ephemeral Disks Validation & Output
if($EphemeralOsDisk -eq 'true')
{
    # Validate if the VM Size supports Ephemeral Disks
    if(($Sku.Capabilities | Where-Object {$_.Name -eq 'EphemeralOSDiskSupported'}).value)
    {
        # Azure Disk Encryption is not support with Ephemeral Disks
        if($DiskEncryption -eq 'true')
        {
            Write-Error -Exception 'INVALID EPHEMERAL DISK CONFIGURATION: Azure Disk Encryption is not supported with an Ephemeral OS Disk.'
        }

        # Azure Disk Encryption is not support with Ephemeral Disks
        if($RecoveryServices -eq 'true' -and $PooledHostPool -eq 'false')
        {
            Write-Error -Exception 'INVALID EPHEMERAL DISK CONFIGURATION: Azure Backup is not supported with an Ephemeral OS Disk.'
        }

        $ImageSize = 127 * 1GB
        $ResourceVolumeMB = ($Sku.Capabilities | Where-Object {$_.Name -eq 'MaxResourceVolumeMB'}).Value
        $ResourceVolumeSize = if($ResourceVolumeMB){[int64]$ResourceVolumeMB * 1MB}else{0}
        $CachedDiskBytes = ($Sku.Capabilities | Where-Object {$_.Name -eq 'CachedDiskBytes'}).Value
        $CacheVolumeSize = if($CachedDiskBytes){[int64]$CachedDiskBytes}else{0}

        if($ResourceVolumeSize -gt $ImageSize)
        {
            $DeploymentScriptOutputs["ephemeralOsDisk"] = 'ResourceDisk'
        }
        elseif ($CacheVolumeSize -gt $ImageSize)
        {
            $DeploymentScriptOutputs["ephemeralOsDisk"] = 'CacheDisk'
        }
    }
    else
    {
        Write-Error -Exception "INVALID VM SIZE: VM Size, $VmSize, does not support Ephemeral Disks."
    }
}
else
{
    $DeploymentScriptOutputs["ephemeralOsDisk"] = 'None'
}


# Hyper-V Generation validation
if($ImageSku -like "*-g2" -and ($Sku.capabilities | Where-Object {$_.name -eq 'HyperVGenerations'}).value -notlike "*2")
{
    Write-Error -Exception 'INVALID HYPER-V GENERATION: The selected VM size does not support the selected Image Sku.'
}


# Kerberos Encryption Type validation
if($DomainServices -eq 'AzureActiveDirectory')
{
    $KerberosRc4Encryption = (Get-AzResource -Name $DomainName -ExpandProperties).Properties.domainSecuritySettings.kerberosRc4Encryption
    if($KerberosRc4Encryption -eq 'Enabled' -and $KerberosEncryption -eq 'AES256')
    {
        Write-Error -Exception 'INVALID KERBEROS ENCRYPTION: The Kerberos Encryption on Azure AD DS does not match your Kerberos Encyrption selection.'
    }
}


# Storage Assignment Validation
# Validate the array length for the Security Principal ID's, Security Principal Names, and Storage Count align
if(($StorageCount -ne $SecurityPrincipalIdsCount -or $StorageCount -ne $SecurityPrincipalNamesCount) -and $StorageCount -gt 0)
{
    Write-Error -Exception 'INVALID ARRAYS: The "SecurityPrinicaplIds" count, "SecurityPrincipalNames" count, and "StorageCount" value must be equal.'
}


# vCPU Count Validation
# Recommended range is 4 min, 24 max
# https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/virtual-machine-recs?context=/azure/virtual-desktop/context/context
$vCPUs = [int]($Sku.capabilities | Where-Object {$_.name -eq 'vCPUs'}).value
if($vCPUs -lt 4 -or $vCPUs -gt 24)
{
    Write-Error -Exception 'INVALID VCPU COUNT: The selected VM Size does not contain the appropriate amount of vCPUs for Azure Virtual Desktop. https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/virtual-machine-recs'
}


# vCPU Quota Validation
$RequestedCores = $vCPUs * $SessionHostCount
$Test = Test-AzureCoreQuota -Location $Location -RequestedCores $RequestedCores -VmSize $VmSize
if(!$Test)
{
    Write-Error -Exception "INSUFFICIENT CORE QUOTA: The selected VM size, $VmSize, does not have adequate core quota in the selected location."
}