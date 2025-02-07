metadata name = 'AVD Accelerator - Baseline Deployment'
metadata description = 'AVD Accelerator - Deployment Baseline'
metadata owner = 'Azure/avdaccelerator'

targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@minLength(2)
@maxLength(4)
@sys.description('The name of the resource group to deploy. (Default: AVD1)')
param deploymentPrefix string = 'AVD1'

@allowed([
  'Dev' // Development
  'Test' // Test
  'Prod' // Production
])
@sys.description('The name of the resource group to deploy. (Default: Dev)')
param deploymentEnvironment string = 'Dev'

@maxValue(730)
@minValue(30)
@sys.description('This value is used to set the expiration date on the disk encryption key. (Default: 60)')
param diskEncryptionKeyExpirationInDays int = 60

@sys.description('Required. Location where to deploy compute services.')
param avdSessionHostLocation string

@sys.description('Required. Location where to deploy AVD management plane.')
param avdManagementPlaneLocation string

@sys.description('AVD workload subscription ID, multiple subscriptions scenario. (Default: "")')
param avdWorkloadSubsId string = ''

@sys.description('Azure Virtual Desktop Enterprise Application object ID. (Default: "")')
param avdEnterpriseAppObjectId string = ''

@sys.description('AVD session host local username.')
param avdVmLocalUserName string

@sys.description('AVD session host local password.')
@secure()
param avdVmLocalUserPassword string

@allowed([
  'ADDS' // Active Directory Domain Services
  'EntraDS' // Microsoft Entra Domain Services
  'EntraID' // Microsoft Entra ID Join
])
@sys.description('Required, The service providing domain services for Azure Virtual Desktop. (Default: ADDS)')
param avdIdentityServiceProvider string = 'ADDS'

@sys.description('Required, Eronll session hosts on Intune. (Default: false)')
param createIntuneEnrollment bool = false

@sys.description('Optional, Identity ID to grant RBAC role to access AVD application group and NTFS permissions. (Default: "")')
param securityPrincipalId string = ''

@sys.description('Optional, Identity name to grant RBAC role to access AVD application group and NTFS permissions. (Default: "")')
param securityPrincipalName string = ''

@sys.description('FQDN of on-premises AD domain, used for FSLogix storage configuration and NTFS setup. (Default: "")')
param identityDomainName string = 'none'

@sys.description('GUID of on-premises AD domain, used for FSLogix storage configuration and NTFS setup. (Default: "")')
param identityDomainGuid string = ''

@sys.description('AVD session host domain join user principal name. (Default: none)')
param avdDomainJoinUserName string = 'none'

@sys.description('AVD session host domain join password. (Default: none)')
@secure()
param avdDomainJoinUserPassword string = 'none'

@sys.description('OU path to join AVd VMs. (Default: "")')
param avdOuPath string = ''

@allowed([
  'Personal'
  'Pooled'
])
@sys.description('AVD host pool type. (Default: Pooled)')
param avdHostPoolType string = 'Pooled'

@sys.description('Optional. The type of preferred application group type, default to Desktop Application Group.')
@allowed([
  'Desktop'
  'RemoteApp'
])
param hostPoolPreferredAppGroupType string = 'Desktop'

@allowed([
  'Disabled' // Blocks public access and requires both clients and session hosts to use the private endpoints
  'Enabled' // Allow clients and session hosts to communicate over the public network
  'EnabledForClientsOnly' // Allows only clients to access AVD over public network
  'EnabledForSessionHostsOnly' // Allows only the session hosts to communicate over the public network
])
@sys.description('Enables or Disables public network access on the host pool. (Default: Enabled.)')
param hostPoolPublicNetworkAccess string = 'Enabled'

@allowed([
  'Disabled'
  'Enabled'
])
@sys.description('Default to Enabled. Enables or Disables public network access on the workspace.')
param workspacePublicNetworkAccess string = 'Enabled'

@allowed([
  'Automatic'
  'Direct'
])
@sys.description('AVD host pool type. (Default: Automatic)')
param avdPersonalAssignType string = 'Automatic'

@allowed([
  'BreadthFirst'
  'DepthFirst'
])
@sys.description('AVD host pool load balacing type. (Default: BreadthFirst)')
param avdHostPoolLoadBalancerType string = 'BreadthFirst'

@sys.description('AVD host pool maximum number of user sessions per session host. (Default: 8)')
param hostPoolMaxSessions int = 8

@sys.description('AVD host pool start VM on Connect. (Default: true)')
param avdStartVmOnConnect bool = true

@sys.description('AVD host pool Custom RDP properties. (Default: audiocapturemode:i:1;audiomode:i:0;drivestoredirect:s:;redirectclipboard:i:1;redirectcomports:i:1;redirectprinters:i:1;redirectsmartcards:i:1;screen mode id:i:2)')
param avdHostPoolRdpProperties string = 'audiocapturemode:i:1;audiomode:i:0;drivestoredirect:s:;redirectclipboard:i:1;redirectcomports:i:1;redirectprinters:i:1;redirectsmartcards:i:1;screen mode id:i:2'

@sys.description('AVD deploy scaling plan. (Default: true)')
param avdDeployScalingPlan bool = true

@sys.description('Create new virtual network. (Default: true)')
param createAvdVnet bool = true

@sys.description('Existing virtual network subnet for AVD. (Default: "")')
param existingVnetAvdSubnetResourceId string = ''

@sys.description('Existing virtual network subnet for private endpoints. (Default: "")')
param existingVnetPrivateEndpointSubnetResourceId string = ''

@sys.description('Existing hub virtual network for perring. (Default: "")')
param existingHubVnetResourceId string = ''

@sys.description('AVD virtual network address prefixes. (Default: 10.10.0.0/16)')
param avdVnetworkAddressPrefixes string = '10.10.0.0/16'

@sys.description('AVD virtual network subnet address prefix. (Default: 10.10.1.0/24)')
param vNetworkAvdSubnetAddressPrefix string = '10.10.1.0/24'

@sys.description('private endpoints virtual network subnet address prefix. (Default: 10.10.2.0/27)')
param vNetworkPrivateEndpointSubnetAddressPrefix string = '10.10.2.0/27'

@sys.description('custom DNS servers IPs. (Default: "")')
param customDnsIps string = ''

@sys.description('Deploy DDoS Network Protection for virtual network. (Default: true)')
param deployDDoSNetworkProtection bool = false

@sys.description('Deploy private endpoints for key vault and storage. (Default: true)')
param deployPrivateEndpointKeyvaultStorage bool = true

@sys.description('Deploys the private link for AVD. Requires resource provider registration or re-registration. (Default: false)')
param deployAvdPrivateLinkService bool = false

@sys.description('Create new  Azure private DNS zones for private endpoints. (Default: true)')
param createPrivateDnsZones bool = true

@sys.description('The ResourceID of the AVD Private DNS Zone for Connection. (privatelink.wvd.azure.com). Only required if createPrivateDNSZones is set to false.')
param avdVnetPrivateDnsZoneConnectionResourceId string = ''

@sys.description('The ResourceID of the AVD Private DNS Zone for Discovery. (privatelink-global.wvd.azure.com). Only required if createPrivateDNSZones is set to false.')
param avdVnetPrivateDnsZoneDiscoveryResourceId string = ''

@sys.description('Use existing Azure private DNS zone for Azure files privatelink.file.core.windows.net or privatelink.file.core.usgovcloudapi.net. (Default: "")')
param avdVnetPrivateDnsZoneFilesId string = ''

@sys.description('Use existing Azure private DNS zone for key vault privatelink.vaultcore.azure.net or privatelink.vaultcore.usgovcloudapi.net. (Default: "")')
param avdVnetPrivateDnsZoneKeyvaultId string = ''

@sys.description('Does the hub contains a virtual network gateway. (Default: false)')
param vNetworkGatewayOnHub bool = false

@sys.description('Deploy Fslogix setup. (Default: true)')
param createAvdFslogixDeployment bool = true

@sys.description('Deploy App Attach setup. (Default: false)')
param createAppAttachDeployment bool = false

@sys.description('Fslogix file share size. (Default: 1)')
param fslogixFileShareQuotaSize int = 1

@sys.description('App Attach file share size. (Default: 1)')
param appAttachFileShareQuotaSize int = 1

@sys.description('Deploy new session hosts. (Default: true)')
param avdDeploySessionHosts bool = true

@sys.description('Deploy VM GPU extension policies. (Default: false)')
param deployGpuPolicies bool = false

@sys.description('Deploy AVD monitoring resources and setings. (Default: false)')
param avdDeployMonitoring bool = false

@sys.description('Deploy AVD Azure log analytics workspace. (Default: true)')
param deployAlaWorkspace bool = true

