targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@description('The subscription ID for the AVD workload.')
param subId string = subscription().subscriptionId

@description('The deployment prefix in lowercase.')
param deploymentPrefix string

@description('The deployment environment in lowercase.')
param deploymentEnvironment string

@description('The session host location acronym derived from the resource group location.')
param location string

@description('The session host or AVD management plane location acronym For example, "eus" for East US.')
param locationAcronym string

@description('The storage service to use (AzureFiles or ANF).')
param storageService string

@description('Indicates whether to use custom naming for AVD.')
param useCustomNaming bool

@description('The naming standard for compute storage resources coming from the main template.')
param computeStorageResourcesNamingStandard string

@description('The custom name for the FSLogix file share.')
param fslogixFileShareCustomName string = ''

@description('The custom name for the App Attach file share.')
param appAttachFileShareCustomName string = ''

@description('The OS image for the management VM.')
param managementVmOsImage string

@sys.description('AVD FSLogix and App Attach storage account prefix custom name.')
param storageAccountPrefixCustomName string = 'st'

@description('The custom name for the ANF account.')
param anfAccountCustomName string = ''

@description('Deployment prefix one character.')
param deploymentEnvironmentOneCharacter string

@description('The resource ID of the Key Vault.')
param keyVaultResourceId string

@description('The Azure Log Analytics workspace resource ID.')
param alaWorkspaceResourceId string

@description('The private DNS zone files resource ID.')
param privateDnsZoneFilesResourceId string

@description('The client ID of the managed identity.')
param managedIdentityClientId string

@description('The FSLogix file share quota size in GiBs.')
param fslogixFileShareQuotaSize int

@description('The App Attach file share quota size in GiBs.')
param appAttachFileShareQuotaSize int

@description('The storage performance level for FSLogix.')
param fslogixStoragePerformance string

@description('The storage performance level for App Attach.')
param appAttachStoragePerformance string

@description('Subnet resource ID for ANF volumes.')
param anfSubnetResourceId string

@description('Subnet resource ID for VMs.')
param vmsSubnetResourceId string

@description('The security type for the VM (e.g., TrustedLaunch, Standard).')
param securityType string

@description('Subnet resource ID for private endpoints.')
param privateEndpointSubnetResourceId string

@description('The resource ID of the disk encryption set.')
param diskEncryptionSetResourceId string

@description('Indicates whether encryption at host is enabled for the VM.')
param encryptionAtHost bool

@description('The resource ID of the managed identity for storage.')
param storageManagedIdentityResourceId string

@description('Indicates whether secure boot is enabled for the VM.')
param secureBootEnabled bool

@description('Indicates whether vTPM is enabled for the VM.')
param vTpmEnabled bool

@description('The time zone for the session host.')
param sessionHostTimeZone string

@description('The resource ID of the application security group.')
param applicationSecurityGroupResourceId string

@description('USe or not zone redundant storage.')
param storageAvailabilityZones bool

@description('The custom DNS IPs.')
param dnsServers string

@description('The identity service provider (e.g., EntraDS).')
param identityServiceProvider string

@description('The domain join username.')
param domainJoinUserName string

@description('The VM local username.')
param vmLocalUserName string

@description('The service objects resource group name.')
param serviceObjectsRgName string

@description('The storage objects resource group name.')
param storageObjectsRgName string

@description('The VM size for the management VM.')
param managementVmSize string

@description('The OU path for AVD session hosts.')
param avdSessionHostsOuPath string

@description('The storage OU path.')
param storageOuPath string = ''

@description('The custom resource tags.')
param customResourceTags object = {}

@description('The AVD default tags.')
param defaultTags object = {}

@description('Indicates whether to create resource tags.')
param createResourceTags bool

@description('The base script URI.')
param baseScriptUri string

@description('The security principal name.')
param securityPrincipalName string = ''

@description('The identity domain name.')
param identityDomainName string

@description('The identity domain GUID.')
param identityDomainGuid string = ''

@description('Indicates whether to deploy private endpoints for Key Vault and storage.')
param deployPrivateEndpointKeyvaultStorage bool

