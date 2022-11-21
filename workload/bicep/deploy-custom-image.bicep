targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@minLength(2)
@maxLength(4)
@description('Required. The name of the resource group to deploy.')
param deploymentPrefix string = ''

@description('Optional. Location where to deploy compute services. (Default: eastus2)')
param avdSharedServicesLocation string = 'eastus2'

@description('Required. AVD shared services subscription ID, multiple subscriptions scenario.')
param avdSharedServicesSubId string = ''

@description('Optional. Creates an availability zone and adds the VMs to it. Cannot be used in combination with availability set nor scale set. (Default: false)')
param avdUseAvailabilityZones bool = false

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
@description('Optional. Azure image builder location. (Default: eastus2)')
param aibLocation string = 'eastus2'

@description('Optional. Create custom azure image builder role. (Default: true)')
param createAibCustomRole bool = true

@allowed([
    'win10_21h2_office'
    'win10_21h2'
    'win11_21h2_office'
    'win11_21h2'
])
@description('Optional. Required. AVD OS image source. (Default: win10-21h2)')
param avdOsImage string = 'win10_21h2'

@description('Optional. Set to deploy image from Azure Compute Gallery. (Default: true)')
param useSharedImage bool = true

@description('Optional. Create azure image Builder managed identity. (Default: true)')
param createAibManagedIdentity bool = true

@description('Optional. Select existing azure image Builder managed identity. (Default: "")')
param existingAibManagedIdentityId string = ''

@description('Optional. Select existing azure image Builder managed identity. (Default: "")')
param existingAibManagedIdentityName string = ''

@description('Optional. Select existing subnet for the network interfaces on the build virtual machines. (Default: "")')
param existingSubnetId string = ''

// Custom Naming
// Input must followe resource naming rules on https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules
@description('Optional. AVD resources custom naming. (Default: false)')
param avdUseCustomNaming bool = false

@maxLength(90)
@description('Optional. AVD shared services resources resource group custom name. (Default: rg-avd-use2-shared-services)')
param avdSharedResourcesRgCustomName string = 'rg-avd-use2-shared-services'

@maxLength(64)
@description('Optional. AVD Azure compute gallery custom name. (Default: gal_avd_use2_001)')
param imageGalleryCustomName string = 'gal_avd_use2_001'

@maxLength(64)
@description('Optional. AVD Azure compute gallery image template custom name. (Default: avd_image_definition_win11_21h2)')
param imageDefinitionsTemSpecCustomName string = 'avd_image_definition_win11_21h2'

@maxLength(9)
@description('Optional. AVD shared services storage account custom name prefix. (Default: stavdshar)')
param avdSharedSResourcesStorageCustomName string = 'stavdshar'

@maxLength(60)
@description('Optional. AVD shared services storage account Azure image builder container custom name. (Default: avd-imagebuilder-app1)')
param avdSharedSResourcesAibContainerCustomName string = 'avd-imagebuilder-app1'

@maxLength(60)
@description('Optional. AVD shared services storage account scripts container custom name. (Default: avd-scripts-app1)')
param avdSharedSResourcesScriptsContainerCustomName string = 'avd-scripts-app1'

@maxLength(6)
@description('Optional. AVD shared services storage account scripts container custom name. (Default: kv-avd)')
param avdSharedServicesKvCustomName string = 'kv-avd'
//

// Resource tagging
// 
@description('Optional. Apply tags on resources and resource groups. (Default: false)')
param createResourceTags bool = false

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
param workloadCriticalityTag string = 'Low'

@description('Optional. Tag value for custom criticality value. (Default: Contoso-Critical)')
param workloadCriticalityCustomValueTag string = 'Contoso-Critical'

@description('Optional. Details about the application.')
param applicationNameTag string = 'Contoso-App'

@description('Optional. Team accountable for day-to-day operations. (Contoso-Ops)')
param opsTeamTag string = 'workload-admins@Contoso.com'

@description('Optional. Organizational owner of the AVD deployment. (Default: Contoso-Owner)')
param ownerTag string = 'workload-owner@Contoso.com'

@description('Optional. Cost center of owner team. (Defualt: Contoso-CC)')
param costCenterTag string = 'Contoso-CC'

