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
param location string = resourceGroup().location

@description('The session host or AVD management plane location acronym For example, "eus" for East US.')
param locationAcronym string

@description('The storage service to use (AzureFiles or ANF).')
param storageService string

@description('Indicates whether to use custom naming for AVD.')
param useCustomNaming bool

@description('The custom name for the FSLogix file share.')
param fslogixFileShareCustomName string = ''

@description('The custom name for the App Attach file share.')
param appAttachFileShareCustomName string = ''

@description('The FSLogix file share quota size in GiBs.')
param fslogixFileShareQuotaSize int

@description('The App Attach file share quota size in GiBs.')
param appAttachFileShareQuotaSize int

@description('The storage performance level for FSLogix.')
param fslogixStoragePerformance string

@description('The storage performance level for App Attach.')
param appAttachStoragePerformance string

@description('Subnet resource ID for ANF volumes.')
param anfSubnetResourceId bool

@description('Subnet resource ID for VMs.')
param vmsSubnetResourceId bool

@description('Subnet resource ID for private endpoints.')
param privateEndpointSubnetResourceId bool

@description('The existing VNet AVD subnet resource ID.')
param existingVnetAvdSubnetResourceId string = ''

@description('The existing VNet private endpoint subnet resource ID.')
param existingVnetPrivateEndpointSubnetResourceId string = ''

@description('The availability setting (AvailabilityZones or other).')
param availability string

@description('The custom DNS IPs.')
param customDnsIps array = []

@description('The AVD identity service provider (e.g., EntraDS).')
param avdIdentityServiceProvider string

@description('The AVD domain join username.')
param avdDomainJoinUserName string

@description('The service objects resource group name.')
param serviceObjectsRgName string

@description('The storage objects resource group name.')
param varStorageObjectsRgName string

@description('The AVD session host location.')
param avdSessionHostLocation string

@description('The AVD management plane location.')
param avdManagementPlaneLocation string

@description('The AVD session hosts size.')
param avdSessionHostsSize string

@description('The AVD OU path.')
param avdOuPath string

@description('The storage OU path.')
param storageOuPath string = ''

@description('The custom resource tags.')
param varCustomResourceTags object = {}

@description('The AVD default tags.')
param varAvdDefaultTags object = {}

@description('Indicates whether to create resource tags.')
param createResourceTags bool

@description('The base script URI.')
param varBaseScriptUri string

@description('The security principal name.')
param varSecurityPrincipalName string = ''

@description('The identity domain name.')
param identityDomainName string

@description('The identity domain GUID.')
param identityDomainGuid string = ''

@description('Indicates whether to deploy private endpoints for Key Vault and storage.')
param deployPrivateEndpointKeyvaultStorage bool

@description('Indicates whether to deploy monitoring.')
param avdDeployMonitoring bool

@description('Indicates whether to deploy AVD session hosts.')
param avdDeploySessionHosts bool

@description('Indicates whether to create FSLogix deployment.')
param createFslogixDeployment bool

@description('Indicates whether to create App Attach deployment.')
param createAppAttachDeployment bool

@description('Indicates whether to create private DNS zones.')
param createPrivateDnsZones bool

@description('The AVD VNet private DNS zone files ID.')
param avdVnetPrivateDnsZoneFilesId string = ''

@description('The existing ALA workspace resource ID.')
param alaExistingWorkspaceResourceId string = ''

@description('Indicates whether to deploy ALA workspace.')
param deployAlaWorkspace bool

