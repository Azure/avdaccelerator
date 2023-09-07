variable "image_offer" {
  type    = string
  default = "office-365"
}

variable "image_publisher" {
  type    = string
  default = "MicrosoftWindowsDesktop"
}

variable "image_sku" {
  type    = string
  default = "win10-22h2-avd-m365-g2"
}

variable "image_version" {
  type    = string
  default = "latest"
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
  type    = string
  default = "southcentralus"
}

variable "resource_group_name" {
  type    = string
  default = "rg_gmdv_packer"
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