@description('Indicates whether to create FSLogix deployment.')
param createFslogixDeployment bool

@description('Indicates whether to create App Attach deployment.')
param createAppAttachDeployment bool

@description('The deployment timestamp.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var varNamingUniqueStringThreeChar = take('${uniqueString(subId, deploymentPrefix, time)}', 3)
var varAnfCapacityPoolSize = ((createFslogixDeployment ? fslogixFileShareQuotaSize : 0) + (createAppAttachDeployment
    ? appAttachFileShareQuotaSize
    : 0)) > 4096
    ? ((createFslogixDeployment ? fslogixFileShareQuotaSize : 0) + (createAppAttachDeployment
        ? appAttachFileShareQuotaSize
        : 0))
  : 4096
var varFslogixFileShareName = storageService == 'AzureFiles'
  ? (useCustomNaming
      ? fslogixFileShareCustomName
      : 'fslogix-pc-${deploymentPrefix}-${deploymentEnvironment}-${locationAcronym}-001')
  : storageService == 'ANF' ? 'fsl${deploymentPrefix}${deploymentEnvironment}${locationAcronym}001' : ''
var varAnfSmbServerNamePrefix = 'anf${deploymentPrefix}${deploymentEnvironment}'
var varAppAttachFileShareName = storageService == 'AzureFiles'
  ? (useCustomNaming
      ? appAttachFileShareCustomName
      : 'appa-${deploymentPrefix}-${deploymentEnvironment}-${locationAcronym}-001')
  : storageService == 'ANF' ? 'appa${deploymentPrefix}01' : ''
var varFslogixAnfVolume = createFslogixDeployment
  ? [
      {
        name: varFslogixFileShareName
        coolAccess: false
        encryptionKeySource: 'Microsoft.NetApp'
        zones: [] // storageAvailabilityZones
        //? availabilityZones
        //: []
        serviceLevel: fslogixStoragePerformance
        networkFeatures: 'Standard'
        usageThreshold: fslogixFileShareQuotaSize * 1073741824 // Convert GiBs to bytes
        protocolTypes: [
          'CIFS'
        ]
        subnetResourceId: anfSubnetResourceId
        creationToken: varFslogixFileShareName
        smbContinuouslyAvailable: true
        securityStyle: 'ntfs'
      }
    ]
  : []
var varAppAttchAnfVolume = createAppAttachDeployment
  ? [
      {
        name: varAppAttachFileShareName
        coolAccess: false
        encryptionKeySource: 'Microsoft.NetApp'
        zones: [] // storageAvailabilityZones
        //? availabilityZones
        //: []
        serviceLevel: appAttachStoragePerformance
        networkFeatures: 'Standard'
        usageThreshold: appAttachFileShareQuotaSize * 1073741824 // Convert GiBs to bytes
        protocolTypes: [
          'CIFS'
        ]
        subnetResourceId: anfSubnetResourceId
        creationToken: varAppAttachFileShareName
        smbContinuouslyAvailable: true
        securityStyle: 'ntfs'
      }
    ]
  : []
var varAnfVolumes = union(varFslogixAnfVolume, varAppAttchAnfVolume)
var varFslogixStorageName = useCustomNaming
  ? '${storageAccountPrefixCustomName}fsl${deploymentPrefix}${deploymentEnvironmentOneCharacter}${varNamingUniqueStringThreeChar}'
  : 'stfsl${deploymentPrefix}${deploymentEnvironmentOneCharacter}${varNamingUniqueStringThreeChar}'
var varAnfAccountName = useCustomNaming 
  ? anfAccountCustomName 
  : 'anf-acc-${computeStorageResourcesNamingStandard}-001'
var varAnfCapacityPoolName = 'anf-cpool-${computeStorageResourcesNamingStandard}-001'
var varFslogixStorageFqdn = createFslogixDeployment
  ? ((storageService == 'AzureFiles')
      ? '${varFslogixStorageName}.file.${environment().suffixes.storage}'
      : (storageService == 'ANF')
          ? '${varFslogixFileShareName}.<subnet-name>.<vnet-name>.${location}.netapp.azure.com'
          : '')
  : ''
var varAppAttachStorageFqdn = createAppAttachDeployment
  ? ((storageService == 'AzureFiles')
      ? '${varAppAttachStorageName}.file.${environment().suffixes.storage}'
      : (storageService == 'ANF')
          ? '${varAppAttachFileShareName}.<subnet-name>.<vnet-name>.${location}.netapp.azure.com'
          : '')
  : ''
var varAppAttachStorageName = useCustomNaming
  ? '${storageAccountPrefixCustomName}appa${deploymentPrefix}${deploymentEnvironmentOneCharacter}${varNamingUniqueStringThreeChar}'
  : 'stappa${deploymentPrefix}${deploymentEnvironmentOneCharacter}${varNamingUniqueStringThreeChar}'
var varManagementVmName = 'vmmgmt${deploymentPrefix}${deploymentEnvironmentOneCharacter}${locationAcronym}'
var varFslogixFileSharePath = createFslogixDeployment
  ? (storageService == 'AzureFiles'
      ? '\\\\${varFslogixStorageName}.file.${environment().suffixes.storage}\\${varFslogixFileShareName}'
      : (storageService == 'ANF' 
        ? '\\\\${netAppAccountGet.outputs.anfSmbServerFqdn}\\${last(split(azureNetAppFiles.outputs.anfFslogixVolumeResourceId, '/'))}'
        : ''))
  : ''
var varAppAttachFileSharePath = createAppAttachDeployment
  ? (storageService == 'AzureFiles'
      ? '\\\\${varAppAttachStorageName}.file.${environment().suffixes.storage}\\${varAppAttachFileShareName}'
      : (storageService == 'ANF' 
        ? '\\\\${netAppAccountGet.outputs.anfSmbServerFqdn}\\${last(split(azureNetAppFiles.outputs.anfAppAttachVolumeResourceId, '/'))}'
        : ''))
  : ''
var varFslogixStoragePerformance = fslogixStoragePerformance == 'Ultra' 
  ? 'Premium' 
  : fslogixStoragePerformance
var varAppAttachStoragePerformance = appAttachStoragePerformance == 'Ultra' 
  ? 'Premium' 
  : appAttachStoragePerformance
var varFslogixStorageSku = (storageAvailabilityZones && storageService == 'AzureFiles')
  ? '${varFslogixStoragePerformance}_ZRS'
  : '${varFslogixStoragePerformance}_LRS'
var varAppAttachStorageSku = storageAvailabilityZones
  ? '${varAppAttachStoragePerformance}_ZRS'
  : '${varAppAttachStoragePerformance}_LRS'
var varStorageAzureFilesDscAgentPackageLocation = 'https://github.com/Azure/avdaccelerator/raw/main/workload/scripts/DSCStorageScripts/1.0.3/DSCStorageScripts.zip'
var varStorageToDomainScriptUri = '${baseScriptUri}scripts/Manual-DSC-Storage-Scripts.ps1'
var varStorageToDomainScript = './Manual-DSC-Storage-Scripts.ps1'
var varOuStgPath = !empty(storageOuPath) 
  ? '"${storageOuPath}"' 
  : '"${varDefaultStorageOuPath}"'
var varDefaultStorageOuPath = (identityServiceProvider == 'EntraDS') 
  ? 'AADDC Computers' 
  : 'Computers'
var varStorageCustomOuPath = !empty(storageOuPath) 
  ? 'true' 
  : 'false'
var varMarketPlaceGalleryWindows = loadJsonContent('../../../variables/osMarketPlaceImages.json')
var varAnfVolumeResourceIdGet = (createFslogixDeployment && (storageService == 'ANF')) 
  ? azureNetAppFiles.outputs.anfFslogixVolumeResourceId 
  : ((createAppAttachDeployment && (storageService == 'ANF')) ? azureNetAppFiles.outputs.anfAppAttachVolumeResourceId 
    : '')
// =========== //
// Deployments //
// =========== //
// Management VM deployment
module managementVm './managementVm.bicep' = if (identityServiceProvider != 'EntraID' && (createFslogixDeployment || createAppAttachDeployment)) {
  name: 'Storage-MGMT-VM-${time}'
  params: {
    diskEncryptionSetResourceId: diskEncryptionSetResourceId
    identityServiceProvider: identityServiceProvider
    vmName: varManagementVmName
    computeTimeZone: sessionHostTimeZone
    applicationSecurityGroupResourceId: applicationSecurityGroupResourceId
    domainJoinUserName: domainJoinUserName
    keyVaultResourceId: keyVaultResourceId
    serviceObjectsRgName: serviceObjectsRgName
    identityDomainName: identityDomainName
    ouPath: avdSessionHostsOuPath
    osDiskType: 'Standard_LRS'
    location: location
    vmSize: managementVmSize
    subnetResourceId: vmsSubnetResourceId
    enableAcceleratedNetworking: true
    securityType: securityType
    secureBootEnabled: secureBootEnabled
    vTpmEnabled: vTpmEnabled
    vmLocalUserName: vmLocalUserName
    subId: subId
    encryptionAtHost: encryptionAtHost
    storageManagedIdentityResourceId: storageManagedIdentityResourceId
    osImage: varMarketPlaceGalleryWindows[managementVmOsImage]
    tags: createResourceTags 
      ? union(customResourceTags, defaultTags) 
      : defaultTags
  }
  dependsOn: []
}

// Azure NetApp Files
module azureNetAppFiles '../azureNetappFiles/deploy.bicep' = if ((storageService == 'ANF') && (!contains(identityServiceProvider,'EntraID'))) {
  name: 'Storage-ANF-${time}'
  params: {
    accountName: varAnfAccountName
    capacityPoolName: varAnfCapacityPoolName
    volumes: varAnfVolumes
    smbServerNamePrefix: varAnfSmbServerNamePrefix
    capacityPoolSize: varAnfCapacityPoolSize
    dnsServers: dnsServers
    performance: fslogixStoragePerformance
    createFslogixStorage: createFslogixDeployment
    createAppAttachStorage: createAppAttachDeployment
    storageOuPath: !empty(storageOuPath) 
      ? storageOuPath 
      : varDefaultStorageOuPath
    domainJoinUserName: domainJoinUserName
    keyVaultResourceId: keyVaultResourceId
    identityDomainName: identityDomainName
    location: location
    storageObjectsRgName: storageObjectsRgName
    subId: subId
    tags: createResourceTags 
      ? union(customResourceTags, defaultTags) 
      : defaultTags
    // alaWorkspaceResourceId: deployMonitoring
    //   ? (deployAlaWorkspace
    //       ? monitoringDiagnosticSettings.outputs.avdAlaWorkspaceResourceId
    //       : alaExistingWorkspaceResourceId)
    //   : ''
  }
  dependsOn: [
    managementVm
  ]
}


// Call on ANF account and volume to get the SMB server FQDN.
module netAppAccountGet '../azureNetappFiles/.bicep/getNetAppVolumeSmbServerFqdn.bicep' = if (storageService == 'ANF') {
  name: 'Get-ANF-SMB-Server-FQDN-${time}'
  params: {
    netAppVolumeResourceId: varAnfVolumeResourceIdGet
  }
}

// FSLogix Azure Files
module fslogixAzureFilesStorage '../storageAzureFiles/deploy.bicep' = if (createFslogixDeployment && (storageService != 'ANF')) {
  name: 'Storage-FSLogix-ST-${time}'
  params: {
    storagePurpose: 'fslogix'
    vmLocalUserName: vmLocalUserName
    fileShareName: varFslogixFileShareName
    fileShareMultichannel: (varFslogixStoragePerformance == 'Premium') 
      ? true 
      : false
    storageSku: varFslogixStorageSku
    fileShareQuotaSize: fslogixFileShareQuotaSize
    storageAccountFqdn: varFslogixStorageFqdn
    storageAccountName: varFslogixStorageName
    storageToDomainScript: varStorageToDomainScript
    storageToDomainScriptUri: varStorageToDomainScriptUri
    identityServiceProvider: identityServiceProvider
    dscAgentPackageLocation: varStorageAzureFilesDscAgentPackageLocation
    storageCustomOuPath: varStorageCustomOuPath
    managementVmName: varManagementVmName
    deployPrivateEndpoint: deployPrivateEndpointKeyvaultStorage
    keyVaultResourceId: keyVaultResourceId
    storageOuPath: varOuStgPath
    managedIdentityClientId: managedIdentityClientId
    securityPrincipalName: securityPrincipalName
    domainJoinUserName: domainJoinUserName
    serviceObjectsRgName: serviceObjectsRgName
    identityDomainName: identityDomainName
    identityDomainGuid: identityDomainGuid
    location: location
    storageObjectsRgName: storageObjectsRgName
    privateEndpointSubnetResourceId: privateEndpointSubnetResourceId
    vmsSubnetResourceId: vmsSubnetResourceId
    privateDnsZoneFilesResourceId: privateDnsZoneFilesResourceId
    subId: subId
    tags: createResourceTags 
      ? union(customResourceTags, defaultTags) 
      : defaultTags
    alaWorkspaceResourceId: alaWorkspaceResourceId
  }
  dependsOn: [
    managementVm
  ]
}

// App Attach Azure Files
module appAttachAzureFilesStorage '../storageAzureFiles/deploy.bicep' = if (createFslogixDeployment && (storageService != 'ANF')) {
  name: 'Storage-AppA-${time}'
  params: {
    storagePurpose: 'AppAttach'
    vmLocalUserName: vmLocalUserName
    fileShareName: varAppAttachFileShareName
    fileShareMultichannel: (varAppAttachStoragePerformance == 'Premium') 
      ? true 
      : false
    storageSku: varAppAttachStorageSku
    fileShareQuotaSize: appAttachFileShareQuotaSize
    storageAccountFqdn: varAppAttachStorageFqdn
    storageAccountName: varAppAttachStorageName
    storageToDomainScript: varStorageToDomainScript
    storageToDomainScriptUri: varStorageToDomainScriptUri
    identityServiceProvider: identityServiceProvider
    dscAgentPackageLocation: varStorageAzureFilesDscAgentPackageLocation
    storageCustomOuPath: varStorageCustomOuPath
    managementVmName: varManagementVmName
    deployPrivateEndpoint: deployPrivateEndpointKeyvaultStorage
    storageOuPath: varOuStgPath
    managedIdentityClientId: managedIdentityClientId
    securityPrincipalName: securityPrincipalName
    domainJoinUserName: domainJoinUserName
    keyVaultResourceId: keyVaultResourceId
    serviceObjectsRgName: serviceObjectsRgName
    identityDomainName: identityDomainName
    identityDomainGuid: identityDomainGuid
    location: location
    storageObjectsRgName: storageObjectsRgName
    privateEndpointSubnetResourceId: privateEndpointSubnetResourceId
    vmsSubnetResourceId: vmsSubnetResourceId
    privateDnsZoneFilesResourceId: privateDnsZoneFilesResourceId
    subId: subId
    tags: createResourceTags 
      ? union(customResourceTags, defaultTags) 
      : defaultTags
    alaWorkspaceResourceId: alaWorkspaceResourceId
  }
  dependsOn: [
    managementVm
  ]
}

// =========== //
//   Outputs   //
// =========== //

output fslogixFileSharePath string = varFslogixFileSharePath
output appAttachFileSharePath string = varAppAttachFileSharePath
output fslogixStorageAccountResourceId string = (createFslogixDeployment && (storageService == 'AzureFiles'))
  ? fslogixAzureFilesStorage.outputs.storageAccountResourceId
  : ''
output appAttachStorageAccountResourceId string = (createAppAttachDeployment && (storageService == 'AzureFiles'))
  ? appAttachAzureFilesStorage.outputs.storageAccountResourceId
  : ''
