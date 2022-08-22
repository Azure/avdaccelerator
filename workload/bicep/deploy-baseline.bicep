targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@minLength(2)
@maxLength(4)
@description('Required. The name of the resource group to deploy.')
param deploymentPrefix string = ''

@description('Optional. Location where to deploy compute services. (Default: eastus2)')
param avdSessionHostLocation string = 'eastus2'

@description('Optional. Location where to deploy AVD management plane. (Default: eastus2)')
param avdManagementPlaneLocation string = 'eastus2'

@description('Required. AVD workload subscription ID, multiple subscriptions scenario.')
param avdWorkloadSubsId string = ''

@description('Required. Azure Virtual Desktop Enterprise Application object ID. ')
param avdEnterpriseAppObjectId string = ''

@description('Required. AVD session host local username.')
param avdVmLocalUserName string = ''

@description('Required. AVD session host local password.')
@secure()
param avdVmLocalUserPassword string = ''

@allowed([
    'ADDS' // Active Directory Domain Services
    'AADDS' // Azure Active Directory Domain Services
    //'AAD' // Azure AD Join
])
@description('Required, The service providing domain services for Azure Virtual Desktop. (Defualt: ADDS)')
param avdIdentityServiceProvider string = 'ADDS'

@description('Required. AD domain name.')
param avdIdentityDomainName string = ''

@description('Required. AVD session host domain join username.')
param avdDomainJoinUserName string = ''

@description('Required. AVD session host domain join password.')
@secure()
param avdDomainJoinUserPassword string = ''

@description('Optional. OU path to join AVd VMs. (Default: "")')
param avdOuPath string = ''

@allowed([
    'Personal'
    'Pooled'
])
@description('Optional. AVD host pool type. (Default: Pooled)')
param avdHostPoolType string = 'Pooled'

@allowed([
    'Automatic'
    'Direct'
])
@description('Optional. AVD host pool type. (Default: Automatic)')
param avdPersonalAssignType string = 'Automatic'

@allowed([
    'BreadthFirst'
    'DepthFirst'
])
@description('Optional. AVD host pool load balacing type. (Default: BreadthFirst)')
param avdHostPoolLoadBalancerType string = 'BreadthFirst'

@description('Optional. AVD host pool maximum number of user sessions per session host. (Default: 15)')
param avhHostPoolMaxSessions int = 15

@description('Optional. AVD host pool start VM on Connect. (Default: true)')
param avdStartVmOnConnect bool = true

@description('Optional. Create custom Start VM on connect role. (Default: true)')
param createStartVmOnConnectCustomRole bool = true

@description('Optional. AVD deploy remote app application group. (Default: false)')
param avdDeployRappGroup bool = false

@description('Optional. AVD host pool Custom RDP properties. (Default: audiocapturemode:i:1;audiomode:i:0;drivestoredirect:s:;redirectclipboard:i:1;redirectcomports:i:1;redirectprinters:i:1;redirectsmartcards:i:1;screen mode id:i:2)')
param avdHostPoolRdpProperties string = 'audiocapturemode:i:1;audiomode:i:0;drivestoredirect:s:;redirectclipboard:i:1;redirectcomports:i:1;redirectprinters:i:1;redirectsmartcards:i:1;screen mode id:i:2'

@description('Optional. Create new virtual network. (Default: true)')
param createAvdVnet bool = true

@description('Optional. Existing virtual network subnet. (Default: "")')
param existingVnetSubnetResourceId string = ''

@description('Required. Existing hub virtual network for perring.')
param existingHubVnetResourceId string = ''

@description('Optional. AVD virtual network address prefixes. (Default: 10.10.0.0/23)')
param avdVnetworkAddressPrefixes string = '10.10.0.0/23'

@description('Optional. AVD virtual network subnet address prefix. (Default: 10.10.0.0/23)')
param avdVnetworkSubnetAddressPrefix string = '10.10.0.0/23'

@description('Optional. custom DNS servers IPs.')
param customDnsIps string = 'none'

@description('Optional. Use Azure private DNS zones for private endpoints. (Default: false)')
param avdVnetPrivateDnsZone bool = false

@description('Optional. Use Azure private DNS zones for private endpoints. (Default: false)')
param avdVnetPrivateDnsZoneFilesId string = ''

@description('Optional. Use Azure private DNS zones for private endpoints. (Default: false)')
param avdVnetPrivateDnsZoneKeyvaultId string = ''

@description('Optional. Does the hub contains a virtual network gateway. (Default: false)')
param vNetworkGatewayOnHub bool = false

@description('Optional. Deploy Fslogix setup. (Default: true)')
param createAvdFslogixDeployment bool = true

@description('Optional. Fslogix file share size. (Default: 5TB)')
param avdFslogixFileShareQuotaSize int = 512

@description('Optional. Deploy new session hosts. (Default: true)')
param avdDeploySessionHosts bool = true

@minValue(1)
@maxValue(999)
@description('Optional. Cuantity of session hosts to deploy. (Default: 1)')
param avdDeploySessionHostsCount int = 1

