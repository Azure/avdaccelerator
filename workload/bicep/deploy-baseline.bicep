targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@minLength(2)
@maxLength(4)
@description('Optional. The name of the resource group to deploy. (Default: )')
param deploymentPrefix string = 'AVD1'

@allowed([
    'Dev' // Development
    'Test' // Test
    'Prod' // Production
])
@description('Optional. The name of the resource group to deploy. (Default: Dev)')
param deploymentEnvironment string = 'Dev'

@maxValue(730)
@minValue(30)
@description('Optional. This value is used to set the expiration date on the disk encryption key. (Default: 60)')
param diskEncryptionKeyExpirationInDays int = 60

@description('Optional. Location where to deploy compute services. (Default: eastus2)')
param avdSessionHostLocation string = 'eastus2'

@description('Optional. Location where to deploy AVD management plane. (Default: eastus2)')
param avdManagementPlaneLocation string = 'eastus2'

@description('Required. AVD workload subscription ID, multiple subscriptions scenario. (Default: )')
param avdWorkloadSubsId string = ''

@description('Required. Azure Virtual Desktop Enterprise Application object ID. (Default: )')
param avdEnterpriseAppObjectId string = ''

@description('Required. AVD session host local username.')
param avdVmLocalUserName string

@description('Required. AVD session host local password.')
@secure()
param avdVmLocalUserPassword string

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
param avdIdentityDomainName string

@description('Required. AD domain GUID.')
param identityDomainGuid string = ''

@description('Required. AVD session host domain join user principal name. (Defualt: "none")')
param avdDomainJoinUserName string = 'none'

@description('Required. AVD session host domain join password. (Defualt: "none")')
@secure()
param avdDomainJoinUserPassword string = 'none'

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

@description('Optional. AVD host pool maximum number of user sessions per session host. (Default: 8)')
param avhHostPoolMaxSessions int = 8

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
param createPrivateDnsZones bool = true

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

@description('Optional. Enables a zero trust configuration on the session host disks. (Default: false)')
param diskZeroTrust bool = false

@description('Optional. Session host VM size. (Defualt: Standard_D4ads_v5)')
param avdSessionHostsSize string = 'Standard_D4ads_v5'

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
@description('Optional. AVD OS image SKU. (Default: win11-21h2)')
param avdOsImage string = 'win11_22h2'

@description('Management VM image SKU (Default: winServer_2022_Datacenter)')
param managementVmOsImage string = 'winServer_2022_Datacenter_core_smalldisk_g2'

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
@description('Optional. AVD service resources resource group custom name. (Default: rg-avd-app1-dev-use2-service-objects)')
param avdServiceObjectsRgCustomName string = 'rg-avd-app1-dev-use2-service-objects'

@maxLength(90)
@description('Optional. AVD network resources resource group custom name. (Default: rg-avd-app1-dev-use2-network)')
param avdNetworkObjectsRgCustomName string = 'rg-avd-app1-dev-use2-network'

@maxLength(90)
@description('Optional. AVD network resources resource group custom name. (Default: rg-avd-app1-dev-use2-pool-compute)')
param avdComputeObjectsRgCustomName string = 'rg-avd-app1-dev-use2-pool-compute'

@maxLength(90)
@description('Optional. AVD network resources resource group custom name. (Default: rg-avd-app1-dev-use2-storage)')
param avdStorageObjectsRgCustomName string = 'rg-avd-app1-dev-use2-storage'

@maxLength(90)
@description('Optional. AVD monitoring resource group custom name. (Default: rg-avd-dev-use2-monitoring)')
param avdMonitoringRgCustomName string = 'rg-avd-dev-use2-monitoring'

@maxLength(64)
@description('Optional. AVD virtual network custom name. (Default: vnet-app1-dev-use2-001)')
param avdVnetworkCustomName string = 'vnet-app1-dev-use2-001'

@maxLength(64)
@description('Optional. AVD Azure log analytics workspace custom name. (Default: log-avd-app1-dev-use2)')
param avdAlaWorkspaceCustomName string = 'log-avd-app1-dev-use2'

//@maxLength(24)
//@description('Optional. Azure Storage Account custom name for NSG flow logs. (Default: stavduse2flowlogs001)')
//param avdStgAccountForFlowLogsCustomName string = 'stavduse2flowlogs001'

@maxLength(80)
@description('Optional. AVD virtual network subnet custom name. (Default: snet-avd-app1-dev-use2-001)')
param avdVnetworkSubnetCustomName string = 'snet-avd-app1-dev-use2-001'

@maxLength(80)
@description('Optional. private endpoints virtual network subnet custom name. (Default: snet-pe-app1-dev-use2-001)')
param privateEndpointVnetworkSubnetCustomName string = 'snet-pe-app1-dev-use2-001'

@maxLength(80)
@description('Optional. AVD network security group custom name. (Default: nsg-avd-app1-dev-use2-001)')
param avdNetworksecurityGroupCustomName string = 'nsg-avd-app1-dev-use2-001'

@maxLength(80)
@description('Optional. Private endpoint network security group custom name. (Default: nsg-pe-app1-dev-use2-001)')
param privateEndpointNetworksecurityGroupCustomName string = 'nsg-pe-app1-dev-use2-001'

@maxLength(80)
@description('Optional. AVD route table custom name. (Default: route-avd-app1-dev-use2-001)')
param avdRouteTableCustomName string = 'route-avd-app1-dev-use2-001'

@maxLength(80)
@description('Optional. Private endpoint route table custom name. (Default: route-avd-app1-dev-use2-001)')
param privateEndpointRouteTableCustomName string = 'route-pe-app1-dev-use2-001'

@maxLength(80)
@description('Optional. AVD application security custom name. (Default: asg-app1-dev-use2-001)')
param avdApplicationSecurityGroupCustomName string = 'asg-app1-dev-use2-001'

