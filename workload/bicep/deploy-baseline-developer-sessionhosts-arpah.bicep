metadata name = 'AVD Accelerator - Developer Host Pool Deployment'
metadata description = 'AVD Accelerator - Deployment Developer Host Pool'

targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@minLength(2)
@maxLength(4)
@sys.description('The name of the resource group to deploy. (Default: AVD1)')
param deploymentPrefix string = 'AVDN'

@allowed([
    'Dev' // Development
    'Test' // Test
    'Prod' // Production
])
@sys.description('The name of the resource group to deploy. (Default: Dev)')
param deploymentEnvironment string = 'Test'

@allowed([
    'Developer'
    'Admin'
])
@sys.description('The name of type of host pool to use for deploying session hosts to. (Default: developer)')
param hostPoolPersona string = 'Developer'

@maxValue(730)
@minValue(30)
@sys.description('This value is used to set the expiration date on the disk encryption key. (Default: 60)')
param diskEncryptionKeyExpirationInDays int = 60

@sys.description('Location where to deploy compute services. (Default: eastus2)')
param avdSessionHostLocation string = 'eastus2'

@sys.description('Location where to deploy AVD management plane. (Default: eastus2)')
param avdManagementPlaneLocation string = 'eastus2'

@sys.description('AVD workload subscription ID, multiple subscriptions scenario. (Default: "")')
param avdWorkloadSubsId string = ''

@allowed([
    'ADDS' // Active Directory Domain Services
    'EntraDS' // Microsoft Entra Domain Services
    'EntraID' // Microsoft Entra ID Join
])
@sys.description('Required, The service providing domain services for Azure Virtual Desktop. (Default: ADDS)')
param avdIdentityServiceProvider string = 'ADDS'

@sys.description('Required, Eronll session hosts on Intune. (Default: false)')
param createIntuneEnrollment bool = false

@sys.description('FQDN of on-premises AD domain, used for FSLogix storage configuration and NTFS setup. (Default: "")')
param identityDomainName string = 'none'

@sys.description('OU path to join AVd VMs. (Default: "")')
param avdOuPath string = ''

@sys.description('Existing virtual network subnet for AVD. (Default: "")')
param existingVnetAvdSubnetResourceId string = ''

@sys.description('Existing virtual network subnet for private endpoints. (Default: "")')
param existingVnetPrivateEndpointSubnetResourceId string = ''

@sys.description('Deploy private endpoints for key vault and storage. (Default: true)')
param deployPrivateEndpointKeyvaultStorage bool = false

@sys.description('Deploy Fslogix setup. (Default: true)')
param createAvdFslogixDeployment bool = true

@sys.description('Deploy new session hosts. (Default: true)')
param avdDeploySessionHosts bool = true

@minValue(1)
@maxValue(100)
@sys.description('Quantity of session hosts to deploy. (Default: 1)')
param avdDeploySessionHostsCount int = 2

@sys.description('The session host number to begin with for the deployment. This is important when adding virtual machines to ensure the names do not conflict. (Default: 0)')
param avdSessionHostCountIndex int = 0

@sys.description('When true VMs are distributed across availability zones, when set to false, VMs will be members of a new availability set. (Default: true)')
param availabilityZonesCompute bool = true

@sys.description('Enables a zero trust configuration on the session host disks. (Default: false)')
param diskZeroTrust bool = false

@sys.description('Session host VM size. (Default: Standard_D4ads_v5)') // getting OverconstrainedZonalAllocationRequest error on provisioning the session host, so switching to Standard_E4s_v5, for prod: Standard_E8s_v5
param avdSessionHostsSize string = 'Standard_E4s_v5'

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
    'win10_21h2'
    'win10_21h2_office'
    'win10_22h2_g2'
    'win10_22h2_office_g2'
    'win11_21h2'
    'win11_21h2_office'
    'win11_22h2'
    'win11_22h2_office'
    'win11_23h2'
    'win11_23h2_office'
])
@sys.description('AVD OS image SKU. (Default: win11-22h2)')
param avdOsImage string = 'win11_23h2_office'

@sys.description('Set to deploy image from Azure Compute Gallery. (Default: false)')
param useSharedImage bool = false

@sys.description('Image from Azure Compute Gallery.')
param goldenImageId string  = ''

@sys.description('Image from Azure Compute Gallery Subscription ID.')
param imageGallerySubscriptionId string = ''