@description('The deployment timestamp.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var varNamingUniqueStringThreeChar = take('${uniqueString(subId, deploymentPrefix, time)}', 3)
var varAnfCapacityPoolSize = ((createFslogixDeployment ? fslogixFileShareQuotaSize : 0) + (createAppAttachDeployment ? appAttachFileShareQuotaSize : 0)) > 4096 
  ? ((createFslogixDeployment ? fslogixFileShareQuotaSize : 0) + (createAppAttachDeployment ? appAttachFileShareQuotaSize : 0)) 
  : 4096
var varFslogixFileShareName = storageService == 'AzureFiles'
  ? (useCustomNaming 
      ? fslogixFileShareCustomName
      : 'fslogix-pc-${deploymentPrefix}-${deploymentEnvironment}-${locationAcronym}-001')
  : storageService == 'ANF'
    ? 'fsl${deploymentPrefix}${deploymentEnvironment}${locationAcronym}001'
    : ''
var varAnfSmbServerNamePrefix = 'anf${deploymentPrefix}${deploymentEnvironment}'
var varAppAttachFileShareName = storageService == 'AzureFiles'
    ? (useCustomNaming 
        ? appAttachFileShareCustomName 
        : 'appa-${deploymentPrefix}-${deploymentEnvironment}-${locationAcronym}-001')
    : storageService == 'ANF'
        ? 'appa${deploymentPrefix}01'
        : ''
var varFslogixAnfVolume = createFslogixDeployment ? [
    {
        name: varFslogixFileShareName
        coolAccess: false
        encryptionKeySource: 'Microsoft.NetApp'
        zones: [] // availability == 'AvailabilityZones'
        //? availabilityZones
        //: []
        serviceLevel: fslogixStoragePerformance
        networkFeatures: 'Standard'
        usageThreshold: fslogixFileShareQuotaSize * 1073741824 // Convert GiBs to bytes
        protocolTypes: [
            'CIFS'
        ]
        subnetResourceId: 
        creationToken: varFslogixFileShareName
        smbContinuouslyAvailable: true
        securityStyle: 'ntfs'
    }
    ] : []
var varAppAttchAnfVolume = createAppAttachDeployment ? [
    {
        name: varAppAttachFileShareName
        coolAccess: false
        encryptionKeySource: 'Microsoft.NetApp'
        zones: [] // availability == 'AvailabilityZones'
        //? availabilityZones
        //: []
        serviceLevel: appAttachStoragePerformance
        networkFeatures: 'Standard'
        usageThreshold: appAttachFileShareQuotaSize * 1073741824 // Convert GiBs to bytes
        protocolTypes: [
            'CIFS'
        ]
        subnetResourceId: anfSubnetId
        creationToken: varAppAttachFileShareName
        smbContinuouslyAvailable: true
        securityStyle: 'ntfs'
    }
    ] : []
var varAnfVolumes = union(varFslogixAnfVolume, varAppAttchAnfVolume)
var varFslogixStorageName = useCustomNaming
  ? '${storageAccountPrefixCustomName}fsl${deploymentPrefix}${varDeploymentEnvironmentComputeStorage}${varNamingUniqueStringThreeChar}'
  : 'stfsl${deploymentPrefix}${varDeploymentEnvironmentComputeStorage}${varNamingUniqueStringThreeChar}'
var varAnfAccountName = useCustomNaming ? anfAccountCustomName : 'anf-acc-${varComputeStorageResourcesNamingStandard}-001'
var varAnfCapacityPoolName = 'anf-cpool-${varComputeStorageResourcesNamingStandard}-001'
var varFslogixStorageFqdn = createFslogixDeployment ? ((storageService == 'AzureFiles') ? '${varFslogixStorageName}.file.${environment().suffixes.storage}' : (storageService == 'ANF') ? '${varFslogixFileShareName}.<subnet-name>.<vnet-name>.${avdSessionHostLocation}.netapp.azure.com' : '') : ''
var varAppAttachStorageFqdn = createAppAttachDeployment ? ((storageService == 'AzureFiles') ? '${varAppAttachStorageName}.file.${environment().suffixes.storage}' : (storageService == 'ANF') ? '${varAppAttachFileShareName}.<subnet-name>.<vnet-name>.${avdSessionHostLocation}.netapp.azure.com' : '') : ''
var varAppAttachStorageName = useCustomNaming
  ? '${storageAccountPrefixCustomName}appa${deploymentPrefix}${varDeploymentEnvironmentComputeStorage}${varNamingUniqueStringThreeChar}'
  : 'stappa${deploymentPrefix}${varDeploymentEnvironmentComputeStorage}${varNamingUniqueStringThreeChar}'
var varManagementVmName = 'vmmgmt${deploymentPrefix}${varDeploymentEnvironmentComputeStorage}${locationAcronym}'
var varFslogixSharePath = createFslogixDeployment
  ? (storageService == 'AzureFiles' 
    ? '\\\\${varFslogixStorageName}.file.${environment().suffixes.storage}\\${varFslogixFileShareName}' 
    : (storageService == 'ANF' 
      ? anf.outputs.anfFslogixVolumeResourceId 
      : '') ) : ''
var varAppAttachSharePath = createAppAttachDeployment
  ? (storageService == 'AzureFiles' 
    ? '\\\\${varAppAttachStorageName}.file.${environment().suffixes.storage}\\${varAppAttachFileShareName}' 
    : (storageService == 'ANF' 
      ? anf.outputs.anfAppAttachVolumeResourceId 
      : '') ) : ''
var varCreateStorageDeployment = (createFslogixDeployment || varCreateAppAttachDeployment == true) ? true : false
var varFslogixStoragePerformance = fslogixStoragePerformance =='Ultra'
    ? 'Premium'
    : fslogixStoragePerformance
var varAppAttachStoragePerformance = appAttachStoragePerformance =='Ultra'
    ? 'Premium'
    : appAttachStoragePerformance
var varStorageAccountAvailability = availability == 'AvailabilityZones'
    ? true
    : false
var varFslogixStorageSku = (varStorageAccountAvailability && storageService == 'AzureFiles')
    ? '${varFslogixStoragePerformance}_ZRS'
    : '${varFslogixStoragePerformance}_LRS'
var varAppAttachStorageSku = varStorageAccountAvailability
    ? '${varAppAttachStoragePerformance}_ZRS'
    : '${varAppAttachStoragePerformance}_LRS'
var varStorageAzureFilesDscAgentPackageLocation = 'https://github.com/Azure/avdaccelerator/raw/main/workload/scripts/DSCStorageScripts/1.0.3/DSCStorageScripts.zip'
var varStorageToDomainScriptUri = '${varBaseScriptUri}scripts/Manual-DSC-Storage-Scripts.ps1'
var varStorageToDomainScript = './Manual-DSC-Storage-Scripts.ps1'
var varOuStgPath = !empty(storageOuPath) ? '"${storageOuPath}"' : '"${varDefaultStorageOuPath}"'
var varDefaultStorageOuPath = (avdIdentityServiceProvider == 'EntraDS') ? 'AADDC Computers' : 'Computers'
var varMarketPlaceGalleryWindows = loadJsonContent('../variables/osMarketPlaceImages.json')
var varStorageCustomOuPath = !empty(storageOuPath) ? 'true' : 'false'


var varMgmtVmSpecs = {
    osImage: varMarketPlaceGalleryWindows[managementVmOsImage]
    osDiskType: 'Standard_LRS'
    mgmtVmSize: avdSessionHostsSize //'Standard_D2ads_v5'
    enableAcceleratedNetworking: false
    ouPath: avdOuPath
    subnetId: vmsSubnetResourceId
    }    
// =========== //
// Deployments //
// =========== //

// Call on the KV.
resource avdWrklKeyVaultget 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
    name: wrklKvName
    scope: resourceGroup('${subId}', '${serviceObjectsRgName}')
}