@description('Optional. The session host number to begin with for the deployment. This is important when adding virtual machines to ensure the names do not conflict. (Default: 0)')
param avdSessionHostCountIndex int = 0

@description('Optional. Creates an availability zone and adds the VMs to it. Cannot be used in combination with availability set nor scale set. (Defualt: true)')
param avdUseAvailabilityZones bool = true

@description('Optional. Sets the number of fault domains for the availability set. (Defualt: 3)')
param avdAsFaultDomainCount int = 2

@description('Optional. Sets the number of update domains for the availability set. (Defualt: 5)')
param avdAsUpdateDomainCount int = 5

@description('Optional. Storage account SKU for FSLogix storage. Recommended tier is Premium LRS or Premium ZRS. (when available) (Defualt: Premium_LRS)')
param fslogixStorageSku string = 'Premium_LRS'

@description('Optional. This property can be used by user in the request to enable or disable the Host Encryption for the virtual machine. This will enable the encryption for all the disks including Resource/Temp disk at host itself. For security reasons, it is recommended to set encryptionAtHost to True. Restrictions: Cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
param encryptionAtHost bool = false

@description('Optional. Session host VM size. (Defualt: Standard_D2s_v3)')
param avdSessionHostsSize string = 'Standard_D2s_v3'

@description('Optional. OS disk type for session host. (Defualt: Standard_LRS)')
param avdSessionHostDiskType string = 'Standard_LRS'

@allowed([
    'win10_21h2_office'
    'win10_21h2'
    'win11_21h2_office'
    'win11_21h2'
])
@description('Optional. AVD OS image source. (Default: win10-21h2)')
param avdOsImage string = 'win10_21h2'

@description('Optional. Set to deploy image from Azure Compute Gallery. (Default: false)')
param useSharedImage bool = false

@description('Optional. Source custom image ID. (Default: "")')
param avdImageTemplataDefinitionId string = ''

@description('Optional. OU name for Azure Storage Account. It is recommended to create a new AD Organizational Unit (OU) in AD and disable password expiration policy on computer accounts or service logon accounts accordingly.  (Default: "")')
param storageOuPath string = ''

@description('Optional. If OU for Azure Storage needs to be created - set to true and ensure the domain join credentials have priviledge to create OU and create computer objects or join to domain. (Default: "")')
param createOuForStorage bool = false

// Custom Naming
// Input must followe resource naming rules on https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules
@description('Required. AVD resources custom naming. (Default: false)')
param avdUseCustomNaming bool = false

@maxLength(90)
@description('Optional. AVD service resources resource group custom name. (Default: rg-avd-use2-app1-service-objects)')
param avdServiceObjectsRgCustomName string = 'rg-avd-use2-app1-service-objects'

@maxLength(90)
@description('Optional. AVD network resources resource group custom name. (Default: rg-avd-use2-app1-network)')
param avdNetworkObjectsRgCustomName string = 'rg-avd-use2-app1-network'

@maxLength(90)
@description('Optional. AVD network resources resource group custom name. (Default: rg-avd-use2-app1-pool-compute)')
param avdComputeObjectsRgCustomName string = 'rg-avd-use2-app1-pool-compute'

@maxLength(90)
@description('Optional. AVD network resources resource group custom name. (Default: rg-avd-use2-app1-storage)')
param avdStorageObjectsRgCustomName string = 'rg-avd-use2-app1-storage'

@maxLength(64)
@description('Optional. AVD virtual network custom name. (Default: vnet-avd-use2-app1-001)')
param avdVnetworkCustomName string = 'vnet-avd-use2-app1-001'

@maxLength(80)
@description('Optional. AVD virtual network subnet custom name. (Default: snet-avd-use2-app1-001)')
param avdVnetworkSubnetCustomName string = 'snet-avd-use2-app1-001'

@maxLength(80)
@description('Optional. AVD network security group custom name. (Default: nsg-avd-use2-app1-001)')
param avdNetworksecurityGroupCustomName string = 'nsg-avd-use2-app1-001'

@maxLength(80)
@description('Optional. AVD route table custom name. (Default: route-avd-use2-app1-001)')
param avdRouteTableCustomName string = 'route-avd-use2-app1-001'

@maxLength(80)
@description('Optional. AVD application security custom name. (Default: asg-avd-use2-app1-001)')
param avdApplicationSecurityGroupCustomName string = 'asg-avd-use2-app1-001'

@maxLength(64)
@description('Optional. AVD workspace custom name. (Default: vdws-use2-app1-001)')
param avdWorkSpaceCustomName string = 'vdws-use2-app1-001'

@maxLength(64)
@description('Optional. AVD host pool custom name. (Default: vdpool-use2-app1-001)')
param avdHostPoolCustomName string = 'vdpool-use2-app1-001'

@maxLength(64)
@description('Optional. AVD desktop application group custom name. (Default: vdag-desktop-use2-app1-001)')
param avdApplicationGroupCustomNameDesktop string = 'vdag-desktop-use2-app1-001'

@maxLength(64)
@description('Optional. AVD remote application group custom name. (Default: vdag-rapp-use2-app1-001)')
param avdApplicationGroupCustomNameRapp string = 'vdag-rapp-use2-app1-001'

@maxLength(11)
@description('Optional. AVD session host prefix custom name. (Default: vm-avd-app1)')
param avdSessionHostCustomNamePrefix string = 'vm-avd-app1'

@maxLength(9)
@description('Optional. AVD availability set custom name. (Default: avail-avd)')
param avdAvailabilitySetCustomNamePrefix string = 'avail-avd'

@maxLength(5)
@description('Optional. AVD fslogix storage account prefix custom name. (Default: stavd)')
param avdFslogixStoragePrefixCustomName string = 'stavd'

@maxLength(64)
@description('Optional. AVD fslogix storage account profile container file share prefix custom name. (Default: fslogix-pc-app1-001)')
param avdFslogixProfileContainerFileShareCustomName string = 'fslogix-pc-app1-001'

//@maxLength(64)
//@description('Optional. AVD fslogix storage account office container file share prefix custom name. (Default: fslogix-oc-app1-001)')
//param avdFslogixOfficeContainerFileShareCustomName string = 'fslogix-oc-app1-001'

@maxLength(6)
@description('Optional. AVD keyvault prefix custom name. (Default: kv-avd)')
param avdWrklKvPrefixCustomName string = 'kv-avd'
//

// Resource tagging
// 
@description('Optional. Apply tags on resources and resource groups. (Default: false)')
param createResourceTags bool = false

@description('Optional. The name of workload for tagging purposes. (Default: Contoso-Workload)')
param workloadNameTag string = 'Contoso-Workload'

@allowed([
    'Light'
    'Medium'
    'High'
    'Power'
])
@description('Optional. Reference to the size of the VM for your workloads (Default: Light)')
param workloadTypeTag string = 'Light'

@allowed([
    'Non-business'
    'Public'
    'General'
    'Confidential'
    'Highly-confidential'
])
@description('Optional. Sensitivity of data hosted (Default: Non-business)')
param dataClassificationTag string = 'Non-business'

@description('Optional. Department that owns the deployment, (Dafult: Contoso-AVD)')
param departmentTag string = 'Contoso-AVD'

@allowed([
    'Low'
    'Medium'
    'High'
    'Mission-critical'
    'Custom'
])
@description('Optional. Criticality of the workload. (Default: Low)')
param workloadCriticalityTag string = 'Low'

@description('Optional. Tag value for custom criticality value. (Default: Contoso-Critical)')
param workloadCriticalityCustomValueTag string = 'Contoso-Critical'

@description('Optional. Details about the application.')
param applicationNameTag string = 'Contoso-App'

@description('Required. Service level agreement level of the worload. (Contoso-SLA)')
param workloadSlaTag string = 'Contoso-SLA'

@description('Optional. Team accountable for day-to-day operations. (workload-admins@Contoso.com)')
param opsTeamTag string = 'workload-admins@Contoso.com'

@description('Optional. Organizational owner of the AVD deployment. (Default: workload-owner@Contoso.com)')
param ownerTag string = 'workload-owner@Contoso.com'

@description('Optional. Cost center of owner team. (Defualt: Contoso-CC)')
param costCenterTag string = 'Contoso-CC'

@allowed([
    'Prod'
    'Dev'
    'Staging '
])
@description('Optional. Deployment environment of the application, workload. (Default: Dev)')
param environmentTypeTag string = 'Dev'
//

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

@description('Enable usage and telemetry feedback to Microsoft.')
param enableTelemetry bool = true

// =========== //
// Variable declaration //
// =========== //
// Resource naming
var deploymentPrefixLowercase = toLower(deploymentPrefix)
var avdSessionHostLocationLowercase = toLower(avdSessionHostLocation)
var avdManagementPlaneLocationLowercase = toLower(avdManagementPlaneLocation)
var avdSessionHostLocationAcronym = locationAcronyms[avdSessionHostLocationLowercase]
var avdManagementPlaneLocationAcronym = locationAcronyms[avdManagementPlaneLocation]
var locationAcronyms = {
    eastasia: 'eas'
    southeastasia: 'seas'
    centralus: 'cus'
    eastus: 'eus'
    eastus2: 'eus2'
    westus: 'wus'
    northcentralus: 'ncus'
    southcentralus: 'scus'
    northeurope: 'neu'
    westeurope: 'weu'
    japanwest: 'jpw'
    japaneast: 'jpe'
    brazilsouth: 'drs'
    australiaeast: 'aue'
    australiasoutheast: 'ause'
    southindia: 'sin'
    centralindia: 'cin'
    westindia: 'win'
    canadacentral: 'cac'
    canadaeast: 'cae'
    uksouth: 'uks'
    ukwest: 'ukw'
    westcentralus: 'wcus'
    westus2: 'wus2'
    koreacentral: 'krc'
    koreasouth: 'krs'
    francecentral: 'frc'
    francesouth: 'frs'
    australiacentral: 'auc'
    australiacentral2: 'auc2'
    uaecentral: 'aec'
    uaenorth: 'aen'
    southafricanorth: 'zan'
    southafricawest: 'zaw'
    switzerlandnorth: 'chn'
    switzerlandwest: 'chw'
    germanynorth: 'den'
    germanywestcentral: 'dewc'
    norwaywest: 'now'
    norwayeast: 'noe'
    brazilsoutheast: 'brse'
    westus3: 'wus3'
    swedencentral: 'sec'
}
var avdNamingUniqueStringSixChar = take('${uniqueString(avdWorkloadSubsId, deploymentPrefixLowercase, time)}', 6)
var avdManagementPlaneNamingStandard = '${avdManagementPlaneLocationAcronym}-${deploymentPrefixLowercase}'
var avdComputeStorageResourcesNamingStandard = '${avdSessionHostLocationAcronym}-${deploymentPrefixLowercase}'
var avdServiceObjectsRgName = avdUseCustomNaming ? avdServiceObjectsRgCustomName : 'rg-avd-${avdManagementPlaneNamingStandard}-service-objects' // max length limit 90 characters
var avdNetworkObjectsRgName = avdUseCustomNaming ? avdNetworkObjectsRgCustomName : 'rg-avd-${avdComputeStorageResourcesNamingStandard}-network' // max length limit 90 characters
var avdComputeObjectsRgName = avdUseCustomNaming ? avdComputeObjectsRgCustomName : 'rg-avd-${avdComputeStorageResourcesNamingStandard}-pool-compute' // max length limit 90 characters
var avdStorageObjectsRgName = avdUseCustomNaming ? avdStorageObjectsRgCustomName : 'rg-avd-${avdComputeStorageResourcesNamingStandard}-storage' // max length limit 90 characters
//var avdSharedResourcesRgName = 'rg-${avdSessionHostLocationAcronym}-avd-shared-resources'
var avdVnetworkName = avdUseCustomNaming ? avdVnetworkCustomName : 'vnet-avd-${avdComputeStorageResourcesNamingStandard}-001'
var avdVnetworkSubnetName = avdUseCustomNaming ? avdVnetworkSubnetCustomName : 'snet-avd-${avdComputeStorageResourcesNamingStandard}-001'
var avdNetworksecurityGroupName = avdUseCustomNaming ? avdNetworksecurityGroupCustomName : 'nsg-avd-${avdComputeStorageResourcesNamingStandard}-001'
var avdRouteTableName = avdUseCustomNaming ? avdRouteTableCustomName : 'route-avd-${avdComputeStorageResourcesNamingStandard}-001'
var avdApplicationSecurityGroupName = avdUseCustomNaming ? avdApplicationSecurityGroupCustomName : 'asg-avd-${avdComputeStorageResourcesNamingStandard}-001'
var avdVnetworkPeeringName = 'peering-avd-${avdComputeStorageResourcesNamingStandard}-${avdNamingUniqueStringSixChar}'
var avdWorkSpaceName = avdUseCustomNaming ? avdWorkSpaceCustomName : 'vdws-${avdManagementPlaneNamingStandard}-001'
var avdHostPoolName = avdUseCustomNaming ? avdHostPoolCustomName : 'vdpool-${avdManagementPlaneNamingStandard}-001'
var avdApplicationGroupNameDesktop = avdUseCustomNaming ? avdApplicationGroupCustomNameDesktop : 'vdag-desktop-${avdManagementPlaneNamingStandard}-001'
var avdApplicationGroupNameRapp = avdUseCustomNaming ? avdApplicationGroupCustomNameRapp : 'vdag-rapp-${avdManagementPlaneNamingStandard}-001'
var avdWrklKvName = avdUseCustomNaming ? '${avdWrklKvPrefixCustomName}-${avdComputeStorageResourcesNamingStandard}-${avdNamingUniqueStringSixChar}' : 'kv-avd-${avdComputeStorageResourcesNamingStandard}-${avdNamingUniqueStringSixChar}' // max length limit 24 characters
var avdWrklKvPrivateEndpointName = 'pe-kv-avd-${deploymentPrefixLowercase}-${avdNamingUniqueStringSixChar}-vault'
var avdSessionHostNamePrefix = avdUseCustomNaming ? avdSessionHostCustomNamePrefix : 'vm-avd-${deploymentPrefixLowercase}'
var avdAvailabilitySetNamePrefix = avdUseCustomNaming ? '${avdAvailabilitySetCustomNamePrefix}-${avdSessionHostLocationAcronym}-${deploymentPrefixLowercase}' : 'avail-avd-${avdSessionHostLocationAcronym}-${deploymentPrefixLowercase}'
var fslogixManagedIdentityName = 'id-avd-fslogix-${avdSessionHostLocationAcronym}-${deploymentPrefixLowercase}'
var avdFslogixProfileContainerFileShareName = avdUseCustomNaming ? avdFslogixProfileContainerFileShareCustomName : 'fslogix-pc-${deploymentPrefixLowercase}-001'
//var avdFslogixOfficeContainerFileShareName = avdUseCustomNaming ? avdFslogixOfficeContainerFileShareCustomName: 'fslogix-oc-${deploymentPrefixLowercase}-001'
var avdFslogixStorageName = avdUseCustomNaming ? '${avdFslogixStoragePrefixCustomName}${deploymentPrefixLowercase}${avdNamingUniqueStringSixChar}' : 'stavd${deploymentPrefixLowercase}${avdNamingUniqueStringSixChar}'
var avdWrklStoragePrivateEndpointName = 'pe-stavd${deploymentPrefixLowercase}${avdNamingUniqueStringSixChar}-file'
var managementVmName = 'vm-mgmt-${deploymentPrefixLowercase}'
//

var marketPlaceGalleryWindows = {
    win10_21h2_office: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'office-365'
        sku: 'win10-21h2-avd-m365'
        version: 'latest'
    }

    win10_21h2: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'windows-10'
        sku: 'win10-21h2-avd'
        version: 'latest'
    }

    win11_21h2_office: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'office-365'
        sku: 'win11-21h2-avd-m365'
        version: 'latest'
    }

    win11_21h2: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-11'
        sku: 'win11-21h2-avd'
        version: 'latest'
    }
}