@sys.description('Source custom image ID. (Default: "")')
param avdImageTemplateDefinitionId string = '/subscriptions/${imageGallerySubscriptionId}/resourceGroups/rg-avd-golden-image/providers/Microsoft.Compute/galleries/acgavd/images/${goldenImageId}'

// Custom Naming
// Input must followe resource naming rules on https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules
@sys.description('AVD resources custom naming. (Default: false)')
param avdUseCustomNaming bool = true

@maxLength(90)
@sys.description('AVD service resources resource group custom name. (Default: rg-avd-app1-dev-use2-service-objects)')
param avdServiceObjectsRgCustomName string = 'avd-nih-arpah-${toLower(deploymentEnvironment)}-use2-service-objects'

@maxLength(90)
@sys.description('AVD network resources resource group custom name. (Default: rg-avd-app1-dev-use2-network)')
param avdNetworkObjectsRgCustomName string = 'avd-nih-arpah-${toLower(deploymentEnvironment)}-use2-network'

@maxLength(90)
@sys.description('AVD network resources resource group custom name. (Default: rg-avd-app1-dev-use2-pool-compute)')
param avdComputeObjectsRgCustomName string = 'avd-nih-arpah-${toLower(deploymentEnvironment)}-use2-pool-compute'

@maxLength(90)
@sys.description('AVD monitoring resource group custom name. (Default: rg-avd-dev-use2-monitoring)')
param avdMonitoringRgCustomName string = 'avd-nih-arpah-${toLower(deploymentEnvironment)}-use2-monitoring'

@maxLength(64)
@sys.description('AVD Azure log analytics workspace custom name. (Default: log-avd-app1-dev-use2)')
param avdAlaWorkspaceCustomName string = 'avd-nih-arpah-${toLower(deploymentEnvironment)}-use2-log'

@maxLength(80)
@sys.description('AVD application security custom name. (Default: asg-app1-dev-use2-001)')
param avdApplicationSecurityGroupCustomName string = 'asg-app1-${toLower(deploymentEnvironment)}-use2-001'

@maxLength(64)
@sys.description('AVD host pool custom name. (Default: vdpool-app1-dev-use2-001)')
//param avdHostPoolCustomName string = 'vdpool-${toLower(hostPoolPersona)}-${toLower(deploymentEnvironment)}-use2-001'
param avdHostPoolCustomName string = 'vdpool-${toLower(hostPoolPersona)}-${toLower(avdHostPoolType)}-${toLower(deploymentEnvironment)}-use2-001'

@maxLength(11)
@sys.description('AVD session host prefix custom name. (Default: vmapp1duse2)')
param avdSessionHostCustomNamePrefix string = 'vmapp1duse2'

@maxLength(2)
@sys.description('AVD FSLogix and MSIX app attach storage account prefix custom name. (Default: st)')
param storageAccountPrefixCustomName string = 'st'

@sys.description('FSLogix file share name. (Default: fslogix-pc-app1-dev-001)')
param fslogixFileShareCustomName string = 'fslogix-pc-app1-${toLower(deploymentEnvironment)}-use2-001'

@maxLength(6)
@sys.description('AVD keyvault prefix custom name (with Zero Trust to store credentials to domain join and local admin). (Default: kv-sec)')
param avdWrklKvPrefixCustomName string = 'kv-sec'

@maxLength(6)
@sys.description('AVD disk encryption set custom name. (Default: des-zt)')
param ztDiskEncryptionSetCustomNamePrefix string = 'des-zt'

@maxLength(6)
@sys.description('AVD key vault custom name for zero trust and store store disk encryption key (Default: kv-key)')
param ztKvPrefixCustomName string = 'kv-key'

//
// Resource tagging
//
@sys.description('Apply tags on resources and resource groups. (Default: false)')
param createResourceTags bool = false

@sys.description('The name of workload for tagging purposes. (Default: Contoso-Workload)')
param workloadNameTag string = 'AVD ${deploymentEnvironment} ARPA-H ${hostPoolPersona} on NIH Network '

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
param departmentTag string = 'ARPA-H-AVD'

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
param workloadCriticalityCustomValueTag string = 'ARPA-H-Critical'

@sys.description('Details about the application.')
param applicationNameTag string = 'ARPA-H-AVD'

@sys.description('Service level agreement level of the worload. (Contoso-SLA)')
param workloadSlaTag string = 'ARPA-H-SLA'

