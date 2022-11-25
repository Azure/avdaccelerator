targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@description('Optional. Location where to deploy compute services. (Default: eastus2)')
param SharedServicesLocation string = 'eastus2'

@description('Required. AVD shared services subscription ID, multiple subscriptions scenario.')
param SharedServicesSubId string = ''

@allowed([
    'Standard_LRS'
    'Standard_ZRS'
])
@description('Optional. Creates an availability zone and adds the VMs to it. Cannot be used in combination with availability set nor scale set. (Default: false)')
param StorageAccountSKU string = 'Standard_LRS'

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
@description('Optional. Azure Image Builder location. (Default: eastus2)')
param AIBLocation string = 'eastus2'

@allowed([
    'win10_21h2_office'
    'win10_21h2'
    'win11_21h2_office'
    'win11_21h2'
])
@description('Optional. AVD OS image source. (Default: win10-21h2)')
param OperatingSystemImage string = 'win10_21h2'

@description('Optional. Set to deploy image from Azure Compute Gallery. (Default: true)')
param SharedImage bool = true

@description('Optional. Input the resource ID for the existing virtual network that the network interfaces on the build virtual machines will join. (Default: "")')
param VirtualNetworkResourceId string = ''

@description('Optional. Input the name of the subnet for the existing virtual network that the network interfaces on the build virtual machines will join. (Default: "")')
param SubnetName string = ''

@description('Optional. Determine whether to enable RDP Short Path for Managed Networks. (Default: false)')
param RDPShortPath bool = false

@description('Optional. Determine whether to enable Screen Capture Protection. (Default: false)')
param ScreenCaptureProtection bool = false

@description('Required.  Azure log analytics workspace name data retention.')
param LogAnalyticsWorkspaceDataRetention int = 30

@description('Optional. Input the email distribution list for alert notifications when AIB builds succeed or fail.')
param DistributionGroup string = ''

// Custom Naming
// Input must followe resource naming rules on https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules
@description('Optional. Azure action group name.')
param ActionGroupCustomName string = 'ag-aib-email'

@description('Optional. Azure automation account name.')
param AutomationAccountCustomName string = 'aa-avd'

@description('Optional. Azure log analytics workspace name.')
param LogAnalyticsWorkspaceCustomName string = 'log-avd'

@description('Optional. AVD resources custom naming. (Default: false)')
param CustomNaming bool = false

@maxLength(90)
@description('Optional. AVD shared services resources resource group custom name. (Default: rg-avd-use2-shared-services)')
param ResourceGroupCustomName string = 'rg-avd-use2-shared-services'

@maxLength(64)
@description('Optional. AVD Azure compute gallery custom name. (Default: gal_avd_use2_001)')
param ImageGalleryCustomName string = 'gal_avd_use2_001'

@maxLength(64)
@description('Optional. AVD Azure compute gallery image definition custom name. (Default: avd-win11-21h2)')
param ImageDefinitionCustomName string = 'avd-win11-21h2'

@maxLength(64)
@description('Optional. AVD Azure image template custom name. (Default: it-avd-win11-21h2)')
param ImageTemplateCustomName string = 'it-avd-win11-21h2'

@maxLength(24)
@description('Optional. AVD shared services storage account custom name prefix. (Default: stavdshar)')
param StorageAccountCustomName string = ''

@maxLength(60)
@description('Optional. AVD shared services storage account Azure image builder container custom name. (Default: avd-imagebuilder-app1)')
param AIBContainerCustomName string = 'aib-artifacts'

@maxLength(60)
@description('Optional. AVD shared services storage account scripts container custom name. (Default: avd-scripts-app1)')
param AVDContainerCustomName string = 'avd-artifacts'

@maxLength(24)
@description('Optional. AVD shared services storage account scripts container custom name. (Default: kv-avd)')
param KeyVaultCustomName string = ''
//

// Resource tagging
// 
@description('Optional. Apply tags on resources and resource groups. (Default: false)')
param ResourceTags bool = false

@description('Optional. The name of workload for tagging purposes. (Default: AVD-Image)')
param ImageBuildNameTag string = 'AVD-Image'

@description('Optional. Reference to the size of the VM for your workloads (Default: Contoso-Workload)')
param WorkloadNameTag string = 'Contoso-Workload'

