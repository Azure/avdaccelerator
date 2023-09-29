/*
This HCL code block sets the variables for creating a custom image using Packer. You may modify the values of the variables to suit your needs.
The variables include:
- image_offer: The offer of the image to use.
- image_publisher: The publisher of the image to use.
- image_sku: The SKU of the image to use.
- image_version: The version of the image to use.
- vm_size: The size of the virtual machine to use.
- resource_group_name: The name of the resource group to use.
- region: The region where the resource group and virtual machine will be created.
*/

image_offer         = "office-365"
image_publisher     = "MicrosoftWindowsDesktop"
image_sku           = "win11-22h2-avd-m365"
image_version       = "latest"
vm_size             = "Standard_NV12ads_A10_v5"
resource_group_name = "gamedev-image-rg"
region              = "southcentralus"