var baseScriptUri = 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/'
var fslogixScriptUri = '${baseScriptUri}scripts/Set-FSLogixRegKeys.ps1'
var fsLogixScript = './Set-FSLogixRegKeys.ps1'
var fslogixSharePath = '\\\\${avdFslogixStorageName}.file.${environment().suffixes.storage}\\${avdFslogixProfileContainerFileShareName}'
var FsLogixScriptArguments = '-volumeshare ${fslogixSharePath}'
var avdAgentPackageLocation = 'https://wvdportalstorageblob.blob.${environment().suffixes.storage}/galleryartifacts/Configuration_01-20-2022.zip'
var storageAccountContributorRoleId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
var readerRoleId = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
var dscAgentPackageLocationAdds = 'https://github.com/Azure/avdaccelerator/raw/main/workload/scripts/DSCDomainJoinStorageScriptsADDS.zip'
var dscAgentPackageLocationAadds = 'https://github.com/Azure/avdaccelerator/raw/main/workload/scripts/DSCNTFSStorageScriptsAADDS.zip'
var storageToDomainScriptUriAdds = '${baseScriptUri}scripts/Manual-DSC-JoinStorage-to-Domain-ADDS.ps1'
var storageToDomainScriptUriAadds = '${baseScriptUri}scripts/Manual-DSC-JoinStorage-to-Domain-AADDS.ps1'
var storageToDomainScriptAdds = './Manual-DSC-JoinStorage-to-Domain-ADDS.ps1'
var storageToDomainScriptAadds = './Manual-DSC-JoinStorage-to-Domain-AADDS.ps1'
var ouStgPath = !empty(storageOuPath) ? '"${storageOuPath}"' : '"${defaultStorageOuPath}"'
var defaultStorageOuPath = (avdIdentityServiceProvider == 'AADDS') ? 'AADDC Computers': 'Computers'
var storageToDomainScriptArgsAdds = '-DscPath ${dscAgentPackageLocationAdds} -StorageAccountName ${avdFslogixStorageName} -StorageAccountRG ${avdStorageObjectsRgName} -DomainName ${avdIdentityDomainName} -AzureCloudEnvironment AzureCloud -SubscriptionId ${avdWorkloadSubsId} -DomainAdminUserName ${avdDomainJoinUserName} -DomainAdminUserPassword ${avdDomainJoinUserPassword} -OUName ${ouStgPath} -CreateNewOU ${createOuForStorageString} -ShareName ${avdFslogixProfileContainerFileShareName} -ClientId ${deployAvdManagedIdentitiesRoleAssign.outputs.fslogixManagedIdentityClientId} -Verbose'
var storageToDomainScriptArgsAadds = '-DscPath ${dscAgentPackageLocationAadds} -StorageAccountName ${avdFslogixStorageName} -StorageAccountRG ${avdStorageObjectsRgName} -DomainName ${avdIdentityDomainName} -AzureCloudEnvironment AzureCloud -SubscriptionId ${avdWorkloadSubsId} -DomainAdminUserName ${avdDomainJoinUserName} -DomainAdminUserPassword ${avdDomainJoinUserPassword} -OUName ${ouStgPath} -CreateNewOU ${createOuForStorageString} -ShareName ${avdFslogixProfileContainerFileShareName} -ClientId ${deployAvdManagedIdentitiesRoleAssign.outputs.fslogixManagedIdentityClientId} -Verbose'
//var allAvailabilityZones = pickZones('Microsoft.Compute', 'virtualMachines', avdSessionHostLocation, 3)
var createOuForStorageString = string(createOuForStorage)
var dnsServers = (customDnsIps == 'none') ? []: (split(customDnsIps, ','))