@sys.description('Create and assign custom Azure Policy for diagnostic settings for the AVD Log Analytics workspace. (Default: false)')
param deployCustomPolicyMonitoring bool = false

@sys.description('AVD Azure log analytics workspace data retention. (Default: 90)')
param avdAlaWorkspaceDataRetention int = 90

@sys.description('Existing Azure log analytics workspace resource ID to connect to. (Default: "")')
param alaExistingWorkspaceResourceId string = ''

@minValue(1)
@maxValue(100)
@sys.description('Quantity of session hosts to deploy. (Default: 1)')
param avdDeploySessionHostsCount int = 1

@sys.description('The session host number to begin with for the deployment. This is important when adding virtual machines to ensure the names do not conflict. (Default: 0)')
param avdSessionHostCountIndex int = 0

@sys.description('When true VMs are distributed across availability zones, when set to false, VMs will be members of a new availability set. (Default: true)')
param availabilityZonesCompute bool = true

@sys.description('When true, Zone Redundant Storage (ZRS) is used, when set to false, Locally Redundant Storage (LRS) is used. (Default: false)')
param zoneRedundantStorage bool = false

// @sys.description('Deploys a VMSS Flex group and associates session hosts with it for availability purposes. (Default: true)')
// param deployVmssFlex bool = true

// @sys.description('Sets the number of fault domains for the availability set. (Default: 2)')
// param vmssFlatformFaultDomainCount int = 2

@allowed([
  'Standard'
  'Premium'
])
@sys.description('Storage account SKU for FSLogix storage. Recommended tier is Premium (Default: Premium)')
param fslogixStoragePerformance string = 'Premium'

@allowed([
  'Standard'
  'Premium'
])
@sys.description('Storage account SKU for App Attach storage. Recommended tier is Premium. (Default: Premium)')
param appAttachStoragePerformance string = 'Premium'

@sys.description('Enables a zero trust configuration on the session host disks. (Default: false)')
param diskZeroTrust bool = false

@sys.description('Session host VM size. (Default: Standard_D4ads_v5)')
param avdSessionHostsSize string = 'Standard_D4ads_v5'

@sys.description('OS disk type for session host. (Default: Premium_LRS)')
param avdSessionHostDiskType string = 'Premium_LRS'

@sys.description('Optional. Custom OS Disk Size.')
param customOsDiskSizeGb string = ''

@sys.description('''Enables accelerated Networking on the session hosts.
If using a Azure Compute Gallery Image, the Image Definition must have been configured with
the \'isAcceleratedNetworkSupported\' property set to \'true\'.
''')
param enableAcceleratedNetworking bool = true

@allowed([
  'Standard'
  'TrustedLaunch'
  'ConfidentialVM'
])
@sys.description('Specifies the securityType of the virtual machine. "ConfidentialVM" and "TrustedLaunch" require a Gen2 Image. (Default: TrustedLaunch)')
param securityType string = 'TrustedLaunch'

@sys.description('Specifies whether secure boot should be enabled on the virtual machine. This parameter is part of the UefiSettings. securityType should be set to TrustedLaunch or ConfidentialVM to enable UefiSettings. (Default: true)')
param secureBootEnabled bool = true

@sys.description('Specifies whether vTPM should be enabled on the virtual machine. This parameter is part of the UefiSettings. securityType should be set to TrustedLaunch or ConfidentialVM to enable UefiSettings. (Default: true)')
param vTpmEnabled bool = true

@allowed([
  'win10_22h2_g2'
  'win10_22h2_office_g2'
  'win11_22h2'
  'win11_22h2_office'
  'win11_23h2'
  'win11_23h2_office'
  'win11_24h2'
  'win11_24h2_office'
])
@sys.description('AVD OS image SKU. (Default: win11_23h2)')
param avdOsImage string = 'win11_23h2'

@sys.description('Management VM image SKU (Default: winServer_2022_Datacenter_smalldisk_g2)')
param managementVmOsImage string = 'winServer_2022_Datacenter_smalldisk_g2'

@sys.description('Set to deploy image from Azure Compute Gallery. (Default: false)')
param useSharedImage bool = false

@sys.description('Source custom image ID. (Default: "")')
param avdImageTemplateDefinitionId string = ''

@sys.description('OU name for Azure Storage Account. It is recommended to create a new AD Organizational Unit (OU) in AD and disable password expiration policy on computer accounts or service logon accounts accordingly.  (Default: "")')
param storageOuPath string = ''

// Custom Naming
// Input must followe resource naming rules on https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules
@sys.description('AVD resources custom naming. (Default: false)')
param avdUseCustomNaming bool = false

@maxLength(90)
@sys.description('AVD service resources resource group custom name. (Default: rg-avd-app1-dev-use2-service-objects)')
param avdServiceObjectsRgCustomName string = 'rg-avd-app1-dev-use2-service-objects'

@maxLength(90)
@sys.description('AVD network resources resource group custom name. (Default: rg-avd-app1-dev-use2-network)')
param avdNetworkObjectsRgCustomName string = 'rg-avd-app1-dev-use2-network'

@maxLength(90)
@sys.description('AVD network resources resource group custom name. (Default: rg-avd-app1-dev-use2-pool-compute)')
param avdComputeObjectsRgCustomName string = 'rg-avd-app1-dev-use2-pool-compute'

@maxLength(90)
@sys.description('AVD network resources resource group custom name. (Default: rg-avd-app1-dev-use2-storage)')
param avdStorageObjectsRgCustomName string = 'rg-avd-app1-dev-use2-storage'

@maxLength(90)
@sys.description('AVD monitoring resource group custom name. (Default: rg-avd-dev-use2-monitoring)')
param avdMonitoringRgCustomName string = 'rg-avd-dev-use2-monitoring'

@maxLength(64)
@sys.description('AVD virtual network custom name. (Default: vnet-app1-dev-use2-001)')
param avdVnetworkCustomName string = 'vnet-app1-dev-use2-001'

@maxLength(64)
@sys.description('AVD Azure log analytics workspace custom name. (Default: log-avd-app1-dev-use2)')
param avdAlaWorkspaceCustomName string = 'log-avd-app1-dev-use2'

@maxLength(80)
@sys.description('AVD virtual network subnet custom name. (Default: snet-avd-app1-dev-use2-001)')
param avdVnetworkSubnetCustomName string = 'snet-avd-app1-dev-use2-001'

@maxLength(80)
@sys.description('private endpoints virtual network subnet custom name. (Default: snet-pe-app1-dev-use2-001)')
param privateEndpointVnetworkSubnetCustomName string = 'snet-pe-app1-dev-use2-001'

@maxLength(80)
@sys.description('AVD network security group custom name. (Default: nsg-avd-app1-dev-use2-001)')
param avdNetworksecurityGroupCustomName string = 'nsg-avd-app1-dev-use2-001'

@maxLength(80)
@sys.description('Private endpoint network security group custom name. (Default: nsg-pe-app1-dev-use2-001)')
param privateEndpointNetworksecurityGroupCustomName string = 'nsg-pe-app1-dev-use2-001'

@maxLength(80)
@sys.description('AVD route table custom name. (Default: route-avd-app1-dev-use2-001)')
param avdRouteTableCustomName string = 'route-avd-app1-dev-use2-001'

@maxLength(80)
@sys.description('Private endpoint route table custom name. (Default: route-avd-app1-dev-use2-001)')
param privateEndpointRouteTableCustomName string = 'route-pe-app1-dev-use2-001'

@maxLength(80)
@sys.description('AVD application security custom name. (Default: asg-app1-dev-use2-001)')
param avdApplicationSecurityGroupCustomName string = 'asg-app1-dev-use2-001'

@maxLength(64)
@sys.description('AVD workspace custom name. (Default: vdws-app1-dev-use2-001)')
param avdWorkSpaceCustomName string = 'vdws-app1-dev-use2-001'

@maxLength(64)
@sys.description('AVD workspace custom friendly (Display) name. (Default: App1 - Dev - East US 2 - 001)')
param avdWorkSpaceCustomFriendlyName string = 'App1 - Dev - East US 2 - 001'

@maxLength(64)
@sys.description('AVD host pool custom name. (Default: vdpool-app1-dev-use2-001)')
param avdHostPoolCustomName string = 'vdpool-app1-dev-use2-001'

@maxLength(64)
@sys.description('AVD host pool custom friendly (Display) name. (Default: App1 - East US - Dev - 001)')
param avdHostPoolCustomFriendlyName string = 'App1 - Dev - East US 2 - 001'

@maxLength(64)
@sys.description('AVD scaling plan custom name. (Default: vdscaling-app1-dev-use2-001)')
param avdScalingPlanCustomName string = 'vdscaling-app1-dev-use2-001'

