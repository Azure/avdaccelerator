provider "azurerm" {
  features {}
}

## Created Shared Image Gallery
resource "azurerm_shared_image_gallery" "sig" {
  name                = var.signame
  resource_group_name = var.rg_name
  location            = var.location
  description         = "Shared images and things."

  tags = {
    Environment = "L400"
    Tech        = "Terraform"
  }
}

resource "azurerm_shared_image" "img" {
  name                = "avd-image"
  gallery_name        = azurerm_shared_image_gallery.sig.name
  resource_group_name = var.rg_name
  location            = var.location
  os_type             = "Windows"

  identifier {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "office-365"
    sku       = "20h2-evd-o365pp"
  }
}