@allowed([
    'Non-business'
    'Public'
    'General'
    'Confidential'
    'Highly confidential'
])
@description('Optional. Sensitivity of data hosted (Default: Non-business)')
param DataClassificationTag string = 'Non-business'

@description('Optional. Department that owns the deployment, (Dafult: Contoso-AVD)')
param DepartmentTag string = 'Contoso-AVD'

@allowed([
    'Low'
    'Medium'
    'High'
    'Mission-critical'
    'custom'
])
@description('Optional. criticality of each workload. (Default: Low)')
param CriticalityTag string = 'Low'

@description('Optional. Tag value for custom criticality value. (Default: Contoso-Critical)')
param CriticalityCustomTag string = 'Contoso-Critical'

@description('Optional. Details about the application.')
param ApplicationNameTag string = 'Contoso-App'

@description('Optional. Team accountable for day-to-day operations. (Contoso-Ops)')
param OperationsTeamTag string = 'workload-admins@Contoso.com'

@description('Optional. Organizational owner of the AVD deployment. (Default: Contoso-Owner)')
param OwnerTag string = 'workload-owner@Contoso.com'

@description('Optional. Cost center of owner team. (Defualt: Contoso-CC)')
param CostCenterTag string = 'Contoso-CC'

@allowed([
    'Prod'
    'Dev'
    'Staging '
])
@description('Optional. Deployment environment of the application, workload. (Default: Dev)')
param EnvironmentTag string = 'Dev'
//

@description('Do not modify, used to set unique value for resource deployment.')
param Time string = utcNow()

@description('Enable usage and telemetry feedback to Microsoft.')
param Telemetry bool = true