@maxLength(64)
@sys.description('AVD desktop application group custom name. (Default: vdag-desktop-app1-dev-use2-001)')
param avdApplicationGroupCustomName string = 'vdag-desktop-app1-dev-use2-001'

@maxLength(64)
@sys.description('AVD desktop application group custom friendly (Display) name. (Default: Desktops - App1 - East US - Dev - 001)')
param avdApplicationGroupCustomFriendlyName string = 'Desktops - App1 - Dev - East US 2 - 001'

@maxLength(11)
@sys.description('AVD session host prefix custom name. (Default: vmapp1duse2)')
param avdSessionHostCustomNamePrefix string = 'vmapp1duse2'

// @maxLength(9)
// @sys.description('AVD VMSS Flex custom name. (Default: vmss)')
// param vmssFlexCustomNamePrefix string = 'vmss'

@maxLength(2)
@sys.description('AVD FSLogix and App Attach storage account prefix custom name. (Default: st)')
param storageAccountPrefixCustomName string = 'st'

@sys.description('FSLogix file share name. (Default: fslogix-pc-app1-dev-001)')
param fslogixFileShareCustomName string = 'fslogix-pc-app1-dev-use2-001'

@sys.description('App Attach file share name. (Default: appa-app1-dev-001)')
param appAttachFileShareCustomName string = 'appa-app1-dev-use2-001'

//@maxLength(64)
//@sys.description('AVD fslogix storage account office container file share prefix custom name. (Default: fslogix-oc-app1-dev-001)')
//param avdFslogixOfficeContainerFileShareCustomName string = 'fslogix-oc-app1-dev-001'

@maxLength(6)
@sys.description('AVD keyvault prefix custom name (with Zero Trust to store credentials to domain join and local admin). (Default: kv-sec)')
param avdWrklKvPrefixCustomName string = 'kv-sec'

@maxLength(6)
@sys.description('AVD disk encryption set custom name. (Default: des-zt)')
param ztDiskEncryptionSetCustomNamePrefix string = 'des-zt'

@maxLength(5)
@sys.description('AVD managed identity for zero trust to encrypt managed disks using a customer managed key.  (Default: id-zt)')
param ztManagedIdentityCustomName string = 'id-zt'

@maxLength(6)
@sys.description('AVD key vault custom name for zero trust and store store disk encryption key (Default: kv-key)')
param ztKvPrefixCustomName string = 'kv-key'

//
// Resource tagging
//
@sys.description('Apply tags on resources and resource groups. (Default: false)')
param createResourceTags bool = false

@sys.description('The name of workload for tagging purposes. (Default: Contoso-Workload)')
param workloadNameTag string = 'Contoso-Workload'

@allowed([
  'Light'
  'Medium'
  'High'
  'Power'
])
@sys.description('Reference to the size of the VM for your workloads (Default: Light)')
param workloadTypeTag string = 'Light'

@allowed([
  'Non-business'
  'Public'
  'General'
  'Confidential'
  'Highly-confidential'
])
@sys.description('Sensitivity of data hosted (Default: Non-business)')
param dataClassificationTag string = 'Non-business'

@sys.description('Department that owns the deployment, (Dafult: Contoso-AVD)')
param departmentTag string = 'Contoso-AVD'

@allowed([
  'Low'
  'Medium'
  'High'
  'Mission-critical'
  'Custom'
])
@sys.description('Criticality of the workload. (Default: Low)')
param workloadCriticalityTag string = 'Low'

@sys.description('Tag value for custom criticality value. (Default: Contoso-Critical)')
param workloadCriticalityCustomValueTag string = 'Contoso-Critical'

@sys.description('Details about the application.')
param applicationNameTag string = 'Contoso-App'

@sys.description('Service level agreement level of the worload. (Contoso-SLA)')
param workloadSlaTag string = 'Contoso-SLA'

@sys.description('Team accountable for day-to-day operations. (workload-admins@Contoso.com)')
param opsTeamTag string = 'workload-admins@Contoso.com'

@sys.description('Organizational owner of the AVD deployment. (Default: workload-owner@Contoso.com)')
param ownerTag string = 'workload-owner@Contoso.com'

@sys.description('Cost center of owner team. (Default: Contoso-CC)')
param costCenterTag string = 'Contoso-CC'
//

//@sys.description('Remove resources not needed afdter deployment. (Default: false)')
//param removePostDeploymentTempResources bool = false

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

@sys.description('Enable usage and telemetry feedback to Microsoft.')
param enableTelemetry bool = true

@sys.description('Enable purge protection for the keyvaults. (Default: true)')
param enableKvPurgeProtection bool = true

@sys.description('Deploys anti malware extension on session hosts. (Default: true)')
param deployAntiMalwareExt bool = true

@sys.description('Additional customer-provided static routes to be added to the route tables.')
param customStaticRoutes array = []

//
// Parameters for Microsoft Defender
//
@sys.description('Enable Microsoft Defender on the subscription. (Default: false)')
param deployDefender bool = false

@sys.description('Enable Microsoft Defender for servers. (Default: true)')
param enableDefForServers bool = true

@sys.description('Enable Microsoft Defender for storage. (Default: true)')
param enableDefForStorage bool = true

@sys.description('Enable Microsoft Defender for Key Vault. (Default: true)')
param enableDefForKeyVault bool = true

@sys.description('Enable Microsoft Defender for Azure Resource Manager. (Default: true)')
param enableDefForArm bool = true

