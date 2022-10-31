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
    'AAD' // Azure AD Join
])
@description('Required, The service providing domain services for Azure Virtual Desktop. (Defualt: ADDS)')
param avdIdentityServiceProvider string = 'ADDS'

@description('Required, Eronll session hosts on Intune. (Defualt: false)')
param createIntuneEnrollment bool = false

@description('Optional, Identity ID to grant RBAC role to access AVD application group. (Defualt: "")')
param avdApplicationGroupIdentitiesIds string = ''

@allowed([
    'Group'
    'ServicePrincipal'
    'User'
])
@description('Optional, Identity type to grant RBAC role to access AVD application group. (Defualt: "")')
param avdApplicationGroupIdentityType string = 'Group'

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

@description('Optional. AVD host pool maximum number of user sessions per session host. (Default: 5)')
param avhHostPoolMaxSessions int = 5

@description('Optional. AVD host pool start VM on Connect. (Default: true)')
param avdStartVmOnConnect bool = true

@description('Optional. Create custom Start VM on connect role. (Default: true)')
param createStartVmOnConnectCustomRole bool = true

@description('Optional. AVD deploy remote app application group. (Default: false)')
param avdDeployRappGroup bool = false

@description('Optional. AVD host pool Custom RDP properties. (Default: audiocapturemode:i:1;audiomode:i:0;drivestoredirect:s:;redirectclipboard:i:1;redirectcomports:i:1;redirectprinters:i:1;redirectsmartcards:i:1;screen mode id:i:2)')
param avdHostPoolRdpProperties string = 'audiocapturemode:i:1;audiomode:i:0;drivestoredirect:s:;redirectclipboard:i:1;redirectcomports:i:1;redirectprinters:i:1;redirectsmartcards:i:1;screen mode id:i:2'

@description('Optional. AVD deploy scaling plan. (Default: true)')
param avdDeployScalingPlan bool = true

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

@description('Optional. Fslogix file share size. (Default: ~1TB)')
param avdFslogixFileShareQuotaSize int = 10

@description('Optional. Deploy new session hosts. (Default: true)')
param avdDeploySessionHosts bool = true

@description('Optional. Deploy AVD monitoring resources and setings. (Default: true)')
param avdDeployMonitoring bool = true

@description('Optional. Deploy AVD Azure log analytics workspace. (Default: true)')
param deployAlaWorkspace bool = true

@description('Required. Create and assign custom Azure Policy for diagnostic settings for the AVD Log Analytics workspace.')
param deployCustomPolicyMonitoring bool = false

@description('Optional. AVD Azure log analytics workspace data retention. (Default: 90)')
param avdAlaWorkspaceDataRetention int = 90

@description('Optional. Existing Azure log analytics workspace resource ID to connect to. (Default: )')
param alaExistingWorkspaceResourceId string = ''

@description('Required. Create and assign custom Azure Policy for NSG flow logs and network security')
param deployCustomPolicyNetworking bool = false 

@description('Optional. Deploy Azure storage account for flow logs. (Default: false)')
param deployStgAccountForFlowLogs bool = false

@description('Optional. Existing Azure Storage account Resourece ID for NSG flow logs. (Default: )')
param stgAccountForFlowLogsId string = ''

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
param avdImageTemplateDefinitionId string = ''

@description('Optional. OU name for Azure Storage Account. It is recommended to create a new AD Organizational Unit (OU) in AD and disable password expiration policy on computer accounts or service logon accounts accordingly.  (Default: "")')
param storageOuPath string = ''

@description('Optional. If OU for Azure Storage needs to be created - set to true and ensure the domain join credentials have priviledge to create OU and create computer objects or join to domain. (Default: "")')
param createOuForStorage bool = false

// Custom Naming
// Input must followe resource naming rules on https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules
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

@maxLength(90)
@description('Optional. AVD monitoring resource group custom name. (Default: rg-avd-use2-app1-monitoring)')
param avdMonitoringRgCustomName string = 'rg-avd-use2-app1-monitoring'

@maxLength(64)
@description('Optional. AVD virtual network custom name. (Default: vnet-avd-use2-app1-001)')
param avdVnetworkCustomName string = 'vnet-avd-use2-app1-001'

@maxLength(64)
@description('Optional. AVD Azure log analytics workspace custom name. (Default: log-avd-use2-app1-001)')
param avdAlaWorkspaceCustomName string = 'log-avd-use2-app1-001'

//@maxLength(24)
//@description('Optional. Azure Storage Account custom name for NSG flow logs. (Default: stavduse2flowlogs001)')
//param avdStgAccountForFlowLogsCustomName string = 'stavduse2flowlogs001'

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
@description('Optional. AVD workspace custom friendly (Display) name. (Default: App1 - East US - 001)')
param avdWorkSpaceCustomFriendlyName string = 'East US - 001'

@maxLength(64)
@description('Optional. AVD host pool custom name. (Default: vdpool-use2-app1-001)')
param avdHostPoolCustomName string = 'vdpool-use2-app1-001'

@maxLength(64)
@description('Optional. AVD host pool custom friendly (Display) name. (Default: App1 - East US - 001)')
param avdHostPoolCustomFriendlyName string = 'App1 - East US - 001'

@maxLength(64)
@description('Optional. AVD scaling plan custom name. (Default: vdscaling-use2-app1-001)')
param avdScalingPlanCustomName string = 'vdscaling-use2-app1-001'

@maxLength(64)
@description('Optional. AVD desktop application group custom name. (Default: vdag-desktop-use2-app1-001)')
param avdApplicationGroupCustomNameDesktop string = 'vdag-desktop-use2-app1-001'

@maxLength(64)
@description('Optional. AVD desktop application group custom friendly (Display) name. (Default: Desktops - App1 - East US - 001)')
param avdApplicationGroupCustomFriendlyName string = 'Desktops - App1 - East US - 001'

