/*
This file contains the variables used in the Packer template for creating a custom image for gaming workloads.
- image_offer: The offer of the base image used for creating the custom image.
- image_publisher: The publisher of the base image used for creating the custom image.
- image_sku: The SKU of the base image used for creating the custom image.
- image_version: The version of the base image used for creating the custom image.
- artifact_storage_account: The name of the storage account where the custom image will be stored.
- artifact_storage_account_container: The name of the container in the storage account where the custom image will be stored.
- msbuild_path: The path to the MSBuild executable used for building the custom image.
- winrm_username: The username used for WinRM authentication.
- region: The Azure region where the custom image will be created.
- resource_group_name: The name of the resource group where the custom image will be created.
- temp_resource_group_name: The name of the temporary resource group used for creating the custom image.
- temp_compute_name: The name of the temporary compute resource used for creating the custom image.
- vm_size: The size of the virtual machine used for creating the custom image.
- install_log_file: The path to the log file where the installation details will be stored.
- dlink_chocolatey: The download link for the Chocolatey package manager.
- dlink_lgpo_tool: The download link for the LGPO tool used for managing local group policies.
- dlink_winsdk: The download link for the Windows SDK.
- dlinks_gdk: The download links for the GDK (Game Development Kit) used for developing games on Windows.
- dlink_pix: The download link for the PIX (Performance Investigator for Xbox) tool used for profiling and debugging DirectX 12 games.
*/
variable "image_offer" {
  type = string
}

variable "image_publisher" {
  type = string
}

variable "image_sku" {
  type = string
}

variable "image_version" {
  type = string
}

variable "artifact_storage_account" {
  type    = string
  default = "industrialgaming"
}

variable "artifact_storage_account_container" {
  type    = string
  default = "images"
}

variable "msbuild_path" {
  type    = string
  default = "%WINDIR%\\Microsoft.NET\\Framework\\v4.0.30319"
}

variable "winrm_username" {
  type    = string
  default = "packer"
}

variable "region" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "temp_resource_group_name" {
  type    = string
  default = "gamingvms"
}

variable "temp_compute_name" {
  type    = string
  default = "vmpkrgamingvm"
}

variable "vm_size" {
  type    = string
  default = "Standard_NV12s_v3"
}

variable "install_log_file" {
  type    = string
  default = "C:\\Azure-GDVM\\INSTALLED_SOFTWARE.txt"
}

variable "dlink_chocolatey" {
  type    = string
  default = "https://chocolatey.org/install.ps1"
}


variable "dlink_lgpo_tool" {
  type    = string
  default = "https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/LGPO.zip"
}


variable "dlink_winsdk" {
  type    = string
  default = "https://go.microsoft.com/fwlink/p/?linkid=2196241"
}

variable "dlinks_gdk" {
  type    = string
  default = "https://github.com/microsoft/GDK/archive/refs/tags/June_2021_Update_9.zip,https://github.com/microsoft/GDK/archive/refs/tags/October_2021_Update_5.zip,https://github.com/microsoft/GDK/archive/refs/tags/March_2022_Update_1.zip,https://github.com/microsoft/GDK/archive/refs/tags/June_2022_Update_1.zip"
}

variable "dlink_pix" {
  type    = string
  default = "https://devblogs.microsoft.com/pix/download"
}