// =========== //
// Variable declaration //
// =========== //
// Resource naming
var varDeploymentPrefixLowercase = toLower(deploymentPrefix)
var varAzureCloudName = environment().name
var varDeploymentEnvironmentLowercase = toLower(deploymentEnvironment)
var varDeploymentEnvironmentComputeStorage = (deploymentEnvironment == 'Dev') ? 'd' : ((deploymentEnvironment == 'Test') ? 't' : ((deploymentEnvironment == 'Prod') ? 'p' : ''))
var varNamingUniqueStringThreeChar = take('${uniqueString(avdWorkloadSubsId, varDeploymentPrefixLowercase, time)}', 3)
var varNamingUniqueStringTwoChar = take('${uniqueString(avdWorkloadSubsId, varDeploymentPrefixLowercase, time)}', 2)
var varSessionHostLocationAcronym = varLocations[varSessionHostLocationLowercase].acronym
var varManagementPlaneLocationAcronym = varLocations[varManagementPlaneLocationLowercase].acronym
var varLocations = loadJsonContent('../variables/locations.json')
var varTimeZoneSessionHosts = varLocations[varSessionHostLocationLowercase].timeZone
var varManagementPlaneNamingStandard = '${varDeploymentPrefixLowercase}-${varDeploymentEnvironmentLowercase}-${varManagementPlaneLocationAcronym}'
var varComputeStorageResourcesNamingStandard = '${varDeploymentPrefixLowercase}-${varDeploymentEnvironmentLowercase}-${varSessionHostLocationAcronym}'
var varDiskEncryptionSetName = avdUseCustomNaming ? '${ztDiskEncryptionSetCustomNamePrefix}-${varComputeStorageResourcesNamingStandard}-001': 'des-zt-${varComputeStorageResourcesNamingStandard}-001'
var varSessionHostLocationLowercase = toLower(replace(avdSessionHostLocation, ' ', ''))
var varManagementPlaneLocationLowercase = toLower(replace(avdManagementPlaneLocation, ' ', ''))
var varServiceObjectsRgName = avdUseCustomNaming ? avdServiceObjectsRgCustomName : 'rg-avd-${varManagementPlaneNamingStandard}-service-objects' // max length limit 90 characters
var varNetworkObjectsRgName = avdUseCustomNaming ? avdNetworkObjectsRgCustomName : 'rg-avd-${varComputeStorageResourcesNamingStandard}-network' // max length limit 90 characters
var varComputeObjectsRgName = avdUseCustomNaming ? avdComputeObjectsRgCustomName : 'rg-avd-${varComputeStorageResourcesNamingStandard}-pool-compute' // max length limit 90 characters
var varStorageObjectsRgName = avdUseCustomNaming ? avdStorageObjectsRgCustomName : 'rg-avd-${varComputeStorageResourcesNamingStandard}-storage' // max length limit 90 characters
var varMonitoringRgName = avdUseCustomNaming ? avdMonitoringRgCustomName : 'rg-avd-${varDeploymentEnvironmentLowercase}-${varManagementPlaneLocationAcronym}-monitoring' // max length limit 90 characters
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
var varDDosProtectionPlanName = 'ddos-${varVnetName}'
var varWorkSpaceName = avdUseCustomNaming ? avdWorkSpaceCustomName : 'vdws-${varManagementPlaneNamingStandard}-001'
var varWorkSpaceFriendlyName = avdUseCustomNaming ? avdWorkSpaceCustomFriendlyName : 'Workspace ${deploymentPrefix} ${deploymentEnvironment} ${avdManagementPlaneLocation} 001'
var varHostPoolName = avdUseCustomNaming ? avdHostPoolCustomName : 'vdpool-${varManagementPlaneNamingStandard}-001'
var varHostFriendlyName = avdUseCustomNaming ? avdHostPoolCustomFriendlyName : 'Hostpool ${deploymentPrefix} ${deploymentEnvironment} ${avdManagementPlaneLocation} 001'
var varHostPoolPreferredAppGroupType = toLower(hostPoolPreferredAppGroupType)
var varApplicationGroupName = avdUseCustomNaming ? avdApplicationGroupCustomName : 'vdag-${varHostPoolPreferredAppGroupType}-${varManagementPlaneNamingStandard}-001'
var varApplicationGroupFriendlyName = avdUseCustomNaming ? avdApplicationGroupCustomFriendlyName : '${varHostPoolPreferredAppGroupType} ${deploymentPrefix} ${deploymentEnvironment} ${avdManagementPlaneLocation} 001'
var varDeployScalingPlan = (varAzureCloudName == 'AzureChinaCloud') ? false : avdDeployScalingPlan
var varCreateAppAttachDeployment = (varAzureCloudName == 'AzureChinaCloud') ? false : createAppAttachDeployment
var varScalingPlanName = avdUseCustomNaming ? avdScalingPlanCustomName : 'vdscaling-${varManagementPlaneNamingStandard}-001'
var varPrivateEndPointConnectionName = 'pe-${varHostPoolName}-connection'
var varPrivateEndPointDiscoveryName = 'pe-${varWorkSpaceName}-discovery'
var varPrivateEndPointWorkspaceName = 'pe-${varWorkSpaceName}-global'
var varScalingPlanExclusionTag = 'exclude-${varScalingPlanName}'
var varScalingPlanWeekdaysScheduleName = 'Weekdays-${varManagementPlaneNamingStandard}'
var varScalingPlanWeekendScheduleName = 'Weekend-${varManagementPlaneNamingStandard}'
var varWrklKvName = avdUseCustomNaming ? '${avdWrklKvPrefixCustomName}-${varComputeStorageResourcesNamingStandard}-${varNamingUniqueStringTwoChar}' : 'kv-sec-${varComputeStorageResourcesNamingStandard}-${varNamingUniqueStringTwoChar}' // max length limit 24 characters
var varWrklKvPrivateEndpointName = 'pe-${varWrklKvName}-vault'
var varWrklKeyVaultSku = (varAzureCloudName == 'AzureCloud' || varAzureCloudName == 'AzureUSGovernment') ? 'premium' : (varAzureCloudName == 'AzureChinaCloud' ? 'standard' : null)
var varSessionHostNamePrefix = avdUseCustomNaming ? avdSessionHostCustomNamePrefix : 'vm${varDeploymentPrefixLowercase}${varDeploymentEnvironmentComputeStorage}${varSessionHostLocationAcronym}'
//var varVmssFlexNamePrefix = avdUseCustomNaming ? '${vmssFlexCustomNamePrefix}-${varComputeStorageResourcesNamingStandard}' : 'vmss-${varComputeStorageResourcesNamingStandard}'
var varStorageManagedIdentityName = 'id-storage-${varComputeStorageResourcesNamingStandard}-001'
var varFslogixFileShareName = avdUseCustomNaming ? fslogixFileShareCustomName : 'fslogix-pc-${varDeploymentPrefixLowercase}-${varDeploymentEnvironmentLowercase}-${varSessionHostLocationAcronym}-001'
var varAppAttachFileShareName = avdUseCustomNaming ? appAttachFileShareCustomName : 'appa-${varDeploymentPrefixLowercase}-${varDeploymentEnvironmentLowercase}-${varSessionHostLocationAcronym}-001'
var varFslogixStorageName = avdUseCustomNaming ? '${storageAccountPrefixCustomName}fsl${varDeploymentPrefixLowercase}${varDeploymentEnvironmentComputeStorage}${varNamingUniqueStringThreeChar}' : 'stfsl${varDeploymentPrefixLowercase}${varDeploymentEnvironmentComputeStorage}${varNamingUniqueStringThreeChar}'
var varFslogixStorageFqdn = createAvdFslogixDeployment ? '${varFslogixStorageName}.file.${environment().suffixes.storage}' : ''
var varAppAttachStorageFqdn = '${varAppAttachStorageName}.file.${environment().suffixes.storage}'
var varAppAttachStorageName = avdUseCustomNaming ? '${storageAccountPrefixCustomName}appa${varDeploymentPrefixLowercase}${varDeploymentEnvironmentComputeStorage}${varNamingUniqueStringThreeChar}' : 'stappa${varDeploymentPrefixLowercase}${varDeploymentEnvironmentComputeStorage}${varNamingUniqueStringThreeChar}'
var varManagementVmName = 'vmmgmt${varDeploymentPrefixLowercase}${varDeploymentEnvironmentComputeStorage}${varSessionHostLocationAcronym}'
var varAlaWorkspaceName = avdUseCustomNaming ? avdAlaWorkspaceCustomName : 'log-avd-${varDeploymentEnvironmentLowercase}-${varManagementPlaneLocationAcronym}'
var varDataCollectionRulesName = 'microsoft-avdi-${varSessionHostLocationLowercase}' // 'dcr-avd-${varDeploymentEnvironmentLowercase}-${varManagementPlaneLocationAcronym}'
var varZtKvName = avdUseCustomNaming ? '${ztKvPrefixCustomName}-${varComputeStorageResourcesNamingStandard}-${varNamingUniqueStringTwoChar}' : 'kv-key-${varComputeStorageResourcesNamingStandard}-${varNamingUniqueStringTwoChar}' // max length limit 24 characters
var varZtKvPrivateEndpointName = 'pe-${varZtKvName}-vault'
//
var varFslogixSharePath = createAvdFslogixDeployment ? '\\\\${varFslogixStorageName}.file.${environment().suffixes.storage}\\${varFslogixFileShareName}' : ''
var varBaseScriptUri = 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/'
var varSessionHostConfigurationScriptUri = '${varBaseScriptUri}scripts/Set-SessionHostConfiguration.ps1'
var varSessionHostConfigurationScript = './Set-SessionHostConfiguration.ps1'
var varDiskEncryptionKeyExpirationInEpoch = dateTimeToEpoch(dateTimeAdd(
  time,
  'P${string(diskEncryptionKeyExpirationInDays)}D'
))
var varCreateStorageDeployment = (createAvdFslogixDeployment || varCreateAppAttachDeployment == true) ? true : false
var varFslogixStorageSku = zoneRedundantStorage ? '${fslogixStoragePerformance}_ZRS' : '${fslogixStoragePerformance}_LRS'
var varAppAttachStorageSku = zoneRedundantStorage ? '${appAttachStoragePerformance}_ZRS' : '${appAttachStoragePerformance}_LRS'
var varMgmtVmSpecs = {
  osImage: varMarketPlaceGalleryWindows[managementVmOsImage]
  osDiskType: 'Standard_LRS'
  mgmtVmSize: avdSessionHostsSize //'Standard_D2ads_v5'
  enableAcceleratedNetworking: false
  ouPath: avdOuPath
  subnetId: createAvdVnet ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetAvdSubnetName}' : existingVnetAvdSubnetResourceId
}
var varMaxSessionHostsPerTemplate = 10
var varMaxSessionHostsDivisionValue = avdDeploySessionHostsCount / varMaxSessionHostsPerTemplate
var varMaxSessionHostsDivisionRemainderValue = avdDeploySessionHostsCount % varMaxSessionHostsPerTemplate
var varSessionHostBatchCount = varMaxSessionHostsDivisionRemainderValue > 0 ? varMaxSessionHostsDivisionValue + 1 : varMaxSessionHostsDivisionValue
// var varMaxVmssFlexMembersCount = 999
// var varDivisionVmssFlexValue = avdDeploySessionHostsCount / varMaxVmssFlexMembersCount
// var varDivisionAvsetRemainderValue = avdDeploySessionHostsCount % varMaxVmssFlexMembersCount
// var varVmssFlexCount = varDivisionAvsetRemainderValue > 0 ? varDivisionVmssFlexValue + 1 : varDivisionVmssFlexValue
var varHostPoolAgentUpdateSchedule = [
  {
    dayOfWeek: 'Tuesday'
    hour: 18
  }
  {
    dayOfWeek: 'Friday'
    hour: 17
  }
] 
var varPersonalScalingPlanSchedules = [
  {
    daysOfWeek: [
      'Monday'
      'Wednesday'
      'Thursday'
      'Friday'
    ]
    name: varScalingPlanWeekdaysScheduleName
    offPeakStartTime: {
      hour: 20
      minute: 0
    }
    offPeakStartVMOnConnect: 'Enable'
    offPeakMinutesToWaitOnDisconnect: 30
    offPeakActionOnDisconnect: 'Hibernate'
    offPeakMinutesToWaitOnLogoff: 0
    offPeakActionOnLogoff: 'Deallocate'
    peakStartTime: {
      hour: 9
      minute: 0
    }
    peakStartVMOnConnect: 'Enable'
    peakMinutesToWaitOnDisconnect: 30
    peakActionOnDisconnect: 'Hibernate'
    peakMinutesToWaitOnLogoff: 0
    peakActionOnLogoff: 'Deallocate'
    rampDownStartTime: {
      hour: 18
      minute: 0
    }
    rampDownStartVMOnConnect: 'Enable'
    rampDownMinutesToWaitOnDisconnect: 30
    rampDownActionOnDisconnect: 'Hibernate'
    rampDownMinutesToWaitOnLogoff: 0
    rampDownActionOnLogoff: 'Deallocate'
    rampUpStartTime: {
      hour: 7
      minute: 0
    }
    rampUpAutoStartHosts: 'WithAssignedUser'
    rampUpStartVMOnConnect: 'Enable'
    rampUpMinutesToWaitOnDisconnect: 30
    rampUpActionOnDisconnect: 'Hibernate'
    rampUpMinutesToWaitOnLogoff: 0
    rampUpActionOnLogoff: 'Deallocate'
  }
  {
    daysOfWeek: [
      'Tuesday'
    ]
    name: '${varScalingPlanWeekdaysScheduleName}-agent-updates'
    offPeakStartTime: {
      hour: 20
      minute: 0
    }
    offPeakStartVMOnConnect: 'Enable'
    offPeakMinutesToWaitOnDisconnect: 30
    offPeakActionOnDisconnect: 'Hibernate'
    offPeakMinutesToWaitOnLogoff: 0
    offPeakActionOnLogoff: 'Deallocate'
    peakStartTime: {
      hour: 9
      minute: 0
    }
    peakStartVMOnConnect: 'Enable'
    peakMinutesToWaitOnDisconnect: 30
    peakActionOnDisconnect: 'Hibernate'
    peakMinutesToWaitOnLogoff: 0
    peakActionOnLogoff: 'Deallocate'
    rampDownStartTime: {
      hour: 18
      minute: 0
    }
    rampDownStartVMOnConnect: 'Enable'
    rampDownMinutesToWaitOnDisconnect: 30
    rampDownActionOnDisconnect: 'Hibernate'
    rampDownMinutesToWaitOnLogoff: 0
    rampDownActionOnLogoff: 'Deallocate'
    rampUpStartTime: {
      hour: 7
      minute: 0
    }
    rampUpAutoStartHosts: 'WithAssignedUser'
    rampUpStartVMOnConnect: 'Enable'
    rampUpMinutesToWaitOnDisconnect: 30
    rampUpActionOnDisconnect: 'Hibernate'
    rampUpMinutesToWaitOnLogoff: 0
    rampUpActionOnLogoff: 'Deallocate'
  }
  {
    daysOfWeek: [
      'Saturday'
      'Sunday'
    ]
    name: varScalingPlanWeekendScheduleName
    offPeakStartTime: {
      hour: 18
      minute: 0
    }
    offPeakStartVMOnConnect: 'Enable'
    offPeakMinutesToWaitOnDisconnect: 30
    offPeakActionOnDisconnect: 'Hibernate'
    offPeakMinutesToWaitOnLogoff: 0
    offPeakActionOnLogoff: 'Deallocate'
    peakStartTime: {
      hour: 10
      minute: 0
    }
    peakStartVMOnConnect: 'Enable'
    peakMinutesToWaitOnDisconnect: 30
    peakActionOnDisconnect: 'Hibernate'
    peakMinutesToWaitOnLogoff: 0
    peakActionOnLogoff: 'Deallocate'
    rampDownStartTime: {
      hour: 16
      minute: 0
    }
    rampDownStartVMOnConnect: 'Enable'
    rampDownMinutesToWaitOnDisconnect: 30
    rampDownActionOnDisconnect: 'Hibernate'
    rampDownMinutesToWaitOnLogoff: 0
    rampDownActionOnLogoff: 'Deallocate'
    rampUpStartTime: {
      hour: 9
      minute: 0
    }
    rampUpAutoStartHosts: 'None'
    rampUpStartVMOnConnect: 'Enable'
    rampUpMinutesToWaitOnDisconnect: 30
    rampUpActionOnDisconnect: 'Hibernate'
    rampUpMinutesToWaitOnLogoff: 0
    rampUpActionOnLogoff: 'Deallocate'
  }
]
var varPooledScalingPlanSchedules = [
  {
    daysOfWeek: [
      'Monday'
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
      'Tuesday'
    ]
    name: '${varScalingPlanWeekdaysScheduleName}-agent-updates'
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
      hour: 19
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
var varMarketPlaceGalleryWindows = loadJsonContent('../variables/osMarketPlaceImages.json')
var varStorageAzureFilesDscAgentPackageLocation = 'https://github.com/Azure/avdaccelerator/raw/main/workload/scripts/DSCStorageScripts/1.0.2/DSCStorageScripts.zip'
var varStorageToDomainScriptUri = '${varBaseScriptUri}scripts/Manual-DSC-Storage-Scripts.ps1'
var varStorageToDomainScript = './Manual-DSC-Storage-Scripts.ps1'
var varOuStgPath = !empty(storageOuPath) ? '"${storageOuPath}"' : '"${varDefaultStorageOuPath}"'
var varDefaultStorageOuPath = (avdIdentityServiceProvider == 'EntraDS') ? 'AADDC Computers' : 'Computers'
var varStorageCustomOuPath = !empty(storageOuPath) ? 'true' : 'false'
var varAllDnsServers = '${customDnsIps},168.63.129.16'
var varDnsServers = empty(customDnsIps) ? [] : (split(varAllDnsServers, ','))
var varCreateVnetPeering = !empty(existingHubVnetResourceId) ? true : false
// Resource tagging
// Tag Exclude-${varAvdScalingPlanName} is used by scaling plans to exclude session hosts from scaling. Exmaple: Exclude-vdscal-eus2-app1-dev-001
var varCustomResourceTags = createResourceTags
  ? {
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
    }
  : {}
var varAllComputeStorageTags = {
  DomainName: identityDomainName
  IdentityServiceProvider: avdIdentityServiceProvider
}
var varAvdDefaultTags = {
  'cm-resource-parent': '/subscriptions/${avdWorkloadSubsId}/resourceGroups/${varServiceObjectsRgName}/providers/Microsoft.DesktopVirtualization/hostpools/${varHostPoolName}'
  Environment: deploymentEnvironment
  ServiceWorkload: 'AVD'
  CreationTimeUTC: time
}
var varWorkloadKeyvaultTag = {
  Purpose: 'Secrets for local admin and domain join credentials'
}
var varZtKeyvaultTag = {
  Purpose: 'Disk encryption keys for zero trust'
}
//
var varTelemetryId = 'pid-2ce4228c-d72c-43fb-bb5b-cd8f3ba2138e-${avdManagementPlaneLocation}'
var varResourceGroups = [
  {
    purpose: 'Service-Objects'
    name: varServiceObjectsRgName
    location: avdManagementPlaneLocation
    enableDefaultTelemetry: false
    tags: createResourceTags
      ? union(varCustomResourceTags, varAvdDefaultTags)
      : union(varAvdDefaultTags, varAllComputeStorageTags)
  }
  {
    purpose: 'Pool-Compute'
    name: varComputeObjectsRgName
    location: avdSessionHostLocation
    enableDefaultTelemetry: false
    tags: createResourceTags
      ? union(varAllComputeStorageTags, varAvdDefaultTags)
      : union(varAvdDefaultTags, varAllComputeStorageTags)
  }
]

// =========== //
// Deployments //
// =========== //

//  Telemetry Deployment
resource telemetrydeployment 'Microsoft.Resources/deployments@2024-03-01' = if (enableTelemetry) {
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
// Compute, service objects, network
// Network
module baselineNetworkResourceGroup '../../avm/1.0.0/res/resources/resource-group/main.bicep' = if (createAvdVnet || createPrivateDnsZones) {
  scope: subscription(avdWorkloadSubsId)
  name: 'Deploy-Network-RG-${time}'
  params: {
    name: varNetworkObjectsRgName
    location: avdSessionHostLocation
    enableTelemetry: false
    tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
  }
}

// Compute, service objects
module baselineResourceGroups '../../avm/1.0.0/res/resources/resource-group/main.bicep' = [
  for resourceGroup in varResourceGroups: {
    scope: subscription(avdWorkloadSubsId)
    name: '${resourceGroup.purpose}-${time}'
    params: {
      name: resourceGroup.name
      location: resourceGroup.location
      enableTelemetry: resourceGroup.enableDefaultTelemetry
      tags: resourceGroup.tags
    }
  }
]

// Storage
module baselineStorageResourceGroup '../../avm/1.0.0/res/resources/resource-group/main.bicep' = if (varCreateStorageDeployment) {
  scope: subscription(avdWorkloadSubsId)
  name: 'Storage-RG-${time}'
  params: {
    name: varStorageObjectsRgName
    location: avdSessionHostLocation
    enableTelemetry: false
    tags: createResourceTags
      ? union(varAllComputeStorageTags, varAvdDefaultTags)
      : union(varAvdDefaultTags, varAllComputeStorageTags)
  }
}

// Azure Policies for monitoring Diagnostic settings. Performance couunters on new or existing Log Analytics workspace. New workspace if needed.
module monitoringDiagnosticSettings './modules/avdInsightsMonitoring/deploy.bicep' = if (avdDeployMonitoring) {
  name: 'Monitoring-${time}'
  params: {
    location: avdManagementPlaneLocation
    deployAlaWorkspace: deployAlaWorkspace
    computeObjectsRgName: varComputeObjectsRgName
    serviceObjectsRgName: varServiceObjectsRgName
    dataCollectionRulesName: varDataCollectionRulesName
    storageObjectsRgName: (createAvdFslogixDeployment || createAppAttachDeployment) ? varStorageObjectsRgName : ''
    networkObjectsRgName: (createAvdVnet) ? varNetworkObjectsRgName : ''
    monitoringRgName: varMonitoringRgName
    deployCustomPolicyMonitoring: deployCustomPolicyMonitoring
    alaWorkspaceId: deployAlaWorkspace ? '' : alaExistingWorkspaceResourceId
    alaWorkspaceName: deployAlaWorkspace ? varAlaWorkspaceName : ''
    alaWorkspaceDataRetention: avdAlaWorkspaceDataRetention
    subscriptionId: avdWorkloadSubsId
    tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
  }
  dependsOn: [
    baselineNetworkResourceGroup
    baselineResourceGroups
    baselineStorageResourceGroup
  ]
}

// Networking
module networking './modules/networking/deploy.bicep' = if (createAvdVnet || createPrivateDnsZones || avdDeploySessionHosts || createAvdFslogixDeployment || varCreateAppAttachDeployment) {
  name: 'Networking-${time}'
  params: {
    createVnet: createAvdVnet
    deployAsg: (avdDeploySessionHosts || createAvdFslogixDeployment || varCreateAppAttachDeployment) ? true : false
    existingAvdSubnetResourceId: existingVnetAvdSubnetResourceId
    createPrivateDnsZones: (deployPrivateEndpointKeyvaultStorage || deployAvdPrivateLinkService)
      ? createPrivateDnsZones
      : false
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
    deployDDoSNetworkProtection: deployDDoSNetworkProtection
    ddosProtectionPlanName: varDDosProtectionPlanName
    deployPrivateEndpointSubnet: (deployPrivateEndpointKeyvaultStorage || deployAvdPrivateLinkService) ? true : false //adding logic that will be used when also including AVD control plane PEs
    deployAvdPrivateLinkService: deployAvdPrivateLinkService
    vNetworkGatewayOnHub: vNetworkGatewayOnHub
    existingHubVnetResourceId: existingHubVnetResourceId
    location: avdDeploySessionHosts ? avdSessionHostLocation : avdManagementPlaneLocation
    vnetAvdSubnetAddressPrefix: vNetworkAvdSubnetAddressPrefix
    vnetPrivateEndpointSubnetAddressPrefix: vNetworkPrivateEndpointSubnetAddressPrefix
    workloadSubsId: avdWorkloadSubsId
    dnsServers: varDnsServers
    tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
    alaWorkspaceResourceId: avdDeployMonitoring
      ? (deployAlaWorkspace
          ? monitoringDiagnosticSettings.outputs.avdAlaWorkspaceResourceId
          : alaExistingWorkspaceResourceId)
      : ''
    customStaticRoutes: customStaticRoutes
  }
  dependsOn: [
    baselineNetworkResourceGroup
    baselineResourceGroups
  ]
}

// AVD management plane
module managementPLane './modules/avdManagementPlane/deploy.bicep' = {
  name: 'AVD-MGMT-Plane-${time}'
  params: {
    applicationGroupName: varApplicationGroupName
    applicationGroupFriendlyNameDesktop: varApplicationGroupFriendlyName
    workSpaceName: varWorkSpaceName
    osImage: avdOsImage
    keyVaultResourceId: wrklKeyVault.outputs.resourceId
    workSpaceFriendlyName: varWorkSpaceFriendlyName
    computeTimeZone: varTimeZoneSessionHosts
    hostPoolName: varHostPoolName
    hostPoolFriendlyName: varHostFriendlyName
    hostPoolRdpProperties: avdHostPoolRdpProperties
    hostPoolLoadBalancerType: avdHostPoolLoadBalancerType
    hostPoolType: avdHostPoolType
    preferredAppGroupType: (hostPoolPreferredAppGroupType == 'RemoteApp') ? 'RailApplications' : 'Desktop'
    deployScalingPlan: varDeployScalingPlan
    scalingPlanExclusionTag: varScalingPlanExclusionTag
    scalingPlanSchedules: (avdHostPoolType == 'Pooled')
      ? varPooledScalingPlanSchedules
      : varPersonalScalingPlanSchedules
    scalingPlanName: varScalingPlanName
    hostPoolMaxSessions: hostPoolMaxSessions
    personalAssignType: avdPersonalAssignType
    managementPlaneLocation: avdManagementPlaneLocation
    serviceObjectsRgName: varServiceObjectsRgName
    startVmOnConnect: avdStartVmOnConnect
    subscriptionId: avdWorkloadSubsId
    identityServiceProvider: avdIdentityServiceProvider
    securityPrincipalId: !empty(securityPrincipalId) ? securityPrincipalId : ''
    tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
    alaWorkspaceResourceId: avdDeployMonitoring
      ? (deployAlaWorkspace
          ? monitoringDiagnosticSettings.outputs.avdAlaWorkspaceResourceId
          : alaExistingWorkspaceResourceId)
      : ''
    hostPoolAgentUpdateSchedule: varHostPoolAgentUpdateSchedule
    deployAvdPrivateLinkService: deployAvdPrivateLinkService
    hostPoolPublicNetworkAccess: hostPoolPublicNetworkAccess
    workspacePublicNetworkAccess: workspacePublicNetworkAccess
    privateEndpointSubnetResourceId: createAvdVnet
      ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetPrivateEndpointSubnetName}'
      : existingVnetPrivateEndpointSubnetResourceId
    avdVnetPrivateDnsZoneDiscoveryResourceId: deployAvdPrivateLinkService
      ? (createPrivateDnsZones
          ? networking.outputs.avdDnsDiscoveryZoneResourceId
          : avdVnetPrivateDnsZoneDiscoveryResourceId)
      : ''
    avdVnetPrivateDnsZoneConnectionResourceId: deployAvdPrivateLinkService
      ? (createPrivateDnsZones
          ? networking.outputs.avdDnsConnectionZoneResourceId
          : avdVnetPrivateDnsZoneConnectionResourceId)
      : ''
    privateEndpointConnectionName: varPrivateEndPointConnectionName
    privateEndpointDiscoveryName: varPrivateEndPointDiscoveryName
    privateEndpointWorkspaceName: varPrivateEndPointWorkspaceName
  }
  dependsOn: [
    baselineResourceGroups
    identity
  ]
}

// Identity: managed identities and role assignments
module identity './modules/identity/deploy.bicep' = {
  name: 'Identities-And-RoleAssign-${time}'
  params: {
    location: avdSessionHostLocation
    subscriptionId: avdWorkloadSubsId
    computeObjectsRgName: varComputeObjectsRgName
    serviceObjectsRgName: varServiceObjectsRgName
    storageObjectsRgName: varStorageObjectsRgName
    avdEnterpriseObjectId: !empty(avdEnterpriseAppObjectId) ? avdEnterpriseAppObjectId : ''
    deployScalingPlan: varDeployScalingPlan
    storageManagedIdentityName: varStorageManagedIdentityName
    enableStartVmOnConnect: avdStartVmOnConnect
    identityServiceProvider: avdIdentityServiceProvider
    createStorageDeployment: varCreateStorageDeployment
    securityPrincipalId: !empty(securityPrincipalId) ? securityPrincipalId : ''
    tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
  }
  dependsOn: [
    baselineResourceGroups
    baselineStorageResourceGroup
    monitoringDiagnosticSettings
  ]
}

// Zero trust
module zeroTrust './modules/zeroTrust/deploy.bicep' = if (diskZeroTrust && avdDeploySessionHosts) {
  scope: subscription(avdWorkloadSubsId)
  name: 'Zero-Trust-${time}'
  params: {
    location: avdSessionHostLocation
    subscriptionId: avdWorkloadSubsId
    diskZeroTrust: diskZeroTrust
    serviceObjectsRgName: varServiceObjectsRgName
    computeObjectsRgName: varComputeObjectsRgName
    vaultSku: varWrklKeyVaultSku
    diskEncryptionKeyExpirationInDays: diskEncryptionKeyExpirationInDays
    diskEncryptionKeyExpirationInEpoch: varDiskEncryptionKeyExpirationInEpoch
    diskEncryptionSetName: varDiskEncryptionSetName
    ztKvName: varZtKvName
    ztKvPrivateEndpointName: varZtKvPrivateEndpointName
    privateEndpointsubnetResourceId: createAvdVnet
      ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetPrivateEndpointSubnetName}'
      : existingVnetPrivateEndpointSubnetResourceId
    deployPrivateEndpointKeyvaultStorage: deployPrivateEndpointKeyvaultStorage
    keyVaultprivateDNSResourceId: createPrivateDnsZones
      ? networking.outputs.keyVaultDnsZoneResourceId
      : avdVnetPrivateDnsZoneKeyvaultId
    tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
    enableKvPurgeProtection: enableKvPurgeProtection
    kvTags: varZtKeyvaultTag
  }
  dependsOn: [
    baselineResourceGroups
    baselineStorageResourceGroup
    identity
  ]
}

// Key vault
module wrklKeyVault '../../avm/1.0.0/res/key-vault/vault/main.bicep' = {
  scope: resourceGroup('${avdWorkloadSubsId}', '${varServiceObjectsRgName}')
  name: 'Workload-KeyVault-${time}'
  params: {
    name: varWrklKvName
    location: avdSessionHostLocation
    enableRbacAuthorization: true
    enablePurgeProtection: enableKvPurgeProtection
    sku: varWrklKeyVaultSku
    softDeleteRetentionInDays: 7
    publicNetworkAccess: deployPrivateEndpointKeyvaultStorage ? 'Disabled' : 'Enabled'
    networkAcls: deployPrivateEndpointKeyvaultStorage
      ? {
          bypass: 'AzureServices'
          defaultAction: 'Deny'
          virtualNetworkRules: []
          ipRules: []
        }
      : {}
    privateEndpoints: deployPrivateEndpointKeyvaultStorage
      ? [
          {
            name: varWrklKvPrivateEndpointName
            subnetResourceId: createAvdVnet
              ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetPrivateEndpointSubnetName}'
              : existingVnetPrivateEndpointSubnetResourceId
            customNetworkInterfaceName: 'nic-01-${varWrklKvPrivateEndpointName}'
            service: 'vault'
            privateDnsZoneGroupName: createPrivateDnsZones
              ? split(networking.outputs.keyVaultDnsZoneResourceId, '/')[8]
              : split(avdVnetPrivateDnsZoneKeyvaultId, '/')[8]
            privateDnsZoneResourceIds: [
              createPrivateDnsZones ? networking.outputs.keyVaultDnsZoneResourceId : avdVnetPrivateDnsZoneKeyvaultId
            ]
          }
        ]
      : []
    secrets: (avdIdentityServiceProvider != 'EntraID')
      ? [
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
        ]
      : [
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
            value: 'NoUsername'
            contentType: 'Domain join credentials'
          }
          {
            name: 'domainJoinUserPassword'
            value: 'NoPassword'
            contentType: 'Domain join credentials'
          }
        ]
    tags: createResourceTags
      ? union(varCustomResourceTags, varAvdDefaultTags, varWorkloadKeyvaultTag)
      : union(varAvdDefaultTags, varWorkloadKeyvaultTag)
  }
  dependsOn: [
    baselineResourceGroups
    monitoringDiagnosticSettings
  ]
}

