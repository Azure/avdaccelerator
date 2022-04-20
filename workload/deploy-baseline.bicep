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
param avdStartVMOnConnect bool

@description('Create custom Start VM on connect role')
param createStartVmOnConnectCustomRole bool

@description('Optional. AVD deploy remote app application group')
param avdDeployRAppGroup bool

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
@maxValue(500)
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
param encryptionAtHost bool

@description('Session host VM size (Defualt: Standard_D2s_v4) ')
param avdSessionHostsSize string = 'Standard_D2s_v4'

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
var avdVnetworkName = 'vnet-${avdSessionHostLocationLowercase}-avd-${deploymentPrefixLowercase}'
var avdVnetworkSubnetName = 'avd-${deploymentPrefixLowercase}'
var avdNetworksecurityGroupName = 'nsg-${avdSessionHostLocationLowercase}-avd-${deploymentPrefixLowercase}'
var avdRouteTableName = 'udr-${avdSessionHostLocationLowercase}-avd-${deploymentPrefixLowercase}'
var avdApplicationsecurityGroupName = 'asg-${avdSessionHostLocationLowercase}-avd-${deploymentPrefixLowercase}'
var avdVNetworkPeeringName = '${uniqueString(deploymentPrefixLowercase, avdSessionHostLocation)}-peering-avd-${deploymentPrefixLowercase}'
var avdWorkSpaceName = 'avdws-${deploymentPrefixLowercase}'
var avdHostPoolName = 'avdhp-${deploymentPrefixLowercase}'
var avdApplicationGroupNameDesktop = 'avd-dag-${deploymentPrefixLowercase}'
var avdApplicationGroupNameRApp = 'avd-raag-${deploymentPrefixLowercase}'
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

var baseScriptUri = 'https://raw.githubusercontent.com/Azure/avdaccelerator/tree/main/workload/'
var fslogixScriptUri = '${baseScriptUri}Scripts/Set-FSLogixRegKeys.ps1'
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
var dscAgentPackageLocation = 'https://github.com/Azure/avdaccelerator/tree/main/workload/scripts/DSCDomainJoinStorageScripts.zip'
var addStorageToDomainScriptUri='${baseScriptUri}Scripts/Manual-DSC-JoinStorage-to-ADDS.ps1'
var addStorageToDomainScript='./Manual-DSC-JoinStorage-to-ADDS.ps1'
var addStorageToDomainScriptArgs='-DscPath ${dscAgentPackageLocation} -StorageAccountName ${avdFslogixStorageName} -StorageAccountRG ${avdStorageObjectsRgName} -DomainName ${avdIdentityDomainName} -AzureCloudEnvironment AzureCloud -DomainAdminUserName ${avdDomainJoinUserName} -DomainAdminUserPassword ${avdDomainJoinUserPassword} -OUName ${storageOUName} -CreateNewOU ${createOUforStorage} -ShareName ${avdFslogixFileShareName} -Verbose'

var avdWrklKvName = 'avd-${uniqueString(deploymentPrefixLowercase, avdSessionHostLocationLowercase)}-${deploymentPrefixLowercase}' // max length limit 24 characters
var avdSessionHostNamePrefix = 'avdsh-${deploymentPrefix}'
var avdAvailabilitySetName = 'avdas-${deploymentPrefix}'
var allAvailabilityZones = pickZones('Microsoft.Compute', 'virtualMachines', avdSessionHostLocation, 3)
var splitExistVnetResId=split(existingVnetSubnetResourceId,'/')
var existingSubnetName = splitExistVnetResId[10]
var existVnetSubsId = splitExistVnetResId[2]
var existingVnetRgName = splitExistVnetResId[4]
var existingVnetName = splitExistVnetResId[8]
var createOUforStorageString = string(createOUforStorage)

// =========== //
// Deployments //
// =========== //

