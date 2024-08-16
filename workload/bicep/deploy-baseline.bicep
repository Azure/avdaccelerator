targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@minLength(2)
@maxLength(4)
@description('Required. The name of the resource group to deploy.')
param deploymentPrefix string = 'AVD1'

@description('Optional. Location where to deploy compute services. (Default: eastus2)')
param avdSessionHostLocation string = 'eastus2'

@description('Optional. Location where to deploy AVD management plane. (Default: eastus2)')
param avdManagementPlaneLocation string = 'eastus2'

@description('Required. AVD workload subscription ID, multiple subscriptions scenario. (Default: )')
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

@description('Optional. AVD deploy remote app application group. (Default: false)')
param avdDeployRappGroup bool = false

@description('Optional. AVD host pool Custom RDP properties. (Default: audiocapturemode:i:1;audiomode:i:0;drivestoredirect:s:;redirectclipboard:i:1;redirectcomports:i:1;redirectprinters:i:1;redirectsmartcards:i:1;screen mode id:i:2)')
param avdHostPoolRdpProperties string = 'audiocapturemode:i:1;audiomode:i:0;drivestoredirect:s:;redirectclipboard:i:1;redirectcomports:i:1;redirectprinters:i:1;redirectsmartcards:i:1;screen mode id:i:2'

@description('Optional. AVD deploy scaling plan. (Default: true)')
param avdDeployScalingPlan bool = true

@description('Optional. Create new virtual network. (Default: true)')
param createAvdVnet bool = true

@description('Optional. Existing virtual network subnet for AVD. (Default: "")')
param existingVnetAvdSubnetResourceId string = ''

@description('Optional. Existing virtual network subnet for private endpoints. (Default: "")')
param existingVnetPrivateEndpointSubnetResourceId string = ''

@description('Required. Existing hub virtual network for perring.')
param existingHubVnetResourceId string = ''

@description('Optional. AVD virtual network address prefixes. (Default: 10.10.0.0/23)')
param avdVnetworkAddressPrefixes string = '10.10.0.0/23'

@description('Optional. AVD virtual network subnet address prefix. (Default: 10.10.0.0/23)')
param vNetworkAvdSubnetAddressPrefix string = '10.10.0.0/24'

@description('Optional. private endpoints virtual network subnet address prefix. (Default: 10.10.1.0/27)')
param vNetworkPrivateEndpointSubnetAddressPrefix string = '10.10.1.0/27'

@description('Optional. custom DNS servers IPs.')
param customDnsIps string = ''

@description('Optional. Deploy private endpoints for key vault and storage. (Default: true)')
param deployPrivateEndpointKeyvaultStorage bool = true

@description('Optional. Use Azure private DNS zones for private endpoints. (Default: true)')
param avdVnetPrivateDnsZone bool = true

@description('Optional. Use Azure private DNS zones for private endpoints. (Default: )')
param avdVnetPrivateDnsZoneFilesId string = ''

@description('Optional. Use Azure private DNS zones for private endpoints. (Default: )')
param avdVnetPrivateDnsZoneKeyvaultId string = ''

@description('Optional. Does the hub contains a virtual network gateway. (Default: false)')
param vNetworkGatewayOnHub bool = false

@description('Optional. Deploy Fslogix setup. (Default: true)')
param createAvdFslogixDeployment bool = true

@description('Optional. Deploy MSIX App Attach setup. (Default: false)')
param createMsixDeployment bool = true

@description('Optional. Fslogix file share size. (Default: ~1TB)')
param fslogixFileShareQuotaSize int = 10

@description('Optional. MSIX file share size. (Default: ~1TB)')
param msixFileShareQuotaSize int = 10

@description('Optional. Deploy new session hosts. (Default: true)')
param avdDeploySessionHosts bool = true

@description('Optional. Deploy AVD monitoring resources and setings. (Default: false)')
param avdDeployMonitoring bool = false

@description('Optional. Deploy AVD Azure log analytics workspace. (Default: true)')
param deployAlaWorkspace bool = false

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
@description('Optional. Quantity of session hosts to deploy. (Default: 1)')
param avdDeploySessionHostsCount int = 1

@description('Optional. The session host number to begin with for the deployment. This is important when adding virtual machines to ensure the names do not conflict. (Default: 0)')
param avdSessionHostCountIndex int = 0

@description('Optional. Creates an availability zone and adds the VMs to it. Cannot be used in combination with availability set nor scale set. (Defualt: true)')
param avdUseAvailabilityZones bool = true

//@description('Optional. Creates an availability zone for MSIXand adds the VMs to it. Cannot be used in combination with availability set nor scale set. (Defualt: true) test')
//param avdMsixUseAvailabilityZones bool = true

@description('Optional. Sets the number of fault domains for the availability set. (Defualt: 3)')
param avdAsFaultDomainCount int = 2

@description('Optional. Sets the number of update domains for the availability set. (Defualt: 5)')
param avdAsUpdateDomainCount int = 5

@allowed([
    'Standard'
    'Premium'
])
@description('Optional. Storage account SKU for FSLogix storage. Recommended tier is Premium (Defualt: Premium)')
param fslogixStoragePerformance string = 'Premium'

@allowed([
    'Standard'
    'Premium'
])
@description('Optional. Storage account SKU for MSIX storage. Recommended tier is Premium. (Defualt: Premium)')
param msixStoragePerformance string = 'Premium'