// Management VM deployment
module managementVm './modules/storageAzureFiles/.bicep/managementVm.bicep' = if (createAvdFslogixDeployment || varCreateAppAttachDeployment) {
  name: 'Storage-MGMT-VM-${time}'
  params: {
    diskEncryptionSetResourceId: diskZeroTrust ? zeroTrust.outputs.ztDiskEncryptionSetResourceId : ''
    identityServiceProvider: avdIdentityServiceProvider
    managementVmName: varManagementVmName
    computeTimeZone: varTimeZoneSessionHosts
    applicationSecurityGroupResourceId: (avdDeploySessionHosts || createAvdFslogixDeployment || varCreateAppAttachDeployment)
      ? '${networking.outputs.applicationSecurityGroupResourceId}'
      : ''
    domainJoinUserName: avdDomainJoinUserName
    wrklKvName: varWrklKvName
    serviceObjectsRgName: varServiceObjectsRgName
    identityDomainName: identityDomainName
    ouPath: varMgmtVmSpecs.ouPath
    osDiskType: varMgmtVmSpecs.osDiskType
    location: avdDeploySessionHosts ? avdSessionHostLocation : avdManagementPlaneLocation
    mgmtVmSize: varMgmtVmSpecs.mgmtVmSize
    subnetId: varMgmtVmSpecs.subnetId
    enableAcceleratedNetworking: varMgmtVmSpecs.enableAcceleratedNetworking
    securityType: securityType == 'Standard' ? '' : securityType
    secureBootEnabled: secureBootEnabled
    vTpmEnabled: vTpmEnabled
    vmLocalUserName: avdVmLocalUserName
    workloadSubsId: avdWorkloadSubsId
    encryptionAtHost: diskZeroTrust
    storageManagedIdentityResourceId: varCreateStorageDeployment
      ? identity.outputs.managedIdentityStorageResourceId
      : ''
    osImage: varMgmtVmSpecs.osImage
    tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
  }
  dependsOn: [
    baselineStorageResourceGroup
    wrklKeyVault
  ]
}