// Resource groups
// AVD Workload subscription RGs
module avdServiceObjectsRg '../carml/1.0.0/Microsoft.Resources/resourceGroups/deploy.bicep' = {
    scope: subscription(avdWorkloadSubsId)
    name: 'AVD-RG-ServiceObjects-${time}'
    params: {
        name: avdServiceObjectsRgName
        location: avdManagementPlaneLocation
    }
}

module avdNetworkObjectsRg '../carml/1.0.0/Microsoft.Resources/resourceGroups/deploy.bicep' = if (createAvdVnet) {
    scope: subscription(avdWorkloadSubsId)
    name: 'AVD-RG-Network-${time}'
    params: {
        name: avdNetworkObjectsRgName
        location: avdSessionHostLocation
    }
}

module avdComputeObjectsRg '../carml/1.0.0/Microsoft.Resources/resourceGroups/deploy.bicep' = {
    scope: subscription(avdWorkloadSubsId)
    name: 'AVD-RG-Compute-${time}'
    params: {
        name: avdComputeObjectsRgName
        location: avdSessionHostLocation
    }
}

module avdStorageObjectsRg '../carml/1.0.0/Microsoft.Resources/resourceGroups/deploy.bicep' = {
    scope: subscription(avdWorkloadSubsId)
    name: 'AVD-RG-Storage-${time}'
    params: {
        name: avdStorageObjectsRgName
        location: avdSessionHostLocation
    }
}
//

// Networking
module avdNetworksecurityGroup '../carml/1.0.0/Microsoft.Network/networkSecurityGroups/deploy.bicep' = if (createAvdVnet) {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdNetworkObjectsRgName}')
    name: 'AVD-NSG-${time}'
    params: {
        name: avdNetworksecurityGroupName
        location: avdSessionHostLocation
    }
    dependsOn: [
        avdNetworkObjectsRg
    ]
}

module avdApplicationSecurityGroup '../carml/1.0.0/Microsoft.Network/applicationSecurityGroups/deploy.bicep' = if (createAvdVnet) {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
    name: 'AVD-ASG-${time}'
    params: {
        name: avdApplicationsecurityGroupName
        location: avdSessionHostLocation
    }
    dependsOn: [
        avdComputeObjectsRg
    ]
}

module avdRouteTable '../carml/1.0.0/Microsoft.Network/routeTables/deploy.bicep' = if (createAvdVnet) {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdNetworkObjectsRgName}')
    name: 'AVD-UDR-${time}'
    params: {
        name: avdRouteTableName
        location: avdSessionHostLocation
    }
    dependsOn: [
        avdNetworkObjectsRg
    ]
}

module avdVirtualNetwork '../carml/1.0.0/Microsoft.Network/virtualNetworks/deploy.bicep' = if (createAvdVnet) {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdNetworkObjectsRgName}')
    name: 'AVD-vNet-${time}'
    params: {
        name: avdVnetworkName
        location: avdSessionHostLocation
        addressPrefixes: array(avdVnetworkAddressPrefixes)
        dnsServers: !empty(customDnsIps) ? array(customDnsIps) : []
        virtualNetworkPeerings: [
            {
                remoteVirtualNetworkId: existingHubVnetResourceId
                name: avdVNetworkPeeringName
                allowForwardedTraffic: true
                allowGatewayTransit: false
                allowVirtualNetworkAccess: true
                doNotVerifyRemoteGateways: true
                useRemoteGateways: vNetworkGatewayOnHub ? true : false
                remotePeeringEnabled: true
                remotePeeringName: avdVNetworkPeeringName
                remotePeeringAllowForwardedTraffic: true
                remotePeeringAllowGatewayTransit: vNetworkGatewayOnHub ? true : false
                remotePeeringAllowVirtualNetworkAccess: true
                remotePeeringDoNotVerifyRemoteGateways: true
                remotePeeringUseRemoteGateways: false
            }
        ]
        subnets: [
            {
                name: avdVnetworkSubnetName
                addressPrefix: avdVnetworkSubnetAddressPrefix
                privateEndpointNetworkPolicies: 'Disabled'
                privateLinkServiceNetworkPolicies: 'Enabled'
                networkSecurityGroupName: avdNetworksecurityGroupName
                routeTableName: avdRouteTableName
            }
        ]
    }
    dependsOn: [
        avdNetworkObjectsRg
        avdNetworksecurityGroup
        avdApplicationSecurityGroup
        avdRouteTable
    ]
}