@maxLength(64)
@description('Optional. AVD workspace custom name. (Default: vdws-app1-dev-use2-001)')
param avdWorkSpaceCustomName string = 'vdws-app1-dev-use2-001'

@maxLength(64)
@description('Optional. AVD workspace custom friendly (Display) name. (Default: App1 - Dev - East US 2 - 001)')
param avdWorkSpaceCustomFriendlyName string = 'App1 - Dev - East US 2 - 001'

@maxLength(64)
@description('Optional. AVD host pool custom name. (Default: vdpool-app1-dev-use2-001)')
param avdHostPoolCustomName string = 'vdpool-app1-dev-use2-001'

@maxLength(64)
@description('Optional. AVD host pool custom friendly (Display) name. (Default: App1 - East US - Dev - 001)')
param avdHostPoolCustomFriendlyName string = 'App1 - Dev - East US 2 - 001'

@maxLength(64)
@description('Optional. AVD scaling plan custom name. (Default: vdscaling-app1-dev-use2-001)')
param avdScalingPlanCustomName string = 'vdscaling-app1-dev-use2-001'

@maxLength(64)
@description('Optional. AVD desktop application group custom name. (Default: vdag-desktop-app1-dev-use2-001)')
param avdApplicationGroupCustomNameDesktop string = 'vdag-desktop-app1-dev-use2-001'

@maxLength(64)
@description('Optional. AVD desktop application group custom friendly (Display) name. (Default: Desktops - App1 - East US - Dev - 001)')
param avdApplicationGroupCustomFriendlyName string = 'Desktops - App1 - Dev - East US 2 - 001'

@maxLength(64)
@description('Optional. AVD remote application group custom name. (Default: vdag-rapp-app1-dev-use2-001)')
param avdApplicationGroupCustomNameRapp string = 'vdag-rapp-app1-dev-use2-001'

@maxLength(64)
@description('Optional. AVD remote application group custom name. (Default: Remote apps - App1 - East US - 001)')
param avdApplicationGroupCustomFriendlyNameRapp string = 'Remote apps - App1 - Dev - East US 2 - 001'

@maxLength(11)
@description('Optional. AVD session host prefix custom name. (Default: vmapp1duse2)')
param avdSessionHostCustomNamePrefix string = 'vmapp1duse2'

@maxLength(9)
@description('Optional. AVD availability set custom name. (Default: avail)')
param avdAvailabilitySetCustomNamePrefix string = 'avail'

@maxLength(2)
@description('Optional. AVD FSLogix and MSIX app attach storage account prefix custom name. (Default: st)')
param storageAccountPrefixCustomName string = 'st'

@description('Optional. FSLogix file share name. (Default: fslogix-pc-app1-dev-001)')
param fslogixFileShareCustomName string = 'fslogix-pc-app1-dev-use2-001'

@description('Optional. MSIX file share name. (Default: msix-app1-dev-001)')
param msixFileShareCustomName string = 'msix-app1-dev-use2-001'

//@maxLength(64)
//@description('Optional. AVD fslogix storage account office container file share prefix custom name. (Default: fslogix-oc-app1-dev-001)')
//param avdFslogixOfficeContainerFileShareCustomName string = 'fslogix-oc-app1-dev-001'

@maxLength(5)
@description('Optional. AVD keyvault prefix custom name. (Default: kv)')
param avdWrklKvPrefixCustomName string = 'kv'

@maxLength(6)
@description('Optional. AVD disk encryption set custom name. (Default: des-zt)')
param ztDiskEncryptionSetCustomNamePrefix string = 'des-zt'

@maxLength(5)
@description('Optional. AVD managed identity for zero trust to encrypt managed disks using a customer managed key.  (Default: id-zt)')
param ztManagedIdentityCustomName string = 'id-zt'