// FSLogix storage
module fslogixAzureFilesStorage './modules/storageAzureFiles/deploy.bicep' = if (createAvdFslogixDeployment) {
  name: 'Storage-FSLogix-${time}'
  params: {
    storagePurpose: 'fslogix'
    vmLocalUserName: avdVmLocalUserName
    fileShareName: varFslogixFileShareName
    fileShareMultichannel: (fslogixStoragePerformance == 'Premium') ? true : false
    storageSku: varFslogixStorageSku
    fileShareQuotaSize: fslogixFileShareQuotaSize
    storageAccountFqdn: varFslogixStorageFqdn
    storageAccountName: varFslogixStorageName
    storageToDomainScript: varStorageToDomainScript
    storageToDomainScriptUri: varStorageToDomainScriptUri
    identityServiceProvider: avdIdentityServiceProvider
    dscAgentPackageLocation: varStorageAzureFilesDscAgentPackageLocation
    storageCustomOuPath: varStorageCustomOuPath
    managementVmName: varManagementVmName
    deployPrivateEndpoint: deployPrivateEndpointKeyvaultStorage
    ouStgPath: varOuStgPath
    managedIdentityClientId: varCreateStorageDeployment ? identity.outputs.managedIdentityStorageClientId : ''
    securityPrincipalName: !empty(securityPrincipalName) ? securityPrincipalName : ''
    domainJoinUserName: avdDomainJoinUserName
    wrklKvName: varWrklKvName
    serviceObjectsRgName: varServiceObjectsRgName
    identityDomainName: identityDomainName
    identityDomainGuid: identityDomainGuid
    location: avdDeploySessionHosts ? avdSessionHostLocation : avdManagementPlaneLocation
    storageObjectsRgName: varStorageObjectsRgName
    privateEndpointSubnetId: createAvdVnet
      ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetPrivateEndpointSubnetName}'
      : existingVnetPrivateEndpointSubnetResourceId
    vmsSubnetId: createAvdVnet ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetAvdSubnetName}' : existingVnetAvdSubnetResourceId
    vnetPrivateDnsZoneFilesId: createPrivateDnsZones
      ? networking.outputs.azureFilesDnsZoneResourceId
      : avdVnetPrivateDnsZoneFilesId
    workloadSubsId: avdWorkloadSubsId
    tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
    alaWorkspaceResourceId: avdDeployMonitoring
      ? (deployAlaWorkspace
          ? monitoringDiagnosticSettings.outputs.avdAlaWorkspaceResourceId
          : alaExistingWorkspaceResourceId)
      : ''
  }
  dependsOn: [
    baselineStorageResourceGroup
    wrklKeyVault
    managementVm
  ]
}