@description('Optional. This property can be used by user in the request to enable or disable the Host Encryption for the virtual machine. This will enable the encryption for all the disks including Resource/Temp disk at host itself. For security reasons, it is recommended to set encryptionAtHost to True. Restrictions: Cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
param encryptionAtHost bool = false

@description('Optional. Session host VM size. (Defualt: Standard_D2s_v3)')
param avdSessionHostsSize string = 'Standard_D2s_v3'

@description('Optional. OS disk type for session host. (Defualt: Standard_LRS)')
param avdSessionHostDiskType string = 'Standard_LRS'

@description('''Optional. Enables accelerated Networking on the session hosts.
If using a Azure Compute Gallery Image, the Image Definition must have been configured with
the \'isAcceleratedNetworkSupported\' property set to \'true\'.
''')
param enableAcceleratedNetworking bool = true

@allowed([
    'Standard'
    'TrustedLaunch'
    'ConfidentialVM'
])
@description('Optional. Specifies the securityType of the virtual machine. "ConfidentialVM" and "TrustedLaunch" require a Gen2 Image. (Default: Standard)')
param securityType string = 'Standard'

@description('Optional. Specifies whether secure boot should be enabled on the virtual machine. This parameter is part of the UefiSettings. securityType should be set to TrustedLaunch or ConfidentialVM to enable UefiSettings. (Default: false)')
param secureBootEnabled bool = false

@description('Optional. Specifies whether vTPM should be enabled on the virtual machine. This parameter is part of the UefiSettings. securityType should be set to TrustedLaunch or ConfidentialVM to enable UefiSettings. (Default: false)')
param vTpmEnabled bool = false

@allowed([
    'win10_21h2'
    'win10_21h2_office'
    'win10_22h2_g2'
    'win10_22h2_office_g2'
    'win11_21h2'
    'win11_21h2_office'
    'win11_22h2'
    'win11_22h2_office'
])
@description('Optional. AVD OS image source. (Default: win11-21h2)')
param avdOsImage string = 'win11_22h2'

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
@description('Optional. private endpoints virtual network subnet custom name. (Default: snet-pe-use2-app1-001)')
param privateEndpointVnetworkSubnetCustomName string = 'snet-pe-use2-app1-001'

@maxLength(80)
@description('Optional. AVD network security group custom name. (Default: nsg-avd-use2-app1-001)')
param avdNetworksecurityGroupCustomName string = 'nsg-avd-use2-app1-001'

@maxLength(80)
@description('Optional. Private endpoint network security group custom name. (Default: nsg-pe-use2-app1-001)')
param privateEndpointNetworksecurityGroupCustomName string = 'nsg-pe-use2-app1-001'

@maxLength(80)
@description('Optional. AVD route table custom name. (Default: route-avd-use2-app1-001)')
param avdRouteTableCustomName string = 'route-avd-use2-app1-001'

@maxLength(80)
@description('Optional. Private endpoint route table custom name. (Default: route-avd-use2-app1-001)')
param privateEndpointRouteTableCustomName string = 'route-pe-use2-app1-001'

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
@description('Optional. AVD FSLogix and MSIX app attach storage account prefix custom name. (Default: stavd)')
param storageAccountPrefixCustomName string = 'stavd'

@description('Optional. FSLogix file share name. (Default: fslogix-pc-app1-001)')
param fslogixFileShareCustomName string = 'fslogix-pc-app1-001'

@description('Optional. MSIX file share name. (Default: fslogix-pc-app1-001)')
param msixFileShareCustomName string = 'msix-pc-app1-001'

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

//@description('Remove resources not needed afdter deployment. (Default: false)')
//param removePostDeploymentTempResources bool = false

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

@description('Enable usage and telemetry feedback to Microsoft.')
param enableTelemetry bool = true


// =========== //
// Variable declaration //
// =========== //
// Resource naming
var varAzureCloudName = environment().name
var varDeploymentPrefixLowercase = toLower(deploymentPrefix)
var varSessionHostLocationLowercase = toLower(avdSessionHostLocation)
var varManagementPlaneLocationLowercase = toLower(avdManagementPlaneLocation)
var varSessionHostLocationAcronym = varLocationAcronyms[varSessionHostLocationLowercase]
var varManagementPlaneLocationAcronym = varLocationAcronyms[varManagementPlaneLocationLowercase]
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
    brazilsouth: 'brs'
    australiaeast: 'aue'
    australiasoutheast: 'ause'
    southindia: 'sin'
    centralindia: 'cin'
    westindia: 'win'
    canadacentral: 'cac'
    canadaeast: 'cae'
    uksouth: 'uks'
    ukwest: 'ukw'
    usgovarizona: 'az'
    usgoviowa: 'ia'
    usgovtexas: 'tx'
    usgovvirginia: 'va'
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

var varNamingUniqueStringSixChar = take('${uniqueString(avdWorkloadSubsId, varDeploymentPrefixLowercase, time)}', 6)
var varManagementPlaneNamingStandard = '${varManagementPlaneLocationAcronym}-${varDeploymentPrefixLowercase}'
var varComputeStorageResourcesNamingStandard = '${varSessionHostLocationAcronym}-${varDeploymentPrefixLowercase}'
var varServiceObjectsRgName = avdUseCustomNaming ? avdServiceObjectsRgCustomName : 'rg-avd-${varManagementPlaneNamingStandard}-service-objects' // max length limit 90 characters
var varNetworkObjectsRgName = avdUseCustomNaming ? avdNetworkObjectsRgCustomName : 'rg-avd-${varComputeStorageResourcesNamingStandard}-network' // max length limit 90 characters
var varComputeObjectsRgName = avdUseCustomNaming ? avdComputeObjectsRgCustomName : 'rg-avd-${varComputeStorageResourcesNamingStandard}-pool-compute' // max length limit 90 characters
var varStorageObjectsRgName = avdUseCustomNaming ? avdStorageObjectsRgCustomName : 'rg-avd-${varComputeStorageResourcesNamingStandard}-storage' // max length limit 90 characters
var varMonitoringRgName = avdUseCustomNaming ? avdMonitoringRgCustomName : 'rg-avd-${varManagementPlaneLocationAcronym}-monitoring' // max length limit 90 characters
//var varAvdSharedResourcesRgName = 'rg-${varAvdSessionHostLocationAcronym}-avd-shared-resources'
var varVnetworkName = avdUseCustomNaming ? avdVnetworkCustomName : 'vnet-avd-${varComputeStorageResourcesNamingStandard}-001'
var varVnetworkAvdSubnetName = avdUseCustomNaming ? avdVnetworkSubnetCustomName : 'snet-avd-${varComputeStorageResourcesNamingStandard}-001'
var varVnetworkPrivateEndpointSubnetName = avdUseCustomNaming ? privateEndpointVnetworkSubnetCustomName : 'snet-pe-${varComputeStorageResourcesNamingStandard}-001'
var varAvdNetworksecurityGroupName = avdUseCustomNaming ? avdNetworksecurityGroupCustomName : 'nsg-avd-${varComputeStorageResourcesNamingStandard}-001'
var varPrivateEndpointNetworksecurityGroupName = avdUseCustomNaming ? privateEndpointNetworksecurityGroupCustomName : 'nsg-pe-${varComputeStorageResourcesNamingStandard}-001'
var varAvdRouteTableName = avdUseCustomNaming ? avdRouteTableCustomName : 'route-avd-${varComputeStorageResourcesNamingStandard}-001'
var varPrivateEndpointRouteTableName = avdUseCustomNaming ? privateEndpointRouteTableCustomName : 'route-pe-${varComputeStorageResourcesNamingStandard}-001'
var varApplicationSecurityGroupName = avdUseCustomNaming ? avdApplicationSecurityGroupCustomName : 'asg-avd-${varComputeStorageResourcesNamingStandard}-001'
var varVnetworkPeeringName = 'peer-avd-${varComputeStorageResourcesNamingStandard}-${varNamingUniqueStringSixChar}'
var varWorkSpaceName = avdUseCustomNaming ? avdWorkSpaceCustomName : 'vdws-${varManagementPlaneNamingStandard}-001'
var varWorkSpaceFriendlyName = avdUseCustomNaming ? avdWorkSpaceCustomFriendlyName : '${deploymentPrefix}-${avdManagementPlaneLocation}-001'
var varHostPoolName = avdUseCustomNaming ? avdHostPoolCustomName : 'vdpool-${varManagementPlaneNamingStandard}-001'
var varHostFriendlyName = avdUseCustomNaming ? avdHostPoolCustomFriendlyName : '${deploymentPrefix}-${avdManagementPlaneLocation}-001'
var varApplicationGroupNameDesktop = avdUseCustomNaming ? avdApplicationGroupCustomNameDesktop : 'vdag-desktop-${varManagementPlaneNamingStandard}-001'
var varApplicationGroupFriendlyName = avdUseCustomNaming ? avdApplicationGroupCustomFriendlyName : 'Desktops-${deploymentPrefix}-${avdManagementPlaneLocation}-001'
var varApplicationGroupAppFriendlyName = 'Desktops-${deploymentPrefix}'
var varApplicationGroupNameRapp = avdUseCustomNaming ? avdApplicationGroupCustomNameRapp : 'vdag-rapp-${varManagementPlaneNamingStandard}-001'
var varApplicationGroupFriendlyNameRapp = avdUseCustomNaming ? avdApplicationGroupCustomFriendlyNameRapp : 'Apps-${deploymentPrefix}-${avdManagementPlaneLocation}-001'
var varScalingPlanName = avdUseCustomNaming ? avdScalingPlanCustomName : 'vdscaling-${varManagementPlaneNamingStandard}-001'
var varScalingPlanExclusionTag = 'Exclude-${varScalingPlanName}'
var varScalingPlanWeekdaysScheduleName = 'Weekdays-${varManagementPlaneNamingStandard}'
var varScalingPlanWeekendScheduleName = 'Weekend-${varManagementPlaneNamingStandard}'
var varWrklKvName = avdUseCustomNaming ? '${avdWrklKvPrefixCustomName}-${varComputeStorageResourcesNamingStandard}-${varNamingUniqueStringSixChar}' : 'kv-avd-${varComputeStorageResourcesNamingStandard}-${varNamingUniqueStringSixChar}' // max length limit 24 characters
var varWrklKvPrivateEndpointName = 'pe-kv-avd-${varDeploymentPrefixLowercase}-${varNamingUniqueStringSixChar}-vault'
var varSessionHostNamePrefix = avdUseCustomNaming ? avdSessionHostCustomNamePrefix : 'vm-avd-${varDeploymentPrefixLowercase}'
var varAvailabilitySetNamePrefix = avdUseCustomNaming ? '${avdAvailabilitySetCustomNamePrefix}-${varSessionHostLocationAcronym}-${varDeploymentPrefixLowercase}' : 'avail-avd-${varSessionHostLocationAcronym}-${varDeploymentPrefixLowercase}'
var varStorageManagedIdentityName = 'id-avd-storage-${varSessionHostLocationAcronym}-${varDeploymentPrefixLowercase}'
var varFslogixStorageName = createAvdFslogixDeployment ? fslogixStorageAzureFiles.outputs.storageAccountName : ''
var varFslogixStorageSku = avdUseAvailabilityZones ? '${fslogixStoragePerformance}_ZRS': '${fslogixStoragePerformance}_LRS'
var varMsixStorageSku = avdUseAvailabilityZones ? '${msixStoragePerformance}_ZRS': '${msixStoragePerformance}_LRS'
var varManagementVmName = 'vm-mgmt-${varDeploymentPrefixLowercase}'
//var varAvdMsixStorageName = deployAvdMsixStorageAzureFiles.outputs.storageAccountName
//var varAvdWrklStoragePrivateEndpointName = 'pe-stavd${varDeploymentPrefixLowercase}${varAvdNamingUniqueStringSixChar}-file'
var varAlaWorkspaceName = avdUseCustomNaming ? avdAlaWorkspaceCustomName :  'log-avd-${varManagementPlaneLocationAcronym}' //'log-avd-${varAvdComputeStorageResourcesNamingStandard}-${varAvdNamingUniqueStringSixChar}'
var varStgAccountForFlowLogsName = avdUseCustomNaming ? '${storageAccountPrefixCustomName}${varDeploymentPrefixLowercase}flowlogs${varNamingUniqueStringSixChar}' : 'stavd${varDeploymentPrefixLowercase}flowlogs${varNamingUniqueStringSixChar}'

var varScalingPlanSchedules = [
    {
        daysOfWeek: [
            'Monday'
            'Tuesday'
            'Wednesday'
            'Thursday'
            'Friday'
        ]
        name: varScalingPlanWeekdaysScheduleName
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
        rampDownMinimumHostsPct: 0 //10
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
        name: varScalingPlanWeekendScheduleName
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
        rampDownMinimumHostsPct: 0
        rampDownNotificationMessage: 'You will be logged off in 30 min. Make sure to save your work.'
        rampDownStartTime: {
            hour: 16
            minute: 0
        }
        rampDownStopHostsWhen: 'ZeroActiveSessions'
        rampDownWaitTimeMinutes: 30
        rampUpCapacityThresholdPct: 90
        rampUpLoadBalancingAlgorithm: 'DepthFirst'
        rampUpMinimumHostsPct: 0
        rampUpStartTime: {
            hour: 9
            minute: 0
        }
    }
]

var varMarketPlaceGalleryWindows = {
    win10_21h2: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'windows-10'
        sku: 'win10-21h2-avd'
        version: 'latest'
    }
    win10_21h2_office: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'office-365'
        sku: 'win10-21h2-avd-m365'
        version: 'latest'
    }
	win10_22h2_g2: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'windows-10'
        sku: 'win10-22h2-avd-g2'
        version: 'latest'
    }
    win10_22h2_office_g2: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'office-365'
        sku: 'win10-21h2-avd-m365-g2'
        version: 'latest'
    }
    win11_21h2: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-11'
        sku: 'win11-21h2-avd'
        version: 'latest'
    }
    win11_21h2_office: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'office-365'
        sku: 'win11-21h2-avd-m365'
        version: 'latest'
    }
    win11_22h2: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-11'
        sku: 'win11-22h2-avd'
        version: 'latest'
    }
    win11_22h2_office: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'office-365'
        sku: 'win11-22h2-avd-m365'
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
var varFslogixFileShareName = createAvdFslogixDeployment ? fslogixStorageAzureFiles.outputs.fileShareName : ''
var varFslogixSharePath = '\\\\${varFslogixStorageName}.file.${environment().suffixes.storage}\\${varFslogixFileShareName}'
var varFsLogixScriptArguments = '-volumeshare ${varFslogixSharePath}'
var varAvdAgentPackageLocation = 'https://wvdportalstorageblob.blob.${environment().suffixes.storage}/galleryartifacts/Configuration_09-08-2022.zip'
var varStorageAccountContributorRoleId = '17d1049b-9a84-46fb-8f53-869881c3d3ab'
var varReaderRoleId = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
var varDesktopVirtualizationPowerOnContributorRoleId = '489581de-a3bd-480d-9518-53dea7416b33'
var varDesktopVirtualizationPowerOnOffContributorRoleId = '40c5ff49-9181-41f8-ae61-143b0e78555e'
var varStorageAzureFilesDscAgentPackageLocation = 'https://github.com/Azure/avdaccelerator/raw/main/workload/scripts/DSCStorageScripts.zip'
var varTempResourcesCleanUpDscAgentPackageLocation = 'https://github.com/Azure/avdaccelerator/raw/main/workload/scripts/postDeploymentTempResourcesCleanUp.zip'
var varStorageToDomainScriptUri = '${varBaseScriptUri}scripts/Manual-DSC-Storage-Scripts.ps1'
var varPostDeploymentTempResuorcesCleanUpScriptUri = '${varBaseScriptUri}scripts/postDeploymentTempResuorcesCleanUp.ps1'
var varStorageToDomainScript = './Manual-DSC-Storage-Scripts.ps1'
var varPostDeploymentTempResuorcesCleanUpScript = './PostDeploymentTempResuorcesCleanUp.ps1'
var varOuStgPath = !empty(storageOuPath) ? '"${storageOuPath}"' : '"${varDefaultStorageOuPath}"'
var varDefaultStorageOuPath = (avdIdentityServiceProvider == 'AADDS') ? 'AADDC Computers': 'Computers'
var varStorageCustomOuPath = !empty(storageOuPath) ? 'true' : 'false'
var varCreateOuForStorageString = string(createOuForStorage)
var varAllDnsServers = '${customDnsIps},168.63.129.16'
var varDnsServers = empty(customDnsIps) ? []: (split(varAllDnsServers, ','))
var varCreateFslogixDeployment = (avdIdentityServiceProvider == 'AAD') ? false: createAvdFslogixDeployment
var varCreateMsixDeployment = (avdIdentityServiceProvider == 'AAD') ? false: createMsixDeployment
var varCreateStorageDeployment = (varCreateFslogixDeployment||varCreateMsixDeployment == true) ? true: false
var varApplicationGroupIdentitiesIds = !empty(avdApplicationGroupIdentitiesIds) ? (split(avdApplicationGroupIdentitiesIds, ',')): []
var varCreateVnetPeering = !empty(existingHubVnetResourceId) ? true: false

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
    JoinType: avdIdentityServiceProvider
}