// Resource tagging
var commonResourceTags = createResourceTags ? {
    WorkloadName: workloadNameTag
    WorkloadType: workloadTypeTag
    DataClassification: dataClassificationTag
    Department: departmentTag
    Criticality: (workloadCriticalityTag == 'Custom') ? workloadCriticalityCustomValueTag : workloadCriticalityTag
    ApplicationName: applicationNameTag
    ServiceClass: workloadSlaTag
    OpsTeam: opsTeamTag
    Owner: ownerTag
    CostCenter: costCenterTag
    Environment: environmentTypeTag

} : {}

var allComputeStorageTags = {
    DomainName: avdIdentityDomainName
    JoinType: 'ADDS' // avdDeviceJoinTypeTag waiting for PR on identity to be merged
}
var allResourceTags = union(commonResourceTags, allComputeStorageTags)
//

var resourceGroups = [
    {
        name: avdServiceObjectsRgName
        location: avdManagementPlaneLocation
    }
    {
        name: avdComputeObjectsRgName
        location: avdSessionHostLocation
    }
    /*
    {
        name: avdStorageObjectsRgName
        location: avdSessionHostLocation
    }
    */
]

var telemetryId = 'pid-2ce4228c-d72c-43fb-bb5b-cd8f3ba2138e-${avdManagementPlaneLocation}'

