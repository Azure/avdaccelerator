targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@description('Optional. Location where to deploy compute services. (Default: eastus)')
param sharedServicesLocation string = 'eastus'

@description('Required. AVD shared services subscription ID, multiple subscriptions scenario.')
param sharedServicesSubId string = ''

@allowed([
    'Standard_LRS'
    'Standard_ZRS'
])
@description('Optional. Creates an availability zone and adds the VMs to it. Cannot be used in combination with availability set nor scale set. (Default: false)')
param storageAccountSku string = 'Standard_LRS'

@allowed([
    'australiaeast'
    'australiasoutheast'
    'brazilsouth'
    'canadacentral'
    'centralindia'
    'centralus'
    'eastasia'
    'eastus'
    'eastus2'
    'francecentral'
    'germanywestcentral'
    'japaneast'
    'jioindiawest'
    'koreacentral'
    'northcentralus'
    'northeurope'
    'norwayeast'
    'qatarcentral'
    'southafricanorth'
    'southcentralus'
    'southeastasia'
    'switzerlandnorth'
    'uaenorth'
    'uksouth'
    'ukwest'
    'usgovarizona'
    'usgovvirginia'
    'westcentralus'
    'westeurope'
    'westus'
    'westus2'
    'westus3'
])
@description('Optional. Azure Image Builder location. (Default: eastus)')
param aibLocation string = 'eastus'

@allowed([
    'win10_21h2_office'
    'win10_21h2'
    'win11_21h2_office'
    'win11_21h2'
])
@description('Optional. AVD OS image source. (Default: win10-21h2)')
param operatingSystemImage string = 'win10_21h2'

@description('Optional. Set to deploy image from Azure Compute Gallery. (Default: true)')
param sharedImage bool = true

@description('Optional. Input the resource ID for the existing virtual network that the network interfaces on the build virtual machines will join. (Default: "")')
param virtualNetworkResourceId string = ''

@description('Optional. Input the name of the subnet for the existing virtual network that the network interfaces on the build virtual machines will join. (Default: "")')
param subnetName string = ''

@description('Optional. Determine whether to enable RDP Short Path for Managed Networks. (Default: false)')
param rdpShortPath bool = false

@description('Optional. Determine whether to enable Screen Capture Protection. (Default: false)')
param screenCaptureProtection bool = false

@description('Required.  Azure log analytics workspace name data retention.')
param logAnalyticsWorkspaceDataRetention int = 30

@description('Optional. Input the email distribution list for alert notifications when AIB builds succeed or fail.')
param distributionGroup string = ''

// Custom Naming
// Input must followe resource naming rules on https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules
@description('Optional. Custom name for Action Group.')
param actionGroupCustomName string = 'ag-aib'

@description('Optional. Custom name for the Automation Account.')
param automationAccountCustomName string = 'aa-avd'

@description('Optional. Custom name for the Log Analytics Workspace.')
param logAnalyticsWorkspaceCustomName string = 'log-avd'

@description('Optional. Determine whether to enable custom naming for the Azure resources. (Default: false)')
param customNaming bool = false

@maxLength(90)
@description('Optional. Custom name for Resource Group. (Default: rg-avd-use2-shared-services)')
param resourceGroupCustomName string = 'rg-avd-use2-shared-services'

@maxLength(64)
@description('Optional. Custom name for Image Gallery. (Default: gal_avd_use2_001)')
param imageGalleryCustomName string = 'gal_avd_use2_001'

@maxLength(64)
@description('Optional. Custom name for Image Definition. (Default: avd-win11-21h2)')
param imageDefinitionCustomName string = 'avd-win11-21h2'

@maxLength(260)
@description('Optional. Custom name for Image Template. (Default: it-avd-win11-21h2)')
param imageTemplateCustomName string = 'it-avd-win11-21h2'

@maxLength(24)
@description('Optional. Custom name for Storage Account. (Default: stavdshar)')
param storageAccountCustomName string = ''

@maxLength(60)
@description('Optional. Custom name for container storing AIB artifacts. (Default: avd-artifacts)')
param aibContainerCustomName string = 'aib-artifacts'

@maxLength(60)
@description('Optional. Custom name for container storing AVD artifacts. (Default: avd-artifacts)')
param avdContainerCustomName string = 'avd-artifacts'