// Update the existing subnet to disable network policies
/*
resource existingVnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = if (!empty(existingVnetSubnetResourceId))  {
    name: existingVnetName
    scope: resourceGroup('${existVnetSubsId}', '${existingVnetRgName}')
}

resource existingSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = if (!empty(existingVnetSubnetResourceId)) {
    name: existingSubnetName
    parent: existingVnet
}

module updateExistingSubnet '../carml/1.0.0/Microsoft.Network/virtualNetworks/subnets/deploy.bicep' = if (!empty(existingVnetSubnetResourceId))  {
scope: resourceGroup('${existVnetSubsId}', '${existingVnetRgName}')
name: 'Disable-NetworkPolicy-on-${existingSubnetName}-${time}'
params:{
    name: '${existingSubnetName}'
    virtualNetworkName: existingVnetName
    addressPrefix: existingSubnet.properties.addressPrefix
    networkSecurityGroupName: !(empty(existingSubnet.properties.networkSecurityGroup.id)) ? split(string(existingSubnet.properties.networkSecurityGroup.id), '/')[8] : ''
    networkSecurityGroupNameResourceGroupName: !(empty(existingSubnet.properties.networkSecurityGroup.id)) ? split(string(existingSubnet.properties.networkSecurityGroup.id), '/')[4] : ''
    routeTableName: !(empty(existingSubnet.properties.routeTable.id)) ? split(string(existingSubnet.properties.routeTable.id), '/')[8] : ''
    routeTableResourceGroupName: !(empty(existingSubnet.properties.routeTable.id)) ? split(string(existingSubnet.properties.routeTable.id), '/')[4] : ''
    //serviceEndpointPolicies: existingSubnet.properties.serviceEndpointPolicies
    privateEndpointNetworkPolicies: 'Disabled'
    }
}
*/
//

// AVD management plane
module avdWorkSpace '../carml/1.0.0/Microsoft.DesktopVirtualization/workspaces/deploy.bicep' = {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
    name: 'AVD-WorkSpace-${time}'
    params: {
        name: avdWorkSpaceName
        location: avdManagementPlaneLocation
        appGroupResourceIds: [
            avdApplicationGroupDesktop.outputs.resourceId
            avdDeployRAppGroup ? avdApplicationGroupRApp.outputs.resourceId : ''
        ]
    }
    dependsOn: [
        avdServiceObjectsRg
        avdApplicationGroupDesktop
        avdApplicationGroupRApp
    ]
}

module avdHostPool '../carml/1.0.0/Microsoft.DesktopVirtualization/hostpools/deploy.bicep' = {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
    name: 'AVD-HostPool-${time}'
    params: {
        name: avdHostPoolName
        location: avdManagementPlaneLocation
        hostpoolType: avdHostPoolType
        startVMOnConnect: avdStartVMOnConnect
        customRdpProperty: avdHostPoolRdpProperty
        loadBalancerType: avdHostPoolloadBalancerType
        maxSessionLimit: avhHostPoolMaxSessions
        personalDesktopAssignmentType: avdPersonalAssignType
    }
    dependsOn: [
        avdServiceObjectsRg
    ]
}