// =========== //
// Deployments //
// =========== //

//  Telemetry Deployment.
resource telemetrydeployment 'Microsoft.Resources/deployments@2021-04-01' = if (enableTelemetry) {
    name: telemetryId
    location: avdManagementPlaneLocation
    properties: {
        mode: 'Incremental'
        template: {
            '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
            contentVersion: '1.0.0.0'
            resources: []
        }
    }
}

// Resource groups.
// Compute, service objects, network.
module avdBaselineResourceGroups '../../carml/1.2.0/Microsoft.Resources/resourceGroups/deploy.bicep' = [for resourceGroup in resourceGroups: {
    scope: subscription(avdWorkloadSubsId)
    name: 'Deploy-${substring(resourceGroup.name, 10)}-${time}'
    params: {
        name: resourceGroup.name
        location: resourceGroup.location
        enableDefaultTelemetry: false
        tags: createResourceTags ? commonResourceTags : {}
    }
}]

// Storage.
module avdBaselineStorageResourceGroup '../../carml/1.2.0/Microsoft.Resources/resourceGroups/deploy.bicep' = if (createAvdFslogixDeployment) {
    scope: subscription(avdWorkloadSubsId)
    name: 'Deploy-${avdStorageObjectsRgName}-${time}'
    params: {
        name: avdStorageObjectsRgName
        location: avdSessionHostLocation
        enableDefaultTelemetry: false
        tags: createResourceTags ? commonResourceTags : {}
    }
}
//