// =========== //
// Variable declaration //
// =========== //
// Resouce Naming.
var UniqueStringSixChar = take('${uniqueString(SharedServicesSubId, Time)}', 6)
var ActionGroupName = CustomNaming ? ActionGroupCustomName : 'ag-aib-email-${NamingStandard}'
var NamingStandard = '${LocationAcronym}'
var LocationLowercase = toLower(SharedServicesLocation)
var ResourceGroupName = CustomNaming ? ResourceGroupCustomName : 'rg-avd-${NamingStandard}-shared-services' // max length limit 90 characters
var ImageGalleryName = CustomNaming ? ImageGalleryCustomName : 'gal_avd_${NamingStandard}'
var UserAssignedIdentityName = 'id-avd-imagebuilder-${NamingStandard}'
var LogAnalyticsWorkspaceName = CustomNaming ? LogAnalyticsWorkspaceCustomName : 'log-aib-${NamingStandard}'
var ImageDefinitionName = CustomNaming ? ImageDefinitionCustomName : 'avd-${OperatingSystemImage}'
var ImageTemplateName = CustomNaming ? ImageTemplateCustomName : 'it-avd-${OperatingSystemImage}'
var AutomationAccountName = CustomNaming ? AutomationAccountCustomName : 'aa-aib-${NamingStandard}'
var StorageAccountName = CustomNaming ? StorageAccountCustomName : 'stavdshar${UniqueStringSixChar}'
var AIBContainerName = CustomNaming ? AIBContainerCustomName : 'aib-artifacts'
var AVDContainerName = CustomNaming ? AVDContainerCustomName : 'avd-artifacts'
var KeyVaultName = CustomNaming ? KeyVaultCustomName : 'kv-avd-${NamingStandard}-${UniqueStringSixChar}' // max length limit 24 characters
var LocationAcronym = locationAcronyms[LocationLowercase]
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
var TimeZone = TimeZones[AIBLocation]
var TimeZones = {
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
//

// Resource tagging
var commonResourceTags = ResourceTags ? {
    ImageBuildName: ImageBuildNameTag
    WorkloadName: WorkloadNameTag
    DataClassification: DataClassificationTag
    Department: DepartmentTag
    Criticality: (CriticalityTag == 'Custom') ? CriticalityCustomTag : CriticalityTag
    ApplicationName: ApplicationNameTag
    OpsTeam: OperationsTeamTag
    Owner: OwnerTag
    CostCenter: CostCenterTag
    Environment: EnvironmentTag

} : {}
//

var VMSize = 'Standard_D4s_v3'
var OperatingSystemImageDefinitions = {
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
// var baseScriptUri = 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/'
var baseScriptUri = 'https://raw.githubusercontent.com/jamasten/avdaccelerator/main/workload/'
var telemetryId = 'pid-b04f18f1-9100-4b92-8e41-71f0d73e3755-${SharedServicesLocation}'

// Customization Steps
var RDPShortPathCustomizer = RDPShortPath ? [
    {
        type: 'PowerShell'
        name: 'RDPShortPath'
        runElevated: true
        runAsSystem: true
        scriptUri: '${baseScriptUri}scripts/Set-RdpShortpath.ps1'
    }
] : []
var ScreenCaptureProtectionCustomizer = ScreenCaptureProtection ? [
    {
        type: 'PowerShell'
        name: 'ScreenCaptureProtection'
        runElevated: true
        runAsSystem: true
        scriptUri: '${baseScriptUri}scripts/Set-ScreenCaptureProtection.ps1'
    }
] : []
var VDOTCustomizer = [
    {
        type: 'PowerShell'
        name: 'VirtualDesktopOptimizationTool'
        runElevated: true
        runAsSystem: true
        scriptUri: '${baseScriptUri}scripts/Set-VirtualDesktopOptimizations.ps1'
    }
]
var ScriptCustomizers = union(RDPShortPathCustomizer, ScreenCaptureProtectionCustomizer, VDOTCustomizer)
var RemainingCustomizers = [
    {
        type: 'WindowsRestart'
        restartCheckCommand: 'Write-Host "Restarting post script customizers"'
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
            'Write-Host "Sleep for a 5 min"'
            'Start-Sleep -Seconds 300'
        ]
    }
    {
        type: 'WindowsRestart'
        restartCheckCommand: 'Write-Host "restarting post Windows updates"'
        restartTimeout: '10m'
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
        restartTimeout: '10m'
    }
]
var CustomizationSteps = union(ScriptCustomizers, RemainingCustomizers)
//
var Alerts = [
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
                    TimeAggregation: 'Count'
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
                    TimeAggregation: 'Count'
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
var Modules = [
    {
        name: 'Az.Accounts'
        uri: 'https://www.powershellgallery.com/api/v2/package'
    }
    {
        name: 'Az.ImageBuilder'
        uri: 'https://www.powershellgallery.com/api/v2/package'
    }
]
var Roles = [
    {
        resourceGroup: split(VirtualNetworkResourceId, '/')[4]
        name: 'Virtual Network Join'
        description: 'Allow resources to join a subnet'
        actions: [
            'Microsoft.Network/virtualNetworks/read'
            'Microsoft.Network/virtualNetworks/subnets/read'
            'Microsoft.Network/virtualNetworks/subnets/join/action'
        ]
    }
    {
        resourceGroup: ResourceGroupName
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
        resourceGroup: ResourceGroupName
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

// =========== //
// Deployments //
// =========== //

//  Telemetry Deployment.
resource telemetrydeployment 'Microsoft.Resources/deployments@2021-04-01' = if (Telemetry) {
    name: telemetryId
    location: SharedServicesLocation
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
    scope: subscription(SharedServicesSubId)
    name: 'AIB_Resource-Group_${Time}'
    params: {
        name: ResourceGroupName
        location: SharedServicesLocation
        tags: ResourceTags ? commonResourceTags : {}
    }
}

module roleDefinitions '../../carml/1.0.0/Microsoft.Authorization/roleDefinitions/subscription/deploy.bicep' = [for i in range(0, length(Roles)): {
    scope: subscription(SharedServicesSubId)
    name: 'AIB_Role-Definition_${i}_${Time}'
    params: {
        subscriptionId: SharedServicesSubId
        description: Roles[i].description
        roleName: Roles[i].name
        actions: Roles[i].actions
        assignableScopes: [
            '/subscriptions/${SharedServicesSubId}'
        ]
    }
}]

module userAssignedIdentity '../../carml/1.0.0/Microsoft.ManagedIdentity/userAssignedIdentities/deploy.bicep' = {
    scope: resourceGroup(SharedServicesSubId, ResourceGroupName)
    name: 'AIB_User-Assigned-Identity_${Time}'
    params: {
        name: UserAssignedIdentityName
        location: SharedServicesLocation
        tags: ResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}

module roleAssignments '../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = [for i in range(0, length(Roles)): {
    name: 'AIB_Role-Assignment_${i}_${Time}'
    scope: resourceGroup('${SharedServicesSubId}', Roles[i].resourceGroup)
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
    scope: resourceGroup(SharedServicesSubId, ResourceGroupName)
    name: 'AIB_Gallery_${Time}'
    params: {
        name: ImageGalleryName
        location: SharedServicesLocation
        galleryDescription: 'Azure Virtual Desktops Images'
        tags: ResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}

// Image Definition
module image '../../carml/1.2.0/Microsoft.Compute/galleries/images/deploy.bicep' = {
    scope: resourceGroup(SharedServicesSubId, ResourceGroupName)
    name: 'AIB_Image-Definition_${Time}'
    params: {
        galleryName: SharedImage ? gallery.outputs.name : ''
        name: ImageDefinitionName
        osState: OperatingSystemImageDefinitions[OperatingSystemImage].osState
        osType: OperatingSystemImageDefinitions[OperatingSystemImage].osType
        publisher: OperatingSystemImageDefinitions[OperatingSystemImage].publisher
        offer: OperatingSystemImageDefinitions[OperatingSystemImage].offer
        sku: OperatingSystemImageDefinitions[OperatingSystemImage].sku
        location: AIBLocation
        hyperVGeneration: OperatingSystemImageDefinitions[OperatingSystemImage].hyperVGeneration
        tags: ResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        gallery
        avdSharedResourcesRg
    ]
}

// Image Template
module imageTemplate '../../carml/1.2.0/Microsoft.VirtualMachineImages/imageTemplates/deploy.bicep' = {
    scope: resourceGroup(SharedServicesSubId, ResourceGroupName)
    name: 'AIB_Image-Template_${Time}'
    params: {
        name: ImageTemplateName
        subnetId: !empty(VirtualNetworkResourceId) && !empty(SubnetName) ? '${VirtualNetworkResourceId}/subnets/${SubnetName}' : ''
        userMsiName: userAssignedIdentity.outputs.name
        userMsiResourceGroup: userAssignedIdentity.outputs.resourceGroupName
        location: AIBLocation
        imageReplicationRegions: (SharedServicesLocation == AIBLocation) ? array('${SharedServicesLocation}') : concat(array('${AIBLocation}'), array('${SharedServicesLocation}'))
        sigImageDefinitionId: SharedImage ? image.outputs.resourceId : ''
        vmSize: VMSize
        customizationSteps: CustomizationSteps
        imageSource: {
            type: 'PlatformImage'
            publisher: OperatingSystemImageDefinitions[OperatingSystemImage].publisher
            offer: OperatingSystemImageDefinitions[OperatingSystemImage].offer
            sku: OperatingSystemImageDefinitions[OperatingSystemImage].sku
            osAccountType: OperatingSystemImageDefinitions[OperatingSystemImage].osAccountType
            version: 'latest'
        }
        tags: ResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        image
        gallery
        avdSharedResourcesRg
        roleAssignments
    ]
}

// Log Analytics Workspace
module workspace '../../carml/1.2.1/Microsoft.OperationalInsights/workspaces/deploy.bicep' = if (!empty(DistributionGroup)) {
    scope: resourceGroup(SharedServicesSubId, ResourceGroupName)
    name: 'AIB_Log-Analytics-Workspace_${Time}'
    params: {
        location: AIBLocation
        name: LogAnalyticsWorkspaceName
        dataRetention: LogAnalyticsWorkspaceDataRetention
        useResourcePermissions: true
        tags: ResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}

module automationAccount '../../carml/1.2.1/Microsoft.Automation/automationAccounts/deploy.bicep' = {
    scope: resourceGroup(SharedServicesSubId, ResourceGroupName)
    name: 'AIB_Automation-Account_${Time}'
    params: {
        diagnosticLogCategoriesToEnable: [
            'JobLogs'
            'JobStreams'
        ]
        diagnosticLogsRetentionInDays: 30
        diagnosticWorkspaceId: empty(DistributionGroup) ? '' : workspace.outputs.resourceId
        name: AutomationAccountName
        jobSchedules: [
            {
                parameters: {
                    ClientId: userAssignedIdentity.outputs.clientId
                    EnvironmentName: environment().name
                    ImageOffer: OperatingSystemImageDefinitions[OperatingSystemImage].offer
                    ImagePublisher: OperatingSystemImageDefinitions[OperatingSystemImage].publisher
                    ImageSku: OperatingSystemImageDefinitions[OperatingSystemImage].sku
                    Location: AIBLocation
                    SubscriptionId: SharedServicesSubId
                    TemplateName: imageTemplate.outputs.name
                    TemplateResourceGroupName: ResourceGroupName
                    TenantId: subscription().tenantId
                }
                runbookName: 'AIB-Build-Automation'
                scheduleName: 'AIB-Build-Automation'
            }
        ]
        location: SharedServicesLocation
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
                name: 'AIB-Build-Automation'
                frequency: 'Day'
                interval: 1
                startTime: dateTimeAdd(Time, 'PT15M')
                TimeZone: TimeZone
                advancedSchedule: {}
            }
        ]
        skuName: 'Free'
        tags: ResourceTags ? commonResourceTags : {}
        systemAssignedIdentity: false
        userAssignedIdentities: {
            '${userAssignedIdentity.outputs.resourceId}': {}
        }
    }
}

@batchSize(1)
module modules '../../carml/1.2.1/Microsoft.Automation/automationAccounts/modules/deploy.bicep' = [for i in range(0, length(Modules)): {
    scope: resourceGroup(SharedServicesSubId, ResourceGroupName)
    name: 'AIB_Automation-Module_${i}_${Time}'
    params: {
        name: Modules[i].name
        location: SharedServicesLocation
        automationAccountName: automationAccount.outputs.name
        uri: Modules[i].uri
    }
}]

module vault '../../carml/1.2.0/Microsoft.KeyVault/vaults/deploy.bicep' = {
    scope: resourceGroup(SharedServicesSubId, ResourceGroupName)
    name: 'AIB_Key-Vault_${Time}'
    params: {
        name: KeyVaultName
        location: SharedServicesLocation
        enableRbacAuthorization: false
        enablePurgeProtection: true
        softDeleteRetentionInDays: 7
        networkAcls: {
            bypass: 'AzureServices'
            defaultAction: 'Deny'
            virtualNetworkRules: []
            ipRules: []
        }
        tags: ResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}

module storageAccount '../../carml/1.2.0/Microsoft.Storage/storageAccounts/deploy.bicep' = {
    scope: resourceGroup(SharedServicesSubId, ResourceGroupName)
    name: 'AIB_Storage-Account_${Time}'
    params: {
        name: StorageAccountName
        location: SharedServicesLocation
        storageAccountSku: StorageAccountSKU
        storageAccountKind: 'StorageV2'
        blobServices: {
            containers: [
                {
                    name: AIBContainerName
                    publicAccess: 'None'
                }
                {
                    name: AVDContainerName
                    publicAccess: 'None'
                }
            ]
        }
        tags: ResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}

module actionGroup '../../carml/1.0.0/Microsoft.Insights/actionGroups/deploy.bicep' = if (!empty(DistributionGroup)) {
    scope: resourceGroup(SharedServicesSubId, ResourceGroupName)
    name: 'AIB_Action-Group_${Time}'
    params: {
        location: 'global'
        groupShortName: 'aib-email'
        name: ActionGroupName
        enabled: true
        emailReceivers: [
            {
                name: DistributionGroup
                emailAddress: DistributionGroup
                useCommonAlertSchema: true
            }
        ]
        tags: ResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}

module scheduledQueryRules '../../carml/1.2.1/Microsoft.Insights/scheduledQueryRules/deploy.bicep' = [for i in range(0, length(Alerts)): if (!empty(DistributionGroup)) {
    scope: resourceGroup(SharedServicesSubId, ResourceGroupName)
    name: 'AIB_Scheduled-Query-Rule_${i}_${Time}'
    params: {
        location: SharedServicesLocation
        name: Alerts[i].name
        alertDescription: Alerts[i].description
        enabled: true
        kind: 'LogAlert'
        autoMitigate: false
        skipQueryValidation: false
        targetResourceTypes: []
        roleAssignments: []
        scopes: [
            workspace.outputs.resourceId
        ]
        severity: Alerts[i].severity
        evaluationFrequency: Alerts[i].evaluationFrequency
        windowSize: Alerts[i].windowSize
        actions: [
            actionGroup.outputs.resourceId
        ]
        criterias: Alerts[i].criterias
        tags: ResourceTags ? commonResourceTags : {}
    }
}]
