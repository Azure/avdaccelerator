targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@sys.description('Location where to deploy compute services.')
param location string

@sys.description('Resource Group name where to deploy session hosts.')
param computeRgResourceGroupName string

@minLength(2)
@maxLength(4)
@sys.description('The name of the resource group to deploy.')
param deploymentPrefix string = 'AVD1'

@allowed([
  'Dev' // Development
  'Test' // Test
  'Prod' // Production
])
@sys.description('The name of the resource group to deploy.')
param deploymentEnvironment string = 'Dev'

@sys.description('AVD Host Pool resource ID.')
param hostPoolResourceId string

@sys.description('AVD resources custom naming.')
param customNaming bool = false

@maxLength(11)
@sys.description('AVD session host prefix custom name.')
param sessionHostCustomNamePrefix string = ''

@sys.description('Quantity of session hosts to deploy.')
param count int = 1

@sys.description('The session host number to begin with for the deployment.')
param countIndex int

@sys.description('OS disk type for session host. (Default: Premium_LRS)')
param diskType string = 'Premium_LRS'

@sys.description('Optional. Define custom OS disk size if larger than image size. Set to 0 for default size.')
param customOsDiskSizeGB int = 0

@sys.description('Session host VM size. (Default: Standard_D4ads_v5)')
param vmSize string = 'Standard_D4ads_v5'

@sys.description('Enables accelerated Networking on the session hosts.')
param enableAcceleratedNetworking bool = true

@sys.description('When true VMs are distributed across availability zones, when set to false, VMs will be deployed at regional level.')
@allowed([
  'None'
  'AvailabilityZones'
])
param availability string = 'None'

@sys.description('The Availability Zones to use for the session hosts.')
@allowed([
  '1'
  '2'
  '3'
])
param availabilityZones array = ['1', '2', '3']

@sys.description('Set to deploy image from Azure Compute Gallery. (Default: false)')
param useSharedImage bool = false

@sys.description('AVD OS image SKU. (Default: win11-23h2)')
param mpImageOffer string = 'Office-365'

@sys.description('AVD OS image SKU. (Default: win11-23h2)')
param mpImageSku string = 'win11-24h2-avd-m365'

@sys.description('Source custom image ID.')
param customImageDefinitionId string = ''

@sys.description('Application Security Group (ASG) for the session hosts.')
param asgResourceId string = ''

@allowed([
  'Standard'
  'TrustedLaunch'
])
@sys.description('Specifies the securityType of the virtual machine. "TrustedLaunch" requires a Gen2 Image. (Default: TrustedLaunch)')
param securityType string = 'TrustedLaunch'

@sys.description('Specifies whether secure boot should be enabled on the virtual machine. This parameter is part of the UefiSettings. securityType should be set to TrustedLaunch or ConfidentialVM to enable UefiSettings.')
param secureBootEnabled bool = true

@sys.description('Specifies whether vTPM should be enabled on the virtual machine. This parameter is part of the UefiSettings. securityType should be set to TrustedLaunch or ConfidentialVM to enable UefiSettings.')
param vTpmEnabled bool = true

@sys.description('Enable Encryption At Host')
param encryptionAtHost bool

@sys.description('AVD disk encryption set resource ID to enable server side encyption.')
param diskEncryptionSetResourceId string = ''

@sys.description('Deploys anti malware extension on session hosts.')
param deployAntiMalwareExt bool = true

