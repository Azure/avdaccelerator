locals {
  storage_name = lower(replace("stavd${var.prefix}${random_string.random.id}", "-", ""))
  subnet_name  = "${var.pesnet}-${substr(var.avdLocation, 0, 5)}-${var.prefix}"
  tags = {
    environment = var.prefix
    source      = "https://github.com/Azure/avdaccelerator/tree/main/workload/terraform/avdbaseline"
  }
}
