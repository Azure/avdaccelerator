targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@minLength(2)
@maxLength(4)
@description('Required. The name of the resource group to deploy')
param deploymentPrefix string = ''

@description('Required. Location where to deploy compute services')
param avdSessionHostLocation string = ''

@description('Required. Location where to deploy AVD management plane')
param avdManagementPlaneLocation string = ''

@description('Optional. AVD workload subscription ID, multiple subscriptions scenario')
param avdWorkloadSubsId string = ''

@description('Azure Virtual Desktop Enterprise Application object ID. ')
param avdEnterpriseAppObjectId string = ''

@description('Required. AVD session host local credentials')
param avdVmLocalUserName string = ''
@secure()
param avdVmLocalUserPassword string = ''

@description('Required. AD domain name')
param avdIdentityDomainName string = ''

@description('Required. AVD session host domain join credentials')
param avdDomainJoinUserName string = ''
@secure()
param avdDomainJoinUserPassword string = ''

@description('Optional. OU path to join AVd VMs')
param avdOuPath string = ''
/*
@description('Optional. Id to grant access to on AVD workload key vault secrets')
param avdWrklSecretAccess string = ''
*/
@allowed([
    'Personal'
    'Pooled'
])
@description('Optional. AVD host pool type (Default: Pooled)')
param avdHostPoolType string = 'Pooled'

@allowed([
    'Automatic'
    'Direct'
])
@description('Optional. AVD host pool type (Default: Automatic)')
param avdPersonalAssignType string = 'Automatic'

@allowed([
    'BreadthFirst'
    'DepthFirst'
])
@description('Required. AVD host pool load balacing type (Default: BreadthFirst)')
param avdHostPoolloadBalancerType string = 'BreadthFirst'

@description('Optional. AVD host pool maximum number of user sessions per session host')
param avhHostPoolMaxSessions int = 15

@description('Optional. AVD host pool start VM on Connect')
param avdStartVmOnConnect bool

@description('Create custom Start VM on connect role')
param createStartVmOnConnectCustomRole bool

@description('Optional. AVD deploy remote app application group')
param avdDeployRappGroup bool

@description('Optional. AVD host pool Custom RDP properties')
param avdHostPoolRdpProperty string = 'audiocapturemode:i:1;audiomode:i:0;drivestoredirect:s:;redirectclipboard:i:1;redirectcomports:i:1;redirectprinters:i:1;redirectsmartcards:i:1;screen mode id:i:2'

@description('Create new virtual network')
param createAvdVnet bool

@description('Existing virtual network subnet')
param existingVnetSubnetResourceId string = ''

@description('Existing hub virtual network for perring')
param existingHubVnetResourceId string = ''

@description('AVD virtual network address prefixes')
param avdVnetworkAddressPrefixes string = ''

@description('AVD virtual network subnet address prefix')
param avdVnetworkSubnetAddressPrefix string = ''

@description('custom DNS servers IPs')
param customDnsIps string = ''

@description('Use Azure private DNS zones for private endpoints (Default: false)')
param avdVnetPrivateDnsZone bool = false

@description('Use Azure private DNS zones for private endpoints (Default: false)')
param avdVnetPrivateDnsZoneFilesId string = ''

@description('Use Azure private DNS zones for private endpoints (Default: false)')
param avdVnetPrivateDnsZoneKeyvaultId string = ''

@description('Does the hub contains a virtual network gateway')
param vNetworkGatewayOnHub bool

@description('Optional. Fslogix file share size (Default: 5TB)')
param avdFslogixFileShareQuotaSize int = 512

@description('Deploy new session hosts')
param avdDeploySessionHosts bool

@minValue(1)
@maxValue(49)
@description('Cuantity of session hosts to deploy')
param avdDeploySessionHostsCount int

@description('Optional. Creates an availability zone and adds the VMs to it. Cannot be used in combination with availability set nor scale set. (Defualt: true)')
param avdUseAvailabilityZones bool = true

@description('Optional. Sets the number of fault domains for the availability set. (Defualt: 3)')
param avdAsFaultDomainCount int = 3

@description('Optional. Sets the number of update domains for the availability set. (Defualt: 5)')
param avdAsUpdateDomainCount int = 5

@description('Storage account SKU for FSLogix storage. Recommended tier is Premium LRS or Premium ZRS (where available)')
param fsLogixstorageSku string = ''