// Optional. Networking.
module avdNetworking 'avd-modules/avd-networking.bicep' = if (createAvdVnet) {
    name: 'Deploy-AVD-Networking-${time}'
    params: {
        avdApplicationSecurityGroupName: avdApplicationSecurityGroupName
        avdComputeObjectsRgName: avdComputeObjectsRgName
        avdNetworkObjectsRgName: avdNetworkObjectsRgName
        avdNetworksecurityGroupName: avdNetworksecurityGroupName
        avdRouteTableName: avdRouteTableName
        avdVnetworkAddressPrefixes: avdVnetworkAddressPrefixes
        avdVnetworkName: avdVnetworkName
        avdVnetworkPeeringName: avdVnetworkPeeringName
        avdVnetworkSubnetName: avdVnetworkSubnetName
        createAvdVnet: createAvdVnet
        vNetworkGatewayOnHub: vNetworkGatewayOnHub
        existingHubVnetResourceId: existingHubVnetResourceId
        avdSessionHostLocation: avdSessionHostLocation
        avdVnetworkSubnetAddressPrefix: avdVnetworkSubnetAddressPrefix
        avdWorkloadSubsId: avdWorkloadSubsId
        dnsServers: dnsServers
        avdTags: createResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        avdBaselineResourceGroups
    ]
}

// AVD management plane.
// Host pool and application groups.
module avdHostPoolandAppGroups 'avd-modules/avd-hostpool-app-groups.bicep' = {
    name: 'Deploy-AVD-HostPool-AppGroups-${time}'
    params: {
        avdApplicationGroupNameDesktop: avdApplicationGroupNameDesktop
        avdApplicationGroupNameRapp: avdApplicationGroupNameRapp
        avdDeployRappGroup: avdDeployRappGroup
        avdHostPoolName: avdHostPoolName
        avdHostPoolRdpProperties: avdHostPoolRdpProperties
        avdHostPoolLoadBalancerType: avdHostPoolLoadBalancerType
        avdHostPoolType: avdHostPoolType
        avhHostPoolMaxSessions: avhHostPoolMaxSessions
        avdPersonalAssignType: avdPersonalAssignType
        avdManagementPlaneLocation: avdManagementPlaneLocation
        avdServiceObjectsRgName: avdServiceObjectsRgName
        avdStartVmOnConnect: avdStartVmOnConnect
        avdWorkloadSubsId: avdWorkloadSubsId
        avdIdentityServiceProvider: avdIdentityServiceProvider
        avdTags: createResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        avdBaselineResourceGroups
    ]
}

// Workspace.
module avdWorkSpace '../../carml/1.2.0/Microsoft.DesktopVirtualization/workspaces/deploy.bicep' = {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
    name: 'Deploy-AVD-WorkSpace-${time}'
    params: {
        name: avdWorkSpaceName
        location: avdManagementPlaneLocation
        appGroupResourceIds: avdHostPoolandAppGroups.outputs.avdAppGroupsArray
        tags: createResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        avdHostPoolandAppGroups
    ]
}
//