// App Attach storage
module appAttachAzureFilesStorage './modules/storageAzureFiles/deploy.bicep' = if (varCreateAppAttachDeployment) {
  name: 'Storage-AppA-${time}'
  params: {
    storagePurpose: 'AppAttach'
    vmLocalUserName: avdVmLocalUserName
    fileShareName: varAppAttachFileShareName
    fileShareMultichannel: (appAttachStoragePerformance == 'Premium') ? true : false
    storageSku: varAppAttachStorageSku
    fileShareQuotaSize: appAttachFileShareQuotaSize
    storageAccountFqdn: varAppAttachStorageFqdn
    storageAccountName: varAppAttachStorageName
    storageToDomainScript: varStorageToDomainScript
    storageToDomainScriptUri: varStorageToDomainScriptUri
    identityServiceProvider: avdIdentityServiceProvider
    dscAgentPackageLocation: varStorageAzureFilesDscAgentPackageLocation
    storageCustomOuPath: varStorageCustomOuPath
    managementVmName: varManagementVmName
    deployPrivateEndpoint: deployPrivateEndpointKeyvaultStorage
    ouStgPath: varOuStgPath
    managedIdentityClientId: varCreateStorageDeployment ? identity.outputs.managedIdentityStorageClientId : ''
    securityPrincipalName: !empty(securityPrincipalName) ? securityPrincipalName : ''
    domainJoinUserName: avdDomainJoinUserName
    wrklKvName: varWrklKvName
    serviceObjectsRgName: varServiceObjectsRgName
    identityDomainName: identityDomainName
    identityDomainGuid: identityDomainGuid
    location: avdDeploySessionHosts ? avdSessionHostLocation : avdManagementPlaneLocation
    storageObjectsRgName: varStorageObjectsRgName
    privateEndpointSubnetId: createAvdVnet
      ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetPrivateEndpointSubnetName}'
      : existingVnetPrivateEndpointSubnetResourceId
    vmsSubnetId: createAvdVnet ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetAvdSubnetName}' : existingVnetAvdSubnetResourceId
    vnetPrivateDnsZoneFilesId: createPrivateDnsZones
      ? networking.outputs.azureFilesDnsZoneResourceId
      : avdVnetPrivateDnsZoneFilesId
    workloadSubsId: avdWorkloadSubsId
    tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
    alaWorkspaceResourceId: avdDeployMonitoring
      ? (deployAlaWorkspace
          ? monitoringDiagnosticSettings.outputs.avdAlaWorkspaceResourceId
          : alaExistingWorkspaceResourceId)
      : ''
  }
  dependsOn: [
    fslogixAzureFilesStorage
    baselineStorageResourceGroup
    wrklKeyVault
    managementVm
  ]
}