@description('Optional. This property can be used by user in the request to enable or disable the Host Encryption for the virtual machine. This will enable the encryption for all the disks including Resource/Temp disk at host itself. For security reasons, it is recommended to set encryptionAtHost to True. Restrictions: Cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
param encryptionAtHost bool = false 

@description('Session host VM size (Defualt: Standard_D2s_v3) ')
param avdSessionHostsSize string = 'Standard_D2s_v3'

@description('OS disk type for session host (Defualt: Standard_LRS) ')
param avdSessionHostDiskType string = 'Standard_LRS'


@allowed([
    'win10_21h2_office'
    'win10_21h2'
    'win11_21h2_office'
    'win11_21h2'
])
@description('Required. AVD OS image source (Default: win10-21h2)')
param avdOsImage string = 'win10_21h2'

@description('Set to deploy image from Azure Compute Gallery')
param useSharedImage bool

@description('Source custom image ID')
param avdImageTemplataDefinitionId string = ''

@description('OU name for Azure Storage Account. It is recommended to create a new AD Organizational Unit (OU) in AD and disable password expiration policy on computer accounts or service logon accounts accordingly. ')
param storageOUName string = ''

@description('If OU for Azure Storage needs to be created - set to true and ensure the domain join credentials have priviledge to create OU and create computer objects or join to domain')
param createOUforStorage bool = false

@description('Do not modify, used to set unique value for resource deployment')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var deploymentPrefixLowercase = toLower(deploymentPrefix)
var avdSessionHostLocationLowercase = toLower(avdSessionHostLocation)
var avdManagementPlaneLocationLowercase = toLower(avdManagementPlaneLocation)
var avdServiceObjectsRgName = 'rg-${avdManagementPlaneLocationLowercase}-avd-${deploymentPrefixLowercase}-service-objects' // max length limit 90 characters
var avdNetworkObjectsRgName = 'rg-${avdSessionHostLocationLowercase}-avd-${deploymentPrefixLowercase}-network' // max length limit 90 characters
var avdComputeObjectsRgName = 'rg-${avdSessionHostLocationLowercase}-avd-${deploymentPrefixLowercase}-pool-compute' // max length limit 90 characters
var avdStorageObjectsRgName = 'rg-${avdSessionHostLocationLowercase}-avd-${deploymentPrefixLowercase}-storage' // max length limit 90 characters
var avdSharedResourcesRgName = 'rg-${avdSessionHostLocationLowercase}-avd-shared-resources'

var avdVnetworkName = 'avdvnet-${avdSessionHostLocationLowercase}-${deploymentPrefixLowercase}'
var avdVnetworkSubnetName = 'avd-${deploymentPrefixLowercase}'
var avdNetworksecurityGroupName = 'avdnsg-${avdSessionHostLocationLowercase}-${deploymentPrefixLowercase}'
var avdRouteTableName = 'avdudr-${avdSessionHostLocationLowercase}-${deploymentPrefixLowercase}'
var avdApplicationsecurityGroupName = 'avdasg-${avdSessionHostLocationLowercase}-${deploymentPrefixLowercase}'
var avdVnetworkPeeringName = '${uniqueString(deploymentPrefixLowercase, avdSessionHostLocation)}-peering-avd-${deploymentPrefixLowercase}'
var avdWorkSpaceName = 'avdws-${deploymentPrefixLowercase}'
var avdHostPoolName = 'avdhp-${deploymentPrefixLowercase}'
var avdApplicationGroupNameDesktop = 'avddag-${deploymentPrefixLowercase}'
var avdApplicationGroupNameRapp = 'avdraag-${deploymentPrefixLowercase}'
var marketPlaceGalleryWindows = {
    'win10_21h2_office': {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'office-365'
        sku: 'win10-21h2-avd-m365'
        version: 'latest'
    }

    'win10_21h2': {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'windows-10'
        sku: 'win10-21h2-avd'
        version: 'latest'
    }

    'win11_21h2_office': {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'office-365'
        sku: 'win11-21h2-avd-m365'
        version: 'latest'
    }

    'win11_21h2': {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-11'
        sku: 'win11-21h2-avd'
        version: 'latest'
    }
}

var baseScriptUri = 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/'
var fslogixScriptUri = '${baseScriptUri}scripts/Set-FSLogixRegKeys.ps1'
var fsLogixScript = './Set-FSLogixRegKeys.ps1'
var fslogixSharePath = '\\\\${avdFslogixStorageName}.file.${environment().suffixes.storage}\\${avdFslogixFileShareName}'
var FsLogixScriptArguments = '-volumeshare ${fslogixSharePath}'
var fslogixManagedIdentityName = 'avd-uai-fslogix'
var avdAgentPackageLocation = 'https://wvdportalstorageblob.blob.${environment().suffixes.storage}/galleryartifacts/Configuration_01-20-2022.zip'
var avdFslogixStorageName = take('fslogix${uniqueString(deploymentPrefixLowercase, avdSessionHostLocationLowercase)}${deploymentPrefixLowercase}',15)
var avdFslogixFileShareName = 'fslogix-${deploymentPrefixLowercase}'
var storageAccountContributorRoleId='b24988ac-6180-42a0-ab88-20f7382dd24c'
var readerRoleId = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
var tempStorageVmName='tempstgvm'
var dscAgentPackageLocation = 'https://github.com/Azure/avdaccelerator/raw/main/workload/scripts/DSCDomainJoinStorageScripts.zip'
var addStorageToDomainScriptUri='${baseScriptUri}scripts/Manual-DSC-JoinStorage-to-ADDS.ps1'
var addStorageToDomainScript='./Manual-DSC-JoinStorage-to-ADDS.ps1'
var addStorageToDomainScriptArgs='-DscPath ${dscAgentPackageLocation} -StorageAccountName ${avdFslogixStorageName} -StorageAccountRG ${avdStorageObjectsRgName} -DomainName ${avdIdentityDomainName} -AzureCloudEnvironment AzureCloud -DomainAdminUserName ${avdDomainJoinUserName} -DomainAdminUserPassword ${avdDomainJoinUserPassword} -OUName ${OuStgName} -CreateNewOU ${createOUforStorageString} -ShareName ${avdFslogixFileShareName} -Verbose'
var OuStgName = !empty(storageOUName)? storageOUName : 'Computers'
var avdWrklKvName = 'avd-${uniqueString(deploymentPrefixLowercase, avdSessionHostLocationLowercase)}-${deploymentPrefixLowercase}' // max length limit 24 characters
var avdSessionHostNamePrefix = 'avdsh-${deploymentPrefix}'
var avdAvailabilitySetName = 'avdas-${deploymentPrefix}'
var allAvailabilityZones = pickZones('Microsoft.Compute', 'virtualMachines', avdSessionHostLocation, 3)
var createOUforStorageString = string(createOUforStorage)

var resourceGroups = [
    {
        name: avdServiceObjectsRgName
        location: avdManagementPlaneLocation
    }
    {
        name: avdComputeObjectsRgName
        location: avdSessionHostLocation
    }
    {
        name: avdStorageObjectsRgName
        location: avdSessionHostLocation
    }
]
// =========== //
// Deployments //
// =========== //

// Resource groups
module avdBaselineResourceGroups '../carml/0.5.0/Microsoft.Resources/resourceGroups/deploy.bicep' = [ for resourceGroup in resourceGroups: {
    scope: subscription(avdWorkloadSubsId)
    name: 'Deploy-${substring(resourceGroup.name,10)}-${time}'
    params: {
        name: resourceGroup.name
        location: resourceGroup.location
        enableDefaultTelemetry: false
    }
}]

// Optional. Networking
module avdNetworking 'avd-modules/avd-networking.bicep' = if (createAvdVnet) {
    name: 'Deploy-AVD-Networking-${time}'
    params: {
        avdApplicationsecurityGroupName: avdApplicationsecurityGroupName
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
        avdWorkloadSubsId:avdWorkloadSubsId
        customDnsIps: customDnsIps
    }
    dependsOn: [
        avdBaselineResourceGroups
    ]
}

// AVD management plane
module avdHostPoolandAppGroups 'avd-modules/avd-hostpool-app-groups.bicep' = {
    name: 'Deploy-AVD-HostPool-AppGroups-${time}'
    params: {
        avdApplicationGroupNameDesktop: avdApplicationGroupNameDesktop
        avdApplicationGroupNameRapp: avdApplicationGroupNameRapp
        avdDeployRappGroup: avdDeployRappGroup
        avdHostPoolName: avdHostPoolName
        avdHostPoolRdpProperty: avdHostPoolRdpProperty
        avdHostPoolloadBalancerType: avdHostPoolloadBalancerType
        avdHostPoolType: avdHostPoolType
        avhHostPoolMaxSessions:avhHostPoolMaxSessions
        avdPersonalAssignType: avdPersonalAssignType
        avdManagementPlaneLocation: avdManagementPlaneLocation
        avdServiceObjectsRgName: avdServiceObjectsRgName
        avdStartVmOnConnect: avdStartVmOnConnect
        avdWorkloadSubsId: avdWorkloadSubsId
    }
    dependsOn: [
        avdBaselineResourceGroups
    ]
}

module avdWorkSpace '../carml/0.5.0/Microsoft.DesktopVirtualization/workspaces/deploy.bicep' = {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
    name: 'Deploy-AVD-WorkSpace-${time}'
    params: {
        name: avdWorkSpaceName
        location: avdManagementPlaneLocation
        appGroupResourceIds: avdHostPoolandAppGroups.outputs.avdAppGroupsArray
    }
    dependsOn: [
        avdHostPoolandAppGroups
    ]
}
//

// Identity: managed identities and role assignments 
module deployAvdManagedIdentitiesRoleAssign 'avd-modules/avd-identity.bicep' = {
    name: 'Create-ManagedIdentities-RoleAssign'
    params: {
        avdComputeObjectsRgName: avdComputeObjectsRgName
        avdDeploySessionHosts: avdDeploySessionHosts
        avdEnterpriseAppObjectId: avdEnterpriseAppObjectId
        avdManagementPlaneLocation: avdManagementPlaneLocation
        avdServiceObjectsRgName: avdServiceObjectsRgName
        avdStorageObjectsRgName: avdStorageObjectsRgName
        avdWorkloadSubsId: avdWorkloadSubsId
        createStartVmOnConnectCustomRole: createStartVmOnConnectCustomRole
        fslogixManagedIdentityName: fslogixManagedIdentityName
        readerRoleId: readerRoleId
        storageAccountContributorRoleId: storageAccountContributorRoleId
    }
    dependsOn:[
        avdBaselineResourceGroups
    ]
}

// Key vault
module avdWrklKeyVault '../carml/1.0.0/Microsoft.KeyVault/vaults/deploy.bicep' = if (avdDeploySessionHosts) {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
    name: 'AVD-Workload-KeyVault-${time}'
    params: {
        name: avdWrklKvName
        location: avdSessionHostLocation
        enableRbacAuthorization: false
        softDeleteRetentionInDays: 7
        networkAcls: {
            bypass: 'AzureServices'
            defaultAction: 'Deny'
            virtualNetworkRules: []
            ipRules: []
        }
        privateEndpoints: avdVnetPrivateDnsZone ? [
            {
                subnetResourceId: createAvdVnet ? '${avdNetworking.outputs.avdVirtualNetworkResourceId}/subnets/${avdVnetworkSubnetName}' : existingVnetSubnetResourceId
                service: 'vault'
                privateDnsZoneResourceIds: [
                    avdVnetPrivateDnsZoneKeyvaultId
                ]
            }
        ] :[
            {
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
    }
    dependsOn: [
        avdBaselineResourceGroups
        //updateExistingSubnet
    ]
}
//

// Call on the KV.
resource avdWrklKeyVaultget 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = if (avdDeploySessionHosts) {
    name: avdWrklKvName
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
}

// Storage
module deployAvdStorageAzureFiles 'avd-modules/avd-storage-azurefiles.bicep' = if (avdDeploySessionHosts) {
    name: 'Deploy-AVD-Storage-AzureFiles-${time}'
    params: {
        addStorageToDomainScript: addStorageToDomainScript
        addStorageToDomainScriptArgs: addStorageToDomainScriptArgs
        addStorageToDomainScriptUri: addStorageToDomainScriptUri
        avdApplicationSecurityGroupResourceId: createAvdVnet ? '${avdNetworking.outputs.avdApplicationSecurityGroupResourceId}' : ''
        avdComputeObjectsRgName: avdComputeObjectsRgName
        avdDomainJoinUserName: avdDomainJoinUserName
        avdDomainJoinUserPassword: avdWrklKeyVaultget.getSecret('avdDomainJoinUserPassword')
        avdFslogixFileShareName: avdFslogixFileShareName
        avdFslogixFileShareQuotaSize: avdFslogixFileShareQuotaSize
        avdFslogixStorageName: avdFslogixStorageName
        avdIdentityDomainName: avdIdentityDomainName
        avdImageTemplataDefinitionId: avdImageTemplataDefinitionId
        avdOuPath: avdOuPath
        avdSessionHostDiskType: avdSessionHostDiskType
        avdSessionHostLocation: avdSessionHostLocation
        avdSessionHostsSize: avdSessionHostsSize
        avdStorageObjectsRgName: avdStorageObjectsRgName
        avdSubnetId: createAvdVnet ? '${avdNetworking.outputs.avdVirtualNetworkResourceId}/subnets/${avdVnetworkSubnetName}' : existingVnetSubnetResourceId
        avdVmLocalUserName: avdVmLocalUserName
        avdVmLocalUserPassword: avdWrklKeyVaultget.getSecret('avdVmLocalUserPassword')
        avdVnetPrivateDnsZone: avdVnetPrivateDnsZone
        avdVnetPrivateDnsZoneFilesId: avdVnetPrivateDnsZoneFilesId
        avdWorkloadSubsId: avdWorkloadSubsId
        encryptionAtHost: encryptionAtHost
        fslogixManagedIdentityResourceId: deployAvdManagedIdentitiesRoleAssign.outputs.fslogixManagedIdentityResourceId
        fsLogixstorageSku: fsLogixstorageSku
        marketPlaceGalleryWindows: marketPlaceGalleryWindows['win10_21h2']
        subnetResourceId: createAvdVnet ? '${avdNetworking.outputs.avdVirtualNetworkResourceId}/subnets/${avdVnetworkSubnetName}' : existingVnetSubnetResourceId
        tempStorageVmName: tempStorageVmName
        useSharedImage: useSharedImage
    }
    dependsOn:[
        avdBaselineResourceGroups
        avdNetworking
        avdWrklKeyVaultget
    ]
}

// Session hosts
module deployAndConfigureAvdSessionHosts 'avd-modules/avd-session-hosts.bicep' = if (avdDeploySessionHosts) {
    name: 'Deploy-and-Configure-AVD-SessionHosts-${time}'
    params: {
        avdAgentPackageLocation: avdAgentPackageLocation
        avdApplicationSecurityGroupResourceId: createAvdVnet ? '${avdNetworking.outputs.avdApplicationSecurityGroupResourceId}' : ''
        avdAsFaultDomainCount: avdAsFaultDomainCount
        avdAsUpdateDomainCount: avdAsUpdateDomainCount
        avdAvailabilitySetName: avdAvailabilitySetName
        avdComputeObjectsRgName: avdComputeObjectsRgName
        avdDeploySessionHostsCount: avdDeploySessionHostsCount
        avdDomainJoinUserName: avdDomainJoinUserName
        avdDomainJoinUserPassword: avdWrklKeyVaultget.getSecret('avdDomainJoinUserPassword')
        avdHostPoolName: avdHostPoolName
        avdIdentityDomainName: avdIdentityDomainName
        avdImageTemplataDefinitionId: avdImageTemplataDefinitionId
        avdOuPath: avdOuPath
        avdSessionHostDiskType: avdSessionHostDiskType
        avdSessionHostLocation: avdSessionHostLocation
        avdSessionHostNamePrefix: avdSessionHostNamePrefix
        avdSessionHostsSize: avdSessionHostsSize
        avdSubnetId: createAvdVnet ? '${avdNetworking.outputs.avdVirtualNetworkResourceId}/subnets/${avdVnetworkSubnetName}' : existingVnetSubnetResourceId
        avdUseAvailabilityZones: avdUseAvailabilityZones
        avdVmLocalUserName: avdVmLocalUserName
        avdVmLocalUserPassword: avdWrklKeyVaultget.getSecret('avdVmLocalUserPassword')
        avdWorkloadSubsId: avdWorkloadSubsId
        encryptionAtHost: encryptionAtHost
        fslogixManagedIdentityResourceId: deployAvdManagedIdentitiesRoleAssign.outputs.fslogixManagedIdentityResourceId
        fsLogixScript: fsLogixScript
        FsLogixScriptArguments: FsLogixScriptArguments
        fslogixScriptUri: fslogixScriptUri
        hostPoolToken: avdHostPoolandAppGroups.outputs.hostPooltoken
        marketPlaceGalleryWindows: marketPlaceGalleryWindows[avdOsImage]
        useSharedImage: useSharedImage
    }
    dependsOn: [
        avdBaselineResourceGroups
        avdNetworking
        avdWrklKeyVaultget
    ]
}