var varAvdCostManagementParentResourceTag = {
    'cm-resource-parent': '/subscriptions/${avdWorkloadSubsId}}/resourceGroups/${varServiceObjectsRgName}/providers/Microsoft.DesktopVirtualization/hostpools/${varHostPoolName}'
}

var varAllResourceTags = union(varCommonResourceTags, varAllComputeStorageTags)
//

var varTelemetryId = 'pid-2ce4228c-d72c-43fb-bb5b-cd8f3ba2138e-${avdManagementPlaneLocation}'

var resourceGroups = [
    {
        purpose: 'Service-Objects'
        name: varServiceObjectsRgName
        location: avdManagementPlaneLocation
        enableDefaultTelemetry: false
        tags: createResourceTags ? union(varCommonResourceTags,varAvdCostManagementParentResourceTag) : varAvdCostManagementParentResourceTag
    }
    {
        purpose: 'Pool-Compute'
        name: varComputeObjectsRgName
        location: avdSessionHostLocation
        enableDefaultTelemetry: false
        tags: createResourceTags ? union(varAllComputeStorageTags,varAvdCostManagementParentResourceTag) : varAvdCostManagementParentResourceTag
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
module baselineNetworkResourceGroup '../../carml/1.3.0/Microsoft.Resources/resourceGroups/deploy.bicep' = if (createAvdVnet) {
    scope: subscription(avdWorkloadSubsId)
    name: 'Deploy-${varNetworkObjectsRgName}-${time}'
    params: {
        name: varNetworkObjectsRgName
        location: avdSessionHostLocation
        enableDefaultTelemetry: false
        tags: createResourceTags ? union(varCommonResourceTags,varAvdCostManagementParentResourceTag) : varAvdCostManagementParentResourceTag
    }
    dependsOn: avdDeployMonitoring ? [
        monitoringDiagnosticSettings
    ]: []
}

// Compute, service objects
module baselineResourceGroups '../../carml/1.3.0/Microsoft.Resources/resourceGroups/deploy.bicep' = [for resourceGroup in resourceGroups: {
    scope: subscription(avdWorkloadSubsId)
    name: 'Deploy-AVD-${resourceGroup.purpose}-${time}'
    params: {
        name: resourceGroup.name
        location: resourceGroup.location
        enableDefaultTelemetry: resourceGroup.enableDefaultTelemetry
        tags: resourceGroup.tags
    }
    dependsOn: avdDeployMonitoring ? [
        monitoringDiagnosticSettings
    ]: []
}]

// Storage.
module baselineStorageResourceGroup '../../carml/1.3.0/Microsoft.Resources/resourceGroups/deploy.bicep' = if (varCreateStorageDeployment && (avdIdentityServiceProvider != 'AAD')) {
    scope: subscription(avdWorkloadSubsId)
    name: 'Deploy-${varStorageObjectsRgName}-${time}'
    params: {
        name: varStorageObjectsRgName
        location: avdSessionHostLocation
        enableDefaultTelemetry: false
        tags: createResourceTags ? union(varAllComputeStorageTags,varAvdCostManagementParentResourceTag) : varAvdCostManagementParentResourceTag
    }
    dependsOn: avdDeployMonitoring ? [
        monitoringDiagnosticSettings
    ]: []
}

/*
// Validation Deployment Script
// This module validates the selected parameter values and collects required data
module validation 'avd-modules/validation.bicep' = {
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
module monitoringDiagnosticSettings './modules/avdInsightsMonitoring/deploy.bicep' = if (avdDeployMonitoring) {
    name: 'Monitoring-${time}'
    params: {
        managementPlaneLocation: avdManagementPlaneLocation
        deployAlaWorkspace: deployAlaWorkspace
        deployCustomPolicyMonitoring: deployCustomPolicyMonitoring
        alaWorkspaceId: deployAlaWorkspace ? '' : alaExistingWorkspaceResourceId
        monitoringRgName: varMonitoringRgName
        alaWorkspaceName: deployAlaWorkspace ? varAlaWorkspaceName: ''
        alaWorkspaceDataRetention: avdAlaWorkspaceDataRetention
        workloadSubsId: avdWorkloadSubsId
        tags: createResourceTags ? union(varAllResourceTags,varAvdCostManagementParentResourceTag) : varAvdCostManagementParentResourceTag
    }
    dependsOn: []
}

// Azure Policies for network monitorig/security . New storage account/Reuse existing one if needed created for the NSG flow logs
module azurePoliciesNetworking './modules/azurePolicyNetworking/deploy.bicep' = if (avdDeployMonitoring && deployCustomPolicyNetworking) {
    name: (length('Enable-Azure-Policy-for-Netwok-Security-${time}') > 64) ? take('Enable-Azure-Policy-for-Netwok-Security-${time}',64) : 'Enable-Azure-Policy-for-Netwok-Security-${time}'
    params: {
        alaWorkspaceResourceId: (avdDeployMonitoring && deployAlaWorkspace) ? monitoringDiagnosticSettings.outputs.avdAlaWorkspaceResourceId : alaExistingWorkspaceResourceId
        alaWorkspaceId: (avdDeployMonitoring && deployAlaWorkspace) ? monitoringDiagnosticSettings.outputs.avdAlaWorkspaceId : alaExistingWorkspaceResourceId
        managementPlaneLocation: avdManagementPlaneLocation
        workloadSubsId: avdWorkloadSubsId
        monitoringRgName: varMonitoringRgName
        stgAccountForFlowLogsId: deployStgAccountForFlowLogs ? '' : stgAccountForFlowLogsId
        stgAccountForFlowLogsName: deployStgAccountForFlowLogs ? varStgAccountForFlowLogsName : ''
        tags: createResourceTags ? union(varAllResourceTags,varAvdCostManagementParentResourceTag) : varAvdCostManagementParentResourceTag
    }
    dependsOn: [
        monitoringDiagnosticSettings
    ]
}

// Networking.
module networking './modules/networking/deploy.bicep' = if (createAvdVnet) {
    name: 'Networking-${time}'
    params: {
        applicationSecurityGroupName: varApplicationSecurityGroupName
        computeObjectsRgName: varComputeObjectsRgName
        networkObjectsRgName: varNetworkObjectsRgName
        avdNetworksecurityGroupName: varAvdNetworksecurityGroupName
        privateEndpointNetworksecurityGroupName: varPrivateEndpointNetworksecurityGroupName
        avdRouteTableName: varAvdRouteTableName
        privateEndpointRouteTableName: varPrivateEndpointRouteTableName
        vNetworkAddressPrefixes: avdVnetworkAddressPrefixes
        vNetworkName: varVnetworkName
        vNetworkPeeringName: avdIdentityServiceProvider == 'AAD' ? '': varVnetworkPeeringName
        vNetworkAvdSubnetName: varVnetworkAvdSubnetName
        vNetworkPrivateEndpointSubnetName: varVnetworkPrivateEndpointSubnetName
        createVnet: createAvdVnet
        createVnetPeering: varCreateVnetPeering
        deployPrivateEndpointSubnet: (deployPrivateEndpointKeyvaultStorage == true) ? true : false //adding logic that will be used when also including AVD control plane PEs
        vNetworkGatewayOnHub: vNetworkGatewayOnHub
        existingHubVnetResourceId: avdIdentityServiceProvider == 'AAD' ? '': existingHubVnetResourceId
        sessionHostLocation: avdSessionHostLocation
        vNetworkAvdSubnetAddressPrefix: vNetworkAvdSubnetAddressPrefix
        vNetworkPrivateEndpointSubnetAddressPrefix: vNetworkPrivateEndpointSubnetAddressPrefix
        workloadSubsId: avdWorkloadSubsId
        dnsServers: varDnsServers
        tags: createResourceTags ? union(varCommonResourceTags,varAvdCostManagementParentResourceTag) : varAvdCostManagementParentResourceTag
        alaWorkspaceResourceId: avdDeployMonitoring ? (deployAlaWorkspace ? monitoringDiagnosticSettings.outputs.avdAlaWorkspaceResourceId : alaExistingWorkspaceResourceId) : ''
        diagnosticLogsRetentionInDays: avdAlaWorkspaceDataRetention
    }
    dependsOn: [
        baselineNetworkResourceGroup
    ]
}

// AVD management plane.
module managementPLane './modules/avdManagementPlane/deploy.bicep' = {
    name: 'HostPool-AppGroups-${time}'
    params: {
        applicationGroupNameDesktop: varApplicationGroupNameDesktop
        applicationGroupFriendlyNameDesktop: varApplicationGroupFriendlyName
        applicationGroupAppFriendlyNameDesktop: varApplicationGroupAppFriendlyName
        workSpaceName: varWorkSpaceName
        osImage: avdOsImage
        workSpaceFriendlyName: varWorkSpaceFriendlyName
        applicationGroupNameRapp: varApplicationGroupNameRapp
        applicationGroupFriendlyNameRapp: varApplicationGroupFriendlyNameRapp
        deployRappGroup: avdDeployRappGroup
        computeTimeZone: varTimeZones[avdSessionHostLocation]
        hostPoolName: varHostPoolName
        hostPoolFriendlyName: varHostFriendlyName
        hostPoolRdpProperties: avdHostPoolRdpProperties
        hostPoolLoadBalancerType: avdHostPoolLoadBalancerType
        hostPoolType: avdHostPoolType
        deployScalingPlan: avdDeployScalingPlan
        scalingPlanExclusionTag: varScalingPlanExclusionTag
        scalingPlanSchedules: varScalingPlanSchedules
        scalingPlanName: varScalingPlanName
        hostPoolMaxSessions: avhHostPoolMaxSessions
        personalAssignType: avdPersonalAssignType
        managementPlaneLocation: avdManagementPlaneLocation
        serviceObjectsRgName: varServiceObjectsRgName
        startVmOnConnect: (avdHostPoolType == 'Pooled') ? avdDeployScalingPlan:  avdStartVmOnConnect
        workloadSubsId: avdWorkloadSubsId
        identityServiceProvider: avdIdentityServiceProvider
        applicationGroupIdentitiesIds: varApplicationGroupIdentitiesIds
        applicationGroupIdentityType: avdApplicationGroupIdentityType
        tags: createResourceTags ? union(varCommonResourceTags,varAvdCostManagementParentResourceTag) : varAvdCostManagementParentResourceTag
        alaWorkspaceResourceId: avdDeployMonitoring ? (deployAlaWorkspace ? monitoringDiagnosticSettings.outputs.avdAlaWorkspaceResourceId : alaExistingWorkspaceResourceId) : ''
        diagnosticLogsRetentionInDays: avdAlaWorkspaceDataRetention
    }
    dependsOn: [
        baselineResourceGroups
        managedIdentitiesRoleAssign
    ]
}

// Identity: managed identities and role assignments.
module managedIdentitiesRoleAssign './modules/identity/deploy.bicep' = {
    name: 'Managed-ID-RoleAssign-${time}'
    params: {
        computeObjectsRgName: varComputeObjectsRgName
        deploySessionHosts: avdDeploySessionHosts
        enterpriseAppObjectId: avdEnterpriseAppObjectId
        deployScalingPlan: avdDeployScalingPlan
        sessionHostLocation: avdSessionHostLocation
        serviceObjectsRgName: varServiceObjectsRgName
        storageObjectsRgName: varStorageObjectsRgName
        workloadSubsId: avdWorkloadSubsId
        storageManagedIdentityName: varStorageManagedIdentityName
        readerRoleId: varReaderRoleId
        enableStartVmOnConnect: avdStartVmOnConnect
        managementPlaneLocation: avdManagementPlaneLocation
        identityServiceProvider: avdIdentityServiceProvider
        storageAccountContributorRoleId: varStorageAccountContributorRoleId
        createStorageDeployment: varCreateStorageDeployment
        desktopVirtualizationPowerOnContributorRoleId: varDesktopVirtualizationPowerOnContributorRoleId
        desktopVirtualizationPowerOnOffContributorRoleId: varDesktopVirtualizationPowerOnOffContributorRoleId
        applicationGroupIdentitiesIds: varApplicationGroupIdentitiesIds
        tags: createResourceTags ? union(varCommonResourceTags,varAvdCostManagementParentResourceTag) : varAvdCostManagementParentResourceTag
    }
    dependsOn: [
        baselineResourceGroups
        baselineStorageResourceGroup
    ]
}

// Key vault.
module wrklKeyVault '../../carml/1.3.0/Microsoft.KeyVault/vaults/deploy.bicep' = if (avdDeploySessionHosts) {
    scope: resourceGroup('${avdWorkloadSubsId}', '${varServiceObjectsRgName}')
    name: 'Workload-KeyVault-${time}'
    params: {
        name: varWrklKvName
        location: avdSessionHostLocation
        enableRbacAuthorization: false
        enablePurgeProtection: true
        softDeleteRetentionInDays: 7
        publicNetworkAccess: deployPrivateEndpointKeyvaultStorage ? 'Disabled' : 'Enabled'
        networkAcls: deployPrivateEndpointKeyvaultStorage ? {
            bypass: 'AzureServices'
            defaultAction: 'Deny'
            virtualNetworkRules: []
            ipRules: []
        } : {}
        privateEndpoints: deployPrivateEndpointKeyvaultStorage ? (avdVnetPrivateDnsZone ? [
            {
                name: varWrklKvPrivateEndpointName
                subnetResourceId: createAvdVnet ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetworkPrivateEndpointSubnetName}' : existingVnetPrivateEndpointSubnetResourceId
                customNetworkInterfaceName: 'nic-01-${varWrklKvPrivateEndpointName}'
                service: 'vault'
                privateDnsZoneGroup: {
                    privateDNSResourceIds: [
                        avdVnetPrivateDnsZoneKeyvaultId
                    ] 
                }
            }
        ] : [
            {
                name: varWrklKvPrivateEndpointName
                subnetResourceId: createAvdVnet ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetworkPrivateEndpointSubnetName}' : existingVnetPrivateEndpointSubnetResourceId
                customNetworkInterfaceName: 'nic-01-${varWrklKvPrivateEndpointName}'
                service: 'vault'
            }
        ]) : []
        secrets: {
            secureList: (avdIdentityServiceProvider != 'AAD') ? [
                {
                    name: 'vmLocalUserPassword'
                    value: avdVmLocalUserPassword
                    contentType: 'Session host local user credentials'
                }
                {
                    name: 'vmLocalUserName'
                    value: avdVmLocalUserName
                    contentType: 'Session host local user credentials'
                }
                {
                    name: 'domainJoinUserName'
                    value: avdDomainJoinUserName
                    contentType: 'Domain join credentials'
                }
                {
                    name: 'domainJoinUserPassword'
                    value: avdDomainJoinUserPassword
                    contentType: 'Domain join credentials'
                }
            ] : [
                {
                    name: 'vmLocalUserPassword'
                    value: avdVmLocalUserPassword
                    contentType: 'Session host local user credentials'
                }
                {
                    name: 'vmLocalUserName'
                    value: avdVmLocalUserName
                    contentType: 'Session host local user credentials'
                }
                {
                    name: 'domainJoinUserName'
                    value: 'AAD-Joined-Deployment-No-Domain-Credentials'
                    contentType: 'Domain join credentials'
                }
                {
                    name: 'domainJoinUserPassword'
                    value: 'AAD-Joined-Deployment-No-Domain-Credentials'
                    contentType: 'Domain join credentials'
                }
            ]
        }
        tags: createResourceTags ? union(varCommonResourceTags,varAvdCostManagementParentResourceTag) : varAvdCostManagementParentResourceTag

    }
    dependsOn: [
        baselineResourceGroups
        //updateExistingSubnet
    ]
}

// FSLogix Storage.
module fslogixStorageAzureFiles './modules/storageAzureFiles/deploy.bicep' = if (varCreateFslogixDeployment && avdDeploySessionHosts && (avdIdentityServiceProvider != 'AAD')) {
    name: 'Storage-Fslogix-Azure-Files-${time}'
    params: {
        storagePurpose: 'fslogix'
        fileShareCustomName: fslogixFileShareCustomName
        identityServiceProvider: avdIdentityServiceProvider
        dscAgentPackageLocation: varStorageAzureFilesDscAgentPackageLocation
        storageCustomOuPath: varStorageCustomOuPath
        managementVmName: varManagementVmName
        deployPrivateEndpoint: deployPrivateEndpointKeyvaultStorage
        ouStgPath: varOuStgPath
        createOuForStorageString: varCreateOuForStorageString
        managedIdentityClientId: varCreateStorageDeployment ? managedIdentitiesRoleAssign.outputs.managedIdentityClientId : ''
        storageToDomainScript:  varStorageToDomainScript
        storageToDomainScriptUri: varStorageToDomainScriptUri
        computeTimeZone: varTimeZones[avdSessionHostLocation]
        applicationSecurityGroupResourceId: createAvdVnet ? '${networking.outputs.applicationSecurityGroupResourceId}' : ''
        computeObjectsRgName: varComputeObjectsRgName
        domainJoinUserName: avdDomainJoinUserName
        wrklKvName: varWrklKvName
        serviceObjectsRgName: varServiceObjectsRgName
        fileShareQuotaSize: fslogixFileShareQuotaSize
        identityDomainName: avdIdentityDomainName
        imageTemplateDefinitionId: avdImageTemplateDefinitionId
        sessionHostOuPath: avdOuPath
        sessionHostDiskType: avdSessionHostDiskType
        sessionHostLocation: avdSessionHostLocation
        sessionHostsSize: avdSessionHostsSize
        storageObjectsRgName: varStorageObjectsRgName
        avdSubnetId: createAvdVnet ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetworkAvdSubnetName}' : existingVnetAvdSubnetResourceId
        privateEndpointSubnetId: createAvdVnet ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetworkPrivateEndpointSubnetName}' : existingVnetPrivateEndpointSubnetResourceId
        enableAcceleratedNetworking: enableAcceleratedNetworking
        createAvdVnet: createAvdVnet
        vmLocalUserName: avdVmLocalUserName
        vnetPrivateDnsZone: avdVnetPrivateDnsZone
        vnetPrivateDnsZoneFilesId: avdVnetPrivateDnsZoneFilesId
        workloadSubsId: avdWorkloadSubsId
        encryptionAtHost: encryptionAtHost
        storageManagedIdentityResourceId: varCreateStorageDeployment ? managedIdentitiesRoleAssign.outputs.managedIdentityResourceId : ''
        fileShareMultichannel: (fslogixStoragePerformance == 'Premium') ? true : false
        storageSku: varFslogixStorageSku
        marketPlaceGalleryWindowsManagementVm: varMarketPlaceGalleryWindows[avdOsImage]
        useSharedImage: useSharedImage
        tags: createResourceTags ? union(varAllResourceTags,varAvdCostManagementParentResourceTag) : varAvdCostManagementParentResourceTag
        alaWorkspaceResourceId: avdDeployMonitoring ? (deployAlaWorkspace ? monitoringDiagnosticSettings.outputs.avdAlaWorkspaceResourceId : alaExistingWorkspaceResourceId) : ''
        diagnosticLogsRetentionInDays: avdAlaWorkspaceDataRetention
        useCustomNaming: avdUseCustomNaming
        storageAccountPrefixCustomName: storageAccountPrefixCustomName
        namingUniqueStringSixChar: varNamingUniqueStringSixChar
        deploymentPrefixLowercase: varDeploymentPrefixLowercase
    }
    dependsOn: [
        baselineStorageResourceGroup
        networking
        wrklKeyVault
    ]
}

// Msix Storage.
module msixStorageAzureFiles './modules/storageAzureFiles/deploy.bicep' = if (varCreateMsixDeployment && avdDeploySessionHosts && (avdIdentityServiceProvider != 'AAD')) {
    name: 'Storage-Msix-AzureFiles-${time}'
    params: {
        storagePurpose: 'msix'
        fileShareCustomName: msixFileShareCustomName
        identityServiceProvider: avdIdentityServiceProvider
        dscAgentPackageLocation: varStorageAzureFilesDscAgentPackageLocation
        storageCustomOuPath: varStorageCustomOuPath
        managementVmName: varManagementVmName
        deployPrivateEndpoint: deployPrivateEndpointKeyvaultStorage
        ouStgPath: varOuStgPath
        createOuForStorageString: varCreateOuForStorageString
        managedIdentityClientId: varCreateStorageDeployment ? managedIdentitiesRoleAssign.outputs.managedIdentityClientId : ''
        storageToDomainScript:  varStorageToDomainScript
        storageToDomainScriptUri: varStorageToDomainScriptUri
        computeTimeZone: varTimeZones[avdSessionHostLocation]
        applicationSecurityGroupResourceId: createAvdVnet ? '${networking.outputs.applicationSecurityGroupResourceId}' : ''
        computeObjectsRgName: varComputeObjectsRgName
        domainJoinUserName: avdDomainJoinUserName
        wrklKvName: varWrklKvName
        serviceObjectsRgName: varServiceObjectsRgName
        fileShareQuotaSize: msixFileShareQuotaSize
        identityDomainName: avdIdentityDomainName
        imageTemplateDefinitionId: avdImageTemplateDefinitionId
        sessionHostOuPath: avdOuPath
        sessionHostDiskType: avdSessionHostDiskType
        sessionHostLocation: avdSessionHostLocation
        sessionHostsSize: avdSessionHostsSize
        storageObjectsRgName: varStorageObjectsRgName
        avdSubnetId: createAvdVnet ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetworkAvdSubnetName}' : existingVnetAvdSubnetResourceId
        privateEndpointSubnetId: createAvdVnet ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetworkPrivateEndpointSubnetName}' : existingVnetPrivateEndpointSubnetResourceId
        enableAcceleratedNetworking: enableAcceleratedNetworking
        createAvdVnet: createAvdVnet
        vmLocalUserName: avdVmLocalUserName
        vnetPrivateDnsZone: avdVnetPrivateDnsZone
        vnetPrivateDnsZoneFilesId: avdVnetPrivateDnsZoneFilesId
        workloadSubsId: avdWorkloadSubsId
        encryptionAtHost: encryptionAtHost
        storageManagedIdentityResourceId: varCreateStorageDeployment ? managedIdentitiesRoleAssign.outputs.managedIdentityResourceId : ''
        fileShareMultichannel: (msixStoragePerformance == 'Premium') ? true : false
        storageSku: varMsixStorageSku
        marketPlaceGalleryWindowsManagementVm: varMarketPlaceGalleryWindows[avdOsImage]
        useSharedImage: useSharedImage
        tags: createResourceTags ? union(varAllResourceTags,varAvdCostManagementParentResourceTag) : varAvdCostManagementParentResourceTag
        alaWorkspaceResourceId: avdDeployMonitoring ? (deployAlaWorkspace ? monitoringDiagnosticSettings.outputs.avdAlaWorkspaceResourceId : alaExistingWorkspaceResourceId) : ''
        diagnosticLogsRetentionInDays: avdAlaWorkspaceDataRetention
        useCustomNaming: avdUseCustomNaming
        storageAccountPrefixCustomName: storageAccountPrefixCustomName
        namingUniqueStringSixChar: varNamingUniqueStringSixChar
        deploymentPrefixLowercase: varDeploymentPrefixLowercase
    }
    dependsOn: [
        baselineStorageResourceGroup
        fslogixStorageAzureFiles
        networking
        wrklKeyVault
    ]
}

// Session hosts.
module sessionHosts './modules/avdSessionHosts/deploy.bicep' = if (avdDeploySessionHosts) {
    name: 'Session-Hosts-${time}'
    params: {

        avdAgentPackageLocation: varAvdAgentPackageLocation
        computeTimeZone: varTimeZones[avdSessionHostLocation]
        applicationSecurityGroupResourceId: createAvdVnet ? '${networking.outputs.applicationSecurityGroupResourceId}' : ''
        availabilitySetFaultDomainCount: avdAsFaultDomainCount
        availabilitySetUpdateDomainCount: avdAsUpdateDomainCount
        identityServiceProvider: avdIdentityServiceProvider
        createIntuneEnrollment: createIntuneEnrollment
        availabilitySetNamePrefix: varAvailabilitySetNamePrefix
        computeObjectsRgName: varComputeObjectsRgName
        deploySessionHostsCount: avdDeploySessionHostsCount
        sessionHostCountIndex: avdSessionHostCountIndex
        domainJoinUserName: avdDomainJoinUserName
        wrklKvName: varWrklKvName
        serviceObjectsRgName: varServiceObjectsRgName
        hostPoolName: varHostPoolName
        identityDomainName: avdIdentityDomainName
        avdImageTemplateDefinitionId: avdImageTemplateDefinitionId
        sessionHostOuPath: avdOuPath
        sessionHostDiskType: avdSessionHostDiskType
        sessionHostLocation: avdSessionHostLocation
        sessionHostNamePrefix: varSessionHostNamePrefix
        sessionHostsSize: avdSessionHostsSize
        enableAcceleratedNetworking: enableAcceleratedNetworking
        securityType: securityType == 'Standard' ? '' : securityType
        secureBootEnabled: secureBootEnabled
        vTpmEnabled: vTpmEnabled
        subnetId: createAvdVnet ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetworkAvdSubnetName}' : existingVnetAvdSubnetResourceId
        createAvdVnet: createAvdVnet
        useAvailabilityZones: avdUseAvailabilityZones
        vmLocalUserName: avdVmLocalUserName
        workloadSubsId: avdWorkloadSubsId
        encryptionAtHost: encryptionAtHost
        createAvdFslogixDeployment: (avdIdentityServiceProvider != 'AAD') ? varCreateFslogixDeployment: false
        storageManagedIdentityResourceId:  (varCreateStorageDeployment && (avdIdentityServiceProvider != 'AAD'))  ? managedIdentitiesRoleAssign.outputs.managedIdentityResourceId : ''
        fsLogixScript: (avdIdentityServiceProvider != 'AAD') ? varFsLogixScript: ''
        fsLogixScriptArguments: (avdIdentityServiceProvider != 'AAD') ? varFsLogixScriptArguments: ''
        fslogixScriptUri: (avdIdentityServiceProvider != 'AAD') ? varFslogixScriptUri: ''
        fslogixSharePath: (avdIdentityServiceProvider != 'AAD') ? varFslogixSharePath: ''
        marketPlaceGalleryWindows: varMarketPlaceGalleryWindows[avdOsImage]
        useSharedImage: useSharedImage
        tags: createResourceTags ? union(varAllResourceTags,varAvdCostManagementParentResourceTag) : varAvdCostManagementParentResourceTag
        deployMonitoring: avdDeployMonitoring
        alaWorkspaceResourceId: avdDeployMonitoring ? (deployAlaWorkspace ? monitoringDiagnosticSettings.outputs.avdAlaWorkspaceResourceId : alaExistingWorkspaceResourceId) : ''
        diagnosticLogsRetentionInDays: avdAlaWorkspaceDataRetention
    }
    dependsOn: [
        fslogixStorageAzureFiles
        baselineResourceGroups
        networking
        wrklKeyVault
    ]
}
/*
// Post deployment resources clean up.
module addShareToDomainScript './modules/postDeploymentTempResourcesCleanUp/deploy.bicep' = if (removePostDeploymentTempResources)  {
    scope: resourceGroup('${avdWorkloadSubsId}', '${varServiceObjectsRgName}')
    name: 'CleanUp-Temp-Resources-${time}'
    params: {
        location: avdSessionHostLocation
        managementVmName: varManagementVmName
        scriptFile: varPostDeploymentTempResuorcesCleanUpScript
        //scriptArguments: varPostDeploymentTempResuorcesCleanUpScriptArgs
        baseScriptUri: varPostDeploymentTempResuorcesCleanUpScriptUri
        azureCloudName: varAzureCloudName
        dscAgentPackageLocation: varTempResourcesCleanUpDscAgentPackageLocation
        subscriptionId: avdWorkloadSubsId
        serviceObjectsRgName: varServiceObjectsRgName
        computeObjectsRgName: varComputeObjectsRgName
        storageObjectsRgName: varStorageObjectsRgName
        networkObjectsRgName: varNetworkObjectsRgName
        monitoringObjectsRgName: varMonitoringRgName
    }
    dependsOn: [
        sessionHosts
        msixStorageAzureFiles
        fslogixStorageAzureFiles
        managementPLane
        networking
    ]
}
*/
