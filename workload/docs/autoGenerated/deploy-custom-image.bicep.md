# AVD Accelerator - Baseline Custom Image Deployment

AVD Accelerator - Custom Image Baseline

## Parameters

Parameter name | Required | Description
-------------- | -------- | -----------
alertsActionGroupCustomName | No       | Custom name for Action Group.
alertsDistributionGroup | No       | Input the email distribution list for alert notifications when AIB builds succeed or fail.
applicationNameTag | No       | Details about the application.
automationAccountCustomName | No       | Custom name for the Automation Account.
buildSchedule  | No       | Determine whether to build the image template one time or check daily for a new marketplace image and auto build when found. (Default: Recurring)
costCenterTag  | No       | Cost center of owner team. (Default: Contoso-CC)
criticalityCustomTag | No       | Tag value for custom criticality value. (Default: Contoso-Critical)
criticalityTag | No       | criticality of each workload. (Default: Low)
customNaming   | No       | Determine whether to enable custom naming for the Azure resources. (Default: false)
dataClassificationTag | No       | Sensitivity of data hosted (Default: Non-business)
departmentTag  | No       | Department that owns the deployment, (Dafult: Contoso-AVD)
deploymentLocation | No       | Location to deploy the resources in this solution, except the image template. (Default: eastus)
enableMonitoringAlerts | No       | Set to deploy monitoring and alerts for the build automation (Default: false).
enableResourceTags | No       | Apply tags on resources and resource groups. (Default: false)
enableTelemetry | No       | Enable usage and telemetry feedback to Microsoft.
environmentTag | No       | Deployment environment of the application, workload. (Default: Dev)
existingLogAnalyticsWorkspaceResourceId | No       | Existing Azure log analytics workspace resource ID to capture build logs. (Default: )
existingSubnetName | No       | Input the name of the subnet for the existing virtual network that the network interfaces on the build virtual machines will join. (Default: "")
existingVirtualNetworkResourceId | No       | Input the resource ID for the existing virtual network that the network interfaces on the build virtual machines will join. (Default: "")
imageBuildNameTag | No       | The name of workload for tagging purposes. (Default: AVD-Image)
imageDefinitionCustomName | No       | Custom name for Image Definition. (Default: avd-win11-21h2)
imageDefinitionAcceleratedNetworkSupported | No       | The image supports accelerated networking. Accelerated networking enables single root I/O virtualization (SR-IOV) to a VM, greatly improving its networking performance. This high-performance path bypasses the host from the data path, which reduces latency, jitter, and CPU utilization for the most demanding network workloads on supported VM types. 
imageDefinitionHibernateSupported | No       | The image will support hibernation.
imageDefinitionSecurityType | No       | Choose the Security Type of the Image Definition. (Default: Standard)
imageGalleryCustomName | No       | Custom name for Image Gallery. (Default: gal_avd_use2_001)
imageTemplateCustomName | No       | Custom name for Image Template. (Default: it-avd-win11-21h2)
imageVersionDisasterRecoveryLocation | No       | Disaster recovery replication location for Image Version. (Default:"")
imageVersionPrimaryLocation | Yes      | Primary replication location for Image Version. (Default:)
imageVersionStorageAccountType | No       | Determine the Storage Account Type for the Image Version distributed by the Image Template. (Default: Standard_LRS)
logAnalyticsWorkspaceCustomName | No       | Custom name for the Log Analytics Workspace.
logAnalyticsWorkspaceDataRetention | No       | Set the data retention in the number of days for the Log Analytics Workspace. (Default: 30)
operatingSystemImage | No       | AVD OS image source. (Default: win11-22h2)
operationsTeamTag | No       | Team accountable for day-to-day operations. (Contoso-Ops)
ownerTag       | No       | Organizational owner of the AVD deployment. (Default: Contoso-Owner)
rdpShortPathManagedNetworks | No       | Determine whether to enable RDP Short Path for Managed Networks. (Default: false)
resourceGroupCustomName | No       | Custom name for Resource Group. (Default: rg-avd-use2-shared-services)
screenCaptureProtection | No       | Determine whether to enable Screen Capture Protection. (Default: false)
sharedServicesSubId | Yes      | AVD shared services subscription ID, multiple subscriptions scenario.
time           | No       | Do not modify, used to set unique value for resource deployment.
useExistingVirtualNetwork | No       | Set to deploy Azure Image Builder to existing virtual network. (Default: false)
userAssignedManagedIdentityCustomName | No       | Custom name for User Assigned Identity. (Default: id-avd)
workloadNameTag | No       | Reference to the size of the VM for your workloads (Default: Contoso-Workload)

### alertsActionGroupCustomName

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Custom name for Action Group.

- Default value: `ag-aib`

### alertsDistributionGroup

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Input the email distribution list for alert notifications when AIB builds succeed or fail.

### applicationNameTag

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Details about the application.

- Default value: `Contoso-App`