@maxLength(24)
@description('Optional. Custom name for Key Vault. (Default: kv-avd)')
param keyVaultCustomName string = ''

@maxLength(128)
@description('Optional. Custom name for User Assigned Identity. (Default: id-avd)')
param userAssignedIdentityCustomName string = ''
//


// TAGS //
@description('Optional. Apply tags on resources and resource groups. (Default: false)')
param resourceTags bool = false

@description('Optional. The name of workload for tagging purposes. (Default: AVD-Image)')
param imageBuildNameTag string = 'AVD-Image'

@description('Optional. Reference to the size of the VM for your workloads (Default: Contoso-Workload)')
param workloadNameTag string = 'Contoso-Workload'

@allowed([
    'Non-business'
    'Public'
    'General'
    'Confidential'
    'Highly confidential'
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
    'custom'
])
@description('Optional. criticality of each workload. (Default: Low)')
param criticalityTag string = 'Low'

@description('Optional. Tag value for custom criticality value. (Default: Contoso-Critical)')
param criticalityCustomTag string = 'Contoso-Critical'

@description('Optional. Details about the application.')
param applicationNameTag string = 'Contoso-App'

@description('Optional. Team accountable for day-to-day operations. (Contoso-Ops)')
param operationsTeamTag string = 'workload-admins@Contoso.com'

@description('Optional. Organizational owner of the AVD deployment. (Default: Contoso-Owner)')
param ownerTag string = 'workload-owner@Contoso.com'

@description('Optional. Cost center of owner team. (Defualt: Contoso-CC)')
param costCenterTag string = 'Contoso-CC'

@allowed([
    'Prod'
    'Dev'
    'Staging '
])
@description('Optional. Deployment environment of the application, workload. (Default: Dev)')
param environmentTag string = 'Dev'
//

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

@description('Enable usage and telemetry feedback to Microsoft.')
param telemetry bool = true

