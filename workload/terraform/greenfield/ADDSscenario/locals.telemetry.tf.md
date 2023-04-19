# Telemetry is collected by creating an empty ARM deployment with a specific name
# If you want to disable telemetry, you can set the disable_telemetry variable to true

# The following locals identify the module
locals {
  # PUID identifies the module
  telem_avd_puid = "89c34160-547d-11ed-baa8-6fad1bf031a2"
}

# The following `can()` is used for when disable_telemetry = true
locals {
  telem_random_hex = can(random.telem[0].hex) ? random.telem[0].hex : local.empty_string
}

# Here we create the ARM templates for the telemetry deployment
locals {
  telem_arm_subscription_template_content = <<TEMPLATE
{
  "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {},
  "variables": {},
  "resources": [],
  "outputs": {
    "telemetry": {
      "type": "String",
      "value": "For more information, see https://aka.ms/alz/tf/telemetry"
    }
  }
}
TEMPLATE
}