// Identity: managed identities and role assignments.
module deployAvdManagedIdentitiesRoleAssign 'avd-modules/avd-identity.bicep' = {
    name: 'Create-Managed-ID-RoleAssign-${time}'
    params: {
        avdComputeObjectsRgName: avdComputeObjectsRgName
        avdDeploySessionHosts: avdDeploySessionHosts
        avdEnterpriseAppObjectId: avdEnterpriseAppObjectId
        avdSessionHostLocation: avdSessionHostLocation
        avdServiceObjectsRgName: avdServiceObjectsRgName
        avdStorageObjectsRgName: avdStorageObjectsRgName
        avdWorkloadSubsId: avdWorkloadSubsId
        createStartVmOnConnectCustomRole: createStartVmOnConnectCustomRole
        fslogixManagedIdentityName: fslogixManagedIdentityName
        readerRoleId: readerRoleId
        storageAccountContributorRoleId: storageAccountContributorRoleId
        createAvdFslogixDeployment: createAvdFslogixDeployment ? true: false
        avdTags: createResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        avdBaselineResourceGroups
    ]
}

// Key vault.
module avdWrklKeyVault '../../carml/1.2.0/Microsoft.KeyVault/vaults/deploy.bicep' = if (avdDeploySessionHosts) {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
    name: 'AVD-Workload-KeyVault-${time}'
    params: {
        name: avdWrklKvName
        location: avdSessionHostLocation
        enableRbacAuthorization: false
        enablePurgeProtection: true
        softDeleteRetentionInDays: 7
        networkAcls: {
            bypass: 'AzureServices'
            defaultAction: 'Deny'
            virtualNetworkRules: []
            ipRules: []
        }
        privateEndpoints: avdVnetPrivateDnsZone ? [
            {
                name: avdWrklKvPrivateEndpointName
                subnetResourceId: createAvdVnet ? '${avdNetworking.outputs.avdVirtualNetworkResourceId}/subnets/${avdVnetworkSubnetName}' : existingVnetSubnetResourceId
                service: 'vault'
                privateDnsZoneResourceIds: [
                    avdVnetPrivateDnsZoneKeyvaultId
                ]
            }
        ] : [
            {
                name: avdWrklKvPrivateEndpointName
                subnetResourceId: createAvdVnet ? '${avdNetworking.outputs.avdVirtualNetworkResourceId}/subnets/${avdVnetworkSubnetName}' : existingVnetSubnetResourceId
                service: 'vault'
            }
        ]
        secrets: {
            secureList: [
                {
                    name: 'avdVmLocalUserPassword'
                    value: avdVmLocalUserPassword
                    contentType: 'Session host local user credentials'
                }
                {
                    name: 'avdVmLocalUserName'
                    value: avdVmLocalUserName
                    contentType: 'Session host local user credentials'
                }
                {
                    name: 'avdDomainJoinUserName'
                    value: avdDomainJoinUserName
                    contentType: 'Domain join credentials'
                }
                {
                    name: 'avdDomainJoinUserPassword'
                    value: avdDomainJoinUserPassword
                    contentType: 'Domain join credentials'
                }
            ]
        }
        tags: createResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        avdBaselineResourceGroups
        //updateExistingSubnet
    ]
}

// Call on the KV.
resource avdWrklKeyVaultget 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = if (avdDeploySessionHosts) {
    name: avdWrklKvName
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
}