@maxLength(5)
@description('Optional. AVD key vault name custom name for zero trust (Default: kv-zt)')
param ztKvPrefixCustomName string = 'kv-zt'

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
var varDeploymentPrefixLowercase = toLower(deploymentPrefix)
var varDeploymentEnvironmentLowercase = toLower(deploymentEnvironment)
var varDeploymentEnvironmentComputeStorage = (deploymentEnvironment == 'Dev') ? 'd': ((deploymentEnvironment == 'Test') ? 't' : ((deploymentEnvironment == 'Prod') ? 'p' : ''))
var varNamingUniqueStringFourChar = take('${uniqueString(avdWorkloadSubsId, varDeploymentPrefixLowercase, time)}', 4)
var varSessionHostLocationAcronym = varLocations[varSessionHostLocationLowercase].acronym
var varManagementPlaneLocationAcronym = varLocations[varManagementPlaneLocationLowercase].acronym
var varLocations = loadJsonContent('../variables/locations.json')
var varTimeZoneSessionHosts = varLocations[varSessionHostLocationLowercase].timeZone
var varTimeZoneManagementPlane = varLocations[varManagementPlaneLocationLowercase].timeZone
var varManagementPlaneNamingStandard = '${varDeploymentPrefixLowercase}-${varDeploymentEnvironmentLowercase}-${varManagementPlaneLocationAcronym}'
var varComputeStorageResourcesNamingStandard = '${varDeploymentPrefixLowercase}-${varDeploymentEnvironmentLowercase}-${varSessionHostLocationAcronym}'
var varDiskEncryptionSetName = avdUseCustomNaming ? '${ztDiskEncryptionSetCustomNamePrefix}-${varComputeStorageResourcesNamingStandard}-001' : 'des-zt-${varComputeStorageResourcesNamingStandard}-001'
var varZtManagedIdentityName = avdUseCustomNaming ? '${ztManagedIdentityCustomName}-${varComputeStorageResourcesNamingStandard}-001' : 'id-zt-${varComputeStorageResourcesNamingStandard}-001'
var varSessionHostLocationLowercase = toLower(replace(avdSessionHostLocation, ' ', ''))
var varManagementPlaneLocationLowercase = toLower(replace(avdManagementPlaneLocation, ' ', ''))
var varServiceObjectsRgName = avdUseCustomNaming ? avdServiceObjectsRgCustomName : 'rg-avd-${varManagementPlaneNamingStandard}-service-objects' // max length limit 90 characters
var varNetworkObjectsRgName = avdUseCustomNaming ? avdNetworkObjectsRgCustomName : 'rg-avd-${varComputeStorageResourcesNamingStandard}-network' // max length limit 90 characters
var varComputeObjectsRgName = avdUseCustomNaming ? avdComputeObjectsRgCustomName : 'rg-avd-${varComputeStorageResourcesNamingStandard}-pool-compute' // max length limit 90 characters
var varStorageObjectsRgName = avdUseCustomNaming ? avdStorageObjectsRgCustomName : 'rg-avd-${varComputeStorageResourcesNamingStandard}-storage' // max length limit 90 characters
var varMonitoringRgName = avdUseCustomNaming ? avdMonitoringRgCustomName : 'rg-avd-${varDeploymentEnvironmentLowercase}-${varManagementPlaneLocationAcronym}-monitoring' // max length limit 90 characters
//var varAvdSharedResourcesRgName = 'rg-${varAvdSessionHostLocationAcronym}-avd-shared-resources'
var varVnetName = avdUseCustomNaming ? avdVnetworkCustomName : 'vnet-${varComputeStorageResourcesNamingStandard}-001'
var varHubVnetName = (createAvdVnet && !empty(existingHubVnetResourceId)) ? split(existingHubVnetResourceId, '/')[8] : ''
var varVnetPeeringName = 'peer-${varHubVnetName}' 
var varRemoteVnetPeeringName = 'peer-${varVnetName}'
var varVnetAvdSubnetName = avdUseCustomNaming ? avdVnetworkSubnetCustomName : 'snet-avd-${varComputeStorageResourcesNamingStandard}-001'
var varVnetPrivateEndpointSubnetName = avdUseCustomNaming ? privateEndpointVnetworkSubnetCustomName : 'snet-pe-${varComputeStorageResourcesNamingStandard}-001'
var varAvdNetworksecurityGroupName = avdUseCustomNaming ? avdNetworksecurityGroupCustomName : 'nsg-avd-${varComputeStorageResourcesNamingStandard}-001'
var varPrivateEndpointNetworksecurityGroupName = avdUseCustomNaming ? privateEndpointNetworksecurityGroupCustomName : 'nsg-pe-${varComputeStorageResourcesNamingStandard}-001'
var varAvdRouteTableName = avdUseCustomNaming ? avdRouteTableCustomName : 'route-avd-${varComputeStorageResourcesNamingStandard}-001'
var varPrivateEndpointRouteTableName = avdUseCustomNaming ? privateEndpointRouteTableCustomName : 'route-pe-${varComputeStorageResourcesNamingStandard}-001'
var varApplicationSecurityGroupName = avdUseCustomNaming ? avdApplicationSecurityGroupCustomName : 'asg-${varComputeStorageResourcesNamingStandard}-001'
var varWorkSpaceName = avdUseCustomNaming ? avdWorkSpaceCustomName : 'vdws-${varManagementPlaneNamingStandard}-001'
var varWorkSpaceFriendlyName = avdUseCustomNaming ? avdWorkSpaceCustomFriendlyName : 'Workspace ${deploymentPrefix} ${deploymentEnvironment} ${avdManagementPlaneLocation} 001'
var varHostPoolName = avdUseCustomNaming ? avdHostPoolCustomName : 'vdpool-${varManagementPlaneNamingStandard}-001'
var varHostFriendlyName = avdUseCustomNaming ? avdHostPoolCustomFriendlyName : 'Hostpool ${deploymentPrefix} ${deploymentEnvironment} ${avdManagementPlaneLocation} 001'
var varApplicationGroupNameDesktop = avdUseCustomNaming ? avdApplicationGroupCustomNameDesktop : 'vdag-desktop-${varManagementPlaneNamingStandard}-001'
var varApplicationGroupFriendlyName = avdUseCustomNaming ? avdApplicationGroupCustomFriendlyName : 'Desktops ${deploymentPrefix} ${deploymentEnvironment} ${avdManagementPlaneLocation} 001'
var varApplicationGroupNameRapp = avdUseCustomNaming ? avdApplicationGroupCustomNameRapp : 'vdag-rapp-${varManagementPlaneNamingStandard}-001'
var varApplicationGroupFriendlyNameRapp = avdUseCustomNaming ? avdApplicationGroupCustomFriendlyNameRapp : 'Apps ${deploymentPrefix} ${deploymentEnvironment} ${avdManagementPlaneLocation} 001'
var varScalingPlanName = avdUseCustomNaming ? avdScalingPlanCustomName : 'vdscaling-${varManagementPlaneNamingStandard}-001'
var varScalingPlanExclusionTag = 'Exclude-${varScalingPlanName}'
var varScalingPlanWeekdaysScheduleName = 'Weekdays-${varManagementPlaneNamingStandard}'
var varScalingPlanWeekendScheduleName = 'Weekend-${varManagementPlaneNamingStandard}'
var varWrklKvName = avdUseCustomNaming ? '${avdWrklKvPrefixCustomName}-${varComputeStorageResourcesNamingStandard}-${varNamingUniqueStringFourChar}' : 'kv-${varComputeStorageResourcesNamingStandard}-${varNamingUniqueStringFourChar}' // max length limit 24 characters
var varWrklKvPrivateEndpointName = 'pe-${varWrklKvName}-vault'
var varSessionHostNamePrefix = avdUseCustomNaming ? avdSessionHostCustomNamePrefix : 'vm${varDeploymentPrefixLowercase}${varDeploymentEnvironmentComputeStorage}${varSessionHostLocationAcronym}'
var varAvailabilitySetNamePrefix = avdUseCustomNaming ? '${avdAvailabilitySetCustomNamePrefix}-${varComputeStorageResourcesNamingStandard}' : 'avail-${varComputeStorageResourcesNamingStandard}'
var varStorageManagedIdentityName = 'id-storage-${varComputeStorageResourcesNamingStandard}-001'
var varFslogixFileShareName = avdUseCustomNaming ? fslogixFileShareCustomName : 'fslogix-pc-${varDeploymentPrefixLowercase}-${varDeploymentEnvironmentLowercase}-${varSessionHostLocationAcronym}-001'
var varMsixFileShareName = avdUseCustomNaming ? msixFileShareCustomName : 'msix-pc-${varDeploymentPrefixLowercase}-${varDeploymentEnvironmentLowercase}-${varSessionHostLocationAcronym}-001'
var varFslogixStorageName = avdUseCustomNaming ? '${storageAccountPrefixCustomName}fsl${varDeploymentPrefixLowercase}${varDeploymentEnvironmentComputeStorage}${varNamingUniqueStringFourChar}' : 'stfsl${varDeploymentPrefixLowercase}${varDeploymentEnvironmentComputeStorage}${varNamingUniqueStringFourChar}'
var varMsixStorageName = avdUseCustomNaming ? '${storageAccountPrefixCustomName}msx${varDeploymentPrefixLowercase}${varDeploymentEnvironmentComputeStorage}${varNamingUniqueStringFourChar}' : 'stmsx${varDeploymentPrefixLowercase}${varDeploymentEnvironmentComputeStorage}${varNamingUniqueStringFourChar}'
//var varAvdMsixStorageName = deployAvdMsixStorageAzureFiles.outputs.storageAccountName
var varManagementVmName = 'vmmgmt${varDeploymentPrefixLowercase}${varDeploymentEnvironmentComputeStorage}${varSessionHostLocationAcronym}'
//var varAvdWrklStoragePrivateEndpointName = 'pe-stavd${varDeploymentPrefixLowercase}${varAvdNamingUniqueStringSixChar}-file'
var varAlaWorkspaceName = avdUseCustomNaming ? avdAlaWorkspaceCustomName : 'log-avd-${varDeploymentEnvironmentLowercase}-${varManagementPlaneLocationAcronym}' //'log-avd-${varAvdComputeStorageResourcesNamingStandard}-${varAvdNamingUniqueStringSixChar}'
var varZtKvName = avdUseCustomNaming ? '${ztKvPrefixCustomName}-${varComputeStorageResourcesNamingStandard}-${varNamingUniqueStringFourChar}' : 'kv-zt-${varComputeStorageResourcesNamingStandard}-${varNamingUniqueStringFourChar}' // max length limit 24 characters
var varZtKvPrivateEndpointName = 'pe-${varZtKvName}-vault'
//
var varFsLogixScriptArguments = (avdIdentityServiceProvider == 'AAD') ? '-volumeshare ${varFslogixSharePath} -storageAccountName ${varFslogixStorageName} -identityDomainName ${avdIdentityDomainName}' : '-volumeshare ${varFslogixSharePath}'
var varFslogixSharePath = '\\\\${varFslogixStorageName}.file.${environment().suffixes.storage}\\${varFslogixFileShareName}'
var varBaseScriptUri = 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/'
var varFslogixScriptUri = (avdIdentityServiceProvider == 'AAD') ? '${varBaseScriptUri}scripts/Set-FSLogixRegKeysAAD.ps1' : '${varBaseScriptUri}scripts/Set-FSLogixRegKeys.ps1'
var varFsLogixScript = (avdIdentityServiceProvider == 'AAD') ? './Set-FSLogixRegKeysAad.ps1' : './Set-FSLogixRegKeys.ps1'
var varAvdAgentPackageLocation = 'https://wvdportalstorageblob.blob.${environment().suffixes.storage}/galleryartifacts/Configuration_09-08-2022.zip'
var varDiskEncryptionKeyExpirationInEpoch = dateTimeToEpoch(dateTimeAdd(time, 'P${string(diskEncryptionKeyExpirationInDays)}D'))
var varCreateStorageDeployment = (createAvdFslogixDeployment || createMsixDeployment == true) ? true : false
var varFslogixStorageSku = avdUseAvailabilityZones ? '${fslogixStoragePerformance}_ZRS' : '${fslogixStoragePerformance}_LRS'
var varMsixStorageSku = avdUseAvailabilityZones ? '${msixStoragePerformance}_ZRS' : '${msixStoragePerformance}_LRS'
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
    winServer_2022_datacenter_core: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-core'
        version: 'latest'
    }
    winServer_2022_datacenter_azure_edition_core: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition-core'
        version: 'latest'
    }
    winServer_2022_Datacenter_core_smalldisk_g2: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-core-smalldisk-g2'
        version: 'latest'
    }
}
var varStorageAccountContributorRoleId = '17d1049b-9a84-46fb-8f53-869881c3d3ab'
var varReaderRoleId = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
var varStorageSmbShareContributorRoleId = '0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb'
var varDesktopVirtualizationPowerOnContributorRoleId = '489581de-a3bd-480d-9518-53dea7416b33'
var varDesktopVirtualizationPowerOnOffContributorRoleId = '40c5ff49-9181-41f8-ae61-143b0e78555e'
var varStorageAzureFilesDscAgentPackageLocation = 'https://github.com/Azure/avdaccelerator/raw/main/workload/scripts/DSCStorageScripts.zip'
var varTempResourcesCleanUpDscAgentPackageLocation = 'https://github.com/Azure/avdaccelerator/raw/main/workload/scripts/postDeploymentTempResourcesCleanUp.zip'
var varStorageToDomainScriptUri = '${varBaseScriptUri}scripts/Manual-DSC-Storage-Scripts.ps1'
var varPostDeploymentTempResuorcesCleanUpScriptUri = '${varBaseScriptUri}scripts/postDeploymentTempResuorcesCleanUp.ps1'
var varStorageToDomainScript = './Manual-DSC-Storage-Scripts.ps1'
var varPostDeploymentTempResuorcesCleanUpScript = './PostDeploymentTempResuorcesCleanUp.ps1'
var varOuStgPath = !empty(storageOuPath) ? '"${storageOuPath}"' : '"${varDefaultStorageOuPath}"'
var varDefaultStorageOuPath = (avdIdentityServiceProvider == 'AADDS') ? 'AADDC Computers' : 'Computers'
var varStorageCustomOuPath = !empty(storageOuPath) ? 'true' : 'false'
var varCreateOuForStorageString = string(createOuForStorage)
var varAllDnsServers = '${customDnsIps},168.63.129.16'
var varDnsServers = empty(customDnsIps) ? [] : (split(varAllDnsServers, ','))
var varApplicationGroupIdentitiesIds = !empty(avdApplicationGroupIdentitiesIds) ? (split(avdApplicationGroupIdentitiesIds, ',')) : []
var varCreateVnetPeering = !empty(existingHubVnetResourceId) ? true : false
// Resource tagging
// Tag Exclude-${varAvdScalingPlanName} is used by scaling plans to exclude session hosts from scaling. Exmaple: Exclude-vdscal-eus2-app1-dev-001
var varCustomResourceTags = createResourceTags ? {
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
} : {}
var varAllComputeStorageTags = {
    DomainName: avdIdentityDomainName
    IdentityServiceProvider: avdIdentityServiceProvider
}
var varAvdDefaultTags = {
    'cm-resource-parent': '/subscriptions/${avdWorkloadSubsId}}/resourceGroups/${varServiceObjectsRgName}/providers/Microsoft.DesktopVirtualization/hostpools/${varHostPoolName}'
    Environment: deploymentEnvironment
    ServiceWorkload: 'AVD'
    CreationTimeUTC: time
}
//
var varTelemetryId = 'pid-2ce4228c-d72c-43fb-bb5b-cd8f3ba2138e-${avdManagementPlaneLocation}'
var verResourceGroups = [
    {
        purpose: 'Service-Objects'
        name: varServiceObjectsRgName
        location: avdManagementPlaneLocation
        enableDefaultTelemetry: false
        tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : union(varAvdDefaultTags, varAllComputeStorageTags)
    }
    {
        purpose: 'Pool-Compute'
        name: varComputeObjectsRgName
        location: avdSessionHostLocation
        enableDefaultTelemetry: false
        tags: createResourceTags ? union(varAllComputeStorageTags, varAvdDefaultTags) : union(varAvdDefaultTags, varAllComputeStorageTags)
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
module baselineNetworkResourceGroup '../../carml/1.3.0/Microsoft.Resources/resourceGroups/deploy.bicep' = if (createAvdVnet || createPrivateDnsZones) {
    scope: subscription(avdWorkloadSubsId)
    name: 'Deploy-Network-RG-${time}'
    params: {
        name: varNetworkObjectsRgName
        location: avdSessionHostLocation
        enableDefaultTelemetry: false
        tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
    }
    dependsOn: avdDeployMonitoring ? [
        monitoringDiagnosticSettings
    ] : []
}

// Compute, service objects
module baselineResourceGroups '../../carml/1.3.0/Microsoft.Resources/resourceGroups/deploy.bicep' = [for resourceGroup in verResourceGroups: {
    scope: subscription(avdWorkloadSubsId)
    name: '${resourceGroup.purpose}-${time}'
    params: {
        name: resourceGroup.name
        location: resourceGroup.location
        enableDefaultTelemetry: resourceGroup.enableDefaultTelemetry
        tags: resourceGroup.tags
    }
    dependsOn: avdDeployMonitoring ? [
        monitoringDiagnosticSettings
    ] : []
}]

// Storage.
module baselineStorageResourceGroup '../../carml/1.3.0/Microsoft.Resources/resourceGroups/deploy.bicep' = if (varCreateStorageDeployment) {
    scope: subscription(avdWorkloadSubsId)
    name: 'Storage-RG-${time}'
    params: {
        name: varStorageObjectsRgName
        location: avdSessionHostLocation
        enableDefaultTelemetry: false
        tags: createResourceTags ? union(varAllComputeStorageTags, varAvdDefaultTags) : union(varAvdDefaultTags, varAllComputeStorageTags)
    }
    dependsOn: avdDeployMonitoring ? [
        monitoringDiagnosticSettings
    ] : []
}

// Azure Policies for monitoring Diagnostic settings. Performance couunters on new or existing Log Analytics workspace. New workspace if needed.
module monitoringDiagnosticSettings './modules/avdInsightsMonitoring/deploy.bicep' = if (avdDeployMonitoring) {
    name: 'Monitoring-${time}'
    params: {
        managementPlaneLocation: avdManagementPlaneLocation
        deployAlaWorkspace: deployAlaWorkspace
        deployCustomPolicyMonitoring: deployCustomPolicyMonitoring
        alaWorkspaceId: deployAlaWorkspace ? '' : alaExistingWorkspaceResourceId
        monitoringRgName: varMonitoringRgName
        alaWorkspaceName: deployAlaWorkspace ? varAlaWorkspaceName : ''
        alaWorkspaceDataRetention: avdAlaWorkspaceDataRetention
        workloadSubsId: avdWorkloadSubsId
        tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
    }
    dependsOn: []
}

// Networking.
module networking './modules/networking/deploy.bicep' = if (createAvdVnet || createPrivateDnsZones || avdDeploySessionHosts || createAvdFslogixDeployment || createMsixDeployment) {
    name: 'Networking-${time}'
    params: {
        createVnet: createAvdVnet
        deployAsg: (avdDeploySessionHosts || createAvdFslogixDeployment || createMsixDeployment) ? true : false
        existingPeSubnetResourceId: existingVnetPrivateEndpointSubnetResourceId
        existingAvdSubnetResourceId: existingVnetAvdSubnetResourceId
        createPrivateDnsZones: createPrivateDnsZones
        applicationSecurityGroupName: varApplicationSecurityGroupName 
        computeObjectsRgName: varComputeObjectsRgName
        networkObjectsRgName: varNetworkObjectsRgName
        avdNetworksecurityGroupName: varAvdNetworksecurityGroupName
        privateEndpointNetworksecurityGroupName: varPrivateEndpointNetworksecurityGroupName
        avdRouteTableName: varAvdRouteTableName
        privateEndpointRouteTableName: varPrivateEndpointRouteTableName
        vnetAddressPrefixes: avdVnetworkAddressPrefixes
        vnetName: varVnetName
        vnetPeeringName: varVnetPeeringName
        remoteVnetPeeringName: varRemoteVnetPeeringName
        vnetAvdSubnetName: varVnetAvdSubnetName
        vnetPrivateEndpointSubnetName: varVnetPrivateEndpointSubnetName
        createVnetPeering: varCreateVnetPeering
        deployPrivateEndpointSubnet: (deployPrivateEndpointKeyvaultStorage == true) ? true : false //adding logic that will be used when also including AVD control plane PEs
        vNetworkGatewayOnHub: vNetworkGatewayOnHub
        existingHubVnetResourceId: existingHubVnetResourceId
        sessionHostLocation: avdSessionHostLocation
        vnetAvdSubnetAddressPrefix: vNetworkAvdSubnetAddressPrefix
        vnetPrivateEndpointSubnetAddressPrefix: vNetworkPrivateEndpointSubnetAddressPrefix
        workloadSubsId: avdWorkloadSubsId
        dnsServers: varDnsServers
        tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
        alaWorkspaceResourceId: avdDeployMonitoring ? (deployAlaWorkspace ? monitoringDiagnosticSettings.outputs.avdAlaWorkspaceResourceId : alaExistingWorkspaceResourceId) : ''
        diagnosticLogsRetentionInDays: avdAlaWorkspaceDataRetention
    }
    dependsOn: [
        baselineNetworkResourceGroup
        monitoringDiagnosticSettings
        baselineResourceGroups
    ]
}

// AVD management plane.
module managementPLane './modules/avdManagementPlane/deploy.bicep' = {
    name: 'AVD-MGMT-Plane-${time}'
    params: {
        applicationGroupNameDesktop: varApplicationGroupNameDesktop
        applicationGroupFriendlyNameDesktop: varApplicationGroupFriendlyName
        workSpaceName: varWorkSpaceName
        osImage: avdOsImage
        workSpaceFriendlyName: varWorkSpaceFriendlyName
        applicationGroupNameRapp: varApplicationGroupNameRapp
        applicationGroupFriendlyNameRapp: varApplicationGroupFriendlyNameRapp
        deployRappGroup: avdDeployRappGroup
        computeTimeZone: varTimeZoneSessionHosts
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
        startVmOnConnect: (avdHostPoolType == 'Pooled') ? avdDeployScalingPlan : avdStartVmOnConnect
        workloadSubsId: avdWorkloadSubsId
        identityServiceProvider: avdIdentityServiceProvider
        applicationGroupIdentitiesIds: varApplicationGroupIdentitiesIds
        applicationGroupIdentityType: avdApplicationGroupIdentityType
        tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
        alaWorkspaceResourceId: avdDeployMonitoring ? (deployAlaWorkspace ? monitoringDiagnosticSettings.outputs.avdAlaWorkspaceResourceId : alaExistingWorkspaceResourceId) : ''
        diagnosticLogsRetentionInDays: avdAlaWorkspaceDataRetention
    }
    dependsOn: [
        baselineResourceGroups
        managedIdentitiesRoleAssign
        monitoringDiagnosticSettings
    ]
}

// Identity: managed identities and role assignments.
module managedIdentitiesRoleAssign './modules/identity/deploy.bicep' = {
    name: 'Identities-And-RoleAssign-${time}'
    params: {
        computeObjectsRgName: varComputeObjectsRgName
        enterpriseAppObjectId: avdEnterpriseAppObjectId
        deployScalingPlan: avdDeployScalingPlan
        sessionHostLocation: avdSessionHostLocation
        serviceObjectsRgName: varServiceObjectsRgName
        storageObjectsRgName: varStorageObjectsRgName
        workloadSubsId: avdWorkloadSubsId
        storageManagedIdentityName: varStorageManagedIdentityName
        readerRoleId: varReaderRoleId
        storageSmbShareContributorRoleId: varStorageSmbShareContributorRoleId
        enableStartVmOnConnect: avdStartVmOnConnect
        identityServiceProvider: avdIdentityServiceProvider
        storageAccountContributorRoleId: varStorageAccountContributorRoleId
        createStorageDeployment: varCreateStorageDeployment
        desktopVirtualizationPowerOnContributorRoleId: varDesktopVirtualizationPowerOnContributorRoleId
        desktopVirtualizationPowerOnOffContributorRoleId: varDesktopVirtualizationPowerOnOffContributorRoleId
        applicationGroupIdentitiesIds: varApplicationGroupIdentitiesIds
        tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
    }
    dependsOn: [
        baselineResourceGroups
        baselineStorageResourceGroup
        monitoringDiagnosticSettings
    ]
}

// Zero trust.
module zeroTrust './modules/zeroTrust/deploy.bicep' = if (diskZeroTrust) {
    name: 'Zero-Trust-${time}'
    params: {
        location: avdSessionHostLocation
        subscriptionId: avdWorkloadSubsId
        diskZeroTrust: diskZeroTrust
        serviceObjectsRgName: varServiceObjectsRgName
        managedIdentityName: varZtManagedIdentityName
        diskEncryptionKeyExpirationInDays: diskEncryptionKeyExpirationInDays
        diskEncryptionKeyExpirationInEpoch: varDiskEncryptionKeyExpirationInEpoch
        diskEncryptionSetName: varDiskEncryptionSetName
        ztKvName: varZtKvName
        ztKvPrivateEndpointName: varZtKvPrivateEndpointName
        privateEndpointsubnetResourceId: createAvdVnet ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetPrivateEndpointSubnetName}' : existingVnetPrivateEndpointSubnetResourceId
        deployPrivateEndpointKeyvaultStorage: deployPrivateEndpointKeyvaultStorage
        keyVaultprivateDNSResourceId: createPrivateDnsZones ? networking.outputs.KeyVaultDnsZoneResourceId : avdVnetPrivateDnsZoneKeyvaultId
        tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
    }
    dependsOn: [
        baselineResourceGroups
        baselineStorageResourceGroup
        monitoringDiagnosticSettings
        managedIdentitiesRoleAssign
    ]
}

// Key vault.
module wrklKeyVault '../../carml/1.3.0/Microsoft.KeyVault/vaults/deploy.bicep' = {
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
        privateEndpoints: deployPrivateEndpointKeyvaultStorage ? [
            {
                name: varWrklKvPrivateEndpointName
                subnetResourceId: createAvdVnet ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetPrivateEndpointSubnetName}' : existingVnetPrivateEndpointSubnetResourceId
                customNetworkInterfaceName: 'nic-01-${varWrklKvPrivateEndpointName}'
                service: 'vault'
                privateDnsZoneGroup: {
                    privateDNSResourceIds: [
                        createPrivateDnsZones ? networking.outputs.KeyVaultDnsZoneResourceId : avdVnetPrivateDnsZoneKeyvaultId
                    ]
                }
            }
        ] : []
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
        tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags

    }
    dependsOn: [
        baselineResourceGroups
        monitoringDiagnosticSettings
    ]
}