// Azure NetApp Files
module anf '../azureNetappFiles/deploy.bicep' = if ((storageService == 'ANF') && (!contains(avdIdentityServiceProvider, 'EntraID'))) {
    name: 'Storage-FSLogix-ANF-${time}'
    params: {
      anfAccountName: varAnfAccountName
      anfCapacityPoolName: varAnfCapacityPoolName
      anfVolumes: varAnfVolumes
      anfSmbServerNamePrefix: varAnfSmbServerNamePrefix
      capacityPoolSize: varAnfCapacityPoolSize
      dnsServers: customDnsIps
      anfPerformance: fslogixStoragePerformance
      createFslogixStorage: createFslogixDeployment
      createAppAttachStorage: createAppAttachDeployment
      // vmLocalUserName: avdVmLocalUserName
      // fileShareName: varFslogixFileShareName
      // fileShareMultichannel: (fslogixStoragePerformance == 'Premium') ? true : false
      // storageSku: varFslogixStorageSku
      // fileShareQuotaSize: fslogixFileShareQuotaSize
      storageToDomainScript: varStorageToDomainScript
      storageToDomainScriptUri: varStorageToDomainScriptUri
      identityServiceProvider: avdIdentityServiceProvider
      dscAgentPackageLocation: varStorageAzureFilesDscAgentPackageLocation
      storageCustomOuPath: varStorageCustomOuPath
      managementVmName: varManagementVmName
      storageService: storageService
      // deployPrivateEndpoint: deployPrivateEndpointKeyvaultStorage
      ouStgPath:  !empty(storageOuPath) ? storageOuPath : varDefaultStorageOuPath
      managedIdentityClientId: varCreateStorageDeployment ? identity.outputs.managedIdentityStorageClientId : ''
      securityPrincipalName: !empty(varSecurityPrincipalName) ? varSecurityPrincipalName : ''
      domainJoinUserName: avdDomainJoinUserName
      kvResourceId: wrklKeyVault.outputs.resourceId
      serviceObjectsRgName: varServiceObjectsRgName
      identityDomainName: identityDomainName
      // identityDomainGuid: identityDomainGuid
      location: avdDeploySessionHosts ? avdSessionHostLocation : avdManagementPlaneLocation
      storageObjectsRgName: varStorageObjectsRgName
      subId: subId
      tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
      // alaWorkspaceResourceId: avdDeployMonitoring
      //   ? (deployAlaWorkspace
      //       ? monitoringDiagnosticSettings.outputs.avdAlaWorkspaceResourceId
      //       : alaExistingWorkspaceResourceId)
      //   : ''
    }
    dependsOn: [
      baselineStorageResourceGroup
      managementVm
    ]
  }

