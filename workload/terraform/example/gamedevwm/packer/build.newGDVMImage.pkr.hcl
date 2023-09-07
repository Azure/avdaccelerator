packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 1.0"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[-TZ:]", "")
}

source "azure-arm" "base" {
  # Add metadata to the image
  azure_tags = {
    build-time = local.timestamp
  }
  # Use Windows as the source image
  os_type         = "Windows"
  os_disk_size_gb = 255

  # Use WinRM for communicate
  communicator = "winrm"
  // winrm_username = var.winrm_username
  winrm_timeout  = "10m"
  winrm_insecure = true
  winrm_use_ssl  = true

  # Specify the details of the source Image
  image_offer     = var.image_offer
  image_publisher = var.image_publisher
  image_sku       = var.image_sku
  image_version   = var.image_version

  # Specify the details of the destination image
  use_azure_cli_auth                = true
  managed_image_name                = "avdPackerImage"
  managed_image_resource_group_name = var.resource_group_name
  location                          = var.region
  // build_resource_group_name         = "rg_gmdv_packer"
  vm_size = "Standard_D2s_v5"

}


build {

  sources = [
    "source.azure-arm.base"
  ]

  # Create the remote scripts directory
  provisioner "windows-shell" {
    inline = ["md C:\\Azure-GDVM"]
  }

  # Upload the custom scripts that run when a new VM is created
  provisioner "file" {
    destination = "C:\\Azure-GDVM\\"
    sources = [
      "app_contents\\GameDevVMConfig.ini",
      "app_contents\\Controller-Initialization.ps1",
      "app_contents\\Task-AvdRegistration.ps1",
      "app_contents\\Task-CreateDataDisk.ps1",
      "app_contents\\Task-MountFileShare.ps1",
      "app_contents\\Task-ConfigureLoginScripts.ps1",
      "app_contents\\Utils-DownloadFile.ps1",
    ]
  }

  # General VM Setup
  provisioner "powershell" {
    environment_vars = [
      "install_log_file=${var.install_log_file}",
      "dlink_lgpo_tool=${var.dlink_lgpo_tool}",
      "dlink_winsdk=${var.dlink_winsdk}",
    ]
    scripts = [
      "windows\\scripts\\General-CommonComponents.ps1",
      "windows\\scripts\\General-WindowsSDK.ps1",
    ]
  }

  provisioner "powershell" {
    environment_vars = [
      "install_log_file=${var.install_log_file}",
      "dlink_pix=${var.dlink_pix}",
    ]
    scripts = [
      "./windows/scripts/General-MicrosoftPIX.ps1",
      "./windows/scripts/General-WindowsStartupTasks.ps1"
    ]
  }

  # Final Build Steps
  provisioner "windows-restart" {
    pause_before          = "5m0s"
    restart_check_command = "powershell -command \"& {Write-Output 'Packer Build VM restarted'}\""
  }

  provisioner "powershell" {
    environment_vars = [
      "install_log_file=${var.install_log_file}",
      "source_name=${source.name}"
    ]
    scripts = [
      "./windows/scripts/General-FinalizationAndSysprep.ps1"
    ]
    skip_clean = true
  }

}