// Management VM deployment
module managementVm './modules/storageAzureFiles/.bicep/managementVm.bicep' = if (createAvdFslogixDeployment || createMsixDeployment) {
    name: 'Storage-MGMT-VM-${time}'
    params: {
        diskEncryptionSetResourceId: diskZeroTrust ? zeroTrust.outputs.ztDiskEncryptionSetResourceId : ''
        identityServiceProvider: avdIdentityServiceProvider
        managementVmName: varManagementVmName
        computeTimeZone: varTimeZoneSessionHosts
        applicationSecurityGroupResourceId: (avdDeploySessionHosts || createAvdFslogixDeployment || createMsixDeployment) ? '${networking.outputs.applicationSecurityGroupResourceId}' : ''
        domainJoinUserName: avdDomainJoinUserName
        wrklKvName: varWrklKvName
        serviceObjectsRgName: varServiceObjectsRgName
        identityDomainName: avdIdentityDomainName
        //imageTemplateDefinitionId: avdImageTemplateDefinitionId
        sessionHostOuPath: avdOuPath
        sessionHostDiskType: avdSessionHostDiskType
        sessionHostLocation: avdSessionHostLocation
        sessionHostsSize: avdSessionHostsSize
        avdSubnetId: createAvdVnet ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetAvdSubnetName}' : existingVnetAvdSubnetResourceId
        enableAcceleratedNetworking: enableAcceleratedNetworking
        securityType: securityType == 'Standard' ? '' : securityType
        secureBootEnabled: secureBootEnabled
        vTpmEnabled: vTpmEnabled
        vmLocalUserName: avdVmLocalUserName
        workloadSubsId: avdWorkloadSubsId
        encryptionAtHost: diskZeroTrust
        storageManagedIdentityResourceId: varCreateStorageDeployment ? managedIdentitiesRoleAssign.outputs.managedIdentityResourceId : ''
        marketPlaceGalleryWindowsManagementVm: varMarketPlaceGalleryWindows[managementVmOsImage]
        tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
    }
    dependsOn: [
        baselineStorageResourceGroup
        networking
        wrklKeyVault
    ]
}