@sys.description('Team accountable for day-to-day operations. (workload-admins@Contoso.com)')
param opsTeamTag string = 'workload-admins@arpa-h.gov'

@sys.description('Organizational owner of the AVD deployment. (Default: workload-owner@Contoso.com)')
param ownerTag string = 'workload-owner@arpa-h.gov'

@sys.description('Cost center of owner team. (Default: Contoso-CC)')
param costCenterTag string = 'ARPA-H-CC'

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

@sys.description('Enable purge protection for the keyvaults. (Default: true)')
param enableKvPurgeProtection bool = true

@sys.description('Deploys anti malware extension on session hosts. (Default: true)')
param deployAntiMalwareExt bool = true

// This is the object id for the 'ARPA-H AVD Default' MS Entra Group
@sys.description('Optional, Identity ID to grant RBAC role to access AVD application group and NTFS permissions. (Default: "")')
param securityPrincipalId string = ''

@allowed([
    'Personal'
    'Pooled'
])
@sys.description('AVD host pool type. (Default: Pooled)')
param avdHostPoolType string = 'Pooled'

param maxSessionHostsPerTemplate int = 10

// @maxLength(90)
// @sys.description('AVD network resources resource group custom name. (Default: rg-avd-app1-dev-use2-storage)')
// param avdStorageObjectsRgCustomName string = 'avd-nih-arpah-${toLower(deploymentEnvironment)}-use2-storage'

// =========== //
// Variable declaration //
// =========== //
// Resource naming
var varDeploymentPrefixLowercase = toLower(deploymentPrefix)
var varAzureCloudName = environment().name
var varDeploymentEnvironmentLowercase = toLower(deploymentEnvironment)
var varDeploymentEnvironmentComputeStorage = (deploymentEnvironment == 'Dev') 
    ? 'd' 
    : ((deploymentEnvironment == 'Test') ? 't' : ((deploymentEnvironment == 'Prod') ? 'p' : ''))
var varNamingUniqueStringThreeChar = take('${uniqueString(avdWorkloadSubsId, varDeploymentPrefixLowercase, time)}', 3)
var varNamingUniqueStringTwoChar = take('${uniqueString(avdWorkloadSubsId, varDeploymentPrefixLowercase, time)}', 2)
var varSessionHostLocationAcronym = varLocations[varSessionHostLocationLowercase].acronym
var varManagementPlaneLocationAcronym = varLocations[varManagementPlaneLocationLowercase].acronym
var varLocations = loadJsonContent('../variables/locations-arpah.json')
var varTimeZoneSessionHosts = varLocations[varSessionHostLocationLowercase].timeZone
var varManagementPlaneNamingStandard = '${varDeploymentPrefixLowercase}-${varDeploymentEnvironmentLowercase}-${varManagementPlaneLocationAcronym}'
var varComputeStorageResourcesNamingStandard = '${varDeploymentPrefixLowercase}-${varDeploymentEnvironmentLowercase}-${varSessionHostLocationAcronym}'
var varDiskEncryptionSetName = avdUseCustomNaming 
    ? '${ztDiskEncryptionSetCustomNamePrefix}-${varComputeStorageResourcesNamingStandard}-001' 
    : 'des-zt-${varComputeStorageResourcesNamingStandard}-001'
var varSessionHostLocationLowercase = toLower(replace(avdSessionHostLocation, ' ', ''))
var varManagementPlaneLocationLowercase = toLower(replace(avdManagementPlaneLocation, ' ', ''))
var varServiceObjectsRgName = avdUseCustomNaming 
    ? avdServiceObjectsRgCustomName 
    : 'rg-avd-${varManagementPlaneNamingStandard}-service-objects' // max length limit 90 characters
var varNetworkObjectsRgName = avdUseCustomNaming 
    ? avdNetworkObjectsRgCustomName 
    : 'rg-avd-${varComputeStorageResourcesNamingStandard}-network' // max length limit 90 characters
var varComputeObjectsRgName = avdUseCustomNaming 
    ? avdComputeObjectsRgCustomName 
    : 'rg-avd-${varComputeStorageResourcesNamingStandard}-pool-compute' // max length limit 90 characters
var varMonitoringRgName = avdUseCustomNaming 
    ? avdMonitoringRgCustomName 
    : 'rg-avd-${varDeploymentEnvironmentLowercase}-${varManagementPlaneLocationAcronym}-monitoring' // max length limit 90 characters
