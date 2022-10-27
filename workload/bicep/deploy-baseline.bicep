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
@description('Optional. AVD scaling plan custom name. (Default: vdscaling-use2-app1-001)')
param avdScalingPlanCustomName string = 'vdscaling-use2-app1-001'

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
var timeZones = {
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
var avdVnetworkPeeringName = 'peer-avd-${avdComputeStorageResourcesNamingStandard}-${avdNamingUniqueStringSixChar}'
var avdWorkSpaceName = avdUseCustomNaming ? avdWorkSpaceCustomName : 'vdws-${avdManagementPlaneNamingStandard}-001'
var avdHostPoolName = avdUseCustomNaming ? avdHostPoolCustomName : 'vdpool-${avdManagementPlaneNamingStandard}-001'
var avdApplicationGroupNameDesktop = avdUseCustomNaming ? avdApplicationGroupCustomNameDesktop : 'vdag-desktop-${avdManagementPlaneNamingStandard}-001'
var avdApplicationGroupNameRapp = avdUseCustomNaming ? avdApplicationGroupCustomNameRapp : 'vdag-rapp-${avdManagementPlaneNamingStandard}-001'
var avdScalingPlanName = avdUseCustomNaming ? avdScalingPlanCustomName : 'vdscaling-${avdManagementPlaneNamingStandard}-001'
var avdScalingPlanExclusionTag = 'Exclude-${avdScalingPlanName}'
var avdScalingPlanWeekdaysScheduleName = 'weekdays-${avdManagementPlaneNamingStandard}'
var avdScalingPlanWeekendScheduleName = 'weekend-${avdManagementPlaneNamingStandard}'
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
var avdScalingPlanSchedules = [
    {
        daysOfWeek: [
            'Monday'
            'Tuesday'
            'Wednesday'
            'Thursday'
            'Friday'
        ]
        name: avdScalingPlanWeekdaysScheduleName
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
        name: avdScalingPlanWeekendScheduleName
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

var baseScriptUri = 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/'
var fslogixScriptUri = '${baseScriptUri}scripts/Set-FSLogixRegKeys.ps1'
var fsLogixScript = './Set-FSLogixRegKeys.ps1'
var fslogixSharePath = '\\\\${avdFslogixStorageName}.file.${environment().suffixes.storage}\\${avdFslogixProfileContainerFileShareName}'
var FsLogixScriptArguments = '-volumeshare ${fslogixSharePath}'
var avdAgentPackageLocation = 'https://wvdportalstorageblob.blob.${environment().suffixes.storage}/galleryartifacts/Configuration_01-20-2022.zip'
var storageAccountContributorRoleId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
var readerRoleId = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
var avdVmPowerStateContributor = '40c5ff49-9181-41f8-ae61-143b0e78555e'
var dscAgentPackageLocation = 'https://github.com/Azure/avdaccelerator/raw/main/workload/scripts/DSCStorageScripts.zip'
var storageToDomainScriptUri = '${baseScriptUri}scripts/Manual-DSC-Storage-Scripts.ps1'
var storageToDomainScript = './Manual-DSC-Storage-Scripts.ps1'
var ouStgPath = !empty(storageOuPath) ? '"${storageOuPath}"' : '"${defaultStorageOuPath}"'
var defaultStorageOuPath = (avdIdentityServiceProvider == 'AADDS') ? 'AADDC Computers': 'Computers'
var storageCustomOuPath = !empty(storageOuPath) ? 'true' : 'false'
var storageToDomainScriptArgs = '-DscPath ${dscAgentPackageLocation} -StorageAccountName ${avdFslogixStorageName} -StorageAccountRG ${avdStorageObjectsRgName} -DomainName ${avdIdentityDomainName} -IdentityServiceProvider ${avdIdentityServiceProvider} -AzureCloudEnvironment AzureCloud -SubscriptionId ${avdWorkloadSubsId} -DomainAdminUserName ${avdDomainJoinUserName} -DomainAdminUserPassword ${avdDomainJoinUserPassword} -CustomOuPath ${storageCustomOuPath} -OUName ${ouStgPath} -CreateNewOU ${createOuForStorageString} -ShareName ${avdFslogixProfileContainerFileShareName} -ClientId ${deployAvdManagedIdentitiesRoleAssign.outputs.fslogixManagedIdentityClientId} -Verbose'
var createOuForStorageString = string(createOuForStorage)
var allDnsServers = '${customDnsIps},168.63.129.16'
var dnsServers = (customDnsIps == 'none') ? []: (split(allDnsServers, ','))
var varCreateAvdFslogixDeployment = (avdIdentityServiceProvider == 'AAD') ? false: createAvdFslogixDeployment
var varAvdApplicationGroupIdentitiesIds = !empty(avdApplicationGroupIdentitiesIds) ? (split(avdApplicationGroupIdentitiesIds, ',')): []
var varCreateAvdVnetPeering = !empty(existingHubVnetResourceId) ? true: false
// Resource tagging
// Tag Exclude-${avdScalingPlanName} is used by scaling plans to exclude session hosts from scaling. Exmaple: Exclude-vdscal-eus2-app1-001
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
// Network.
module avdBaselineNetworkResourceGroup '../../carml/1.2.0/Microsoft.Resources/resourceGroups/deploy.bicep' = if (createAvdVnet) {
    scope: subscription(avdWorkloadSubsId)
    name: 'Deploy-${avdNetworkObjectsRgName}-${time}'
    params: {
        name: avdNetworkObjectsRgName
        location: avdSessionHostLocation
        enableDefaultTelemetry: false
        tags: createResourceTags ? commonResourceTags : {}
    }
}

// Service objects.
module avdBaselineServiceObjectsResourceGroup '../../carml/1.2.0/Microsoft.Resources/resourceGroups/deploy.bicep' = {
    scope: subscription(avdWorkloadSubsId)
    name: 'Deploy-${avdServiceObjectsRgName}-${time}'
    params: {
        name: avdServiceObjectsRgName
        location: avdSessionHostLocation
        enableDefaultTelemetry: false
        tags: createResourceTags ? commonResourceTags : {}
    }
}

// Compute.
module avdBaselineComputeResourceGroup '../../carml/1.2.0/Microsoft.Resources/resourceGroups/deploy.bicep' = {
    scope: subscription(avdWorkloadSubsId)
    name: 'Deploy-${avdComputeObjectsRgName}-${time}'
    params: {
        name: avdComputeObjectsRgName
        location: avdSessionHostLocation
        enableDefaultTelemetry: false
        tags: createResourceTags ? allComputeStorageTags : {}
    }
}

// Storage.
module avdBaselineStorageResourceGroup '../../carml/1.2.0/Microsoft.Resources/resourceGroups/deploy.bicep' = if (varCreateAvdFslogixDeployment && (avdIdentityServiceProvider != 'AAD')) {
    scope: subscription(avdWorkloadSubsId)
    name: 'Deploy-${avdStorageObjectsRgName}-${time}'
    params: {
        name: avdStorageObjectsRgName
        location: avdSessionHostLocation
        enableDefaultTelemetry: false
        tags: createResourceTags ? allComputeStorageTags : {}
    }
}
//

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


// Networking.
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
        avdVnetworkPeeringName: avdIdentityServiceProvider == 'AAD' ? '': avdVnetworkPeeringName
        avdVnetworkSubnetName: avdVnetworkSubnetName
        createAvdVnet: createAvdVnet
        createAvdVnetPeering: varCreateAvdVnetPeering
        vNetworkGatewayOnHub: vNetworkGatewayOnHub
        existingHubVnetResourceId: avdIdentityServiceProvider == 'AAD' ? '': existingHubVnetResourceId
        avdSessionHostLocation: avdSessionHostLocation
        avdVnetworkSubnetAddressPrefix: avdVnetworkSubnetAddressPrefix
        avdWorkloadSubsId: avdWorkloadSubsId
        dnsServers: dnsServers
        avdTags: createResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        avdBaselineNetworkResourceGroup
    ]
}

// AVD management plane.
module avdManagementPLane 'avd-modules/avd-management-plane.bicep' = {
    name: 'Deploy-AVD-HostPool-AppGroups-${time}'
    params: {
        avdApplicationGroupNameDesktop: avdApplicationGroupNameDesktop
        avdWorkSpaceName: avdWorkSpaceName
        avdApplicationGroupNameRapp: avdApplicationGroupNameRapp
        avdDeployRappGroup: avdDeployRappGroup
        avdTimeZone: timeZones[avdSessionHostLocation]
        avdHostPoolName: avdHostPoolName
        avdHostPoolRdpProperties: avdHostPoolRdpProperties
        avdHostPoolLoadBalancerType: avdHostPoolLoadBalancerType
        avdHostPoolType: avdHostPoolType
        avdDeployScalingPlan: avdDeployScalingPlan
        avdScalingPlanExclusionTag: avdScalingPlanExclusionTag
        avdScalingPlanSchedules: avdScalingPlanSchedules
        avdScalingPlanName: avdScalingPlanName
        avhHostPoolMaxSessions: avhHostPoolMaxSessions
        avdPersonalAssignType: avdPersonalAssignType
        avdManagementPlaneLocation: avdManagementPlaneLocation
        avdServiceObjectsRgName: avdServiceObjectsRgName
        avdStartVmOnConnect: avdStartVmOnConnect
        avdWorkloadSubsId: avdWorkloadSubsId
        avdIdentityServiceProvider: avdIdentityServiceProvider
        avdApplicationGroupIdentitiesIds: varAvdApplicationGroupIdentitiesIds
        avdApplicationGroupIdentityType: avdApplicationGroupIdentityType
        avdTags: createResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        avdBaselineServiceObjectsResourceGroup
        deployAvdManagedIdentitiesRoleAssign
    ]
}

// Identity: managed identities and role assignments.
module deployAvdManagedIdentitiesRoleAssign 'avd-modules/avd-identity.bicep' = {
    name: 'Create-Managed-ID-RoleAssign-${time}'
    params: {
        avdComputeObjectsRgName: avdComputeObjectsRgName
        avdDeploySessionHosts: avdDeploySessionHosts
        avdEnterpriseAppObjectId: avdEnterpriseAppObjectId
        avdDeployScalingPlan: avdDeployScalingPlan
        avdSessionHostLocation: avdSessionHostLocation
        avdServiceObjectsRgName: avdServiceObjectsRgName
        avdStorageObjectsRgName: avdStorageObjectsRgName
        avdWorkloadSubsId: avdWorkloadSubsId
        createStartVmOnConnectCustomRole: createStartVmOnConnectCustomRole
        fslogixManagedIdentityName: fslogixManagedIdentityName
        readerRoleId: readerRoleId
        avdManagementPlaneLocation: avdManagementPlaneLocation
        avdIdentityServiceProvider: avdIdentityServiceProvider
        storageAccountContributorRoleId: storageAccountContributorRoleId
        avdVmPowerStateContributor: avdVmPowerStateContributor
        createAvdFslogixDeployment: varCreateAvdFslogixDeployment
        avdApplicationGroupIdentitiesIds: varAvdApplicationGroupIdentitiesIds
        avdTags: createResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        avdBaselineComputeResourceGroup
        avdBaselineStorageResourceGroup
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
        tags: createResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        avdBaselineServiceObjectsResourceGroup
        //updateExistingSubnet
    ]
}

// Call on the KV.
resource avdWrklKeyVaultget 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = if (avdDeploySessionHosts) {
    name: avdWrklKvName
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
}

// Storage.
module deployAvdStorageAzureFiles 'avd-modules/avd-storage-azurefiles.bicep' = if (varCreateAvdFslogixDeployment && avdDeploySessionHosts && (avdIdentityServiceProvider != 'AAD')) {
    name: 'Deploy-AVD-Storage-AzureFiles-${time}'
    params: {
        avdIdentityServiceProvider: avdIdentityServiceProvider
        storageToDomainScript:  storageToDomainScript
        storageToDomainScriptArgs: storageToDomainScriptArgs
        storageToDomainScriptUri: storageToDomainScriptUri
        avdTimeZone: timeZones[avdSessionHostLocation]
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
        avdImageTemplateDefinitionId: avdImageTemplateDefinitionId
        sessionHostOuPath: avdOuPath
        avdSessionHostDiskType: avdSessionHostDiskType
        avdSessionHostLocation: avdSessionHostLocation
        avdSessionHostsSize: avdSessionHostsSize
        avdStorageObjectsRgName: avdStorageObjectsRgName
        avdSubnetId: createAvdVnet ? '${avdNetworking.outputs.avdVirtualNetworkResourceId}/subnets/${avdVnetworkSubnetName}' : existingVnetSubnetResourceId
        createAvdVnet: createAvdVnet
        avdVmLocalUserName: avdVmLocalUserName
        avdVnetPrivateDnsZone: avdVnetPrivateDnsZone
        avdVnetPrivateDnsZoneFilesId: avdVnetPrivateDnsZoneFilesId
        avdWorkloadSubsId: avdWorkloadSubsId
        encryptionAtHost: encryptionAtHost
        fslogixManagedIdentityResourceId: varCreateAvdFslogixDeployment ? deployAvdManagedIdentitiesRoleAssign.outputs.fslogixManagedIdentityResourceId : ''
        avdFslogixFileShareMultichannel: (contains(fslogixStorageSku, 'Premium_LRS') || contains(fslogixStorageSku, 'Premium_ZRS')) ? true : false
        fslogixStorageSku: fslogixStorageSku
        marketPlaceGalleryWindows: marketPlaceGalleryWindows['win10_21h2']
        subnetResourceId: createAvdVnet ? '${avdNetworking.outputs.avdVirtualNetworkResourceId}/subnets/${avdVnetworkSubnetName}' : existingVnetSubnetResourceId
        managementVmName: managementVmName
        useSharedImage: useSharedImage
        avdTags: createResourceTags ? allResourceTags : {}
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
        avdAgentPackageLocation: avdAgentPackageLocation
        avdTimeZone: timeZones[avdSessionHostLocation]
        avdApplicationSecurityGroupResourceId: createAvdVnet ? '${avdNetworking.outputs.avdApplicationSecurityGroupResourceId}' : ''
        avdAsFaultDomainCount: avdAsFaultDomainCount
        avdAsUpdateDomainCount: avdAsUpdateDomainCount
        avdIdentityServiceProvider: avdIdentityServiceProvider
        createIntuneEnrollment: createIntuneEnrollment
        avdAvailabilitySetNamePrefix: avdAvailabilitySetNamePrefix
        avdComputeObjectsRgName: avdComputeObjectsRgName
        avdDeploySessionHostsCount: avdDeploySessionHostsCount
        avdSessionHostCountIndex: avdSessionHostCountIndex
        avdDomainJoinUserName: avdDomainJoinUserName
        avdWrklKvName: avdWrklKvName
        avdServiceObjectsRgName: avdServiceObjectsRgName
        avdHostPoolName: avdHostPoolName
        avdIdentityDomainName: avdIdentityDomainName
        avdImageTemplateDefinitionId: avdImageTemplateDefinitionId
        sessionHostOuPath: avdOuPath
        avdSessionHostDiskType: avdSessionHostDiskType
        avdSessionHostLocation: avdSessionHostLocation
        avdSessionHostNamePrefix: avdSessionHostNamePrefix
        avdSessionHostsSize: avdSessionHostsSize
        avdSubnetId: createAvdVnet ? '${avdNetworking.outputs.avdVirtualNetworkResourceId}/subnets/${avdVnetworkSubnetName}' : existingVnetSubnetResourceId
        createAvdVnet: createAvdVnet
        avdUseAvailabilityZones: avdUseAvailabilityZones
        avdVmLocalUserName: avdVmLocalUserName
        avdWorkloadSubsId: avdWorkloadSubsId
        encryptionAtHost: encryptionAtHost
        createAvdFslogixDeployment: (avdIdentityServiceProvider != 'AAD') ? varCreateAvdFslogixDeployment: false
        fslogixManagedIdentityResourceId:  (varCreateAvdFslogixDeployment && (avdIdentityServiceProvider != 'AAD'))  ? deployAvdManagedIdentitiesRoleAssign.outputs.fslogixManagedIdentityResourceId : ''
        fsLogixScript: (avdIdentityServiceProvider != 'AAD') ? fsLogixScript: ''
        FsLogixScriptArguments: (avdIdentityServiceProvider != 'AAD') ? FsLogixScriptArguments: ''
        fslogixScriptUri: (avdIdentityServiceProvider != 'AAD') ? fslogixScriptUri: ''
        FslogixSharePath: (avdIdentityServiceProvider != 'AAD') ? fslogixSharePath: ''
        hostPoolToken: avdManagementPLane.outputs.hostPooltoken
        marketPlaceGalleryWindows: marketPlaceGalleryWindows[avdOsImage]
        useSharedImage: useSharedImage
        avdTags: createResourceTags ? allResourceTags : {}
    }
    dependsOn: [
        avdBaselineComputeResourceGroup
        avdNetworking
        avdWrklKeyVaultget
        avdWrklKeyVault
    ]
}