// FSLogix storage.
module fslogixAzureFilesStorage './modules/storageAzureFiles/deploy.bicep' = if (createAvdFslogixDeployment) {
    name: 'Storage-FSLogix-${time}'
    params: {
        storagePurpose: 'fslogix'
        fileShareName: varFslogixFileShareName
        fileShareMultichannel: (fslogixStoragePerformance == 'Premium') ? true : false
        storageSku: varFslogixStorageSku
        fileShareQuotaSize: fslogixFileShareQuotaSize
        storageAccountName: varFslogixStorageName
        storageToDomainScript: varStorageToDomainScript
        storageToDomainScriptUri: varStorageToDomainScriptUri
        identityServiceProvider: avdIdentityServiceProvider
        dscAgentPackageLocation: varStorageAzureFilesDscAgentPackageLocation
        storageCustomOuPath: varStorageCustomOuPath
        managementVmName: varManagementVmName
        deployPrivateEndpoint: deployPrivateEndpointKeyvaultStorage
        ouStgPath: varOuStgPath
        createOuForStorageString: varCreateOuForStorageString
        managedIdentityClientId: varCreateStorageDeployment ? managedIdentitiesRoleAssign.outputs.managedIdentityClientId : ''
        domainJoinUserName: avdDomainJoinUserName
        wrklKvName: varWrklKvName
        serviceObjectsRgName: varServiceObjectsRgName
        identityDomainName: avdIdentityDomainName
        identityDomainGuid: identityDomainGuid
        sessionHostLocation: avdSessionHostLocation
        storageObjectsRgName: varStorageObjectsRgName
        privateEndpointSubnetId: createAvdVnet ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetPrivateEndpointSubnetName}' : existingVnetPrivateEndpointSubnetResourceId
        vnetPrivateDnsZoneFilesId: createPrivateDnsZones ? networking.outputs.azureFilesDnsZoneResourceId : avdVnetPrivateDnsZoneFilesId
        workloadSubsId: avdWorkloadSubsId
        tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
        alaWorkspaceResourceId: avdDeployMonitoring ? (deployAlaWorkspace ? monitoringDiagnosticSettings.outputs.avdAlaWorkspaceResourceId : alaExistingWorkspaceResourceId) : ''
        diagnosticLogsRetentionInDays: avdAlaWorkspaceDataRetention
    }
    dependsOn: [
        baselineStorageResourceGroup
        networking
        wrklKeyVault
        managementVm
        monitoringDiagnosticSettings
    ]
}