@maxLength(64)
@description('Optional. AVD remote application group custom name. (Default: vdag-rapp-use2-app1-001)')
param avdApplicationGroupCustomNameRapp string = 'vdag-rapp-use2-app1-001'

@maxLength(64)
@description('Optional. AVD remote application group custom name. (Default: Remote apps - App1 - East US - 001)')
param avdApplicationGroupCustomFriendlyNameRapp string = 'Remote apps - App1 - East US - 001'

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
var varDeploymentPrefixLowercase = toLower(deploymentPrefix)
var varAvdSessionHostLocationLowercase = toLower(avdSessionHostLocation)
var varAvdManagementPlaneLocationLowercase = toLower(avdManagementPlaneLocation)
var varAvdSessionHostLocationAcronym = varLocationAcronyms[varAvdSessionHostLocationLowercase]
var varAvdManagementPlaneLocationAcronym = varLocationAcronyms[varAvdManagementPlaneLocationLowercase]
var varLocationAcronyms = {
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
var varTimeZones = {
    australiacentral: 'AUS Eastern Standard Time'
    australiacentral2: 'AUS Eastern Standard Time'
    australiaeast: 'AUS Eastern Standard Time'
    australiasoutheast: 'AUS Eastern Standard Time'
    brazilsouth: 'E. South America Standard Time'
    brazilsoutheast: 'E. South America Standard Time'
    canadacentral: 'Eastern Standard Time'
    canadaeast: 'Eastern Standard Time'
    centralindia: 'India Standard Time'
    centralus: 'Central Standard Time'
    chinaeast: 'China Standard Time'
    chinaeast2: 'China Standard Time'
    chinanorth: 'China Standard Time'
    chinanorth2: 'China Standard Time'
    eastasia: 'China Standard Time'
    eastus: 'Eastern Standard Time'
    eastus2: 'Eastern Standard Time'
    francecentral: 'Central Europe Standard Time'
    francesouth: 'Central Europe Standard Time'
    germanynorth: 'Central Europe Standard Time'
    germanywestcentral: 'Central Europe Standard Time'
    japaneast: 'Tokyo Standard Time'
    japanwest: 'Tokyo Standard Time'
    jioindiacentral: 'India Standard Time'
    jioindiawest: 'India Standard Time'
    koreacentral: 'Korea Standard Time'
    koreasouth: 'Korea Standard Time'
    northcentralus: 'Central Standard Time'
    northeurope: 'GMT Standard Time'
    norwayeast: 'Central Europe Standard Time'
    norwaywest: 'Central Europe Standard Time'
    southafricanorth: 'South Africa Standard Time'
    southafricawest: 'South Africa Standard Time'
    southcentralus: 'Central Standard Time'
    southindia: 'India Standard Time'
    southeastasia: 'Singapore Standard Time'
    swedencentral: 'Central Europe Standard Time'
    switzerlandnorth: 'Central Europe Standard Time'
    switzerlandwest: 'Central Europe Standard Time'
    uaecentral: 'Arabian Standard Time'
    uaenorth: 'Arabian Standard Time'
    uksouth: 'GMT Standard Time'
    ukwest: 'GMT Standard Time'
    usdodcentral: 'Central Standard Time'
    usdodeast: 'Eastern Standard Time'
    usgovarizona: 'Mountain Standard Time'
    usgoviowa: 'Central Standard Time'
    usgovtexas: 'Central Standard Time'
    usgovvirginia: 'Eastern Standard Time'
    westcentralus: 'Mountain Standard Time'
    westeurope: 'Central Europe Standard Time'
    westindia: 'India Standard Time'
    westus: 'Pacific Standard Time'
    westus2: 'Pacific Standard Time'
    westus3: 'Mountain Standard Time'
}

var varAvdNamingUniqueStringSixChar = take('${uniqueString(avdWorkloadSubsId, varDeploymentPrefixLowercase, time)}', 6)
var varAvdManagementPlaneNamingStandard = '${varAvdManagementPlaneLocationAcronym}-${varDeploymentPrefixLowercase}'
var varAvdComputeStorageResourcesNamingStandard = '${varAvdSessionHostLocationAcronym}-${varDeploymentPrefixLowercase}'
var varAvdServiceObjectsRgName = avdUseCustomNaming ? avdServiceObjectsRgCustomName : 'rg-avd-${varAvdManagementPlaneNamingStandard}-service-objects' // max length limit 90 characters
var varAvdNetworkObjectsRgName = avdUseCustomNaming ? avdNetworkObjectsRgCustomName : 'rg-avd-${varAvdComputeStorageResourcesNamingStandard}-network' // max length limit 90 characters
var varAvdComputeObjectsRgName = avdUseCustomNaming ? avdComputeObjectsRgCustomName : 'rg-avd-${varAvdComputeStorageResourcesNamingStandard}-pool-compute' // max length limit 90 characters
var varAvdStorageObjectsRgName = avdUseCustomNaming ? avdStorageObjectsRgCustomName : 'rg-avd-${varAvdComputeStorageResourcesNamingStandard}-storage' // max length limit 90 characters
var varAvdMonitoringRgName = avdUseCustomNaming ? avdMonitoringRgCustomName : 'rg-avd-${varAvdSessionHostLocationAcronym}-monitoring' // max length limit 90 characters
//var varAvdSharedResourcesRgName = 'rg-${varAvdSessionHostLocationAcronym}-avd-shared-resources'
var varAvdVnetworkName = avdUseCustomNaming ? avdVnetworkCustomName : 'vnet-avd-${varAvdComputeStorageResourcesNamingStandard}-001'
var varAvdVnetworkSubnetName = avdUseCustomNaming ? avdVnetworkSubnetCustomName : 'snet-avd-${varAvdComputeStorageResourcesNamingStandard}-001'
var varAvdNetworksecurityGroupName = avdUseCustomNaming ? avdNetworksecurityGroupCustomName : 'nsg-avd-${varAvdComputeStorageResourcesNamingStandard}-001'
var varAvdRouteTableName = avdUseCustomNaming ? avdRouteTableCustomName : 'route-avd-${varAvdComputeStorageResourcesNamingStandard}-001'
var varAvdApplicationSecurityGroupName = avdUseCustomNaming ? avdApplicationSecurityGroupCustomName : 'asg-avd-${varAvdComputeStorageResourcesNamingStandard}-001'
var varAvdVnetworkPeeringName = 'peer-avd-${varAvdComputeStorageResourcesNamingStandard}-${varAvdNamingUniqueStringSixChar}'
var varAvdWorkSpaceName = avdUseCustomNaming ? avdWorkSpaceCustomName : 'vdws-${varAvdManagementPlaneNamingStandard}-001'
var varAvdWorkSpaceFriendlyName = avdUseCustomNaming ? avdWorkSpaceCustomFriendlyName : '${avdManagementPlaneLocation} - 001'
var varAvdHostPoolName = avdUseCustomNaming ? avdHostPoolCustomName : 'vdpool-${varAvdManagementPlaneNamingStandard}-001'
var varAvdHostFriendlyName = avdUseCustomNaming ? avdHostPoolCustomFriendlyName : '${deploymentPrefix} - ${avdManagementPlaneLocation} - 001'
var varAvdApplicationGroupNameDesktop = avdUseCustomNaming ? avdApplicationGroupCustomNameDesktop : 'vdag-desktop-${varAvdManagementPlaneNamingStandard}-001'
var varAvdApplicationGroupFriendlyName = avdUseCustomNaming ? avdApplicationGroupCustomFriendlyName : 'Desktops - ${deploymentPrefix} - ${avdManagementPlaneLocation} - 001'
var varAvdApplicationGroupAppFriendlyName = 'Session Desktops - ${deploymentPrefix} '
var varAvdApplicationGroupNameRapp = avdUseCustomNaming ? avdApplicationGroupCustomNameRapp : 'vdag-rapp-${varAvdManagementPlaneNamingStandard}-001'
var varAvdApplicationGroupFriendlyNameRapp = avdUseCustomNaming ? avdApplicationGroupCustomFriendlyNameRapp : 'Remote apps - ${deploymentPrefix} - ${avdManagementPlaneLocation} - 001'
var varAvdScalingPlanName = avdUseCustomNaming ? avdScalingPlanCustomName : 'vdscaling-${varAvdManagementPlaneNamingStandard}-001'
var varAvdScalingPlanExclusionTag = 'Exclude-${varAvdScalingPlanName}'
var varAvdScalingPlanWeekdaysScheduleName = 'weekdays-${varAvdManagementPlaneNamingStandard}'
var varAvdScalingPlanWeekendScheduleName = 'weekend-${varAvdManagementPlaneNamingStandard}'
var varAvdWrklKvName = avdUseCustomNaming ? '${avdWrklKvPrefixCustomName}-${varAvdComputeStorageResourcesNamingStandard}-${varAvdNamingUniqueStringSixChar}' : 'kv-avd-${varAvdComputeStorageResourcesNamingStandard}-${varAvdNamingUniqueStringSixChar}' // max length limit 24 characters
var varAvdWrklKvPrivateEndpointName = 'pe-kv-avd-${varDeploymentPrefixLowercase}-${varAvdNamingUniqueStringSixChar}-vault'
var varAvdSessionHostNamePrefix = avdUseCustomNaming ? avdSessionHostCustomNamePrefix : 'vm-avd-${varDeploymentPrefixLowercase}'
var varAvdAvailabilitySetNamePrefix = avdUseCustomNaming ? '${avdAvailabilitySetCustomNamePrefix}-${varAvdSessionHostLocationAcronym}-${varDeploymentPrefixLowercase}' : 'avail-avd-${varAvdSessionHostLocationAcronym}-${varDeploymentPrefixLowercase}'
var varFslogixManagedIdentityName = 'id-avd-fslogix-${varAvdSessionHostLocationAcronym}-${varDeploymentPrefixLowercase}'
var varAvdFslogixProfileContainerFileShareName = avdUseCustomNaming ? avdFslogixProfileContainerFileShareCustomName : 'fslogix-pc-${varDeploymentPrefixLowercase}-001'
//var varAvdFslogixOfficeContainerFileShareName = avdUseCustomNaming ? avdFslogixOfficeContainerFileShareCustomName: 'fslogix-oc-${varDeploymentPrefixLowercase}-001'
var varAvdFslogixStorageName = avdUseCustomNaming ? '${avdFslogixStoragePrefixCustomName}${varDeploymentPrefixLowercase}${varAvdNamingUniqueStringSixChar}' : 'stavd${varDeploymentPrefixLowercase}${varAvdNamingUniqueStringSixChar}'
var varAvdWrklStoragePrivateEndpointName = 'pe-stavd${varDeploymentPrefixLowercase}${varAvdNamingUniqueStringSixChar}-file'
var varManagementVmName = 'vm-mgmt-${varDeploymentPrefixLowercase}'
var varAvdAlaWorkspaceName = avdUseCustomNaming ? avdAlaWorkspaceCustomName :  'log-avd-${varAvdManagementPlaneLocationAcronym}' //'log-avd-${varAvdComputeStorageResourcesNamingStandard}-${varAvdNamingUniqueStringSixChar}'
var varStgAccountForFlowLogsName = avdUseCustomNaming ? '${avdFslogixStoragePrefixCustomName}${varDeploymentPrefixLowercase}flowlogs${varAvdNamingUniqueStringSixChar}' : 'stavd${varDeploymentPrefixLowercase}flowlogs${varAvdNamingUniqueStringSixChar}'
//
var varAvdScalingPlanSchedules = [
    {
        daysOfWeek: [
            'Monday'
            'Tuesday'
            'Wednesday'
            'Thursday'
            'Friday'
        ]
        name: varAvdScalingPlanWeekdaysScheduleName
        offPeakLoadBalancingAlgorithm: 'DepthFirst'
        offPeakStartTime: {
            hour: 20
            minute: 0
        }
        peakLoadBalancingAlgorithm: 'DepthFirst'
        peakStartTime: {
            hour: 9
            minute: 0
        }
        rampDownCapacityThresholdPct: 90
        rampDownForceLogoffUsers: true
        rampDownLoadBalancingAlgorithm: 'DepthFirst'
        rampDownMinimumHostsPct: 10
        rampDownNotificationMessage: 'You will be logged off in 30 min. Make sure to save your work.'
        rampDownStartTime: {
            hour: 18
            minute: 0
        }
        rampDownStopHostsWhen: 'ZeroActiveSessions'
        rampDownWaitTimeMinutes: 30
        rampUpCapacityThresholdPct: 80
        rampUpLoadBalancingAlgorithm: 'BreadthFirst'
        rampUpMinimumHostsPct: 20
        rampUpStartTime: {
            hour: 7
            minute: 0
        }
    }
    {
        daysOfWeek: [
            'Saturday'
            'Sunday'
        ]
        name: varAvdScalingPlanWeekendScheduleName
        offPeakLoadBalancingAlgorithm: 'DepthFirst'
        offPeakStartTime: {
            hour: 18
            minute: 0
        }
        peakLoadBalancingAlgorithm: 'DepthFirst'
        peakStartTime: {
            hour: 10
            minute: 0
        }
        rampDownCapacityThresholdPct: 90
        rampDownForceLogoffUsers: true
        rampDownLoadBalancingAlgorithm: 'DepthFirst'
        rampDownMinimumHostsPct: 5
        rampDownNotificationMessage: 'You will be logged off in 30 min. Make sure to save your work.'
        rampDownStartTime: {
            hour: 16
            minute: 0
        }
        rampDownStopHostsWhen: 'ZeroActiveSessions'
        rampDownWaitTimeMinutes: 30
        rampUpCapacityThresholdPct: 90
        rampUpLoadBalancingAlgorithm: 'DepthFirst'
        rampUpMinimumHostsPct: 5
        rampUpStartTime: {
            hour: 9
            minute: 0
        }
    }
]

var varMarketPlaceGalleryWindows = {
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
    winServer_2022_Datacenter: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter'
        version: 'latest'
    }
    winServer_2019_Datacenter: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-datacenter'
        version: 'latest'
    }
}

