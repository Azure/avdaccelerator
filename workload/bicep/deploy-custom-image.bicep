targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@minLength(2)
@maxLength(4)
@description('Required. The name of the resource group to deploy')
param deploymentPrefix string = ''

@description('Optional. Location where to deploy compute services (Default: eastus2)')
param avdSharedServicesLocation string = 'eastus2'

@description('Required. AVD shared services subscription ID, multiple subscriptions scenario')
param avdSharedServicesSubId string = ''

@description('Optional. Creates an availability zone and adds the VMs to it. Cannot be used in combination with availability set nor scale set (Default: false)')
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
@description('Optional. Azure image builder location (Default: eastus2)')
param aibLocation string = 'eastus2'

@description('Optional. Create custom azure image builder role (Default: true)')
param createAibCustomRole bool = true

@allowed([
    'win10_21h2_office'
    'win10_21h2'
    'win11_21h2_office'
    'win11_21h2'
])
@description('Optional. Required. AVD OS image source (Default: win10-21h2)')
param avdOsImage string = 'win10_21h2'

@description('Optional. Set to deploy image from Azure Compute Gallery (Default: true)')
param useSharedImage bool = true

@description('Optional. Create azure image Builder managed identity (Default: true)')
param createAibManagedIdentity bool = true

@description('Optional. Select existing azure image Builder managed identity (Default: "")')
param existingAibManagedIdentityId string = ''

@description('Optional. Select existing azure image Builder managed identity (Default: "")')
param existingAibManagedIdentityName string = ''

@description('Do not modify, used to set unique value for resource deployment')
param time string = utcNow()

@description('Enable usage and telemetry feedback to Microsoft.')
param enableTelemetry bool = true

// =========== //
// Variable declaration //
// =========== //
var deploymentPrefixLowercase = toLower(deploymentPrefix)
var avdSharedServicesLocationLowercase = toLower(avdSharedServicesLocation)
var avdSharedResourcesRgName = 'rg-${avdSharedServicesLocationLowercase}-avd-shared-resources'
var imageGalleryName = 'avdgallery${avdSharedServicesLocationLowercase}'
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
var baseScriptUri = 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/'
var avdSharedSResourcesStorageName = 'avd${uniqueString(deploymentPrefixLowercase, avdSharedServicesLocationLowercase)}shared'
var avdSharedSResourcesAibContainerName = 'aib-${deploymentPrefixLowercase}'
var avdSharedSResourcesScriptsContainerName = 'scripts-${deploymentPrefixLowercase}'
var avdSharedServicesKvName = 'avd-${uniqueString(deploymentPrefixLowercase, avdSharedServicesLocationLowercase, avdSharedServicesSubId)}-shared' // max length limit 24 characters
var telemetryId = 'pid-b04f18f1-9100-4b92-8e41-71f0d73e3755-${location}'

// =========== //
// Deployments //
// =========== //

//  Telemetry Deployment
resource telemetrydeployment 'Microsoft.Resources/deployments@2021-04-01' = if (enableTelemetry) {
  name: telemetryId
  location: location
  scope: tenant()
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#'
      'contentVersion': '1.0.0.0'
      'parameters': {}
      'resources': {}
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
//

// Managed identities.
module imageBuilderManagedIdentity '../../carml/1.0.0/Microsoft.ManagedIdentity/userAssignedIdentities/deploy.bicep' = if (createAibManagedIdentity) {
    scope: resourceGroup('${avdSharedServicesSubId}', '${avdSharedResourcesRgName}')
    name: 'image-Builder-Managed-Identity-${time}'
    params: {
        name: aibManagedIdentityName
        location: avdSharedServicesLocation
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}

module deployScriptManagedIdentity '../../carml/1.0.0/Microsoft.ManagedIdentity/userAssignedIdentities/deploy.bicep' = {
    scope: resourceGroup('${avdSharedServicesSubId}', '${avdSharedResourcesRgName}')
    name: 'deployment-Script-Managed-Identity-${time}'
    params: {
        name: deployScriptManagedIdentityName
        location: avdSharedServicesLocation
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}

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
// RBAC role Assignments.
resource azureImageBuilderExistingRole 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = if (!createAibCustomRole) {
    name: 'AzureImageBuilder-AVD'
    scope: subscription(avdSharedServicesSubId)
  }

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

// Custom images: Azure Image Builder deployment. Azure Compute Gallery --> Image Template Definition --> Image Template --> Build and Publish Template --> Create VMs.
// Azure Compute Gallery.
module azureComputeGallery '../../carml/1.2.0/Microsoft.Compute/galleries/deploy.bicep' = {
    scope: resourceGroup('${avdSharedServicesSubId}', '${avdSharedResourcesRgName}')
    name: 'Deploy-Azure-Compute-Gallery-${time}'
    params: {
        name: imageGalleryName
        location: avdSharedServicesLocation
        galleryDescription: 'Azure Virtual Desktops Images'
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}

// Image Template Definition.
module avdImageTemplataDefinition '../../carml/1.2.0/Microsoft.Compute/galleries/images/deploy.bicep' = {
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
    }
    dependsOn: [
        azureComputeGallery
        avdSharedResourcesRg
    ]
}
//

// Create Image Template.
module imageTemplate '../../carml/1.2.0/Microsoft.VirtualMachineImages/imageTemplates/deploy.bicep' = {
    scope: resourceGroup('${avdSharedServicesSubId}', '${avdSharedResourcesRgName}')
    name: 'AVD-Deploy-Image-Template-${time}'
    params: {
        name: imageDefinitionsTemSpecName
        userMsiName: createAibManagedIdentity && useSharedImage ? imageBuilderManagedIdentity.outputs.name : existingAibManagedIdentityName
        userMsiResourceGroup: createAibManagedIdentity && useSharedImage ? imageBuilderManagedIdentity.outputs.resourceGroupName : avdSharedResourcesRgName
        location: aibLocation
        imageReplicationRegions: (avdSharedServicesLocation == aibLocation) ? array('${avdSharedServicesLocation}') : concat(array('${aibLocation}'), array('${avdSharedServicesLocation}'))
        sigImageDefinitionId: useSharedImage ? avdImageTemplataDefinition.outputs.resourceId : ''
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
    }
    dependsOn: [
        avdImageTemplataDefinition
        azureComputeGallery
        avdSharedResourcesRg
        azureImageBuilderRoleAssign
    ]
}

// Build Image Template.
module imageTemplateBuild '../../carml/1.2.0/Microsoft.Resources/deploymentScripts/deploy.bicep' = {
    scope: resourceGroup('${avdSharedServicesSubId}', '${avdSharedResourcesRgName}')
    name: 'AVD-Build-Image-Template-${time}'
    params: {
        name: 'imageTemplateBuildName-${avdOsImage}'
        location: aibLocation
        azPowerShellVersion: '6.2'
        cleanupPreference: 'Always'
        timeout: 'PT2H'
        containerGroupName: 'imageTemplateBuildName-${avdOsImage}-aci'
        userAssignedIdentities: createAibManagedIdentity ? {
            '${imageBuilderManagedIdentity.outputs.resourceId}': {}
        } : {
            '${existingAibManagedIdentityId}': {}
        }
        arguments: '-subscriptionId \'${avdSharedServicesSubId}\' -resourceGroupName \'${avdSharedResourcesRgName}\' -imageTemplateName \'${(useSharedImage ? imageTemplate.outputs.name : null)}\''
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
        avdSharedServicesKeyVault
    ]
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
    }
    dependsOn: [
        avdSharedResourcesRg
    ]
}