// MSIX storage.
module msixAzureFilesStorage './modules/storageAzureFiles/deploy.bicep' = if (createMsixDeployment) {
    name: 'Storage-MSIX-${time}'
    params: {
        storagePurpose: 'msix'
        fileShareName: varMsixFileShareName
        fileShareMultichannel: (msixStoragePerformance == 'Premium') ? true : false
        storageSku: varMsixStorageSku
        fileShareQuotaSize: msixFileShareQuotaSize
        storageAccountName: varMsixStorageName
        storageToDomainScript: varStorageToDomainScript
        storageToDomainScriptUri: varStorageToDomainScriptUri
        identityServiceProvider: avdIdentityServiceProvider
        dscAgentPackageLocation: varStorageAzureFilesDscAgentPackageLocation
        storageCustomOuPath: varStorageCustomOuPath
        managementVmName: varManagementVmName
        deployPrivateEndpoint: deployPrivateEndpointKeyvaultStorage
        ouStgPath: varOuStgPath
        createOuForStorageString: varCreateOuForStorageString
        managedIdentityClientId: varCreateStorageDeployment ? managedIdentitiesRoleAssign.outputs.managedIdentityClientId : ''
        domainJoinUserName: avdDomainJoinUserName
        wrklKvName: varWrklKvName
        serviceObjectsRgName: varServiceObjectsRgName
        identityDomainName: avdIdentityDomainName
        identityDomainGuid: identityDomainGuid
        sessionHostLocation: avdSessionHostLocation
        storageObjectsRgName: varStorageObjectsRgName
        privateEndpointSubnetId: createAvdVnet ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetPrivateEndpointSubnetName}' : existingVnetPrivateEndpointSubnetResourceId
        vnetPrivateDnsZoneFilesId: createPrivateDnsZones ? networking.outputs.azureFilesDnsZoneResourceId : avdVnetPrivateDnsZoneFilesId
        workloadSubsId: avdWorkloadSubsId
        tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
        alaWorkspaceResourceId: avdDeployMonitoring ? (deployAlaWorkspace ? monitoringDiagnosticSettings.outputs.avdAlaWorkspaceResourceId : alaExistingWorkspaceResourceId) : ''
        diagnosticLogsRetentionInDays: avdAlaWorkspaceDataRetention
    }
    dependsOn: [
        fslogixAzureFilesStorage
        baselineStorageResourceGroup
        networking
        wrklKeyVault
        managementVm
        monitoringDiagnosticSettings
    ]
}