var varBaseScriptUri = 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/'
var varFslogixScriptUri = '${varBaseScriptUri}scripts/Set-FSLogixRegKeys.ps1'
var varFsLogixScript = './Set-FSLogixRegKeys.ps1'
var varFslogixSharePath = '\\\\${varAvdFslogixStorageName}.file.${environment().suffixes.storage}\\${varAvdFslogixProfileContainerFileShareName}'
var varFsLogixScriptArguments = '-volumeshare ${varFslogixSharePath}'
var varAvdAgentPackageLocation = 'https://wvdportalstorageblob.blob.${environment().suffixes.storage}/galleryartifacts/Configuration_09-08-2022.zip'
var varStorageAccountContributorRoleId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
var varReaderRoleId = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
var varAvdVmPowerStateContributor = '40c5ff49-9181-41f8-ae61-143b0e78555e'
var varDscAgentPackageLocation = 'https://github.com/Azure/avdaccelerator/raw/main/workload/scripts/DSCStorageScripts.zip'
var varStorageToDomainScriptUri = '${varBaseScriptUri}scripts/Manual-DSC-Storage-Scripts.ps1'
var varStorageToDomainScript = './Manual-DSC-Storage-Scripts.ps1'
var varOuStgPath = !empty(storageOuPath) ? '"${storageOuPath}"' : '"${varDefaultStorageOuPath}"'
var varDefaultStorageOuPath = (avdIdentityServiceProvider == 'AADDS') ? 'AADDC Computers': 'Computers'
var varStorageCustomOuPath = !empty(storageOuPath) ? 'true' : 'false'
var varStorageToDomainScriptArgs = '-DscPath ${varDscAgentPackageLocation} -StorageAccountName ${varAvdFslogixStorageName} -StorageAccountRG ${varAvdStorageObjectsRgName} -DomainName ${avdIdentityDomainName} -IdentityServiceProvider ${avdIdentityServiceProvider} -AzureCloudEnvironment AzureCloud -SubscriptionId ${avdWorkloadSubsId} -DomainAdminUserName ${avdDomainJoinUserName} -DomainAdminUserPassword ${avdDomainJoinUserPassword} -CustomOuPath ${varStorageCustomOuPath} -OUName ${varOuStgPath} -CreateNewOU ${varCreateOuForStorageString} -ShareName ${varAvdFslogixProfileContainerFileShareName} -ClientId ${deployAvdManagedIdentitiesRoleAssign.outputs.fslogixManagedIdentityClientId} -Verbose'
var varCreateOuForStorageString = string(createOuForStorage)
var allDnsServers = '${customDnsIps},168.63.129.16'
var varDnsServers = (customDnsIps == 'none') ? []: (split(allDnsServers, ','))
var varCreateAvdFslogixDeployment = (avdIdentityServiceProvider == 'AAD') ? false: createAvdFslogixDeployment
var varAvdApplicationGroupIdentitiesIds = !empty(avdApplicationGroupIdentitiesIds) ? (split(avdApplicationGroupIdentitiesIds, ',')): []
var varCreateAvdVnetPeering = !empty(existingHubVnetResourceId) ? true: false
// Resource tagging
// Tag Exclude-${varAvdScalingPlanName} is used by scaling plans to exclude session hosts from scaling. Exmaple: Exclude-vdscal-eus2-app1-001
var varCommonResourceTags = createResourceTags ? {
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

var varAllComputeStorageTags = {
    DomainName: avdIdentityDomainName
    JoinType: 'ADDS' // avdDeviceJoinTypeTag waiting for PR on identity to be merged
}
var varAllResourceTags = union(varCommonResourceTags, varAllComputeStorageTags)
//

var varTelemetryId = 'pid-2ce4228c-d72c-43fb-bb5b-cd8f3ba2138e-${avdManagementPlaneLocation}'

var resourceGroups = [
    {
        purpose: 'Service-Objects'
        name: varAvdServiceObjectsRgName
        location: avdManagementPlaneLocation
        enableDefaultTelemetry: false
        tags: createResourceTags ? varCommonResourceTags : {}
    }
    {
        purpose: 'Pool-Compute'
        name: varAvdComputeObjectsRgName
        location: avdSessionHostLocation
        enableDefaultTelemetry: false
        tags: createResourceTags ? varAllComputeStorageTags : {}
    }
]

// =========== //
// Deployments //
// =========== //

//  Telemetry Deployment.
resource telemetrydeployment 'Microsoft.Resources/deployments@2021-04-01' = if (enableTelemetry) {
    name: varTelemetryId
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
// Network.
module avdBaselineNetworkResourceGroup '../../carml/1.2.0/Microsoft.Resources/resourceGroups/deploy.bicep' = if (createAvdVnet) {
    scope: subscription(avdWorkloadSubsId)
    name: 'Deploy-${varAvdNetworkObjectsRgName}-${time}'
    params: {
        name: varAvdNetworkObjectsRgName
        location: avdSessionHostLocation
        enableDefaultTelemetry: false
        tags: createResourceTags ? varCommonResourceTags : {}
    }
    dependsOn: avdDeployMonitoring ? [
        deployMonitoringDiagnosticSettings
    ]: []
}

// Compute, service objects
module avdBaselineResourceGroups '../../carml/1.2.0/Microsoft.Resources/resourceGroups/deploy.bicep' = [for resourceGroup in resourceGroups: {
    scope: subscription(avdWorkloadSubsId)
    name: 'Deploy-AVD-${resourceGroup.purpose}-${time}'
    params: {
        name: resourceGroup.name
        location: resourceGroup.location
        enableDefaultTelemetry: resourceGroup.enableDefaultTelemetry
        tags: resourceGroup.tags
    }
}]

// Storage.
module avdBaselineStorageResourceGroup '../../carml/1.2.0/Microsoft.Resources/resourceGroups/deploy.bicep' = if (varCreateAvdFslogixDeployment && (avdIdentityServiceProvider != 'AAD')) {
    scope: subscription(avdWorkloadSubsId)
    name: 'Deploy-${varAvdStorageObjectsRgName}-${time}'
    params: {
        name: varAvdStorageObjectsRgName
        location: avdSessionHostLocation
        enableDefaultTelemetry: false
        tags: createResourceTags ? varAllComputeStorageTags : {}
    }
    dependsOn: avdDeployMonitoring ? [
        deployMonitoringDiagnosticSettings
    ]: []
}

/*
// Validation Deployment Script
// This module validates the selected parameter values and collects required data
module validation 'avd-modules/avd-validation.bicep' = {
  name: 'AVD-Deployment-Validation-${time}'
  scope: resourceGroup(avdServiceObjectsRgName)
  params: {
    Availability: Availability
    DiskEncryption: DiskEncryption
    DiskSku: DiskSku
    DomainName: DomainName
    DomainServices: DomainServices
    EphemeralOsDisk: EphemeralOsDisk
    ImageSku: ImageSku
    KerberosEncryption: KerberosEncryption
    Location: Location
    ManagedIdentityResourceId: managedIdentity.outputs.resourceIdentifier
    NamingStandard: NamingStandard
    PooledHostPool: PooledHostPool
    RecoveryServices: RecoveryServices
    SasToken: SasToken
    ScriptsUri: ScriptsUri    
    SecurityPrincipalIds: SecurityPrincipalObjectIds
    SecurityPrincipalNames: SecurityPrincipalNames
    SessionHostCount: SessionHostCount
    SessionHostIndex: SessionHostIndex
    StartVmOnConnect: StartVmOnConnect
    //StorageCount: StorageCount
    StorageSolution: StorageSolution
    Tags: createResourceTags ? commonResourceTags : {}
    Timestamp: time
    VirtualNetwork: VirtualNetwork
    VirtualNetworkResourceGroup: VirtualNetworkResourceGroup
    VmSize: avdSessionHostsSize
  }
  dependsOn: [
    resourceGroups
    managedIdentity
  ]
}
*/

// Azure Policies for monitoring Diagnostic settings. Performance couunters on new or existing Log Analytics workspace. New workspace if needed.
module deployMonitoringDiagnosticSettings './avd-modules/avd-monitoring.bicep' = if (avdDeployMonitoring) {
    name: 'Deploy-AVD-Monitoring-${time}'
    params: {
        avdManagementPlaneLocation: avdManagementPlaneLocation
        deployAlaWorkspace: deployAlaWorkspace
        deployCustomPolicyMonitoring: deployCustomPolicyMonitoring
        alaWorkspaceId: deployAlaWorkspace ? '' : alaExistingWorkspaceResourceId
        avdMonitoringRgName: varAvdMonitoringRgName
        avdAlaWorkspaceName: deployAlaWorkspace ? varAvdAlaWorkspaceName: ''
        avdAlaWorkspaceDataRetention: avdAlaWorkspaceDataRetention
        avdWorkloadSubsId: avdWorkloadSubsId
        avdTags: createResourceTags ? varAllResourceTags : {}
    }
    dependsOn: []
}

// Azure Policies for network monitorig/security . New storage account/Reuse existing one if needed created for the NSG flow logs

module deployAzurePolicyNetworking './avd-modules/avd-azure-policy-networking.bicep' = if (avdDeployMonitoring && deployCustomPolicyNetworking) {
    name: (length('Enable-Azure-Policy-for-Netwok-Security-${time}') > 64) ? take('Enable-Azure-Policy-for-Netwok-Security-${time}',64) : 'Enable-Azure-Policy-for-Netwok-Security-${time}'
    params: {
        alaWorkspaceResourceId: (avdDeployMonitoring && deployAlaWorkspace) ? deployMonitoringDiagnosticSettings.outputs.avdAlaWorkspaceResourceId : alaExistingWorkspaceResourceId
        alaWorkspaceId: (avdDeployMonitoring && deployAlaWorkspace) ? deployMonitoringDiagnosticSettings.outputs.avdAlaWorkspaceId : alaExistingWorkspaceResourceId 
        avdManagementPlaneLocation: avdManagementPlaneLocation
        avdWorkloadSubsId: avdWorkloadSubsId
        avdMonitoringRgName: varAvdMonitoringRgName
        stgAccountForFlowLogsId: deployStgAccountForFlowLogs ? '' : stgAccountForFlowLogsId
        stgAccountForFlowLogsName: deployStgAccountForFlowLogs ? varStgAccountForFlowLogsName : ''
        avdTags: createResourceTags ? varAllResourceTags : {}
    }
    dependsOn: [
    ]
}


// Networking.
module avdNetworking 'avd-modules/avd-networking.bicep' = if (createAvdVnet) {
    name: 'Deploy-AVD-Networking-${time}'
    params: {
        avdApplicationSecurityGroupName: varAvdApplicationSecurityGroupName
        avdComputeObjectsRgName: varAvdComputeObjectsRgName
        avdNetworkObjectsRgName: varAvdNetworkObjectsRgName
        avdNetworksecurityGroupName: varAvdNetworksecurityGroupName
        avdRouteTableName: varAvdRouteTableName
        avdVnetworkAddressPrefixes: avdVnetworkAddressPrefixes
        avdVnetworkName: varAvdVnetworkName
        avdVnetworkPeeringName: avdIdentityServiceProvider == 'AAD' ? '': varAvdVnetworkPeeringName
        avdVnetworkSubnetName: varAvdVnetworkSubnetName
        createAvdVnet: createAvdVnet
        createAvdVnetPeering: varCreateAvdVnetPeering
        vNetworkGatewayOnHub: vNetworkGatewayOnHub
        existingHubVnetResourceId: avdIdentityServiceProvider == 'AAD' ? '': existingHubVnetResourceId
        avdSessionHostLocation: avdSessionHostLocation
        avdVnetworkSubnetAddressPrefix: avdVnetworkSubnetAddressPrefix
        avdWorkloadSubsId: avdWorkloadSubsId
        dnsServers: varDnsServers
        avdTags: createResourceTags ? varCommonResourceTags : {}
        avdAlaWorkspaceResourceId: avdDeployMonitoring ? (deployAlaWorkspace ? deployMonitoringDiagnosticSettings.outputs.avdAlaWorkspaceResourceId : alaExistingWorkspaceResourceId) : ''
        avdDiagnosticLogsRetentionInDays: avdAlaWorkspaceDataRetention
    }
    dependsOn: [
        avdBaselineNetworkResourceGroup
    ]
}

// AVD management plane.
module avdManagementPLane 'avd-modules/avd-management-plane.bicep' = {
    name: 'Deploy-AVD-HostPool-AppGroups-${time}'
    params: {
        avdApplicationGroupNameDesktop: varAvdApplicationGroupNameDesktop
        avdApplicationGroupFriendlyNameDesktop: varAvdApplicationGroupFriendlyName
        avdApplicationGroupAppFriendlyNameDesktop: varAvdApplicationGroupAppFriendlyName
        avdWorkSpaceName: varAvdWorkSpaceName
        avdWorkSpaceFriendlyName: varAvdWorkSpaceFriendlyName
        avdApplicationGroupNameRapp: varAvdApplicationGroupNameRapp
        avdApplicationGroupFriendlyNameRapp: varAvdApplicationGroupFriendlyNameRapp
        avdDeployRappGroup: avdDeployRappGroup
        avdTimeZone: varTimeZones[avdSessionHostLocation]
        avdHostPoolName: varAvdHostPoolName
        avdHostPoolFriendlyName: varAvdHostFriendlyName
        avdHostPoolRdpProperties: avdHostPoolRdpProperties
        avdHostPoolLoadBalancerType: avdHostPoolLoadBalancerType
        avdHostPoolType: avdHostPoolType
        avdDeployScalingPlan: avdDeployScalingPlan
        avdScalingPlanExclusionTag: varAvdScalingPlanExclusionTag
        avdScalingPlanSchedules: varAvdScalingPlanSchedules
        avdScalingPlanName: varAvdScalingPlanName
        avhHostPoolMaxSessions: avhHostPoolMaxSessions
        avdPersonalAssignType: avdPersonalAssignType
        avdManagementPlaneLocation: avdManagementPlaneLocation
        avdServiceObjectsRgName: varAvdServiceObjectsRgName
        avdStartVmOnConnect: avdStartVmOnConnect
        avdWorkloadSubsId: avdWorkloadSubsId
        avdIdentityServiceProvider: avdIdentityServiceProvider
        avdApplicationGroupIdentitiesIds: varAvdApplicationGroupIdentitiesIds
        avdApplicationGroupIdentityType: avdApplicationGroupIdentityType
        avdTags: createResourceTags ? varCommonResourceTags : {}
        avdAlaWorkspaceResourceId: avdDeployMonitoring ? (deployAlaWorkspace ? deployMonitoringDiagnosticSettings.outputs.avdAlaWorkspaceResourceId : alaExistingWorkspaceResourceId) : ''
        avdDiagnosticLogsRetentionInDays: avdAlaWorkspaceDataRetention
    }
    dependsOn: [
        avdBaselineResourceGroups
        deployAvdManagedIdentitiesRoleAssign
    ]
}

// Identity: managed identities and role assignments.
module deployAvdManagedIdentitiesRoleAssign 'avd-modules/avd-identity.bicep' = {
    name: 'Create-Managed-ID-RoleAssign-${time}'
    params: {
        avdComputeObjectsRgName: varAvdComputeObjectsRgName
        avdDeploySessionHosts: avdDeploySessionHosts
        avdEnterpriseAppObjectId: avdEnterpriseAppObjectId
        avdDeployScalingPlan: avdDeployScalingPlan
        avdSessionHostLocation: avdSessionHostLocation
        avdServiceObjectsRgName: varAvdServiceObjectsRgName
        avdStorageObjectsRgName: varAvdStorageObjectsRgName
        avdWorkloadSubsId: avdWorkloadSubsId
        createStartVmOnConnectCustomRole: createStartVmOnConnectCustomRole
        fslogixManagedIdentityName: varFslogixManagedIdentityName
        readerRoleId: varReaderRoleId
        avdManagementPlaneLocation: avdManagementPlaneLocation
        avdIdentityServiceProvider: avdIdentityServiceProvider
        storageAccountContributorRoleId: varStorageAccountContributorRoleId
        avdVmPowerStateContributor: varAvdVmPowerStateContributor
        createAvdFslogixDeployment: varCreateAvdFslogixDeployment
        avdApplicationGroupIdentitiesIds: varAvdApplicationGroupIdentitiesIds
        avdTags: createResourceTags ? varCommonResourceTags : {}
    }
    dependsOn: [
        avdBaselineResourceGroups
        avdBaselineStorageResourceGroup
    ]
}

// Key vault.
module avdWrklKeyVault '../../carml/1.2.0/Microsoft.KeyVault/vaults/deploy.bicep' = if (avdDeploySessionHosts) {
    scope: resourceGroup('${avdWorkloadSubsId}', '${varAvdServiceObjectsRgName}')
    name: 'AVD-Workload-KeyVault-${time}'
    params: {
        name: varAvdWrklKvName
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
                name: varAvdWrklKvPrivateEndpointName
                subnetResourceId: createAvdVnet ? '${avdNetworking.outputs.avdVirtualNetworkResourceId}/subnets/${varAvdVnetworkSubnetName}' : existingVnetSubnetResourceId
                service: 'vault'
                privateDnsZoneResourceIds: [
                    avdVnetPrivateDnsZoneKeyvaultId
                ]
            }
        ] : [
            {
                name: varAvdWrklKvPrivateEndpointName
                subnetResourceId: createAvdVnet ? '${avdNetworking.outputs.avdVirtualNetworkResourceId}/subnets/${varAvdVnetworkSubnetName}' : existingVnetSubnetResourceId
                service: 'vault'
            }
        ]
        secrets: {
            secureList: (avdIdentityServiceProvider != 'AAD') ? [
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
            ] : [
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
                    value: 'AAD-Joined-Deployment-No-Domain-Credentials'
                    contentType: 'Domain join credentials'
                }
                {
                    name: 'avdDomainJoinUserPassword'
                    value: 'AAD-Joined-Deployment-No-Domain-Credentials'
                    contentType: 'Domain join credentials'
                }
            ]
        }
        tags: createResourceTags ? varCommonResourceTags : {}
    }
    dependsOn: [
        avdBaselineResourceGroups
        //updateExistingSubnet
    ]
}