@sys.description('The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string = 'ADDS'

@sys.description('Required, Eronll session hosts on Intune.')
param createIntuneEnrollment bool = false

@sys.description('FQDN of on-premises AD domain, used for FSLogix storage configuration and NTFS setup.')
param identityDomainName string = ''

@sys.description('OU path to join AVd VMs.')
param sessionHostOuPath string = ''

@sys.description('AVD session host domain join user principal name.')
param domainJoinUserPrincipalName string = ''

@sys.description('Resource ID of keyvault that contains credentials.')
param keyVaultResourceId string

@sys.description('AVD session host subnet resource ID.')
param subnetResourceId string

@sys.description('Deploy AVD monitoring resources and setings.')
param enableMonitoring bool = false

@sys.description('Data collection rule ID.')
param dataCollectionRuleId string

@sys.description('Deploy Fslogix setup.')
param configureFslogix bool = false

@sys.description('The resource ID of the Azure Files storage account.')
param fslogixStorageAccountResourceId string = ''

@sys.description('FSLogix file share name.')
param fslogixFileShareName string = ''

@sys.description('Apply tags on resources and resource groups.')
param createResourceTags bool = false

@sys.description('Details about the application.')
param applicationNameTag string = ''

@sys.description('Cost center of owner team.')
param costCenterTag string = ''

@allowed([
  ''
  'Non-business'
  'Public'
  'General'
  'Confidential'
  'Highly-confidential'
])
@sys.description('Sensitivity of data hosted')
param dataClassificationTag string = ''

@sys.description('Department that owns the deployment.')
param departmentTag string = ''

@sys.description('Team accountable for day-to-day operations.')
param opsTeamTag string = ''

@sys.description('Organizational owner of the AVD deployment.')
param ownerTag string = ''

@sys.description('The name of workload for tagging purposes.')
param workloadNameTag string = ''

@allowed([
  ''
  'Light'
  'Medium'
  'High'
  'Power'
])
@sys.description('Reference to the size of the VM for your workloads.')
param workloadTypeTag string = ''

@allowed([
  ''
  'Low'
  'Medium'
  'High'
  'Mission-critical'
  'Custom'
])
@sys.description('Criticality of the workload.')
param workloadCriticalityTag string = ''

@sys.description('Tag value for custom criticality value.')
param workloadCriticalityCustomValueTag string = ''

@sys.description('Service level agreement level of the worload.')
param workloadSlaTag string = ''

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var varDeploymentPrefixLowercase = toLower(deploymentPrefix)
var varSessionHostLocationAcronym = varLocations[varSessionHostLocationLowercase].acronym
var varMaxSessionHostsPerTemplate = 10
var varMaxSessionHostsDivisionValue = count / varMaxSessionHostsPerTemplate
var varMaxSessionHostsDivisionRemainderValue = count % varMaxSessionHostsPerTemplate
var varSessionHostBatchCount = varMaxSessionHostsDivisionRemainderValue > 0
  ? varMaxSessionHostsDivisionValue + 1
  : varMaxSessionHostsDivisionValue

var varDeploymentEnvironmentComputeStorage = (deploymentEnvironment == 'Dev')
  ? 'd'
  : ((deploymentEnvironment == 'Test') ? 't' : ((deploymentEnvironment == 'Prod') ? 'p' : ''))
var varSessionHostNamePrefix = customNaming
  ? sessionHostCustomNamePrefix
  : 'vm${varDeploymentPrefixLowercase}${varDeploymentEnvironmentComputeStorage}${varSessionHostLocationAcronym}'
var varLocations = loadJsonContent('../../../variables/locations.json')
var varTimeZoneSessionHosts = varLocations[varSessionHostLocationLowercase].timeZone
var varSessionHostLocationLowercase = toLower(replace(location, ' ', ''))

var varFslogixSharePath = configureFslogix
  ? '\\\\${last(split(fslogixStorageAccountResourceId, '/'))}.file.${environment().suffixes.storage}\\${fslogixFileShareName}'
  : ''
var varBaseScriptUri = 'https://raw.githubusercontent.com/azure/avdaccelerator/main/workload/'
var varSessionHostConfigurationScriptUri = '${varBaseScriptUri}scripts/Set-SessionHostConfiguration.ps1'
var varSessionHostConfigurationScript = 'Set-SessionHostConfiguration.ps1'
var varAvdDefaultTags = {
  'cm-resource-parent': hostPoolResourceId
  Environment: deploymentEnvironment
  ServiceWorkload: 'AVD'
  CreationTimeUTC: time
}

var varTagsWithValues = union(
  empty(workloadNameTag) ? {} : { WorkloadName: workloadNameTag },
  empty(workloadTypeTag) ? {} : { WorkloadType: workloadTypeTag },
  empty(dataClassificationTag) ? {} : { DataClassification: dataClassificationTag },
  empty(departmentTag) ? {} : { Department: departmentTag },
  empty(workloadCriticalityTag)
    ? {}
    : { Criticality: (workloadCriticalityTag == 'Custom') ? workloadCriticalityCustomValueTag : workloadCriticalityTag },
  empty(applicationNameTag) ? {} : { ApplicationName: applicationNameTag },
  empty(workloadSlaTag) ? {} : { ServiceClass: workloadSlaTag },
  empty(opsTeamTag) ? {} : { OpsTeam: opsTeamTag },
  empty(ownerTag) ? {} : { Owner: ownerTag },
  empty(costCenterTag) ? {} : { CostCenter: costCenterTag }
)

var varCustomResourceTags = createResourceTags ? varTagsWithValues : {}

// =========== //
// Deployments //
// =========== //

// Call on the hotspool
resource hostPoolGet 'Microsoft.DesktopVirtualization/hostPools@2023-09-05' existing = {
  name: last(split(hostPoolResourceId, '/'))
  scope: resourceGroup(split(hostPoolResourceId, '/')[4])
}

// Hostpool update
module hostPool '../../../../avm/1.0.0/res/desktop-virtualization/host-pool/main.bicep' = {
  scope: resourceGroup(split(hostPoolResourceId, '/')[4])
  name: 'HostPool-${time}'
  params: {
    name: hostPoolGet.name
    friendlyName: hostPoolGet.properties.friendlyName
    location: hostPoolGet.location
    keyVaultResourceId: keyVaultResourceId
    hostPoolType: (hostPoolGet.properties.hostPoolType == 'Personal')
      ? 'Personal'
      : (hostPoolGet.properties.hostPoolType == 'Pooled') ? 'Pooled' : null
    startVMOnConnect: hostPoolGet.properties.startVMOnConnect
    customRdpProperty: hostPoolGet.properties.customRdpProperty
    loadBalancerType: (hostPoolGet.properties.loadBalancerType == 'BreadthFirst')
      ? 'BreadthFirst'
      : (hostPoolGet.properties.loadBalancerType == 'DepthFirst')
          ? 'DepthFirst'
          : (hostPoolGet.properties.loadBalancerType == 'Persistent') ? 'Persistent' : null
    maxSessionLimit: hostPoolGet.properties.maxSessionLimit
    preferredAppGroupType: (hostPoolGet.properties.preferredAppGroupType == 'Desktop')
      ? 'Desktop'
      : (hostPoolGet.properties.preferredAppGroupType == 'RailApplications') ? 'RailApplications' : null
    personalDesktopAssignmentType: (hostPoolGet.properties.personalDesktopAssignmentType == 'Automatic')
      ? 'Automatic'
      : (hostPoolGet.properties.personalDesktopAssignmentType == 'Direct') ? 'Direct' : null
    description: hostPoolGet.properties.description
    ssoadfsAuthority: hostPoolGet.properties.ssoadfsAuthority
    ssoClientId: hostPoolGet.properties.ssoClientId
    ssoClientSecretKeyVaultPath: hostPoolGet.properties.ssoClientSecretKeyVaultPath
    validationEnvironment: hostPoolGet.properties.validationEnvironment
    ring: hostPoolGet.properties.ring
    tags: hostPoolGet.tags
    agentUpdate: hostPoolGet.properties.agentUpdate
  }
}

@batchSize(10)
module sessionHosts '../../modules/avdSessionHosts/deploy.bicep' = [
  for i in range(1, varSessionHostBatchCount): {
    name: 'SH-Batch-${i}-${time}'
    params: {
      asgResourceId: asgResourceId
      availability: availability
      availabilityZones: availabilityZones
      batchId: i - 1
      computeObjectsRgName: computeRgResourceGroupName
      configureFslogix: configureFslogix
      count: i == varSessionHostBatchCount && varMaxSessionHostsDivisionRemainderValue > 0
        ? varMaxSessionHostsDivisionRemainderValue
        : varMaxSessionHostsPerTemplate
      countIndex: i == 1
        ? countIndex
        : (((i - 1) * varMaxSessionHostsPerTemplate) + countIndex)
      createIntuneEnrollment: createIntuneEnrollment      
      customImageDefinitionId: customImageDefinitionId
      customOsDiskSizeGB: customOsDiskSizeGB
      dataCollectionRuleId: dataCollectionRuleId
      deployAntiMalwareExt: deployAntiMalwareExt
      deployMonitoring: enableMonitoring
      diskEncryptionSetResourceId: diskEncryptionSetResourceId
      diskType: diskType
      domainJoinUserPrincipalName: domainJoinUserPrincipalName
      enableAcceleratedNetworking: enableAcceleratedNetworking
      encryptionAtHost: encryptionAtHost
      fslogixSharePath: varFslogixSharePath     
      fslogixStorageAccountResourceId: fslogixStorageAccountResourceId
      hostPoolResourceId: hostPoolResourceId      
      identityDomainName: identityDomainName
      identityServiceProvider: identityServiceProvider      
      keyVaultResourceId: keyVaultResourceId      
      location: location      
      mpImageOffer: mpImageOffer
      mpImageSku: mpImageSku
      namePrefix: varSessionHostNamePrefix
      secureBootEnabled: secureBootEnabled
      securityType: securityType == 'Standard' ? '' : securityType
      sessionHostConfigurationScriptUri: varSessionHostConfigurationScriptUri
      sessionHostConfigurationScript: varSessionHostConfigurationScript
      sessionHostOuPath: sessionHostOuPath
      subnetId: subnetResourceId
      tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
      timeZone: varTimeZoneSessionHosts
      useSharedImage: useSharedImage
      vmSize: vmSize
      vTpmEnabled: vTpmEnabled     
      subscriptionId: subscription().subscriptionId
    }
  }
]
