provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

resource "random_uuid" "aib" {
}

resource "random_string" "aib" {
  length  = 8
  special = false
  upper   = false
  numeric = false
  lower   = true
  keepers = {
    always_run = "${timestamp()}"
  }
}

resource "azurerm_resource_group" "aib" {
  name     = "rg-${var.location}-avd-${var.prefix}-shared-resources"
  location = var.location
  tags     = var.tags
}

resource "azurerm_user_assigned_identity" "aib" {
  name                = "AIB-${random_uuid.aib.result}"
  resource_group_name = azurerm_resource_group.aib.name
  location            = azurerm_resource_group.aib.location
  tags                = var.tags
}

resource "azurerm_role_definition" "aib" {
  name        = "AIB-${random_uuid.aib.result}"
  scope       = data.azurerm_subscription.current.id
  description = "Azure Image Builder AVD"

  permissions {
    actions = [
      "Microsoft.Authorization/*/read",
      "Microsoft.Compute/images/write",
      "Microsoft.Compute/images/read",
      "Microsoft.Compute/images/delete",
      "Microsoft.Compute/galleries/read",
      "Microsoft.Compute/galleries/images/read",
      "Microsoft.Compute/galleries/images/versions/read",
      "Microsoft.Compute/galleries/images/versions/write",
      "Microsoft.Storage/storageAccounts/blobServices/containers/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/write",
      "Microsoft.Storage/storageAccounts/blobServices/read",
      "Microsoft.ContainerInstance/containerGroups/read",
      "Microsoft.ContainerInstance/containerGroups/write",
      "Microsoft.ContainerInstance/containerGroups/start/action",
      "Microsoft.ManagedIdentity/userAssignedIdentities/*/read",
      "Microsoft.ManagedIdentity/userAssignedIdentities/*/assign/action",
      "Microsoft.Authorization/*/read",
      "Microsoft.Resources/deployments/*",
      "Microsoft.Resources/deploymentScripts/read",
      "Microsoft.Resources/deploymentScripts/write",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.VirtualMachineImages/imageTemplates/run/action",
      "Microsoft.VirtualMachineImages/imageTemplates/read",
      "Microsoft.Network/virtualNetworks/read",
      "Microsoft.Network/virtualNetworks/subnets/join/action"
    ]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.current.id,
    azurerm_resource_group.aib.id
  ]
}

resource "azurerm_role_assignment" "aib" {
  scope              = azurerm_resource_group.aib.id
  role_definition_id = azurerm_role_definition.aib.role_definition_resource_id
  principal_id       = azurerm_user_assigned_identity.aib.principal_id
}

resource "time_sleep" "aib" {
  depends_on      = [azurerm_role_assignment.aib]
  create_duration = "60s"
}

resource "azurerm_shared_image_gallery" "aib" {
  name                = "avdgallery_${var.location}"
  resource_group_name = azurerm_resource_group.aib.name
  location            = azurerm_resource_group.aib.location
  tags                = var.tags
}

resource "azurerm_shared_image" "aib" {
  name                = "avdImage-${var.publisher}-${var.offer}-${var.sku}"
  gallery_name        = azurerm_shared_image_gallery.aib.name
  resource_group_name = azurerm_resource_group.aib.name
  location            = azurerm_resource_group.aib.location
  os_type             = "Windows"
  hyper_v_generation  = "V2"

  identifier {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
  }
}

resource "azurerm_resource_group_template_deployment" "aib" {
  name                = random_string.aib.result
  resource_group_name = azurerm_resource_group.aib.name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "imageTemplateName" = {
      value = random_string.aib.result
    },
    "api-version" = {
      value = var.aib_api_version
    }
    "svclocation" = {
      value = var.aib_region
    }
  })

  template_content = <<TEMPLATE
  {
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
      "imageTemplateName": {
        "type": "string"
      },
      "api-version": {
        "type": "string"
      },
      "svclocation": {
        "type": "string"
      }
    },
  
    "variables": {},
  
    "resources": [
      {
        "name": "[parameters('imageTemplateName')]",
        "type": "Microsoft.VirtualMachineImages/imageTemplates",
        "apiVersion": "[parameters('api-version')]",
        "location": "[parameters('svclocation')]",
        "dependsOn": [],
        "tags": {
          "imagebuilderTemplate": "AzureImageBuilderSIG",
          "userIdentity": "enabled"
        },
        "identity": {
          "type": "UserAssigned",
          "userAssignedIdentities": {
            "${azurerm_user_assigned_identity.aib.id}": {}
          }
        },
  
        "properties": {
          "buildTimeoutInMinutes": 100,
  
          "vmProfile": {
            "vmSize": "Standard_DS4_v2",
            "osDiskSizeGB": 127
          },
  
          "source": {
            "type": "PlatformImage",
            "publisher": "microsoftwindowsdesktop",
            "offer": "office-365",
            "sku": "win11-21h2-avd-m365",
            "version": "latest"
          },
          "customize": [
            {
              "type": "PowerShell",
              "name": "CreateBuildPath",
              "scriptUri": "https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/scripts/Optimize_OS_for_AVD.ps1"
            },
            {
              "type": "WindowsRestart",
              "restartCheckCommand": "echo Azure-Image-Builder-Restarted-the-VM  > c:\\buildArtifacts\\azureImageBuilderRestart.txt",
              "restartTimeout": "5m"
            },
            {
              "type": "WindowsUpdate",
              "searchCriteria": "IsInstalled=0",
              "filters": ["exclude:$_.Title -like '*Preview*'", "include:$true"],
              "updateLimit": 40
            }
          ],
          "distribute": [
            {
              "type": "SharedImage",
              "galleryImageId": "${azurerm_shared_image.aib.id}",
              "runOutputName": "[parameters('imageTemplateName')]",
              "artifactTags": {
                "source": "azureVmImageBuilder",
                "baseosimg": "windows11"
              },
              "replicationRegions": [${join(",", formatlist("\"%s\"", var.image_replication_regions))}]
            }
          ]
        }
      }
    ]
  }
TEMPLATE

  depends_on = [
    time_sleep.aib,
    azurerm_shared_image.aib
  ]
}

resource "null_resource" "aib" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "az resource invoke-action --resource-group ${azurerm_resource_group.aib.name} --resource-type Microsoft.VirtualMachineImages/imageTemplates -n ${random_string.aib.result} --action Run"
  }

  depends_on = [
    azurerm_resource_group_template_deployment.aib,
  ]
}