var varApplicationSecurityGroupName = avdUseCustomNaming 
    ? avdApplicationSecurityGroupCustomName 
    : 'asg-${varComputeStorageResourcesNamingStandard}-001'
var varHostPoolName = avdUseCustomNaming ? avdHostPoolCustomName : 'vdpool-${varManagementPlaneNamingStandard}-001'
var varWrklKvName = avdUseCustomNaming 
    ? '${avdWrklKvPrefixCustomName}-${varComputeStorageResourcesNamingStandard}' 
    : 'kv-sec-${varComputeStorageResourcesNamingStandard}-${varNamingUniqueStringTwoChar}' // max length limit 24 characters
var varWrklKeyVaultSku = (varAzureCloudName == 'AzureCloud' || varAzureCloudName == 'AzureUSGovernment') 
    ? 'premium' 
    : (varAzureCloudName == 'AzureChinaCloud' ? 'standard' : null)
var varSessionHostNamePrefix = avdUseCustomNaming 
    ? avdSessionHostCustomNamePrefix 
    : 'vm${varDeploymentPrefixLowercase}${varDeploymentEnvironmentComputeStorage}${varSessionHostLocationAcronym}'
var varFslogixFileShareName = avdUseCustomNaming 
    ? fslogixFileShareCustomName 
    : 'fslogix-pc-${varDeploymentPrefixLowercase}-${varDeploymentEnvironmentLowercase}-${varSessionHostLocationAcronym}-001'
var varFslogixStorageName = avdUseCustomNaming 
    ? '${storageAccountPrefixCustomName}fsl${varDeploymentPrefixLowercase}${varDeploymentEnvironmentComputeStorage}biz' 
    : 'stfsl${varDeploymentPrefixLowercase}${varDeploymentEnvironmentComputeStorage}${varNamingUniqueStringThreeChar}'
var varFslogixStorageFqdn = createAvdFslogixDeployment 
    ? '${varFslogixStorageName}.file.${environment().suffixes.storage}' 
    : ''
var varDataCollectionRulesName = 'dcr-avd-${varDeploymentEnvironmentLowercase}-${varManagementPlaneLocationAcronym}'
var varZtKvName = avdUseCustomNaming 
    ? '${ztKvPrefixCustomName}-${varComputeStorageResourcesNamingStandard}-${varNamingUniqueStringTwoChar}' 
    : 'kv-key-${varComputeStorageResourcesNamingStandard}-${varNamingUniqueStringTwoChar}' // max length limit 24 characters
var varZtKvPrivateEndpointName = 'pe-${varZtKvName}-vault'
//
var varFslogixSharePath = createAvdFslogixDeployment 
    ? '\\\\${varFslogixStorageName}.file.${environment().suffixes.storage}\\${varFslogixFileShareName}' 
    : ''

var varBaseScriptUri = 'https://raw.githubusercontent.com/ARPA-H/avdaccelerator-nih/main/workload/'
var varSessionHostConfigurationScriptUri = '${varBaseScriptUri}scripts/Set-SessionHostConfiguration.ps1'
var varSessionHostConfigurationScript = './Set-SessionHostConfiguration.ps1'
var varMaxSessionHostsPerTemplate = maxSessionHostsPerTemplate
var varMaxSessionHostsDivisionValue = avdDeploySessionHostsCount / varMaxSessionHostsPerTemplate
var varMaxSessionHostsDivisionRemainderValue = avdDeploySessionHostsCount % varMaxSessionHostsPerTemplate
var varSessionHostBatchCount = varMaxSessionHostsDivisionRemainderValue > 0 
    ? varMaxSessionHostsDivisionValue + 1 
    : varMaxSessionHostsDivisionValue

var varMarketPlaceGalleryWindows = loadJsonContent('../variables/osMarketPlaceImages.json')
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

var varAvdDefaultTags = {
    'cm-resource-parent': '/subscriptions/${avdWorkloadSubsId}/resourceGroups/${varServiceObjectsRgName}/providers/Microsoft.DesktopVirtualization/hostpools/${varHostPoolName}'
    Environment: deploymentEnvironment
    ServiceWorkload: 'AVD'
    CreationTimeUTC: time
}

var varZtKeyvaultTag = {
    Purpose: 'Disk encryption keys for zero trust'
}    

// retrieve existing resources
resource keyVaultExisting 'Microsoft.KeyVault/vaults@2024-12-01-preview' existing = {
  name: varWrklKvName
  scope: resourceGroup('${avdWorkloadSubsId}', '${varServiceObjectsRgName}')
}