// =========== //
// Variable declaration //
// =========== //
// Resouce Naming.
var varUniqueStringSixChar = take('${uniqueString(sharedServicesSubId, time)}', 6)
var varActionGroupName = customNaming ? actionGroupCustomName : 'ag-avd-${varNamingStandard}'
var varNamingStandard = '${varLocationAcronym}'
var varLocationLowercase = toLower(sharedServicesLocation)
var varResourceGroupName = customNaming ? resourceGroupCustomName : 'rg-avd-${varNamingStandard}-shared-services'
var varImageGalleryName = customNaming ? imageGalleryCustomName : 'gal_avd_${varNamingStandard}'
var varUserAssignedIdentityName = customNaming ? userAssignedIdentityCustomName : 'id-aib-${varNamingStandard}'
var varLogAnalyticsWorkspaceName = customNaming ? logAnalyticsWorkspaceCustomName : 'log-avd-${varNamingStandard}'
var varImageDefinitionName = customNaming ? imageDefinitionCustomName : 'avd-${operatingSystemImage}'
var varImageTemplateName = customNaming ? imageTemplateCustomName : 'it-avd-${operatingSystemImage}'
var varAutomationAccountName = customNaming ? automationAccountCustomName : 'aa-avd-${varNamingStandard}'
var varStorageAccountName = customNaming ? storageAccountCustomName : 'stavd${varNamingStandard}${varUniqueStringSixChar}'
var varAibContainerName = customNaming ? aibContainerCustomName : 'aib-artifacts'
var varAvdContainerName = customNaming ? avdContainerCustomName : 'avd-artifacts'
var varKeyVaultName = customNaming ? keyVaultCustomName : 'kv-avd-${varNamingStandard}-${varUniqueStringSixChar}'
var varLocationAcronym = varLocationAcronyms[varLocationLowercase]
var varLocationAcronyms = {
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
var varTimeZone = varTimeZones[aibLocation]
var varTimeZones = {
    australiacentral: 'AUS Eastern Standard time'
    australiacentral2: 'AUS Eastern Standard time'
    australiaeast: 'AUS Eastern Standard time'
    australiasoutheast: 'AUS Eastern Standard time'
    brazilsouth: 'E. South America Standard time'
    brazilsoutheast: 'E. South America Standard time'
    canadacentral: 'Eastern Standard time'
    canadaeast: 'Eastern Standard time'
    centralindia: 'India Standard time'
    centralus: 'Central Standard time'
    chinaeast: 'China Standard time'
    chinaeast2: 'China Standard time'
    chinanorth: 'China Standard time'
    chinanorth2: 'China Standard time'
    eastasia: 'China Standard time'
    eastus: 'Eastern Standard time'
    eastus2: 'Eastern Standard time'
    francecentral: 'Central Europe Standard time'
    francesouth: 'Central Europe Standard time'
    germanynorth: 'Central Europe Standard time'
    germanywestcentral: 'Central Europe Standard time'
    japaneast: 'Tokyo Standard time'
    japanwest: 'Tokyo Standard time'
    jioindiacentral: 'India Standard time'
    jioindiawest: 'India Standard time'
    koreacentral: 'Korea Standard time'
    koreasouth: 'Korea Standard time'
    northcentralus: 'Central Standard time'
    northeurope: 'GMT Standard time'
    norwayeast: 'Central Europe Standard time'
    norwaywest: 'Central Europe Standard time'
    southafricanorth: 'South Africa Standard time'
    southafricawest: 'South Africa Standard time'
    southcentralus: 'Central Standard time'
    southindia: 'India Standard time'
    southeastasia: 'Singapore Standard time'
    swedencentral: 'Central Europe Standard time'
    switzerlandnorth: 'Central Europe Standard time'
    switzerlandwest: 'Central Europe Standard time'
    uaecentral: 'Arabian Standard time'
    uaenorth: 'Arabian Standard time'
    uksouth: 'GMT Standard time'
    ukwest: 'GMT Standard time'
    usdodcentral: 'Central Standard time'
    usdodeast: 'Eastern Standard time'
    usgovarizona: 'Mountain Standard time'
    usgoviowa: 'Central Standard time'
    usgovtexas: 'Central Standard time'
    usgovvirginia: 'Eastern Standard time'
    westcentralus: 'Mountain Standard time'
    westeurope: 'Central Europe Standard time'
    westindia: 'India Standard time'
    westus: 'Pacific Standard time'
    westus2: 'Pacific Standard time'
    westus3: 'Mountain Standard time'
}
//

// Resource tagging
var varCommonresourceTags = resourceTags ? {
    ImageBuildName: imageBuildNameTag
    WorkloadName: workloadNameTag
    DataClassification: dataClassificationTag
    Department: departmentTag
    Criticality: (criticalityTag == 'Custom') ? criticalityCustomTag : criticalityTag
    ApplicationName: applicationNameTag
    OpsTeam: operationsTeamTag
    Owner: ownerTag
    CostCenter: costCenterTag
    Environment: environmentTag

} : {}
//

var varVmSize = 'Standard_D4s_v3'
var varOperatingSystemImageDefinitions = {
    win10_21h2_office: {
        name: 'Windows10_21H2_Office'
        osType: 'Windows'
        osState: 'Generalized'
        offer: 'office-365'
        publisher: 'MicrosoftWindowsDesktop'
        sku: 'win10-21h2-avd-m365'
        osAccountType: 'Standard_LRS'
        hyperVGeneration: 'V1'
    }
    win10_21h2: {
        name: 'Windows10_21H2'
        osType: 'Windows'
        osState: 'Generalized'
        offer: 'windows-10'
        publisher: 'MicrosoftWindowsDesktop'
        sku: 'win10-21h2-avd'
        osAccountType: 'Standard_LRS'
        hyperVGeneration: 'V1'
    }
    win11_21h2_office: {
        name: 'Windows11_21H2'
        osType: 'Windows'
        osState: 'Generalized'
        offer: 'office-365'
        publisher: 'MicrosoftWindowsDesktop'
        sku: 'win11-21h2-avd-m365'
        osAccountType: 'Standard_LRS'
        hyperVGeneration: 'V2'
    }
    win11_21h2: {
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
// Change back before Pull Request
// var varBaseScriptUri = 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/'
var varBaseScriptUri = 'https://raw.githubusercontent.com/jamasten/avdaccelerator/main/workload/'
var varTelemetryId = 'pid-b04f18f1-9100-4b92-8e41-71f0d73e3755-${sharedServicesLocation}'

// Customization Steps
var varRdpShortPathCustomizer = rdpShortPath ? [
    {
        type: 'PowerShell'
        name: 'rdpShortPath'
        runElevated: true
        runAsSystem: true
        scriptUri: '${varBaseScriptUri}scripts/Set-rdpShortPath.ps1'
    }
] : []
var varScreenCaptureProtectionCustomizer = screenCaptureProtection ? [
    {
        type: 'PowerShell'
        name: 'screenCaptureProtection'
        runElevated: true
        runAsSystem: true
        scriptUri: '${varBaseScriptUri}scripts/Set-screenCaptureProtection.ps1'
    }
] : []
var varVdotCustomizer = [
    {
        type: 'PowerShell'
        name: 'VirtualDesktopOptimizationTool'
        runElevated: true
        runAsSystem: true
        scriptUri: '${varBaseScriptUri}scripts/Set-VirtualDesktopOptimizations.ps1'
    }
]
var varScriptCustomizers = union(varRdpShortPathCustomizer, varScreenCaptureProtectionCustomizer, varVdotCustomizer)
var varRemainingCustomizers = [
    {
        type: 'WindowsRestart'
        restartCheckCommand: 'Write-Host "Restarting post script customizers"'
        restarttimeout: '10m'
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
            'Write-Host "Sleep for a 5 min"'
            'Start-Sleep -Seconds 300'
        ]
    }
    {
        type: 'WindowsRestart'
        restartCheckCommand: 'Write-Host "restarting post Windows updates"'
        restarttimeout: '10m'
    }
    {
        type: 'PowerShell'
        name: 'Sleep for a min'
        runElevated: true
        runAsSystem: true
        inline: [
            'Write-Host "Sleep for a min"'
            'Start-Sleep -Seconds 60'
        ]
    }
    {
        type: 'WindowsRestart'
        restarttimeout: '10m'
    }
]
var varCustomizationSteps = union(varScriptCustomizers, varRemainingCustomizers)
//
var varAlerts = [
    {
        name: 'Azure Image Builder - Build Failure'
        description: 'Sends an error alert when a build fails on an image template for Azure Image Builder.'
        severity: 0
        evaluationFrequency: 'PT5M'
        windowSize: 'PT5M'
        criterias: {
            allOf: [
                {
                    query: 'AzureDiagnostics\n| where ResourceProvider == "MICROSOFT.AUTOMATION"\n| where Category  == "JobStreams"\n| where ResultDescription has "Image Template build failed"'
                    timeAggregation: 'Count'
                    dimensions: [
                        {
                            name: 'ResultDescription'
                            operator: 'Include'
                            values: [
                                '*'
                            ]
                        }
                    ]
                    operator: 'GreaterThanOrEqual'
                    threshold: 1
                    failingPeriods: {
                        numberOfEvaluationPeriods: 1
                        minFailingPeriodsToAlert: 1
                    }
                }
            ]
        }
    }
    {
        name: 'Azure Image Builder - Build Success'
        description: 'Sends an informational alert when a build succeeds on an image template for Azure Image Builder.'
        severity: 3
        evaluationFrequency: 'PT5M'
        windowSize: 'PT5M'
        criterias: {
            allOf: [
                {
                    query: 'AzureDiagnostics\n| where ResourceProvider == "MICROSOFT.AUTOMATION"\n| where Category  == "JobStreams"\n| where ResultDescription has "Image Template build succeeded"'
                    timeAggregation: 'Count'
                    dimensions: [
                        {
                            name: 'ResultDescription'
                            operator: 'Include'
                            values: [
                                '*'
                            ]
                        }
                    ]
                    operator: 'GreaterThanOrEqual'
                    threshold: 1
                    failingPeriods: {
                        numberOfEvaluationPeriods: 1
                        minFailingPeriodsToAlert: 1
                    }
                }
            ]
        }
    }
]
var varModules = [
    {
        name: 'Az.Accounts'
        uri: 'https://www.powershellgallery.com/api/v2/package'
    }
    {
        name: 'Az.ImageBuilder'
        uri: 'https://www.powershellgallery.com/api/v2/package'
    }
]

// Role Definitions & Assignments
var varDistributionGroupRole = !empty(distributionGroup) ? [
    {
        resourceGroup: split(virtualNetworkResourceId, '/')[4]
        name: 'Virtual Network Join'
        description: 'Allow resources to join a subnet'
        actions: [
            'Microsoft.Network/virtualNetworks/read'
            'Microsoft.Network/virtualNetworks/subnets/read'
            'Microsoft.Network/virtualNetworks/subnets/join/action'
        ]
    }
] : []
var varImageTemplateRoles = [
    {
        resourceGroup: varResourceGroupName
        name: 'Image Template Contributor'
        description: 'Allow the creation and management of images'
        actions: [
            'Microsoft.Compute/galleries/read'
            'Microsoft.Compute/galleries/images/read'
            'Microsoft.Compute/galleries/images/versions/read'
            'Microsoft.Compute/galleries/images/versions/write'
            'Microsoft.Compute/images/read'
            'Microsoft.Compute/images/write'
            'Microsoft.Compute/images/delete'
        ]
    }
    {
        resourceGroup: varResourceGroupName
        name: 'Image Template Build Automation'
        description: 'Allow Image Template build automation using a Managed Identity on an Automation Account.'
        actions: [
            'Microsoft.VirtualMachineImages/imageTemplates/run/action'
            'Microsoft.VirtualMachineImages/imageTemplates/read'
            'Microsoft.Compute/locations/publishers/artifacttypes/offers/skus/versions/read'
            'Microsoft.Compute/locations/publishers/artifacttypes/offers/skus/read'
            'Microsoft.Compute/locations/publishers/artifacttypes/offers/read'
            'Microsoft.Compute/locations/publishers/read'
        ]
    }
]
var varRoles = union(varDistributionGroupRole, varImageTemplateRoles)
//

// =========== //
// Deployments //
// =========== //

//  telemetry Deployment.
resource telemetrydeployment 'Microsoft.Resources/deployments@2021-04-01' = if (telemetry) {
    name: varTelemetryId
    location: sharedServicesLocation
    properties: {
        mode: 'Incremental'
        template: {
            '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
            contentVersion: '1.0.0.0'
            resources: []
        }
    }
}

// AVD Shared Services Resource Group
module avdSharedResourcesRg '../../carml/1.0.0/Microsoft.Resources/resourceGroups/deploy.bicep' = {
    scope: subscription(sharedServicesSubId)
    name: 'Resource-Group_${time}'
    params: {
        name: varResourceGroupName
        location: sharedServicesLocation
        tags: resourceTags ? varCommonresourceTags : {}
    }
}

module roleDefinitions '../../carml/1.0.0/Microsoft.Authorization/roleDefinitions/subscription/deploy.bicep' = [for i in range(0, length(varRoles)): {
    scope: subscription(sharedServicesSubId)
    name: 'Role-Definition_${i}_${time}'
    params: {
        subscriptionId: sharedServicesSubId
        description: varRoles[i].description
        roleName: varRoles[i].name
        actions: varRoles[i].actions
        assignableScopes: [
            '/subscriptions/${sharedServicesSubId}'
        ]
    }
}]

module userAssignedIdentity '../../carml/1.0.0/Microsoft.ManagedIdentity/userAssignedIdentities/deploy.bicep' = {
    scope: resourceGroup(sharedServicesSubId, varResourceGroupName)
    name: 'User-Assigned-Identity_${time}'
    params: {
        name: varUserAssignedIdentityName
        location: sharedServicesLocation
        tags: resourceTags ? varCommonresourceTags : {}
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}

module roleAssignments '../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = [for i in range(0, length(varRoles)): {
    name: 'Role-Assignment_${i}_${time}'
    scope: resourceGroup(sharedServicesSubId, varRoles[i].resourceGroup)
    params: {
        roleDefinitionIdOrName: roleDefinitions[i].outputs.resourceId
        principalId: userAssignedIdentity.outputs.principalId
        principalType: 'ServicePrincipal'
    }
    dependsOn: [

    ]
}]

// Compute Gallery
module gallery '../../carml/1.2.0/Microsoft.Compute/galleries/deploy.bicep' = {
    scope: resourceGroup(sharedServicesSubId, varResourceGroupName)
    name: 'Gallery_${time}'
    params: {
        name: varImageGalleryName
        location: sharedServicesLocation
        galleryDescription: 'Azure Virtual Desktops Images'
        tags: resourceTags ? varCommonresourceTags : {}
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}

// Image Definition
module image '../../carml/1.2.0/Microsoft.Compute/galleries/images/deploy.bicep' = {
    scope: resourceGroup(sharedServicesSubId, varResourceGroupName)
    name: 'Image-Definition_${time}'
    params: {
        galleryName: sharedImage ? gallery.outputs.name : ''
        name: varImageDefinitionName
        osState: varOperatingSystemImageDefinitions[operatingSystemImage].osState
        osType: varOperatingSystemImageDefinitions[operatingSystemImage].osType
        publisher: varOperatingSystemImageDefinitions[operatingSystemImage].publisher
        offer: varOperatingSystemImageDefinitions[operatingSystemImage].offer
        sku: varOperatingSystemImageDefinitions[operatingSystemImage].sku
        location: aibLocation
        hyperVGeneration: varOperatingSystemImageDefinitions[operatingSystemImage].hyperVGeneration
        tags: resourceTags ? varCommonresourceTags : {}
    }
    dependsOn: [
        gallery
        avdSharedResourcesRg
    ]
}

// Image Template
module imageTemplate '../../carml/1.2.0/Microsoft.VirtualMachineImages/imageTemplates/deploy.bicep' = {
    scope: resourceGroup(sharedServicesSubId, varResourceGroupName)
    name: 'Image-Template_${time}'
    params: {
        name: varImageTemplateName
        subnetId: !empty(virtualNetworkResourceId) && !empty(subnetName) ? '${virtualNetworkResourceId}/subnets/${subnetName}' : ''
        userMsiName: userAssignedIdentity.outputs.name
        userMsiResourceGroup: userAssignedIdentity.outputs.resourceGroupName
        location: aibLocation
        imageReplicationRegions: (sharedServicesLocation == aibLocation) ? array('${sharedServicesLocation}') : concat(array('${aibLocation}'), array('${sharedServicesLocation}'))
        sigImageDefinitionId: sharedImage ? image.outputs.resourceId : ''
        vmSize: varVmSize
        customizationSteps: varCustomizationSteps
        imageSource: {
            type: 'PlatformImage'
            publisher: varOperatingSystemImageDefinitions[operatingSystemImage].publisher
            offer: varOperatingSystemImageDefinitions[operatingSystemImage].offer
            sku: varOperatingSystemImageDefinitions[operatingSystemImage].sku
            osAccountType: varOperatingSystemImageDefinitions[operatingSystemImage].osAccountType
            version: 'latest'
        }
        tags: resourceTags ? varCommonresourceTags : {}
    }
    dependsOn: [
        image
        gallery
        avdSharedResourcesRg
        roleAssignments
    ]
}

// Log Analytics Workspace
module workspace '../../carml/1.2.1/Microsoft.OperationalInsights/workspaces/deploy.bicep' = if (!empty(distributionGroup)) {
    scope: resourceGroup(sharedServicesSubId, varResourceGroupName)
    name: 'Log-Analytics-Workspace_${time}'
    params: {
        location: aibLocation
        name: varLogAnalyticsWorkspaceName
        dataRetention: logAnalyticsWorkspaceDataRetention
        useResourcePermissions: true
        tags: resourceTags ? varCommonresourceTags : {}
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}

module automationAccount '../../carml/1.2.1/Microsoft.Automation/automationAccounts/deploy.bicep' = {
    scope: resourceGroup(sharedServicesSubId, varResourceGroupName)
    name: 'Automation-Account_${time}'
    params: {
        diagnosticLogCategoriesToEnable: [
            'JobLogs'
            'JobStreams'
        ]
        diagnosticLogsRetentionInDays: 30
        diagnosticWorkspaceId: empty(distributionGroup) ? '' : workspace.outputs.resourceId
        name: varAutomationAccountName
        jobSchedules: [
            {
                parameters: {
                    ClientId: userAssignedIdentity.outputs.clientId
                    EnvironmentName: environment().name
                    ImageOffer: varOperatingSystemImageDefinitions[operatingSystemImage].offer
                    ImagePublisher: varOperatingSystemImageDefinitions[operatingSystemImage].publisher
                    ImageSku: varOperatingSystemImageDefinitions[operatingSystemImage].sku
                    Location: aibLocation
                    SubscriptionId: sharedServicesSubId
                    TemplateName: imageTemplate.outputs.name
                    TemplatevarResourceGroupName: varResourceGroupName
                    TenantId: subscription().tenantId
                }
                runbookName: 'AIB-Build-Automation'
                scheduleName: varImageTemplateName
            }
        ]
        location: sharedServicesLocation
        runbooks: [
            {
                name: 'AIB-Build-Automation'
                description: 'When this runbook is triggered, last build date is checked on the AIB image template.  If a new marketplace image has been released since that date, a new build is initiated. If a build has never been initiated then it will be start one.'
                runbookType: 'PowerShell'
                // ToDo: Update URL before PR submission
                uri: 'https://raw.githubusercontent.com/jamasten/avdaccelerator/main/workload/scripts/New-AzureImageBuilderBuild.ps1'
                version: '1.0.0.0'
            }
        ]
        schedules: [
            {
                name: varImageTemplateName
                frequency: 'Day'
                interval: 1
                starttime: dateTimeAdd(time, 'PT15M')
                varTimeZone: varTimeZone
                advancedSchedule: {}
            }
        ]
        skuName: 'Free'
        tags: resourceTags ? varCommonresourceTags : {}
        systemAssignedIdentity: false
        userAssignedIdentities: {
            '${userAssignedIdentity.outputs.resourceId}': {}
        }
    }
}

@batchSize(1)
module modules '../../carml/1.2.1/Microsoft.Automation/automationAccounts/modules/deploy.bicep' = [for i in range(0, length(varModules)): {
    scope: resourceGroup(sharedServicesSubId, varResourceGroupName)
    name: 'Automation-Module_${i}_${time}'
    params: {
        name: varModules[i].name
        location: sharedServicesLocation
        automationAccountName: automationAccount.outputs.name
        uri: varModules[i].uri
    }
}]

module vault '../../carml/1.2.0/Microsoft.KeyVault/vaults/deploy.bicep' = {
    scope: resourceGroup(sharedServicesSubId, varResourceGroupName)
    name: 'Key-Vault_${time}'
    params: {
        name: varKeyVaultName
        location: sharedServicesLocation
        enableRbacAuthorization: false
        enablePurgeProtection: true
        softDeleteRetentionInDays: 7
        networkAcls: {
            bypass: 'AzureServices'
            defaultAction: 'Deny'
            virtualNetworkRules: []
            ipRules: []
        }
        tags: resourceTags ? varCommonresourceTags : {}
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}

module storageAccount '../../carml/1.2.0/Microsoft.Storage/storageAccounts/deploy.bicep' = {
    scope: resourceGroup(sharedServicesSubId, varResourceGroupName)
    name: 'Storage-Account_${time}'
    params: {
        name: varStorageAccountName
        location: sharedServicesLocation
        storageAccountSku: storageAccountSku
        storageAccountKind: 'StorageV2'
        blobServices: {
            containers: [
                {
                    name: varAibContainerName
                    publicAccess: 'None'
                }
                {
                    name: varAvdContainerName
                    publicAccess: 'None'
                }
            ]
        }
        tags: resourceTags ? varCommonresourceTags : {}
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}

module actionGroup '../../carml/1.0.0/Microsoft.Insights/actionGroups/deploy.bicep' = if (!empty(distributionGroup)) {
    scope: resourceGroup(sharedServicesSubId, varResourceGroupName)
    name: 'Action-Group_${time}'
    params: {
        location: 'global'
        groupShortName: 'aib-email'
        name: varActionGroupName
        enabled: true
        emailReceivers: [
            {
                name: distributionGroup
                emailAddress: distributionGroup
                useCommonvarAlertschema: true
            }
        ]
        tags: resourceTags ? varCommonresourceTags : {}
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}

module scheduledQueryRules '../../carml/1.2.1/Microsoft.Insights/scheduledQueryRules/deploy.bicep' = [for i in range(0, length(varAlerts)): if (!empty(distributionGroup)) {
    scope: resourceGroup(sharedServicesSubId, varResourceGroupName)
    name: 'Scheduled-Query-Rule_${i}_${time}'
    params: {
        location: sharedServicesLocation
        name: varAlerts[i].name
        alertDescription: varAlerts[i].description
        enabled: true
        kind: 'LogAlert'
        autoMitigate: false
        skipQueryValidation: false
        targetResourceTypes: []
        roleAssignments: []
        scopes: !empty(distributionGroup) ? [
            workspace.outputs.resourceId
        ] : []
        severity: varAlerts[i].severity
        evaluationFrequency: varAlerts[i].evaluationFrequency
        windowSize: varAlerts[i].windowSize
        actions: !empty(distributionGroup) ? [
            actionGroup.outputs.resourceId
        ] : []
        criterias: varAlerts[i].criterias
        tags: resourceTags ? varCommonresourceTags : {}
    }
}]