// Session hosts.
module sessionHosts './modules/avdSessionHosts/deploy.bicep' = if (avdDeploySessionHosts) {
    name: 'Session-Hosts-${time}'
    params: {
        diskEncryptionSetResourceId: diskZeroTrust ? zeroTrust.outputs.ztDiskEncryptionSetResourceId : ''
        avdAgentPackageLocation: varAvdAgentPackageLocation
        computeTimeZone: varTimeZoneSessionHosts
        applicationSecurityGroupResourceId: (avdDeploySessionHosts || createAvdFslogixDeployment || createMsixDeployment) ? '${networking.outputs.applicationSecurityGroupResourceId}' : ''
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
        subnetId: createAvdVnet ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetAvdSubnetName}' : existingVnetAvdSubnetResourceId
        createAvdVnet: createAvdVnet
        useAvailabilityZones: avdUseAvailabilityZones
        vmLocalUserName: avdVmLocalUserName
        workloadSubsId: avdWorkloadSubsId
        encryptionAtHost: diskZeroTrust
        createAvdFslogixDeployment: createAvdFslogixDeployment
        storageManagedIdentityResourceId: (varCreateStorageDeployment) ? managedIdentitiesRoleAssign.outputs.managedIdentityResourceId : ''
        fsLogixScript: varFsLogixScript
        fslogixScriptUri: varFslogixScriptUri
        fslogixSharePath: '\\\\${varFslogixStorageName}.file.${environment().suffixes.storage}\\${varFslogixFileShareName}'
        fsLogixScriptArguments: varFsLogixScriptArguments
        marketPlaceGalleryWindows: varMarketPlaceGalleryWindows[avdOsImage]
        useSharedImage: useSharedImage
        tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
        deployMonitoring: avdDeployMonitoring
        alaWorkspaceResourceId: avdDeployMonitoring ? (deployAlaWorkspace ? monitoringDiagnosticSettings.outputs.avdAlaWorkspaceResourceId : alaExistingWorkspaceResourceId) : ''
        diagnosticLogsRetentionInDays: avdAlaWorkspaceDataRetention
    }
    dependsOn: [
        fslogixAzureFilesStorage
        baselineResourceGroups
        networking
        wrklKeyVault
        monitoringDiagnosticSettings
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