// Call on the KV.
resource avdWrklKeyVaultget 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = if (avdDeploySessionHosts) {
    name: varAvdWrklKvName
    scope: resourceGroup('${avdWorkloadSubsId}', '${varAvdServiceObjectsRgName}')
}

// Storage.
module deployAvdStorageAzureFiles 'avd-modules/avd-storage-azurefiles.bicep' = if (varCreateAvdFslogixDeployment && avdDeploySessionHosts && (avdIdentityServiceProvider != 'AAD')) {
    name: 'Deploy-AVD-Storage-AzureFiles-${time}'
    params: {
        avdIdentityServiceProvider: avdIdentityServiceProvider
        storageToDomainScript:  varStorageToDomainScript
        storageToDomainScriptArgs: varStorageToDomainScriptArgs
        storageToDomainScriptUri: varStorageToDomainScriptUri
        avdTimeZone: varTimeZones[avdSessionHostLocation]
        avdWrklStoragePrivateEndpointName: varAvdWrklStoragePrivateEndpointName
        avdApplicationSecurityGroupResourceId: createAvdVnet ? '${avdNetworking.outputs.avdApplicationSecurityGroupResourceId}' : ''
        avdComputeObjectsRgName: varAvdComputeObjectsRgName
        avdDomainJoinUserName: avdDomainJoinUserName
        avdWrklKvName: varAvdWrklKvName
        avdServiceObjectsRgName: varAvdServiceObjectsRgName
        avdFslogixProfileContainerFileShareName: varAvdFslogixProfileContainerFileShareName
        avdFslogixFileShareQuotaSize: avdFslogixFileShareQuotaSize
        avdFslogixStorageName: varAvdFslogixStorageName
        avdIdentityDomainName: avdIdentityDomainName
        avdImageTemplateDefinitionId: avdImageTemplateDefinitionId
        sessionHostOuPath: avdOuPath
        avdSessionHostDiskType: avdSessionHostDiskType
        avdSessionHostLocation: avdSessionHostLocation
        avdSessionHostsSize: avdSessionHostsSize
        avdStorageObjectsRgName: varAvdStorageObjectsRgName
        avdSubnetId: createAvdVnet ? '${avdNetworking.outputs.avdVirtualNetworkResourceId}/subnets/${varAvdVnetworkSubnetName}' : existingVnetSubnetResourceId
        createAvdVnet: createAvdVnet
        avdVmLocalUserName: avdVmLocalUserName
        avdVnetPrivateDnsZone: avdVnetPrivateDnsZone
        avdVnetPrivateDnsZoneFilesId: avdVnetPrivateDnsZoneFilesId
        avdWorkloadSubsId: avdWorkloadSubsId
        encryptionAtHost: encryptionAtHost
        fslogixManagedIdentityResourceId: varCreateAvdFslogixDeployment ? deployAvdManagedIdentitiesRoleAssign.outputs.fslogixManagedIdentityResourceId : ''
        avdFslogixFileShareMultichannel: (contains(fslogixStorageSku, 'Premium_LRS') || contains(fslogixStorageSku, 'Premium_ZRS')) ? true : false
        fslogixStorageSku: fslogixStorageSku
        //marketPlaceGalleryWindowsManagementVm: varMarketPlaceGalleryWindows['winServer_2022_Datacenter']
        marketPlaceGalleryWindowsManagementVm: varMarketPlaceGalleryWindows[avdOsImage]
        subnetResourceId: createAvdVnet ? '${avdNetworking.outputs.avdVirtualNetworkResourceId}/subnets/${varAvdVnetworkSubnetName}' : existingVnetSubnetResourceId
        managementVmName: varManagementVmName
        useSharedImage: useSharedImage
        avdTags: createResourceTags ? varAllResourceTags : {}
        avdAlaWorkspaceResourceId: avdDeployMonitoring ? (deployAlaWorkspace ? deployMonitoringDiagnosticSettings.outputs.avdAlaWorkspaceResourceId : alaExistingWorkspaceResourceId) : ''
        avdDiagnosticLogsRetentionInDays: avdAlaWorkspaceDataRetention
    }
    dependsOn: [
        avdBaselineStorageResourceGroup
        avdNetworking
        avdWrklKeyVaultget
        avdWrklKeyVault
    ]
}