module avdApplicationGroupDesktop '../carml/1.0.0/Microsoft.DesktopVirtualization/applicationgroups/deploy.bicep' = {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
    name: 'AVD-AppGroup-Desktop-${time}'
    params: {
        name: avdApplicationGroupNameDesktop
        location: avdManagementPlaneLocation
        applicationGroupType: 'Desktop'
        hostpoolName: avdHostPool.outputs.name
    }
    dependsOn: [
        avdServiceObjectsRg
        avdHostPool
    ]
}

module avdApplicationGroupRApp '../carml/1.0.0/Microsoft.DesktopVirtualization/applicationgroups/deploy.bicep' = if (avdDeployRAppGroup) {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
    name: 'AVD-AppGroup-RApp-${time}'
    params: {
        name: avdApplicationGroupNameRApp
        location: avdManagementPlaneLocation
        applicationGroupType: 'RemoteApp'
        hostpoolName: avdHostPool.outputs.name
    }
    dependsOn: [
        avdServiceObjectsRg
        avdHostPool
    ]
}
// Identity 

module fslogixManagedIdentity '../carml/1.0.0/Microsoft.ManagedIdentity/userAssignedIdentities/deploy.bicep' = if (avdDeploySessionHosts) {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
    name: 'fslogix-Managed-Identity-${time}'
    params: {
        name: fslogixManagedIdentityName
        location: avdManagementPlaneLocation
    }
    dependsOn: [
        avdServiceObjectsRg
    ]
}

// RBAC Roles
module startVMonConnectRole '../carml/1.0.0/Microsoft.Authorization/roleDefinitions/subscription/deploy.bicep' = if (createStartVmOnConnectCustomRole) {
    scope: subscription(avdWorkloadSubsId)
    name: 'Start-VM-on-Connect-Role-${time}'
    params: {
        subscriptionId: avdWorkloadSubsId
        description: 'Start VM on connect AVD'
        roleName: 'StartVMonConnect-AVD'
        actions: [
            'Microsoft.Compute/virtualMachines/start/action'
            'Microsoft.Compute/virtualMachines/*/read'
        ]
        assignableScopes: [
            '/subscriptions/${avdWorkloadSubsId}'
        ]
    }
}

//

// RBAC role Assignments

module startVMonConnectRoleAssign '../carml/1.0.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (createStartVmOnConnectCustomRole) {
    name: 'Start-VM-OnConnect-RoleAssign-${time}'
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
    params: {
        roleDefinitionIdOrName: createStartVmOnConnectCustomRole ? startVMonConnectRole.outputs.resourceId : ''
        principalId: avdEnterpriseAppObjectId
    }
    dependsOn: [
        avdServiceObjectsRg
        startVMonConnectRole
    ]
}

module fslogixConnectRoleAssign '../carml/1.0.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (avdDeploySessionHosts) {
    name: 'fslogix-UserAIdentity-RoleAssign-${time}'
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdStorageObjectsRgName}')
    params: {
        roleDefinitionIdOrName: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${storageAccountContributorRoleId}'
        principalId: fslogixManagedIdentity.outputs.principalId
    }
    dependsOn: [
        fslogixManagedIdentity
    ]
}

module fslogixConnectReaderRoleAssign '../carml/1.0.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (avdDeploySessionHosts) {
    name: 'fslogix-UserAIdentity-ReaderRoleAssign-${time}'
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdStorageObjectsRgName}')
    params: {
        roleDefinitionIdOrName: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${readerRoleId}'
        principalId: fslogixManagedIdentity.outputs.principalId
    }
    dependsOn: [
        fslogixManagedIdentity
    ]
}