resource privateDnsZoneKeyVault 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: 'privatelink.vaultcore.azure.net'
  scope: resourceGroup('${avdWorkloadSubsId}', '${varNetworkObjectsRgName}')
}

resource applicationSecurityGroupExisting 'Microsoft.Network/applicationSecurityGroups@2023-04-01' existing = {
  name: varApplicationSecurityGroupName
  scope: resourceGroup('${avdWorkloadSubsId}', '${varComputeObjectsRgName}')
}

resource dataCollectionRulesExisting 'Microsoft.Insights/dataCollectionRules@2022-06-01' existing = {
  name: varDataCollectionRulesName
  scope: resourceGroup('${avdWorkloadSubsId}', '${varMonitoringRgName}')
}

resource logAnalyticsWorkspaceExisting 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: avdAlaWorkspaceCustomName
  scope: resourceGroup('${avdWorkloadSubsId}', '${varMonitoringRgName}')
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
      vaultSku: any(varWrklKeyVaultSku)
      diskEncryptionKeyExpirationInDays: diskEncryptionKeyExpirationInDays
      diskEncryptionSetName: varDiskEncryptionSetName
      ztKvName: varZtKvName
      ztKvPrivateEndpointName: varZtKvPrivateEndpointName
      privateEndpointsubnetResourceId: existingVnetPrivateEndpointSubnetResourceId
      deployPrivateEndpointKeyvaultStorage: deployPrivateEndpointKeyvaultStorage
      keyVaultprivateDNSResourceId: privateDnsZoneKeyVault.id
      tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
      enableKvPurgeProtection: enableKvPurgeProtection
      kvTags: varZtKeyvaultTag
    }
}  

resource existingHostPool 'Microsoft.DesktopVirtualization/hostPools@2023-09-05' existing = {
    name: avdHostPoolCustomName
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgCustomName}')
}

// Session hosts
@batchSize(3)
module sessionHosts './modules/avdSessionHosts/deploy-developer-arpah.bicep' = [
  for i in range(1, varSessionHostBatchCount): if (avdDeploySessionHosts) {
    name: 'SH-Batch-${i - 1}-${time}'
    params: {
      diskEncryptionSetResourceId: diskZeroTrust ? zeroTrust.outputs.ztDiskEncryptionSetResourceId : ''
      timeZone: varTimeZoneSessionHosts
      asgResourceId: (avdDeploySessionHosts || createAvdFslogixDeployment)
        ? '${applicationSecurityGroupExisting.id}'
        : ''
      identityServiceProvider: avdIdentityServiceProvider
      createIntuneEnrollment: createIntuneEnrollment
      batchId: i - 1
      computeObjectsRgName: varComputeObjectsRgName
      count: i == varSessionHostBatchCount && varMaxSessionHostsDivisionRemainderValue > 0
        ? varMaxSessionHostsDivisionRemainderValue
        : varMaxSessionHostsPerTemplate
      countIndex: i == 1
        ? avdSessionHostCountIndex
        : (((i - 1) * varMaxSessionHostsPerTemplate) + avdSessionHostCountIndex)
      domainJoinUserName: keyVaultExisting.getSecret('domainJoinUserName')
      domainJoinPassword: keyVaultExisting.getSecret('domainJoinUserPassword')
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
      subnetId: existingVnetAvdSubnetResourceId
      useAvailabilityZones: availabilityZonesCompute
      subscriptionId: avdWorkloadSubsId
      encryptionAtHost: diskZeroTrust
      createAvdFslogixDeployment: createAvdFslogixDeployment
      fslogixSharePath: varFslogixSharePath
      fslogixStorageAccountResourceId: ''
      hostPoolResourceId: existingHostPool.id
      fslogixStorageFqdn: varFslogixStorageFqdn
      sessionHostConfigurationScriptUri: varSessionHostConfigurationScriptUri
      sessionHostConfigurationScript: varSessionHostConfigurationScript
      marketPlaceGalleryWindows: varMarketPlaceGalleryWindows[avdOsImage]
      useSharedImage: useSharedImage
      tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
      deployMonitoring: true
      alaWorkspaceResourceId: logAnalyticsWorkspaceExisting.id
      dataCollectionRuleId: dataCollectionRulesExisting.id
      deployAntiMalwareExt: deployAntiMalwareExt
      securityPrincipalId: securityPrincipalId
    }
  }
]