// Session hosts.
module deployAndConfigureAvdSessionHosts './avd-modules/avd-session-hosts-batch.bicep' = if (avdDeploySessionHosts) {
    name: 'Deploy-and-Configure-AVD-SessionHosts-${time}'
    params: {
        avdAgentPackageLocation: varAvdAgentPackageLocation
        avdTimeZone: varTimeZones[avdSessionHostLocation]
        avdApplicationSecurityGroupResourceId: createAvdVnet ? '${avdNetworking.outputs.avdApplicationSecurityGroupResourceId}' : ''
        avdAsFaultDomainCount: avdAsFaultDomainCount
        avdAsUpdateDomainCount: avdAsUpdateDomainCount
        avdIdentityServiceProvider: avdIdentityServiceProvider
        createIntuneEnrollment: createIntuneEnrollment
        avdAvailabilitySetNamePrefix: varAvdAvailabilitySetNamePrefix
        avdComputeObjectsRgName: varAvdComputeObjectsRgName
        avdDeploySessionHostsCount: avdDeploySessionHostsCount
        avdSessionHostCountIndex: avdSessionHostCountIndex
        avdDomainJoinUserName: avdDomainJoinUserName
        avdWrklKvName: varAvdWrklKvName
        avdServiceObjectsRgName: varAvdServiceObjectsRgName
        avdHostPoolName: varAvdHostPoolName
        avdIdentityDomainName: avdIdentityDomainName
        avdImageTemplateDefinitionId: avdImageTemplateDefinitionId
        sessionHostOuPath: avdOuPath
        avdSessionHostDiskType: avdSessionHostDiskType
        avdSessionHostLocation: avdSessionHostLocation
        avdSessionHostNamePrefix: varAvdSessionHostNamePrefix
        avdSessionHostsSize: avdSessionHostsSize
        avdSubnetId: createAvdVnet ? '${avdNetworking.outputs.avdVirtualNetworkResourceId}/subnets/${varAvdVnetworkSubnetName}' : existingVnetSubnetResourceId
        createAvdVnet: createAvdVnet
        avdUseAvailabilityZones: avdUseAvailabilityZones
        avdVmLocalUserName: avdVmLocalUserName
        avdWorkloadSubsId: avdWorkloadSubsId
        encryptionAtHost: encryptionAtHost
        createAvdFslogixDeployment: (avdIdentityServiceProvider != 'AAD') ? varCreateAvdFslogixDeployment: false
        fslogixManagedIdentityResourceId:  (varCreateAvdFslogixDeployment && (avdIdentityServiceProvider != 'AAD'))  ? deployAvdManagedIdentitiesRoleAssign.outputs.fslogixManagedIdentityResourceId : ''
        //fslogixManagedIdentityResourceId:  (varCreateAvdFslogixDeployment && (avdIdentityServiceProvider != 'AAD'))  ? deployAvdManagedIdentitiesRoleAssign.outputs.fslogixManagedIdentityResourceId : 'none'
        fsLogixScript: (avdIdentityServiceProvider != 'AAD') ? varFsLogixScript: ''
        FsLogixScriptArguments: (avdIdentityServiceProvider != 'AAD') ? varFsLogixScriptArguments: ''
        fslogixScriptUri: (avdIdentityServiceProvider != 'AAD') ? varFslogixScriptUri: ''
        FslogixSharePath: (avdIdentityServiceProvider != 'AAD') ? varFslogixSharePath: ''
        hostPoolToken: avdManagementPLane.outputs.hostPooltoken
        marketPlaceGalleryWindows: varMarketPlaceGalleryWindows[avdOsImage]
        useSharedImage: useSharedImage
        avdTags: createResourceTags ? varAllResourceTags : {}
        avdDeployMonitoring: avdDeployMonitoring
        avdAlaWorkspaceResourceId: avdDeployMonitoring ? (deployAlaWorkspace ? deployMonitoringDiagnosticSettings.outputs.avdAlaWorkspaceResourceId : alaExistingWorkspaceResourceId) : ''
        avdDiagnosticLogsRetentionInDays: avdAlaWorkspaceDataRetention
    }
    dependsOn: [
        avdBaselineResourceGroups
        avdNetworking
        avdWrklKeyVaultget
        avdWrklKeyVault
    ]
}