// VMSS Flex
// module vmScaleSetFlex './modules/avdSessionHosts/.bicep/vmScaleSet.bicep' = if (avdDeploySessionHosts && deployVmssFlex) {
//   name: 'AVD-VMSS-Flex-${time}'
//   scope: resourceGroup('${avdWorkloadSubsId}', '${varComputeObjectsRgName}')
//   params: {
//     namePrefix: varVmssFlexNamePrefix
//     location: avdSessionHostLocation
//     count: varVmssFlexCount
//     platformFaultDomainCount: vmssFlatformFaultDomainCount
//     useAvailabilityZones: availabilityZonesCompute
//     tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
//   }
//   dependsOn: [
//     baselineResourceGroups
//     monitoringDiagnosticSettings
//   ]
// }

// Session hosts
@batchSize(3)
module sessionHosts './modules/avdSessionHosts/deploy.bicep' = [
  for i in range(1, varSessionHostBatchCount): if (avdDeploySessionHosts) {
    name: 'SH-Batch-${i - 1}-${time}'
    params: {
      diskEncryptionSetResourceId: diskZeroTrust ? zeroTrust.outputs.ztDiskEncryptionSetResourceId : ''
      timeZone: varTimeZoneSessionHosts
      asgResourceId: (avdDeploySessionHosts || createAvdFslogixDeployment || varCreateAppAttachDeployment)
        ? '${networking.outputs.applicationSecurityGroupResourceId}'
        : ''
      identityServiceProvider: avdIdentityServiceProvider
      createIntuneEnrollment: createIntuneEnrollment
      // maxVmssFlexMembersCount: varMaxVmssFlexMembersCount
      // vmssFlexNamePrefix: varVmssFlexNamePrefix
      //useVmssFlex: deployVmssFlex
      batchId: i - 1
      computeObjectsRgName: varComputeObjectsRgName
      count: i == varSessionHostBatchCount && varMaxSessionHostsDivisionRemainderValue > 0
        ? varMaxSessionHostsDivisionRemainderValue
        : varMaxSessionHostsPerTemplate
      countIndex: i == 1
        ? avdSessionHostCountIndex
        : (((i - 1) * varMaxSessionHostsPerTemplate) + avdSessionHostCountIndex)
      domainJoinUserName: avdDomainJoinUserName
      wrklKvName: varWrklKvName
      serviceObjectsRgName: varServiceObjectsRgName
      identityDomainName: identityDomainName
      avdImageTemplateDefinitionId: avdImageTemplateDefinitionId
      sessionHostOuPath: avdOuPath
      diskType: avdSessionHostDiskType
      customOsDiskSizeGB: customOsDiskSizeGb
      location: avdSessionHostLocation
      namePrefix: varSessionHostNamePrefix
      vmSize: avdSessionHostsSize
      enableAcceleratedNetworking: enableAcceleratedNetworking
      securityType: securityType == 'Standard' ? '' : securityType
      secureBootEnabled: secureBootEnabled
      vTpmEnabled: vTpmEnabled
      subnetId: createAvdVnet
        ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetAvdSubnetName}'
        : existingVnetAvdSubnetResourceId
      useAvailabilityZones: availabilityZonesCompute
      vmLocalUserName: avdVmLocalUserName
      subscriptionId: avdWorkloadSubsId
      encryptionAtHost: diskZeroTrust
      createAvdFslogixDeployment: createAvdFslogixDeployment
      fslogixSharePath: varFslogixSharePath
      fslogixStorageFqdn: varFslogixStorageFqdn
      sessionHostConfigurationScriptUri: varSessionHostConfigurationScriptUri
      sessionHostConfigurationScript: varSessionHostConfigurationScript
      marketPlaceGalleryWindows: varMarketPlaceGalleryWindows[avdOsImage]
      useSharedImage: useSharedImage
      tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
      deployMonitoring: avdDeployMonitoring
      alaWorkspaceResourceId: avdDeployMonitoring
        ? (deployAlaWorkspace
            ? monitoringDiagnosticSettings.outputs.avdAlaWorkspaceResourceId
            : alaExistingWorkspaceResourceId)
        : ''
      dataCollectionRuleId: avdDeployMonitoring ? monitoringDiagnosticSettings.outputs.dataCollectionRuleId : ''
      deployAntiMalwareExt: deployAntiMalwareExt
    }
    dependsOn: [
      fslogixAzureFilesStorage
      baselineResourceGroups
      wrklKeyVault
      //vmScaleSetFlex
      managementPLane
    ]
  }
]

// VM GPU extension policies
module gpuPolicies './modules/azurePolicies/gpuExtensionsSubscriptions.bicep' = if (deployGpuPolicies) {
  scope: subscription('${avdWorkloadSubsId}')
  name: 'GPU-VM-Extensions-${time}'
  params: {
    computeObjectsRgName: varComputeObjectsRgName
    location: avdSessionHostLocation
    subscriptionId: avdWorkloadSubsId
  }
  dependsOn: [
    sessionHosts
  ]
}

module defenderPolicySet './modules/azurePolicies/defenderSubscription.bicep' = if (deployDefender) {
  scope: subscription('${avdWorkloadSubsId}')
  name: 'Defender-Policies-${time}'
  params: {
    enableDefForServers: enableDefForServers
    enableDefForStorage: enableDefForStorage
    enableDefForKeyVault: enableDefForKeyVault
    enableDefForArm: enableDefForArm
  }
  dependsOn: [
    sessionHosts
  ]
}