@allowed([
    'Prod'
    'Dev'
    'staging '
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
// Resouce Naming.
var deploymentPrefixLowercase = toLower(deploymentPrefix)
var avdNamingUniqueStringSixChar = take('${uniqueString(avdSharedServicesSubId, deploymentPrefixLowercase, time)}', 6)
var avdSharedResourcesNamingStandard = '${avdSharedServicesLocationAcronym}'
var avdSharedServicesLocationLowercase = toLower(avdSharedServicesLocation)
var avdSharedResourcesRgName = avdUseCustomNaming ? avdSharedResourcesRgCustomName : 'rg-avd-${avdSharedResourcesNamingStandard}-shared-services' // max length limit 90 characters
var imageGalleryName = avdUseCustomNaming ? imageGalleryCustomName : 'gal_avd_${avdSharedServicesLocationAcronym}_001'
var aibManagedIdentityName = 'id-avd-imagebuilder-${avdSharedServicesLocationAcronym}'
var deployScriptManagedIdentityName = 'id-avd-deployscript-${avdSharedServicesLocationAcronym}'
var imageDefinitionsTemSpecName = avdUseCustomNaming ? imageDefinitionsTemSpecCustomName : 'avd_image_definition_${avdOsImage}'
var avdSharedResourcesAutomationAccount = avdUseCustomNaming ? imageDefinitionsTemSpecCustomName : 'aa-avd-${avdSharedResourcesNamingStandard}-auto-build'
var avdSharedSResourcesStorageName = avdUseCustomNaming ? avdSharedSResourcesStorageCustomName : 'stavdshar${avdNamingUniqueStringSixChar}'
var avdSharedSResourcesAibContainerName = avdUseCustomNaming ? avdSharedSResourcesAibContainerCustomName : 'avd-imagebuilder-${deploymentPrefixLowercase}'
var avdSharedSResourcesScriptsContainerName = avdUseCustomNaming ? avdSharedSResourcesScriptsContainerCustomName : 'avd-scripts-${deploymentPrefixLowercase}'
var avdSharedServicesKvName = avdUseCustomNaming ? avdSharedServicesKvCustomName : 'kv-avd-${avdSharedResourcesNamingStandard}-${avdNamingUniqueStringSixChar}' // max length limit 24 characters
var avdSharedServicesLocationAcronym = locationAcronyms[avdSharedServicesLocationLowercase]
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
var TimeZone = TimeZones[aibLocation]
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
var commonResourceTags = createResourceTags ? {
    ImageBuildName: imageBuildNameTag
    WorkloadName: workloadNameTag
    DataClassification: dataClassificationTag
    Department: departmentTag
    Criticality: (workloadCriticalityTag == 'Custom') ? workloadCriticalityCustomValueTag : workloadCriticalityTag
    ApplicationName: applicationNameTag
    OpsTeam: opsTeamTag
    Owner: ownerTag
    CostCenter: costCenterTag
    Environment: environmentTypeTag

} : {}
//

var imageVmSize = 'Standard_D4s_v3'
var avdOsImageDefinitions = {
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
var baseScriptUri = 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/'
var telemetryId = 'pid-b04f18f1-9100-4b92-8e41-71f0d73e3755-${avdSharedServicesLocation}'

// =========== //
// Deployments //
// =========== //

//  Telemetry Deployment.
resource telemetrydeployment 'Microsoft.Resources/deployments@2021-04-01' = if (enableTelemetry) {
    name: telemetryId
    location: avdSharedServicesLocation
    properties: {
        mode: 'Incremental'
        template: {
            '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
            contentVersion: '1.0.0.0'
            resources: []
        }
    }
}

// Resource groups (AVD shared services subscription RG).
module avdSharedResourcesRg '../../carml/1.0.0/Microsoft.Resources/resourceGroups/deploy.bicep' = {
    scope: subscription(avdSharedServicesSubId)
    name: 'AVD-RG-Shared-Resources-${time}'
    params: {
        name: avdSharedResourcesRgName
        location: avdSharedServicesLocation
        tags: createResourceTags ? commonResourceTags : {}
    }
}

// RBAC Roles.
module azureImageBuilderRole '../../carml/1.0.0/Microsoft.Authorization/roleDefinitions/subscription/deploy.bicep' = if (createAibCustomRole) {
    scope: subscription(avdSharedServicesSubId)
    name: 'Azure-Image-Builder-Role-${time}'
    params: {
        subscriptionId: avdSharedServicesSubId
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
            '/subscriptions/${avdSharedServicesSubId}'
        ]
    }
}

// Managed identities.
// Image builder.
module imageBuilderManagedIdentity '../../carml/1.0.0/Microsoft.ManagedIdentity/userAssignedIdentities/deploy.bicep' = if (createAibManagedIdentity) {
    scope: resourceGroup('${avdSharedServicesSubId}', '${avdSharedResourcesRgName}')
    name: 'image-Builder-Managed-Identity-${time}'
    params: {
        name: aibManagedIdentityName
        location: avdSharedServicesLocation
        tags: createResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}

// Script deployment.
module deployScriptManagedIdentity '../../carml/1.0.0/Microsoft.ManagedIdentity/userAssignedIdentities/deploy.bicep' = {
    scope: resourceGroup('${avdSharedServicesSubId}', '${avdSharedResourcesRgName}')
    name: 'deployment-Script-Managed-Identity-${time}'
    params: {
        name: deployScriptManagedIdentityName
        location: avdSharedServicesLocation
        tags: createResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}
//

// Introduce delay for User Managed Assigned Identity to propagate through the system.
module userManagedIdentityDelay '../../carml/1.0.0/Microsoft.Resources/deploymentScripts/deploy.bicep' = if (createAibManagedIdentity) {
    scope: resourceGroup('${avdSharedServicesSubId}', '${avdSharedResourcesRgName}')
    name: 'AVD-userManagedIdentityDelay-${time}'
    params: {
        name: 'AVD-userManagedIdentityDelay-${time}'
        location: avdSharedServicesLocation
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
        //imageBuilderManagedIdentity
        deployScriptManagedIdentity
    ]
}

// Enterprise applications.
// RBAC role Assignments image builder.
resource azureImageBuilderExistingRole 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = if (!createAibCustomRole) {
    name: 'AzureImageBuilder-AVD'
    scope: subscription(avdSharedServicesSubId)
}

// RBAC role Assignments image builder.
module azureImageBuilderRoleAssign '../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = {
    name: 'Azure-Image-Builder-RoleAssign-${time}'
    scope: resourceGroup('${avdSharedServicesSubId}', '${avdSharedResourcesRgName}')
    params: {
        roleDefinitionIdOrName: createAibCustomRole ? azureImageBuilderRole.outputs.resourceId : azureImageBuilderExistingRole.id
        principalId: createAibManagedIdentity ? imageBuilderManagedIdentity.outputs.principalId : existingAibManagedIdentityId
    }
    dependsOn: [
        userManagedIdentityDelay
    ]
}

// RBAC role Assignments deployment script.
module deployScriptRoleAssign '../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = {
    name: 'deploy-script-RoleAssign-${time}'
    scope: resourceGroup('${avdSharedServicesSubId}', '${avdSharedResourcesRgName}')
    params: {
        roleDefinitionIdOrName: createAibCustomRole ? azureImageBuilderRole.outputs.resourceId : '/subscriptions/${avdSharedServicesSubId}/providers/Microsoft.Authorization/roleDefinitions/f1a07417-d97a-45cb-824c-7a7467783830'
        principalId: useSharedImage ? deployScriptManagedIdentity.outputs.principalId : ''
    }
    dependsOn: [
        userManagedIdentityDelay
    ]
}
//

// Custom images: Azure Image Builder deployment. Azure Compute Gallery --> Image Template Definition --> Image Template --> Build and Publish Template --> Create VMs.
// Azure Compute Gallery.
module azureComputeGallery '../../carml/1.2.0/Microsoft.Compute/galleries/deploy.bicep' = {
    scope: resourceGroup('${avdSharedServicesSubId}', '${avdSharedResourcesRgName}')
    name: 'Deploy-Azure-Compute-Gallery-${time}'
    params: {
        name: imageGalleryName
        location: avdSharedServicesLocation
        galleryDescription: 'Azure Virtual Desktops Images'
        tags: createResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}

// Image Template Definition.
module avdImageTemplateDefinition '../../carml/1.2.0/Microsoft.Compute/galleries/images/deploy.bicep' = {
    scope: resourceGroup('${avdSharedServicesSubId}', '${avdSharedResourcesRgName}')
    name: 'Deploy-AVD-Image-Template-Definition-${time}'
    params: {
        galleryName: useSharedImage ? azureComputeGallery.outputs.name : ''
        name: imageDefinitionsTemSpecName
        osState: avdOsImageDefinitions[avdOsImage].osState
        osType: avdOsImageDefinitions[avdOsImage].osType
        publisher: avdOsImageDefinitions[avdOsImage].publisher
        offer: avdOsImageDefinitions[avdOsImage].offer
        sku: avdOsImageDefinitions[avdOsImage].sku
        location: aibLocation
        hyperVGeneration: avdOsImageDefinitions[avdOsImage].hyperVGeneration
        tags: createResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        azureComputeGallery
        avdSharedResourcesRg
    ]
}

// Create Image Template.
module imageTemplate '../../carml/1.2.0/Microsoft.VirtualMachineImages/imageTemplates/deploy.bicep' = {
    scope: resourceGroup('${avdSharedServicesSubId}', '${avdSharedResourcesRgName}')
    name: 'AVD-Deploy-Image-Template-${time}'
    params: {
        name: imageDefinitionsTemSpecName
        subnetId: !empty(existingSubnetId) ? existingSubnetId : ''
        userMsiName: createAibManagedIdentity && useSharedImage ? imageBuilderManagedIdentity.outputs.name : existingAibManagedIdentityName
        userMsiResourceGroup: createAibManagedIdentity && useSharedImage ? imageBuilderManagedIdentity.outputs.resourceGroupName : avdSharedResourcesRgName
        location: aibLocation
        imageReplicationRegions: (avdSharedServicesLocation == aibLocation) ? array('${avdSharedServicesLocation}') : concat(array('${aibLocation}'), array('${avdSharedServicesLocation}'))
        sigImageDefinitionId: useSharedImage ? avdImageTemplateDefinition.outputs.resourceId : ''
        vmSize: imageVmSize
        customizationSteps: [
            {
                type: 'PowerShell'
                name: 'OptimizeOS'
                runElevated: true
                runAsSystem: true
                scriptUri: '${baseScriptUri}scripts/Optimize_OS_for_AVD.ps1' // need to update value to accelerator github after
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
        tags: createResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        avdImageTemplateDefinition
        azureComputeGallery
        avdSharedResourcesRg
        azureImageBuilderRoleAssign
    ]
}

// Image Template Build Automation.
module automationAccount '../../carml/1.2.1/Microsoft.Automation/automationAccounts/deploy.bicep' = {
    scope: resourceGroup('${avdSharedServicesSubId}', '${avdSharedResourcesRgName}')
    name: 'AVD-Deploy-Automation-Account-${time}'
    params: {
        diagnosticLogCategoriesToEnable: [
            'JobLogs'
            'JobStreams'
        ]
        diagnosticLogsRetentionInDays: 30
        diagnosticWorkspaceId: '' // TO DO
        name: avdSharedResourcesAutomationAccount
        jobSchedules: [
            {
                parameters: {
                    EnvironmentName: environment().name
                    ImageOffer: avdOsImageDefinitions[avdOsImage].offer
                    ImagePublisher: avdOsImageDefinitions[avdOsImage].publisher
                    ImageSku: avdOsImageDefinitions[avdOsImage].sku
                    Location: aibLocation
                    SubscriptionId: avdSharedServicesSubId
                    TemplateName: imageDefinitionsTemSpecName
                    TemplateResourceGroupName: avdSharedResourcesRgName
                    TenantId: subscription().tenantId
                }
                runbookName: 'AIB-Build-Automation'
                scheduleName: 'AIB-Build-Automation'
            }
        ]
        location: avdSharedServicesLocation
        modules: [
            {
                name: 'Az.Accounts'
                uri: 'https://www.powershellgallery.com/api/v2/package/Az.Accounts'
                version: null
            }
            {
                name: 'Az.ImageBuilder'
                uri: 'https://www.powershellgallery.com/api/v2/package/Az.ImageBuilder'
                version: null
            }
        ]
        runbooks: [
            {
                name: 'AIB-Build-Automation'
                description: 'When this runbook is triggered, last build date is checked on the AIB image template.  If a new marketplace image has been released since that date, a new build is initiated. If a build has never been initiated then it will be start one.'
                runbookType: 'PowerShell'
                // ToDo: Update URL before PR submission
                uri: 'https://raw.githubusercontent.com/jamasten/Azure/main/solutions/imageBuilder/scripts/New-AzureImageBuilderBuild_Schedule.ps1'
                version: '1.0.0.0'
            }
        ]
        schedules: [
            {
                name: 'AIB-Build-Automation'
                frequency: 'Day'
                interval: 1
                startTime: dateTimeAdd(time, 'PT15M')
                timeZone: TimeZone
            }
        ]
        skuName: 'Free'
        tags: createResourceTags ? commonResourceTags : {}
    }
}

// Key vaults.
module avdSharedServicesKeyVault '../../carml/1.2.0/Microsoft.KeyVault/vaults/deploy.bicep' = {
    scope: resourceGroup('${avdSharedServicesSubId}', '${avdSharedResourcesRgName}')
    name: 'AVD-Shared-Services-KeyVault-${time}'
    params: {
        name: avdSharedServicesKvName
        location: avdSharedServicesLocation
        enableRbacAuthorization: false
        enablePurgeProtection: true
        softDeleteRetentionInDays: 7
        networkAcls: {
            bypass: 'AzureServices'
            defaultAction: 'Deny'
            virtualNetworkRules: []
            ipRules: []
        }
        tags: createResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}

// Storage.
module avdSharedServicesStorage '../../carml/1.2.0/Microsoft.Storage/storageAccounts/deploy.bicep' = {
    scope: resourceGroup('${avdSharedServicesSubId}', '${avdSharedResourcesRgName}')
    name: 'AVD-Shared-Services-Storage-${time}'
    params: {
        name: avdSharedSResourcesStorageName
        location: avdSharedServicesLocation
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
        tags: createResourceTags ? commonResourceTags : {}
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}
