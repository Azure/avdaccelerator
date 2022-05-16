targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@minLength(2)
@maxLength(4)
@description('Required. The name of the resource group to deploy')
param deploymentPrefix string = ''

@allowed([
    'Multiple'
    'Single'
])
@description('Required. AVD subscription model (Default: Multiple)')
param avdSubOrgsOption string = 'Multiple'

@description('Required. Location where to deploy compute services')
param avdSessionHostLocation string = ''

@description('Required. Location where to deploy AVD management plane')
param avdManagementPlaneLocation string = ''

@description('Optional. AVD shared services subscription ID, single subscriptions scenario')
param avdSingleSubsId string = ''

@description('Optional. AVD shared services subscription ID, multiple subscriptions scenario')
param avdShrdlSubsId string = ''

@description('Optional. AVD workload subscription ID, multiple subscriptions scenario')
param avdWrklSubsId string = ''

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

/*
@description('Existing virtual network subscription')
param existingVnetSubscriptionId string = ''

@description('Existing virtual network resource group')
param existingVnetRgName string = ''

@description('Existing virtual network')
param existingVnetName string = ''

@description('Existing virtual network subnet (subnet requires PrivateEndpointNetworkPolicies property to be disabled)')
param existingVnetSubnetName string = ''
*/

@description('Existing virtual network subnet')
param existingVnetSubnetResourceId string = ''

/*
@description('Existing hub virtual network subscription')
param existingHubVnetSubscriptionId string

@description('Existing hub virtual network resource group')
param existingHubVnetRgName string = ''

@description('Existing hub virtual network')
param existingHubVnetName string = ''
*/
@description('Existing hub virtual network for perring')
param existingHubVnetResourceId string = ''

@description('AVD virtual network address prefixes')
param avdVnetworkAddressPrefixes string = ''

@description('AVD virtual network subnet address prefix')
param avdVnetworkSubnetAddressPrefix string = ''

@description('custom DNS servers IPs')
param customDnsIps string = ''

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

@description('Storage account SKU for FSLogix storage. Recommended tier is Premium LRS or Premium ZRS (where available)')
param fsLogixstorageSku string = ''