### automationAccountCustomName

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Custom name for the Automation Account.

- Default value: `aa-avd`

### buildSchedule

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Determine whether to build the image template one time or check daily for a new marketplace image and auto build when found. (Default: Recurring)

- Default value: `Recurring`

- Allowed values: `OneTime`, `Recurring`

### costCenterTag

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Cost center of owner team. (Default: Contoso-CC)

- Default value: `Contoso-CC`

### criticalityCustomTag

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Tag value for custom criticality value. (Default: Contoso-Critical)

- Default value: `Contoso-Critical`

### criticalityTag

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

criticality of each workload. (Default: Low)

- Default value: `Low`

- Allowed values: `Low`, `Medium`, `High`, `Mission-critical`, `Custom`

### customNaming

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Determine whether to enable custom naming for the Azure resources. (Default: false)

- Default value: `False`

### dataClassificationTag

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Sensitivity of data hosted (Default: Non-business)

- Default value: `Non-business`

- Allowed values: `Non-business`, `Public`, `General`, `Confidential`, `Highly Confidential`

### departmentTag

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Department that owns the deployment, (Dafult: Contoso-AVD)

- Default value: `Contoso-AVD`

### deploymentLocation

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Location to deploy the resources in this solution, except the image template. (Default: eastus)

- Default value: `eastus`

- Allowed values: `australiaeast`, `australiasoutheast`, `brazilsouth`, `canadacentral`, `centralindia`, `centralus`, `eastasia`, `eastus`, `eastus2`, `francecentral`, `germanywestcentral`, `japaneast`, `jioindiawest`, `koreacentral`, `northcentralus`, `northeurope`, `norwayeast`, `qatarcentral`, `southafricanorth`, `southcentralus`, `southeastasia`, `switzerlandnorth`, `uaenorth`, `uksouth`, `ukwest`, `usgovarizona`, `usgoviowa`, `usgovtexas`, `usgovvirginia`, `westcentralus`, `westeurope`, `westus`, `westus2`, `westus3`

### enableMonitoringAlerts

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Set to deploy monitoring and alerts for the build automation (Default: false).

- Default value: `False`

### enableResourceTags

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Apply tags on resources and resource groups. (Default: false)

- Default value: `False`

### enableTelemetry

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Enable usage and telemetry feedback to Microsoft.

- Default value: `True`

### environmentTag

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Deployment environment of the application, workload. (Default: Dev)

- Default value: `Dev`

- Allowed values: `Prod`, `Dev`, `Staging`

### existingLogAnalyticsWorkspaceResourceId

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Existing Azure log analytics workspace resource ID to capture build logs. (Default: )

### existingSubnetName

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Input the name of the subnet for the existing virtual network that the network interfaces on the build virtual machines will join. (Default: "")

### existingVirtualNetworkResourceId

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Input the resource ID for the existing virtual network that the network interfaces on the build virtual machines will join. (Default: "")

### imageBuildNameTag

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

The name of workload for tagging purposes. (Default: AVD-Image)

- Default value: `AVD-Image`

### imageDefinitionCustomName

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Custom name for Image Definition. (Default: avd-win11-21h2)

- Default value: `avd-win11-21h2`

### imageDefinitionAcceleratedNetworkSupported

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

The image supports accelerated networking.
Accelerated networking enables single root I/O virtualization (SR-IOV) to a VM, greatly improving its networking performance.
This high-performance path bypasses the host from the data path, which reduces latency, jitter, and CPU utilization for the
most demanding network workloads on supported VM types.


- Default value: `true`

- Allowed values: `true`, `false`

### imageDefinitionHibernateSupported

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

The image will support hibernation.

- Default value: `false`

- Allowed values: `true`, `false`

### imageDefinitionSecurityType

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Choose the Security Type of the Image Definition. (Default: Standard)

- Default value: `Standard`

- Allowed values: `Standard`, `TrustedLaunch`, `ConfidentialVM`, `ConfidentialVMSupported`

### imageGalleryCustomName

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Custom name for Image Gallery. (Default: gal_avd_use2_001)

- Default value: `gal_avd_use2_001`

### imageTemplateCustomName

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Custom name for Image Template. (Default: it-avd-win11-21h2)

- Default value: `it-avd-win11-22h2`

### imageVersionDisasterRecoveryLocation

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Disaster recovery replication location for Image Version. (Default:"")

### imageVersionPrimaryLocation

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Primary replication location for Image Version. (Default:)

### imageVersionStorageAccountType

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Determine the Storage Account Type for the Image Version distributed by the Image Template. (Default: Standard_LRS)

- Default value: `Standard_LRS`

- Allowed values: `Standard_LRS`, `Standard_ZRS`

### logAnalyticsWorkspaceCustomName

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Custom name for the Log Analytics Workspace.

- Default value: `log-avd`

### logAnalyticsWorkspaceDataRetention

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Set the data retention in the number of days for the Log Analytics Workspace. (Default: 30)