// Key vaults
module avdWrklKeyVault '../carml/1.0.0/Microsoft.KeyVault/vaults/deploy.bicep' = {
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
        privateEndpoints: [
            {
                subnetResourceId: createAvdVnet ? '${avdVirtualNetwork.outputs.resourceId}/subnets/${avdVnetworkSubnetName}' : existingVnetSubnetResourceId
                service: 'vault'
                privateDnsZoneResourceIds: [
                    avdVnetPrivateDnsZone ? avdVnetPrivateDnsZoneKeyvaultId : ''
                ]
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
        avdComputeObjectsRg
        //updateExistingSubnet
    ]
}
//

// Storage

// Provision temporary domain and add it to domain 

module storageVM '../carml/1.0.0/Microsoft.Compute/virtualMachines/deploy.bicep' =  if (avdDeploySessionHosts) {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
    name: 'Deploy-temporary-VM-FsLogixStorageToDomain-${time}'
    params: {
        name: tempStorageVmName
        location: avdSessionHostLocation
        userAssignedIdentities: {
            '${fslogixManagedIdentity.outputs.resourceId}' : {} 
        }
        encryptionAtHost: encryptionAtHost
        osType: 'Windows'
        licenseType: 'Windows_Client'
        vmSize: avdSessionHostsSize
        imageReference: useSharedImage ? json('{\'id\': \'${avdImageTemplataDefinitionId}\'}') : marketPlaceGalleryWindows['win10_21h2']
        osDisk: {
            createOption: 'fromImage'
            deleteOption: 'Delete'
            diskSizeGB: 128
            managedDisk: {
                storageAccountType: avdSessionHostDiskType
            }
        }
        adminUsername: avdVmLocalUserName
        adminPassword: avdVmLocalUserPassword //avdWrklKeyVaultget.getSecret('avdVmLocalUserPassword') //avdVmLocalUserPassword // need to update to get value from KV
        nicConfigurations: [
            {
                nicSuffix: '-nic-01'
                deleteOption: 'Delete'
                asgId: createAvdVnet ? '${avdApplicationSecurityGroup.outputs.resourceId}' : null
                enableAcceleratedNetworking: false
                ipConfigurations: [
                    {
                        name: 'ipconfig01'
                        subnetId: createAvdVnet ? '${avdVirtualNetwork.outputs.resourceId}/subnets/${avdVnetworkSubnetName}' : existingVnetSubnetResourceId
                    }
                ]
            }
        ]
        // Join domain
        allowExtensionOperations: true
        extensionDomainJoinPassword: avdDomainJoinUserPassword //avdWrklKeyVaultget.getSecret('avdDomainJoinUserPassword')
        extensionDomainJoinConfig: {
            enabled: true
            settings: {
                name: avdIdentityDomainName
                ouPath: !empty(avdOuPath) ? avdOuPath : null
                user: avdDomainJoinUserName
                restart: 'true'
                options: '3'
            }
        }
    }
    dependsOn: [
        avdComputeObjectsRg
        avdWrklKeyVault
        avdWrklKeyVaultget
    ]
}



// Provision the storage account and Azure Files
module fslogixStorage '../carml/1.0.0/Microsoft.Storage/storageAccounts/deploy.bicep' = if (avdDeploySessionHosts) {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdStorageObjectsRgName}')
    name: 'AVD-Fslogix-Storage-${time}'
    params: {
        name: avdFslogixStorageName
        location: avdSessionHostLocation
        storageAccountSku: fsLogixstorageSku
        allowBlobPublicAccess: false
        storageAccountKind:  ((fsLogixstorageSku =~ 'Premium_LRS') || (fsLogixstorageSku =~ 'Premium_ZRS')) ? 'FileStorage': 'StorageV2'
        storageAccountAccessTier: 'Hot'
        networkAcls: {
            bypass: 'AzureServices'
            defaultAction: 'Deny'
            virtualNetworkRules: []
            ipRules: []
        }
        fileServices: {
            shares: [
                {
                    name: avdFslogixFileShareName
                    shareQuota: avdFslogixFileShareQuotaSize * 100 //Portal UI steps scale
                }
            ]
        }
        privateEndpoints: [
            {
                subnetResourceId: createAvdVnet ? '${avdVirtualNetwork.outputs.resourceId}/subnets/${avdVnetworkSubnetName}' : existingVnetSubnetResourceId
                service: 'file'
                privateDnsZoneResourceIds: [
                    avdVnetPrivateDnsZone ? avdVnetPrivateDnsZoneFilesId : ''
                ]
            }
        ]
    }
    dependsOn: [
        avdStorageObjectsRg
        //updateExistingSubnet
    ]
}