@description('Optional. This property can be used by user in the request to enable or disable the Host Encryption for the virtual machine. This will enable the encryption for all the disks including Resource/Temp disk at host itself. For security reasons, it is recommended to set encryptionAtHost to True. Restrictions: Cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
param encryptionAtHost bool = true

@description('Session host VM size (Defualt: Standard_D2s_v4) ')
param avdSessionHostsSize string = 'Standard_D2s_v4'

@description('OS disk type for session host (Defualt: Standard_LRS) ')
param avdSessionHostDiskType string = 'Standard_LRS'

@allowed([
    'eastus'
    'eastus2'
    'westcentralus'
    'westus'
    'westus2'
    'westus3'
    'southcentralus'
    'northeurope'
    'westeurope'
    'southeastasia'
    'australiasoutheast'
    'australiaeast'
    'uksouth'
    'ukwest'
])
@description('Azure image builder location (Defualt: eastus2)')
param aiblocation string = 'eastus2'

@description('Create custom azure image builder role')
param createAibCustomRole bool = true

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

@description('Regions to replicate AVD images (Defualt: eastus2)')
param avdImageRegionsReplicas array = [
    'eastus2'
]

@description('Create azure image Builder managed identity')
param createAibManagedIdentity bool = true

@description('Do not modify, used to set unique value for resource deployment')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var deploymentPrefixLowercase = toLower(deploymentPrefix)
var avdSessionHostLocationLowercase = toLower(avdSessionHostLocation)
var avdManagementPlaneLocationLowercase = toLower(avdManagementPlaneLocation)
var avdWrklSubscriptionId = (avdSubOrgsOption == 'Multiple') ? avdWrklSubsId : avdSingleSubsId
var avdShrdlSubscriptionId = (avdSubOrgsOption == 'Multiple') ? avdShrdlSubsId : avdSingleSubsId
var avdServiceObjectsRgName = 'rg-${avdManagementPlaneLocationLowercase}-avd-${deploymentPrefixLowercase}-service-objects' // max length limit 90 characters
var avdNetworkObjectsRgName = 'rg-${avdSessionHostLocationLowercase}-avd-${deploymentPrefixLowercase}-network' // max length limit 90 characters
var avdComputeObjectsRgName = 'rg-${avdSessionHostLocationLowercase}-avd-${deploymentPrefixLowercase}-pool-compute' // max length limit 90 characters
var avdStorageObjectsRgName = 'rg-${avdSessionHostLocationLowercase}-avd-${deploymentPrefixLowercase}-storage' // max length limit 90 characters
var avdSharedResourcesRgName = 'rg-${avdSessionHostLocationLowercase}-avd-shared-resources'
var imageGalleryName = 'avdgallery${avdSessionHostLocationLowercase}'
//var existingVnetResourceId = '/subscriptions/${existingVnetSubscriptionId}/resourceGroups/${existingVnetRgName}/providers/Microsoft.Network/virtualNetworks/${existingVnetName}'
//var hubVnetId = '/subscriptions/${existingHubVnetSubscriptionId}/resourceGroups/${existingHubVnetRgName}/providers/Microsoft.Network/virtualNetworks/${existingHubVnetName}'
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
var aibManagedIdentityName = 'avd-uai-aib'
var deployScriptManagedIdentityName = 'avd-uai-deployScript'
var imageDefinitionsTemSpecName = 'AVDImageDefinition_${avdOsImage}'
var imageVmSize = 'Standard_D4s_v3'
var avdOsImageDefinitions = {
    'win10_21h2_office': {
        name: 'Windows10_21H2_Office'
        osType: 'Windows'
        osState: 'Generalized'
        offer: 'office-365'
        publisher: 'MicrosoftWindowsDesktop'
        sku: 'win10-21h2-avd-m365'
        osAccountType: 'Standard_LRS'
        hyperVGeneration: 'V1'
    }
    'win10_21h2': {
        name: 'Windows10_21H2'
        osType: 'Windows'
        osState: 'Generalized'
        offer: 'windows-10'
        publisher: 'MicrosoftWindowsDesktop'
        sku: 'win10-21h2-avd'
        osAccountType: 'Standard_LRS'
        hyperVGeneration: 'V1'
    }
    'win11_21h2_office': {
        name: 'Windows11_21H2'
        osType: 'Windows'
        osState: 'Generalized'
        offer: 'office-365'
        publisher: 'MicrosoftWindowsDesktop'
        sku: 'win11-21h2-avd-m365'
        osAccountType: 'Standard_LRS'
        hyperVGeneration: 'V2'
    }
    'win11_21h2': {
        name: 'Windows11_21H2'
        osType: 'Windows'
        osState: 'Generalized'
        offer: 'windows-11'
        publisher: 'MicrosoftWindowsDesktop'
        sku: 'win11-21h2-avd'
        osAccountType: 'Standard_LRS'
        hyperVGeneration: 'V2'
    }
}

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

var baseScriptUri = 'https://raw.githubusercontent.com/nataliakon/ResourceModules/AVD-Accelerator/workload/'
var fslogixScriptUri = '${baseScriptUri}Scripts/Set-FSLogixRegKeys.ps1'
var fsLogixScript = './Set-FSLogixRegKeys.ps1'
var fslogixSharePath = '\\\\${avdFslogixStorageName}.file.${environment().suffixes.storage}\\${avdFslogixFileShareName}'
var FsLogixScriptArguments = '-volumeshare ${fslogixSharePath}'
// var avdAgentPackageLocation = 'https://wvdportalstorageblob.blob.${environment().suffixes.storage}/galleryartifacts/Configuration_01-20-2022.zip'
var avdAgentPackageLocation = 'https://wvdportalstorageblob.blob.${environment().suffixes.storage}/galleryartifacts/Configuration_10-6-2021.zip'
var avdFslogixStorageName = 'fslogix${uniqueString(deploymentPrefixLowercase, avdSessionHostLocationLowercase)}${deploymentPrefixLowercase}'
var avdFslogixFileShareName = 'fslogix-${deploymentPrefixLowercase}'
var avdSharedSResourcesStorageName = 'avd${uniqueString(deploymentPrefixLowercase, avdSessionHostLocationLowercase)}shared'
var avdSharedSResourcesAibContainerName = 'aib-${deploymentPrefixLowercase}'
var avdSharedSResourcesScriptsContainerName = 'scripts-${deploymentPrefixLowercase}'
var avdSharedServicesKvName = 'avd-${uniqueString(deploymentPrefixLowercase, avdSessionHostLocationLowercase)}-shared' // max length limit 24 characters
var avdWrklKvName = 'avd-${uniqueString(deploymentPrefixLowercase, avdSessionHostLocationLowercase)}-${deploymentPrefixLowercase}' // max length limit 24 characters
var avdSessionHostNamePrefix = 'avdsh-${deploymentPrefix}'
var avdAvailabilitySetName = 'avdas-${deploymentPrefix}'
var allAvailabilityZones = pickZones('Microsoft.Compute', 'virtualMachines', avdSessionHostLocation, 3)

// =========== //
// Deployments //
// =========== //

// Resource groups
// AVD shared services subscription RGs
module avdSharedResourcesRg '../carml/1.0.0/Microsoft.Resources/resourceGroups/deploy.bicep' = {
    scope: subscription(avdShrdlSubscriptionId)
    name: 'AVD-RG-Shared-Resources-${time}'
    params: {
        name: avdSharedResourcesRgName
        location: avdSessionHostLocation
    }
}
// AVD Workload subscription RGs
module avdServiceObjectsRg '../carml/1.0.0/Microsoft.Resources/resourceGroups/deploy.bicep' = {
    scope: subscription(avdWrklSubscriptionId)
    name: 'AVD-RG-ServiceObjects-${time}'
    params: {
        name: avdServiceObjectsRgName
        location: avdManagementPlaneLocation
    }
}

module avdNetworkObjectsRg '../carml/1.0.0/Microsoft.Resources/resourceGroups/deploy.bicep' = if (createAvdVnet) {
    scope: subscription(avdWrklSubscriptionId)
    name: 'AVD-RG-Network-${time}'
    params: {
        name: avdNetworkObjectsRgName
        location: avdSessionHostLocation
    }
}

module avdComputeObjectsRg '../carml/1.0.0/Microsoft.Resources/resourceGroups/deploy.bicep' = {
    scope: subscription(avdWrklSubscriptionId)
    name: 'AVD-RG-Compute-${time}'
    params: {
        name: avdComputeObjectsRgName
        location: avdSessionHostLocation
    }
}

module avdStorageObjectsRg '../carml/1.0.0/Microsoft.Resources/resourceGroups/deploy.bicep' = {
    scope: subscription(avdWrklSubscriptionId)
    name: 'AVD-RG-Storage-${time}'
    params: {
        name: avdStorageObjectsRgName
        location: avdSessionHostLocation
    }
}
//

// Networking
module avdNetworksecurityGroup '../carml/1.0.0/Microsoft.Network/networkSecurityGroups/deploy.bicep' = if (createAvdVnet) {
    scope: resourceGroup('${avdWrklSubscriptionId}', '${avdNetworkObjectsRgName}')
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
    scope: resourceGroup('${avdWrklSubscriptionId}', '${avdComputeObjectsRgName}')
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
    scope: resourceGroup('${avdWrklSubscriptionId}', '${avdNetworkObjectsRgName}')
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
    scope: resourceGroup('${avdWrklSubscriptionId}', '${avdNetworkObjectsRgName}')
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

//

// AVD management plane
module avdWorkSpace '../carml/1.0.0/Microsoft.DesktopVirtualization/workspaces/deploy.bicep' = {
    scope: resourceGroup('${avdWrklSubscriptionId}', '${avdServiceObjectsRgName}')
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
    scope: resourceGroup('${avdWrklSubscriptionId}', '${avdServiceObjectsRgName}')
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
    scope: resourceGroup('${avdWrklSubscriptionId}', '${avdServiceObjectsRgName}')
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
    scope: resourceGroup('${avdWrklSubscriptionId}', '${avdServiceObjectsRgName}')
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
//

// RBAC Roles
module startVMonConnectRole '../carml/1.0.0/Microsoft.Authorization/roleDefinitions/subscription/deploy.bicep' = if (createStartVmOnConnectCustomRole) {
    scope: subscription(avdWrklSubscriptionId)
    name: 'Start-VM-on-Connect-Role-${time}'
    params: {
        subscriptionId: avdWrklSubscriptionId
        description: 'Start VM on connect AVD'
        roleName: 'StartVMonConnect-AVD'
        actions: [
            'Microsoft.Compute/virtualMachines/start/action'
            'Microsoft.Compute/virtualMachines/*/read'
        ]
        assignableScopes: [
            '/subscriptions/${avdWrklSubscriptionId}'
        ]
    }
}

module azureImageBuilderRole '../carml/1.0.0/Microsoft.Authorization/roleDefinitions/subscription/deploy.bicep' = if (createAibCustomRole) {
    scope: subscription(avdShrdlSubscriptionId)
    name: 'Azure-Image-Builder-Role-${time}'
    params: {
        subscriptionId: avdShrdlSubscriptionId
        description: 'Azure Image Builder AVD'
        roleName: 'AzureImageBuilder-AVD'
        actions: [
            'Microsoft.Authorization/*/read'
            'Microsoft.Compute/images/write'
            'Microsoft.Compute/images/read'
            'Microsoft.Compute/images/delete'
            'Microsoft.Compute/galleries/read'
            'Microsoft.Compute/galleries/images/read'
            'Microsoft.Compute/galleries/images/versions/read'
            'Microsoft.Compute/galleries/images/versions/write'
            'Microsoft.Storage/storageAccounts/blobServices/containers/read'
            'Microsoft.Storage/storageAccounts/blobServices/containers/write'
            'Microsoft.Storage/storageAccounts/blobServices/read'
            'Microsoft.ContainerInstance/containerGroups/read'
            'Microsoft.ContainerInstance/containerGroups/write'
            'Microsoft.ContainerInstance/containerGroups/start/action'
            'Microsoft.ManagedIdentity/userAssignedIdentities/*/read'
            'Microsoft.ManagedIdentity/userAssignedIdentities/*/assign/action'
            'Microsoft.Authorization/*/read'
            'Microsoft.Resources/deployments/*'
            'Microsoft.Resources/deploymentScripts/read'
            'Microsoft.Resources/deploymentScripts/write'
            'Microsoft.Resources/subscriptions/resourceGroups/read'
            'Microsoft.VirtualMachineImages/imageTemplates/run/action'
            'Microsoft.VirtualMachineImages/imageTemplates/read'
            'Microsoft.Network/virtualNetworks/read'
            'Microsoft.Network/virtualNetworks/subnets/join/action'
        ]
        assignableScopes: [
            '/subscriptions/${avdShrdlSubscriptionId}'
        ]
    }
}
//

// Managed identities
module imageBuilderManagedIdentity '../carml/1.0.0/Microsoft.ManagedIdentity/userAssignedIdentities/deploy.bicep' = if (createAibManagedIdentity) {
    scope: resourceGroup('${avdShrdlSubscriptionId}', '${avdSharedResourcesRgName}')
    name: 'image-Builder-Managed-Identity-${time}'
    params: {
        name: aibManagedIdentityName
        location: avdSessionHostLocation
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}

module deployScriptManagedIdentity '../carml/1.0.0/Microsoft.ManagedIdentity/userAssignedIdentities/deploy.bicep' = if (useSharedImage) {
    scope: resourceGroup('${avdShrdlSubscriptionId}', '${avdSharedResourcesRgName}')
    name: 'deployment-Script-Managed-Identity-${time}'
    params: {
        name: deployScriptManagedIdentityName
        location: avdSessionHostLocation
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}
//

// Introduce delay for User Managed Assigned Identity to propagate through the system

module userManagedIdentityDelay '../carml/1.0.0/Microsoft.Resources/deploymentScripts/deploy.bicep' = if (useSharedImage || createAibManagedIdentity) {
    scope: resourceGroup('${avdShrdlSubscriptionId}', '${avdSharedResourcesRgName}')
    name: 'AVD-userManagedIdentityDelay-${time}'
    params: {
        name: 'AVD-userManagedIdentityDelay-${time}'
        location: avdSessionHostLocation
        azPowerShellVersion: '6.2'
        cleanupPreference: 'Always'
        timeout: 'PT10M'
        scriptContent: useSharedImage || createAibManagedIdentity ? '''
        Write-Host "Start"
        Get-Date
        Start-Sleep -Seconds 60
        Write-Host "Stop"
        Get-Date
        ''' : ''
    }
    dependsOn: [
        imageBuilderManagedIdentity
        deployScriptManagedIdentity
    ]
}

// Enterprise applications
//

// RBAC role Assignments
module azureImageBuilderRoleAssign '../carml/1.0.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (createAibCustomRole && createAibManagedIdentity) {
    name: 'Azure-Image-Builder-RoleAssign-${time}'
    scope: resourceGroup('${avdShrdlSubscriptionId}', '${avdSharedResourcesRgName}')
    params: {
        roleDefinitionIdOrName: createAibCustomRole ? azureImageBuilderRole.outputs.resourceId : ''
        principalId: createAibManagedIdentity ? imageBuilderManagedIdentity.outputs.principalId : ''
    }
    dependsOn: [
        userManagedIdentityDelay
    ]
}

module deployScriptRoleAssign '../carml/1.0.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (createAibCustomRole && useSharedImage) {
    name: 'deploy-script-RoleAssign-${time}'
    scope: resourceGroup('${avdShrdlSubscriptionId}', '${avdSharedResourcesRgName}')
    params: {
        roleDefinitionIdOrName: createAibCustomRole ? azureImageBuilderRole.outputs.resourceId : '/subscriptions/${avdShrdlSubscriptionId}/providers/Microsoft.Authorization/roleDefinitions/f1a07417-d97a-45cb-824c-7a7467783830'
        principalId: useSharedImage ? deployScriptManagedIdentity.outputs.principalId : ''
    }
    dependsOn: [
        userManagedIdentityDelay
    ]
}

/*
module azureImageBuilderRoleAssignExisting '../arm/1.0.0/Microsoft.Authorization/roleAssignments/.bicep/nested_rbac_rg.bicep' = if (!createAibCustomRole && createAibManagedIdentity) {
    name: 'Azure-Image-Builder-RoleAssign-${time}'
    scope: resourceGroup('${avdShrdlSubscriptionId}', '${avdSharedResourcesRgName}')
    params: {
        roleDefinitionIdOrName: createAibCustomRole ? azureImageBuilderRole.outputs.resourceId : ''
        principalId: imageBuilderManagedIdentity.outputs.principalId
    }
    dependsOn: [
        azureImageBuilderRole
        imageBuilderManagedIdentity
    ]
}
*/
module startVMonConnectRoleAssign '../carml/1.0.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (createStartVmOnConnectCustomRole) {
    name: 'Start-VM-OnConnect-RoleAssign-${time}'
    scope: resourceGroup('${avdWrklSubscriptionId}', '${avdComputeObjectsRgName}')
    params: {
        roleDefinitionIdOrName: createStartVmOnConnectCustomRole ? startVMonConnectRole.outputs.resourceId : ''
        principalId: avdEnterpriseAppObjectId
    }
    dependsOn: [
        avdServiceObjectsRg
        startVMonConnectRole
    ]
}

// Custom images: Azure Image Builder deployment. Azure Compute Gallery --> Image Template Definition --> Image Template --> Build and Publish Template --> Create VMs
// Azure Compute Gallery
module azureComputeGallery '../carml/1.0.0/Microsoft.Compute/galleries/deploy.bicep' = if (useSharedImage) {
    scope: resourceGroup('${avdShrdlSubscriptionId}', '${avdSharedResourcesRgName}')
    name: 'Deploy-Azure-Compute-Gallery-${time}'
    params: {
        name: imageGalleryName
        location: avdSessionHostLocation

        galleryDescription: 'Azure Virtual Desktops Images'
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}
//

// Image Template Definition
module avdImageTemplataDefinition '../carml/1.0.0/Microsoft.Compute/galleries/images/deploy.bicep' = if (useSharedImage) {
    scope: resourceGroup('${avdShrdlSubscriptionId}', '${avdSharedResourcesRgName}')
    name: 'Deploy-AVD-Image-Template-Definition-${time}'
    params: {
        galleryName: useSharedImage ? azureComputeGallery.outputs.name : ''
        name: imageDefinitionsTemSpecName
        osState: avdOsImageDefinitions[avdOsImage].osState
        osType: avdOsImageDefinitions[avdOsImage].osType
        publisher: avdOsImageDefinitions[avdOsImage].publisher
        offer: avdOsImageDefinitions[avdOsImage].offer
        sku: avdOsImageDefinitions[avdOsImage].sku
        location: aiblocation
        hyperVGeneration: avdOsImageDefinitions[avdOsImage].hyperVGeneration
    }
    dependsOn: [
        azureComputeGallery
        avdSharedResourcesRg
    ]
}

//

// Create Image Template
module imageTemplate '../carml/1.0.0/Microsoft.VirtualMachineImages/imageTemplates/deploy.bicep' = if (useSharedImage) {
    scope: resourceGroup('${avdShrdlSubscriptionId}', '${avdSharedResourcesRgName}')
    name: 'AVD-Deploy-Image-Template-${time}'
    params: {
        name: imageDefinitionsTemSpecName
        userMsiName: createAibManagedIdentity && useSharedImage ? imageBuilderManagedIdentity.outputs.name : ''
        userMsiResourceGroup: createAibManagedIdentity && useSharedImage ? imageBuilderManagedIdentity.outputs.resourceGroupName : ''
        location: aiblocation
        imageReplicationRegions: (avdSessionHostLocation == aiblocation) ? array('${avdSessionHostLocation}') : concat(array('${aiblocation}'), array('${avdSessionHostLocation}'))
        sigImageDefinitionId: useSharedImage ? avdImageTemplataDefinition.outputs.resourceId : ''
        vmSize: imageVmSize
        customizationSteps: [
            {
                type: 'PowerShell'
                name: 'OptimizeOS'
                runElevated: true
                runAsSystem: true
                scriptUri: '${baseScriptUri}Scripts/Optimize_OS_for_AVD.ps1' // need to update value to accelerator github after
            }

            {
                type: 'WindowsRestart'
                restartCheckCommand: 'write-host "restarting post Optimizations"'
                restartTimeout: '10m'
            }

            {
                type: 'WindowsUpdate'
                searchCriteria: 'IsInstalled=0'
                filters: [
                    'exclude:$_.Title -like \'*Preview*\''
                    'include:$true'
                ]
                updateLimit: 40
            }
            {
                type: 'PowerShell'
                name: 'Sleep for a min'
                runElevated: true
                runAsSystem: true
                inline: [
                    'Write-Host "Sleep for a 5 min" '
                    'Start-Sleep -Seconds 300'
                ]
            }
            {
                type: 'WindowsRestart'
                restartCheckCommand: 'write-host "restarting post Windows updates"'
                restartTimeout: '10m'
            }
            {
                type: 'PowerShell'
                name: 'Sleep for a min'
                runElevated: true
                runAsSystem: true
                inline: [
                    'Write-Host "Sleep for a min" '
                    'Start-Sleep -Seconds 60'
                ]
            }
            {
                type: 'WindowsRestart'
                restartTimeout: '10m'
            }
        ]
        imageSource: {
            type: 'PlatformImage'
            publisher: avdOsImageDefinitions[avdOsImage].publisher
            offer: avdOsImageDefinitions[avdOsImage].offer
            sku: avdOsImageDefinitions[avdOsImage].sku
            osAccountType: avdOsImageDefinitions[avdOsImage].osAccountType
            version: 'latest'
        }
    }
    dependsOn: [
        avdImageTemplataDefinition
        azureComputeGallery
        avdSharedResourcesRg
        azureImageBuilderRoleAssign
    ]
}
//

// Build Image Template
module imageTemplateBuild '../carml/1.0.0/Microsoft.Resources/deploymentScripts/deploy.bicep' = if (useSharedImage) {
    scope: resourceGroup('${avdShrdlSubscriptionId}', '${avdSharedResourcesRgName}')
    name: 'AVD-Build-Image-Template-${time}'
    params: {
        name: 'imageTemplateBuildName-${avdOsImage}'
        location: aiblocation
        azPowerShellVersion: '6.2'
        cleanupPreference: 'Always'
        timeout: 'PT2H'
        containerGroupName: 'imageTemplateBuildName-${avdOsImage}-aci'
        userAssignedIdentities: createAibManagedIdentity ? {
            '${imageBuilderManagedIdentity.outputs.resourceId}': {}
        } : {}
        arguments: '-subscriptionId \'${avdShrdlSubscriptionId}\' -resourceGroupName \'${avdSharedResourcesRgName}\' -imageTemplateName \'${(useSharedImage ? imageTemplate.outputs.name : null)}\''
        scriptContent: useSharedImage ? '''
        param(
            [string] [Parameter(Mandatory=$true)] $resourceGroupName,
            [string] [Parameter(Mandatory=$true)] $imageTemplateName,
            [string] [Parameter(Mandatory=$true)] $subscriptionId
            )
                $ErrorActionPreference = "Stop"
                Install-Module -Name Az.ImageBuilder -Force
                # Kick off the Azure Image Build 
                Write-Host "Kick off Image buld for $imageTemplateName"
                Invoke-AzResourceAction -ResourceName $imageTemplateName -ResourceGroupName $resourceGroupName -ResourceType "Microsoft.VirtualMachineImages/imageTemplates" -Action Run -Force              
                $DeploymentScriptOutputs = @{}
            $getStatus=$(Get-AzImageBuilderTemplate -ResourceGroupName $resourceGroupName -Name $imageTemplateName)
            $status=$getStatus.LastRunStatusRunState
            $statusMessage=$getStatus.LastRunStatusMessage
            $startTime=Get-Date
            $reset=$startTime + (New-TimeSpan -Minutes 40)
            Write-Host "Script will time out in $reset"
                do {
                $now=Get-Date
                Write-Host "Getting the current time: $now"
                if (($now -eq $reset) -or ($now -gt $reset)) {
                    break
                }
                $expiryTime=(Get-AzAccessToken).ExpiresOn.Datetime
                Write-Host "Token expiry time is $expiryTime"
                $getStatus=$(Get-AzImageBuilderTemplate -ResourceGroupName $resourceGroupName -Name $imageTemplateName)
                $status=$getStatus.LastRunStatusRunState
                Write-Host "Current status of the image build $imageTemplateName is: $status"
                Write-Host "Script will time out in $reset"
                $DeploymentScriptOutputs=$now
                $DeploymentScriptOutputs=$status
                if ($status -eq "Failed") {
                    Write-Host "Build failed for image template: $imageTemplateName. Check the Packer logs"
                    $DeploymentScriptOutputs="Build Failed"
                    throw "Build Failed"
                }
                if (($status -eq "Canceled") -or ($status -eq "Canceling") ) {
                    Write-Host "User canceled the build. Delete the Image template definition: $imageTemplateName"
                    throw "User canceled the build."
                }
                if ($status -eq "Succeeded") {
                    Write-Host "Success. Image template definition: $imageTemplateName is finished "
                    break
                }
            }
            until (($now -eq $reset) -or ($now -gt $reset))
            Write-Host "Finished check for image build status at $now"


        ''' : ''
    }
    dependsOn: [
        imageTemplate
        avdSharedResourcesRg
        azureImageBuilderRoleAssign
    ]
}

// Execute Deployment script to check the status of the image build.

module imageTemplateBuildCheck '../carml/1.0.0/Microsoft.Resources/deploymentScripts/deploy.bicep' = if (useSharedImage) {
    scope: resourceGroup('${avdShrdlSubscriptionId}', '${avdSharedResourcesRgName}')
    name: 'AVD-Build-Image-Template-${avdOsImage}-Check-Build'
    params: {
        name: 'imageTemplateBuildCheckName-${avdOsImage}'
        location: aiblocation
        timeout: 'PT30M'
        containerGroupName: 'imageTemplateBuildCheckName-${avdOsImage}-aci'
        runOnce: false
        azPowerShellVersion: '6.2'
        cleanupPreference: 'Always'
        userAssignedIdentities: useSharedImage ? {
            '${deployScriptManagedIdentity.outputs.resourceId}': {}
        } : {}
        arguments: '-subscriptionId \'${avdShrdlSubscriptionId}\' -resourceGroupName \'${avdSharedResourcesRgName}\' -imageTemplateName \'${(useSharedImage ? imageTemplate.outputs.name : null)}\''
        scriptContent: useSharedImage ? '''
        param(
        [string] [Parameter(Mandatory=$true)] $resourceGroupName,
        [string] [Parameter(Mandatory=$true)] $imageTemplateName,
        [string] [Parameter(Mandatory=$true)] $subscriptionId
        )
            $ErrorActionPreference = "Stop"
            Install-Module -Name Az.ImageBuilder -Force
            $DeploymentScriptOutputs = @{}
        $getStatus=$(Get-AzImageBuilderTemplate -ResourceGroupName $resourceGroupName -Name $imageTemplateName)
        $status=$getStatus.LastRunStatusRunState
        $statusMessage=$getStatus.LastRunStatusMessage
        $startTime=Get-Date
        $reset=$startTime + (New-TimeSpan -Minutes 40)
        Write-Host "Script will time out in $reset"
            do {
            $now=Get-Date
            Write-Host "Getting the current time: $now"
            if (($now -eq $reset) -or ($now -gt $reset)) {
                break
            }
            $expiryTime=(Get-AzAccessToken).ExpiresOn.Datetime
            Write-Host "Token expiry time is $expiryTime"
            $getStatus=$(Get-AzImageBuilderTemplate -ResourceGroupName $resourceGroupName -Name $imageTemplateName)
            $status=$getStatus.LastRunStatusRunState
            Write-Host "Current status of the image build $imageTemplateName is: $status"
            Write-Host "Script will time out in $reset"
            $DeploymentScriptOutputs=$now
            $DeploymentScriptOutputs=$status
            if ($status -eq "Failed") {
                Write-Host "Build failed for image template: $imageTemplateName. Check the Packer logs"
                $DeploymentScriptOutputs="Build Failed"
                throw "Build Failed"
            }
            if (($status -eq "Canceled") -or ($status -eq "Canceling") ) {
                Write-Host "User canceled the build. Delete the Image template definition: $imageTemplateName"
                throw "User canceled the build."
            }
            if ($status -eq "Succeeded") {
                Write-Host "Success. Image template definition: $imageTemplateName is finished "
                break
            }
        }
        until (($now -eq $reset) -or ($now -gt $reset))
        Write-Host "Finished check for image build status at $now"

        ''' : ''
    }
    dependsOn: [
        imageTemplate //we need to make this dependson conditional so it plays well with other deployment flags
        avdSharedResourcesRg
        azureImageBuilderRoleAssign
        imageTemplateBuild //we need to make this dependson conditional so it plays well with other deployment flags
    ]
}

//

// Key vaults
module avdWrklKeyVault '../carml/1.0.0/Microsoft.KeyVault/vaults/deploy.bicep' = {
    scope: resourceGroup('${avdWrklSubscriptionId}', '${avdServiceObjectsRgName}')
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
                //subnetResourceId: createAvdVnet ? '${avdVirtualNetwork.outputs.resourceId}/subnets/${avdVnetworkSubnetName}' : '${existingVnetResourceId}/subnets/${existingVnetSubnetName}'
                subnetResourceId: createAvdVnet ? '${avdVirtualNetwork.outputs.resourceId}/subnets/${avdVnetworkSubnetName}' : existingVnetSubnetResourceId
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
        /*
        accessPolicies: [
            {
                objectId: avdWrklSecretAccess
                permissions: {
                    secrets: [
                        'get'
                        'list'
                    ]
                }
            }
        ]
        */
    }
    dependsOn: [
        avdComputeObjectsRg
    ]
}

module avdSharedServicesKeyVault '../carml/1.0.0/Microsoft.KeyVault/vaults/deploy.bicep' = {
    scope: resourceGroup('${avdShrdlSubscriptionId}', '${avdSharedResourcesRgName}')
    name: 'AVD-Shared-Services-KeyVault-${time}'
    params: {
        name: avdSharedServicesKvName
        location: avdSessionHostLocation
        enableRbacAuthorization: false
        softDeleteRetentionInDays: 7
        networkAcls: {
            bypass: 'AzureServices'
            defaultAction: 'Deny'
            virtualNetworkRules: []
            ipRules: []
        }
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}
//

// Storage

module fslogixStorage '../carml/1.0.0/Microsoft.Storage/storageAccounts/deploy.bicep' = if (avdDeploySessionHosts) {
    scope: resourceGroup('${avdWrklSubscriptionId}', '${avdStorageObjectsRgName}')
    name: 'AVD-Fslogix-Storage-${time}'
    params: {
        name: avdFslogixStorageName
        location: avdSessionHostLocation
        storageAccountSku: fsLogixstorageSku
        allowBlobPublicAccess: false
        //azureFilesIdentityBasedAuthentication:
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
                //subnetResourceId: createAvdVnet ? '${avdVirtualNetwork.outputs.resourceId}/subnets/${avdVnetworkSubnetName}' : '${existingVnetResourceId}/subnets/${existingVnetSubnetName}'
                subnetResourceId: createAvdVnet ? '${avdVirtualNetwork.outputs.resourceId}/subnets/${avdVnetworkSubnetName}' : existingVnetSubnetResourceId
                service: 'file'
            }
        ]
    }
    dependsOn: [
        avdStorageObjectsRg
    ]
}

module avdSharedServicesStorage '../carml/1.0.0/Microsoft.Storage/storageAccounts/deploy.bicep' = {
    scope: resourceGroup('${avdShrdlSubscriptionId}', '${avdSharedResourcesRgName}')
    name: 'AVD-Shared-Services-Storage-${time}'
    params: {
        name: avdSharedSResourcesStorageName
        location: avdSessionHostLocation
        storageAccountSku: avdUseAvailabilityZones ? 'Standard_ZRS' : 'Standard_LRS'
        storageAccountKind: 'StorageV2'
        blobServices: {
            containers: [
                {
                    name: avdSharedSResourcesAibContainerName
                    publicAccess: 'None'
                }
                {
                    name: avdSharedSResourcesScriptsContainerName
                    publicAccess: 'None'
                }
            ]
        }
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}
//

// Availability set
module avdAvailabilitySet '../carml/1.0.0/Microsoft.Compute/availabilitySets/deploy.bicep' = if (!avdUseAvailabilityZones && avdDeploySessionHosts) {
    name: 'AVD-Availability-Set-${time}'
    scope: resourceGroup('${avdWrklSubscriptionId}', '${avdComputeObjectsRgName}')
    params: {
        name: avdAvailabilitySetName
        location: avdSessionHostLocation
        availabilitySetFaultDomain: 3
        availabilitySetUpdateDomain: 5
    }
    dependsOn: [
        avdComputeObjectsRg
    ]
}

// Session hosts

// Session hosts
// Call on the KV.
resource avdWrklKeyVaultget 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = if (avdDeploySessionHosts) {
    name: avdWrklKvName
    scope: resourceGroup('${avdWrklSubscriptionId}', '${avdServiceObjectsRgName}')
}
/*
resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2021-01-14-preview' existing = {
    name: avdHostPoolName
    scope: resourceGroup('${avdWrklSubscriptionId}', '${avdServiceObjectsRgName}')
}
*/
module avdSessionHosts '../carml/1.0.0/Microsoft.Compute/virtualMachines/deploy.bicep' = [for i in range(0, avdDeploySessionHostsCount): if (avdDeploySessionHosts) {
    scope: resourceGroup('${avdWrklSubscriptionId}', '${avdComputeObjectsRgName}')
    name: 'AVD-Session-Host-${i}-${time}'
    //wait: 30
    //retry: 5
    params: {
        name: '${avdSessionHostNamePrefix}-${i}'
        location: avdSessionHostLocation
        systemAssignedIdentity: true
        availabilityZone: avdUseAvailabilityZones ? take(skip(allAvailabilityZones, i % length(allAvailabilityZones)), 1) : []
        encryptionAtHost: encryptionAtHost
        availabilitySetName: !avdUseAvailabilityZones ? (avdDeploySessionHosts ? avdAvailabilitySet.outputs.name : '') : ''
        osType: 'Windows'
        licenseType: 'Windows_Client'
        vmSize: avdSessionHostsSize
        imageReference: useSharedImage ? json('{\'id\': \'${avdImageTemplataDefinition.outputs.resourceId}\'}') : marketPlaceGalleryWindows[avdOsImage]
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
                        //subnetId: createAvdVnet ? '${avdVirtualNetwork.outputs.resourceId}/subnets/${avdVnetworkSubnetName}' : '${existingVnetResourceId}/subnets/${existingVnetSubnetName}'
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
                //enableAutomaticUpgrade: true
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
                //enableAutomaticUpgrade: true
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
        imageTemplateBuildCheck
    ]
}]
// Add session hosts to AVD Host pool.
module addAvdHostsToHostPool '../carml/1.0.0/Microsoft.Compute/virtualMachines/extensions/add-avd-session-hosts.bicep' = [for i in range(0, avdDeploySessionHostsCount): if (avdDeploySessionHosts) {
    scope: resourceGroup('${avdWrklSubscriptionId}', '${avdComputeObjectsRgName}')
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
    scope: resourceGroup('${avdWrklSubscriptionId}', '${avdComputeObjectsRgName}')
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

// ======= //
// Outputs //
// ======= //
/*
output avdSharedResourcesRgId string = avdSharedResourcesRg.outputs.resourceId
output avdServiceObjectsRgId string = avdServiceObjectsRg.outputs.resourceId
output adNetworkObjectsRgId string = avdNetworkObjectsRg.outputs.resourceId
output avdComputeObjectsRgId string = avdComputeObjectsRg.outputs.resourceId
output avdStorageObjectsRgId string = avdStorageObjectsRg.outputs.resourceId
output avdApplicationGroupId string = avdApplicationGroup.outputs.resourceId
output avdHPoolId string = avdHostPool.outputs.resourceId
output azureImageBuilderRoleId string = azureImageBuilderRole.outputs.resourceId
output aibManagedIdentityNameId string = imageBuilderManagedIdentity.outputs.principalId
output avdVirtualNetworkId string = avdVirtualNetwork.outputs.resourceId
output avdNetworksecurityGroupId string = avdNetworksecurityGroup.outputs.resourceId
output fslogixStorageId string = fslogixStorage.outputs.resourceId
*/