// FSLogix Azure Files
module fslogixAzureFilesStorage '../storageAzureFiles/deploy.bicep' = if (createFslogixDeployment && (storageService != 'ANF')) {
    name: 'Storage-FSLogix-ST-${time}'
    params: {
        storagePurpose: 'fslogix'
        vmLocalUserName: avdVmLocalUserName
        fileShareName: varFslogixFileShareName
        fileShareMultichannel: (varFslogixStoragePerformance == 'Premium') ? true : false
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
        managedIdentityClientId: varCreateStorageDeployment && avdIdentityServiceProvider != 'EntraID'
        ? identity.outputs.managedIdentityStorageClientId
        : ''
        securityPrincipalName: varSecurityPrincipalName
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
        vmsSubnetId: createAvdVnet
        ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetAvdSubnetName}'
        : existingVnetAvdSubnetResourceId
        vnetPrivateDnsZoneFilesId: createPrivateDnsZones
        ? networking.outputs.azureFilesDnsZoneResourceId
        : avdVnetPrivateDnsZoneFilesId
        subId: subId
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
  
    // App Attach Azure Files
module appAttachAzureFilesStorage '../storageAzureFiles/deploy.bicep' = if (createFslogixDeployment && (storageService != 'ANF')) {
    name: 'Storage-AppA-${time}'
    params: {
        storagePurpose: 'AppAttach'
        vmLocalUserName: avdVmLocalUserName
        fileShareName: varAppAttachFileShareName
        fileShareMultichannel: (varAppAttachStoragePerformance == 'Premium') ? true : false
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
        managedIdentityClientId: varCreateStorageDeployment && avdIdentityServiceProvider != 'EntraID'
        ? identity.outputs.managedIdentityStorageClientId
        : ''
        securityPrincipalName: varSecurityPrincipalName
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
        vmsSubnetId: createAvdVnet
        ? '${networking.outputs.virtualNetworkResourceId}/subnets/${varVnetAvdSubnetName}'
        : existingVnetAvdSubnetResourceId
        vnetPrivateDnsZoneFilesId: createPrivateDnsZones
        ? networking.outputs.azureFilesDnsZoneResourceId
        : avdVnetPrivateDnsZoneFilesId
        subId: subId
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

// =========== //
//   Outputs   //
// =========== //
