locals {
  storage_name = lower(replace("stavd${var.prefix}${random_string.random.id}", "-", ""))
  tags = {
    environment = var.prefix
    source      = "https://github.com/Azure/avdaccelerator/tree/main/workload/terraform/avdbaseline"
  }
}
