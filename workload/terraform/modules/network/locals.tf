locals {
  tags = {
    environment = var.prefix
    source      = "https://github.com/Azure/avdaccelerator/tree/main/workload/terraform/avdbaseline"
  }

  #Validate if identity_subscription_id is equal to hub_subscription_id
  use_same_hub_identity_vnet =  var.identity_subscription_id == var.hub_subscription_id ? true : false
}