- Default value: `30`

### operatingSystemImage

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

AVD OS image source. (Default: win11-22h2)

- Default value: `win11_22h2`

- Allowed values: `win10_21h2`, `win10_21h2_office`, `win10_22h2_g2`, `win10_22h2_office_g2`, `win11_21h2`, `win11_21h2_office`, `win11_22h2`, `win11_22h2_office`, `win11_23h2`, `win11_23h2_office`

### operationsTeamTag

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Team accountable for day-to-day operations. (Contoso-Ops)

- Default value: `workload-admins@Contoso.com`

### ownerTag

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Organizational owner of the AVD deployment. (Default: Contoso-Owner)

- Default value: `workload-owner@Contoso.com`

### rdpShortPathManagedNetworks

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Determine whether to enable RDP Short Path for Managed Networks. (Default: false)

- Default value: `False`

### resourceGroupCustomName

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Custom name for Resource Group. (Default: rg-avd-use2-shared-services)

- Default value: `rg-avd-use2-shared-services`

### screenCaptureProtection

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Determine whether to enable Screen Capture Protection. (Default: false)

- Default value: `False`

### sharedServicesSubId

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

AVD shared services subscription ID, multiple subscriptions scenario.

### time

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Do not modify, used to set unique value for resource deployment.

- Default value: `[utcNow()]`

### useExistingVirtualNetwork

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Set to deploy Azure Image Builder to existing virtual network. (Default: false)

- Default value: `False`

### userAssignedManagedIdentityCustomName

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Custom name for User Assigned Identity. (Default: id-avd)

### workloadNameTag

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Reference to the size of the VM for your workloads (Default: Contoso-Workload)

- Default value: `Contoso-Workload`

## Snippets

### Parameter file

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "metadata": {
        "template": "workload/arm/deploy-custom-image.json"
    },
    "parameters": {
        "alertsActionGroupCustomName": {
            "value": "ag-aib"
        },
        "alertsDistributionGroup": {
            "value": ""
        },
        "applicationNameTag": {
            "value": "Contoso-App"
        },
        "automationAccountCustomName": {
            "value": "aa-avd"
        },
        "buildSchedule": {
            "value": "Recurring"
        },
        "costCenterTag": {
            "value": "Contoso-CC"
        },
        "criticalityCustomTag": {
            "value": "Contoso-Critical"
        },
        "criticalityTag": {
            "value": "Low"
        },
        "customNaming": {
            "value": false
        },
        "dataClassificationTag": {
            "value": "Non-business"
        },
        "departmentTag": {
            "value": "Contoso-AVD"
        },
        "deploymentLocation": {
            "value": "eastus"
        },
        "enableMonitoringAlerts": {
            "value": false
        },
        "enableResourceTags": {
            "value": false
        },
        "enableTelemetry": {
            "value": true
        },
        "environmentTag": {
            "value": "Dev"
        },
        "existingLogAnalyticsWorkspaceResourceId": {
            "value": ""
        },
        "existingSubnetName": {
            "value": ""
        },
        "existingVirtualNetworkResourceId": {
            "value": ""
        },
        "imageBuildNameTag": {
            "value": "AVD-Image"
        },
        "imageDefinitionCustomName": {
            "value": "avd-win11-21h2"
        },
        "imageDefinitionAcceleratedNetworkSupported": {
            "value": "true"
        },
        "imageDefinitionHibernateSupported": {
            "value": "false"
        },
        "imageDefinitionSecurityType": {
            "value": "Standard"
        },
        "imageGalleryCustomName": {
            "value": "gal_avd_use2_001"
        },
        "imageTemplateCustomName": {
            "value": "it-avd-win11-22h2"
        },
        "imageVersionDisasterRecoveryLocation": {
            "value": ""
        },
        "imageVersionPrimaryLocation": {
            "value": ""
        },
        "imageVersionStorageAccountType": {
            "value": "Standard_LRS"
        },
        "logAnalyticsWorkspaceCustomName": {
            "value": "log-avd"
        },
        "logAnalyticsWorkspaceDataRetention": {
            "value": 30
        },
        "operatingSystemImage": {
            "value": "win11_22h2"
        },
        "operationsTeamTag": {
            "value": "workload-admins@Contoso.com"
        },
        "ownerTag": {
            "value": "workload-owner@Contoso.com"
        },
        "rdpShortPathManagedNetworks": {
            "value": false
        },
        "resourceGroupCustomName": {
            "value": "rg-avd-use2-shared-services"
        },
        "screenCaptureProtection": {
            "value": false
        },
        "sharedServicesSubId": {
            "value": ""
        },
        "time": {
            "value": "[utcNow()]"
        },
        "useExistingVirtualNetwork": {
            "value": false
        },
        "userAssignedManagedIdentityCustomName": {
            "value": ""
        },
        "workloadNameTag": {
            "value": "Contoso-Workload"
        }
    }
}
```