// Custom Extension call in on the DSC script to join Azure storage to domain. 

module addFslogixShareToADDSSript '../carml/1.0.0/Microsoft.Compute/virtualMachines/extensions/add-azure-files-to-adds-script.bicep' =  if (avdDeploySessionHosts) {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
    name: 'Add-FslogixStorage-toADDS-${time}'
    params: {
        location: avdSessionHostLocation
        name: storageVM.outputs.name
        file: addStorageToDomainScript
        ScriptArguments: addStorageToDomainScriptArgs
        baseScriptUri: addStorageToDomainScriptUri
    }
    dependsOn: [
        fslogixStorage
        storageVM
    ]
}


    // Run deployment script to remove the VM --> 0.2 release. 
    // needs user managed identity --> Virtual machine contributor role assignment. Deployment script to assume the identity to delete VM. Include NIC and disks (force)

//

// Availability set
module avdAvailabilitySet '../carml/1.0.0/Microsoft.Compute/availabilitySets/deploy.bicep' = if (!avdUseAvailabilityZones && avdDeploySessionHosts) {
    name: 'AVD-Availability-Set-${time}'
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
    params: {
        name: avdAvailabilitySetName
        location: avdSessionHostLocation
        availabilitySetFaultDomain: avdAsFaultDomainCount
        availabilitySetUpdateDomain: avdAsUpdateDomainCount
    }
    dependsOn: [
        avdComputeObjectsRg
    ]
}

// Session hosts
// Call on the KV.
resource avdWrklKeyVaultget 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = if (avdDeploySessionHosts) {
    name: avdWrklKvName
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
}

