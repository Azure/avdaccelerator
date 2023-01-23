locals {
  tags = {
    environment = var.prefix
    source      = "https://github.com/Azure/avdaccelerator/tree/main/workload/terraform/network"
  }
}