// Storage.
module deployAvdStorageAzureFiles 'avd-modules/avd-storage-azurefiles.bicep' = if (createAvdFslogixDeployment && avdDeploySessionHosts && (avdIdentityServiceProvider == 'AADDS' || avdIdentityServiceProvider == 'ADDS')) {
    name: 'Deploy-AVD-Storage-AzureFiles-${time}'
    params: {
        avdIdentityServiceProvider: avdIdentityServiceProvider
        storageToDomainScript:  (avdIdentityServiceProvider == 'ADDS') ? storageToDomainScriptAdds: storageToDomainScriptAadds
        storageToDomainScriptArgs: (avdIdentityServiceProvider == 'ADDS') ? storageToDomainScriptArgsAdds: storageToDomainScriptArgsAadds
        storageToDomainScriptUri: (avdIdentityServiceProvider == 'ADDS') ? storageToDomainScriptUriAdds: storageToDomainScriptUriAadds
        avdWrklStoragePrivateEndpointName: avdWrklStoragePrivateEndpointName
        avdApplicationSecurityGroupResourceId: createAvdVnet ? '${avdNetworking.outputs.avdApplicationSecurityGroupResourceId}' : ''
        avdComputeObjectsRgName: avdComputeObjectsRgName
        avdDomainJoinUserName: avdDomainJoinUserName
        avdWrklKvName: avdWrklKvName
        avdServiceObjectsRgName: avdServiceObjectsRgName
        avdFslogixProfileContainerFileShareName: avdFslogixProfileContainerFileShareName
        avdFslogixFileShareQuotaSize: avdFslogixFileShareQuotaSize
        avdFslogixStorageName: avdFslogixStorageName
        avdIdentityDomainName: avdIdentityDomainName
        avdImageTemplataDefinitionId: avdImageTemplataDefinitionId
        sessionHostOuPath: avdOuPath
        avdSessionHostDiskType: avdSessionHostDiskType
        avdSessionHostLocation: avdSessionHostLocation
        avdSessionHostsSize: avdSessionHostsSize
        avdStorageObjectsRgName: avdStorageObjectsRgName
        avdSubnetId: createAvdVnet ? '${avdNetworking.outputs.avdVirtualNetworkResourceId}/subnets/${avdVnetworkSubnetName}' : existingVnetSubnetResourceId
        avdVmLocalUserName: avdVmLocalUserName
        avdVnetPrivateDnsZone: avdVnetPrivateDnsZone
        avdVnetPrivateDnsZoneFilesId: avdVnetPrivateDnsZoneFilesId
        avdWorkloadSubsId: avdWorkloadSubsId
        encryptionAtHost: encryptionAtHost
        fslogixManagedIdentityResourceId: createAvdFslogixDeployment ? deployAvdManagedIdentitiesRoleAssign.outputs.fslogixManagedIdentityResourceId : ''
        avdFslogixFileShareMultichannel: (contains(fslogixStorageSku, 'Premium_LRS') || contains(fslogixStorageSku, 'Premium_ZRS')) ? true : false
        fslogixStorageSku: fslogixStorageSku
        marketPlaceGalleryWindows: marketPlaceGalleryWindows['win10_21h2']
        subnetResourceId: createAvdVnet ? '${avdNetworking.outputs.avdVirtualNetworkResourceId}/subnets/${avdVnetworkSubnetName}' : existingVnetSubnetResourceId
        managementVmName: managementVmName
        useSharedImage: useSharedImage
        avdTags: createResourceTags ? allResourceTags : {}
    }
    dependsOn: [
        avdBaselineResourceGroups
        avdNetworking
        avdWrklKeyVaultget
        avdWrklKeyVault
    ]
}

// Session hosts.
module deployAndConfigureAvdSessionHosts './avd-modules/avd-session-hosts-batch.bicep' = if (avdDeploySessionHosts) {
    name: 'Deploy-and-Configure-AVD-SessionHosts-${time}'
    params: {
        avdAgentPackageLocation: avdAgentPackageLocation
        avdApplicationSecurityGroupResourceId: createAvdVnet ? '${avdNetworking.outputs.avdApplicationSecurityGroupResourceId}' : ''
        avdAsFaultDomainCount: avdAsFaultDomainCount
        avdAsUpdateDomainCount: avdAsUpdateDomainCount
        avdIdentityServiceProvider: avdIdentityServiceProvider
        avdAvailabilitySetNamePrefix: avdAvailabilitySetNamePrefix
        avdComputeObjectsRgName: avdComputeObjectsRgName
        avdDeploySessionHostsCount: avdDeploySessionHostsCount
        avdSessionHostCountIndex: avdSessionHostCountIndex
        avdDomainJoinUserName: avdDomainJoinUserName
        avdWrklKvName: avdWrklKvName
        avdServiceObjectsRgName: avdServiceObjectsRgName
        avdHostPoolName: avdHostPoolName
        avdIdentityDomainName: avdIdentityDomainName
        avdImageTemplataDefinitionId: avdImageTemplataDefinitionId
        sessionHostOuPath: avdOuPath
        avdSessionHostDiskType: avdSessionHostDiskType
        avdSessionHostLocation: avdSessionHostLocation
        avdSessionHostNamePrefix: avdSessionHostNamePrefix
        avdSessionHostsSize: avdSessionHostsSize
        avdSubnetId: createAvdVnet ? '${avdNetworking.outputs.avdVirtualNetworkResourceId}/subnets/${avdVnetworkSubnetName}' : existingVnetSubnetResourceId
        avdUseAvailabilityZones: avdUseAvailabilityZones
        avdVmLocalUserName: avdVmLocalUserName
        avdWorkloadSubsId: avdWorkloadSubsId
        encryptionAtHost: encryptionAtHost
        createAvdFslogixDeployment: createAvdFslogixDeployment
        fslogixManagedIdentityResourceId: createAvdFslogixDeployment ? deployAvdManagedIdentitiesRoleAssign.outputs.fslogixManagedIdentityResourceId : 'none'
        fsLogixScript: fsLogixScript
        FsLogixScriptArguments: FsLogixScriptArguments
        fslogixScriptUri: fslogixScriptUri
        hostPoolToken: avdHostPoolandAppGroups.outputs.hostPooltoken
        marketPlaceGalleryWindows: marketPlaceGalleryWindows[avdOsImage]
        useSharedImage: useSharedImage
        avdTags: createResourceTags ? allResourceTags : {}
    }
    dependsOn: [
        avdBaselineResourceGroups
        avdNetworking
        avdWrklKeyVaultget
        avdWrklKeyVault
    ]
}