module avdSessionHosts '../carml/1.0.0/Microsoft.Compute/virtualMachines/deploy.bicep' = [for i in range(0, avdDeploySessionHostsCount): if (avdDeploySessionHosts) {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
    name: 'AVD-Session-Host-${i}-${time}'
    params: {
        name: '${avdSessionHostNamePrefix}-${i}'
        location: avdSessionHostLocation
        userAssignedIdentities: {
            '${fslogixManagedIdentity.outputs.resourceId}' : {} 
        }
        availabilityZone: avdUseAvailabilityZones ? take(skip(allAvailabilityZones, i % length(allAvailabilityZones)), 1) : []
        encryptionAtHost: encryptionAtHost
        availabilitySetName: !avdUseAvailabilityZones ? (avdDeploySessionHosts ? avdAvailabilitySet.outputs.name : '') : ''
        osType: 'Windows'
        licenseType: 'Windows_Client'
        vmSize: avdSessionHostsSize
        imageReference: useSharedImage ? json('{\'id\': \'${avdImageTemplataDefinitionId}\'}') : marketPlaceGalleryWindows[avdOsImage]
        osDisk: {
            createOption: 'fromImage'
            deleteOption: 'Delete'
            diskSizeGB: 128
            managedDisk: {
                storageAccountType: avdSessionHostDiskType
            }
        }
        adminUsername: avdVmLocalUserName
        adminPassword: avdVmLocalUserPassword //avdWrklKeyVaultget.getSecret('avdVmLocalUserPassword') //avdVmLocalUserPassword // need to update to get value from KV
        nicConfigurations: [
            {
                nicSuffix: '-nic-01'
                deleteOption: 'Delete'
                asgId: createAvdVnet ? '${avdApplicationSecurityGroup.outputs.resourceId}' : null
                enableAcceleratedNetworking: false
                ipConfigurations: [
                    {
                        name: 'ipconfig01'
                        subnetId: createAvdVnet ? '${avdVirtualNetwork.outputs.resourceId}/subnets/${avdVnetworkSubnetName}' : existingVnetSubnetResourceId
                    }
                ]
            }
        ]
        // Join domain
        allowExtensionOperations: true
        extensionDomainJoinPassword: avdDomainJoinUserPassword //avdWrklKeyVaultget.getSecret('avdDomainJoinUserPassword')
        extensionDomainJoinConfig: {
            enabled: true
            settings: {
                name: avdIdentityDomainName
                ouPath: !empty(avdOuPath) ? avdOuPath : null
                user: avdDomainJoinUserName
                restart: 'true'
                options: '3'
            }
        }
        // Enable and Configure Microsoft Malware
        extensionAntiMalwareConfig: {
            enabled: true
            settings: {
                AntimalwareEnabled: true
                RealtimeProtectionEnabled: 'true'
                ScheduledScanSettings: {
                    isEnabled: 'true'
                    day: '7' // Day of the week for scheduled scan (1-Sunday, 2-Monday, ..., 7-Saturday)
                    time: '120' // When to perform the scheduled scan, measured in minutes from midnight (0-1440). For example: 0 = 12AM, 60 = 1AM, 120 = 2AM.
                    scanType: 'Quick' //Indicates whether scheduled scan setting type is set to Quick or Full (default is Quick)
                }
                Exclusions: {
                    Extensions: '*.vhd;*.vhdx'
                    Paths: '"%ProgramFiles%\\FSLogix\\Apps\\frxdrv.sys;%ProgramFiles%\\FSLogix\\Apps\\frxccd.sys;%ProgramFiles%\\FSLogix\\Apps\\frxdrvvt.sys;%TEMP%\\*.VHD;%TEMP%\\*.VHDX;%Windir%\\TEMP\\*.VHD;%Windir%\\TEMP\\*.VHDX;\\\\server\\share\\*\\*.VHD;\\\\server\\share\\*\\*.VHDX'
                    Processes: '%ProgramFiles%\\FSLogix\\Apps\\frxccd.exe;%ProgramFiles%\\FSLogix\\Apps\\frxccds.exe;%ProgramFiles%\\FSLogix\\Apps\\frxsvc.exe'
                }
            }
        }
    }
    dependsOn: [
        avdComputeObjectsRg
        avdWrklKeyVault
        avdWrklKeyVaultget
    ]
}]
// Add session hosts to AVD Host pool.
module addAvdHostsToHostPool '../carml/1.0.0/Microsoft.Compute/virtualMachines/extensions/add-avd-session-hosts.bicep' = [for i in range(0, avdDeploySessionHostsCount): if (avdDeploySessionHosts) {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
    name: 'Add-AVD-Session-Host-${i}-to-HostPool-${time}'
    params: {
        location: avdSessionHostLocation
        hostPoolToken: '${avdHostPool.outputs.hostPoolRestrationInfo.token}'
        name: '${avdSessionHostNamePrefix}-${i}'
        hostPoolName: avdHostPoolName
        avdAgentPackageLocation: avdAgentPackageLocation
    }
    dependsOn: [
        avdSessionHosts
        avdHostPool
    ]
}]

// Add the registry keys for Fslogix. Alternatively can be enforced via GPOs
module configureFsLogixForAvdHosts '../carml/1.0.0/Microsoft.Compute/virtualMachines/extensions/configure-fslogix-session-hosts.bicep' = [for i in range(0, avdDeploySessionHostsCount): if (avdDeploySessionHosts) {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
    name: 'Configure-FsLogix-for-${avdSessionHostNamePrefix}-${i}-${time}'
    params: {
        location: avdSessionHostLocation
        name: '${avdSessionHostNamePrefix}-${i}'
        file: fsLogixScript
        FsLogixScriptArguments: FsLogixScriptArguments
        baseScriptUri: fslogixScriptUri
    }
    dependsOn: [
        avdSessionHosts
    ]
}]
//
