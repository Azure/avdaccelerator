# Create a custom initiative or policy set definition for AVD Zero Trust policies
resource "azurerm_policy_set_definition" "avdzt" {
  name         = "Custom-AVD ZT Policy Set"
  policy_type  = "Custom"
  display_name = "Custom-AVD ZT Policy Set"
  description  = "This policy set deploys AVD Zero Trust Policies to AVD Landing Zone."
  metadata     = <<METADATA
  {
    "category": "AVD Zero Trust Policies",
    "version": "1.1.0"
  }
  METADATA

  #Storage accounts should have infrastructure encryption
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/4733ea7b-a883-42fe-8cac-97454c2a9e4a"
  }

  #Storage accounts should use private link
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/6edd7eda-6dd8-40f7-810d-67160c639cd9"
  }

  #Azure Defender for servers should be enabled
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/308fbb08-4ab8-4e67-9b29-592e93fb94fa"
  }

  #Storage accounts should disable public network access
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/4da35fc9-c9e7-4960-aec9-797fe7d9051d"
  }

  #Storage accounts should disable public network access
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/b2982f36-99f2-4db5-8eff-283140c09693"
  }

  #Storage accounts should use customer-managed key for encryption
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/6fac406b-40ca-413b-bf8e-0bf964659c25"
  }

  #Storage accounts should restrict network access 
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/34c877ad-507e-4c82-993e-3452a6e0ad3c"
  }

  #[Preview]: All Internet traffic should be routed via your deployed Azure Firewall 
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/fc5e4038-4584-4632-8c85-c0448d374b2c"
  }

  #[Preview]: vTPM should be enabled on supported virtual machines
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1c30f9cd-b84c-49cc-aa2c-9288447cc3b3"
  }

  #[Preview]: Secure Boot should be enabled on supported Windows virtual machines
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/97566dd7-78ae-4997-8b36-1c7bfe0d8121"
  }

  #[Preview]: Guest Attestation extension should be installed on supported Windows virtual machines
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1cb4d9c2-f88f-4069-bee0-dba239a57b09"
  }

  #System updates should be installed on your machines
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/86b3d65f-7626-441e-b690-81a8b71cff60"
  }

  #Management ports of virtual machines should be protected with just-in-time network access control
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/b0f33259-77d7-4c9e-aac6-3aabcfae693c"
  }

  #Accounts with read permissions on Azure resources should be MFA enabled
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/81b3ccb4-e6e8-4e4a-8d05-5df25cd29fd4"
  }

  #Accounts with write permissions on Azure resources should be MFA enabled
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/931e118d-50a1-4457-a5e4-78550e086c52"
  }

  #Accounts with owner permissions on Azure resources should be MFA enabled
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e3e008c3-56b9-4133-8fd7-d3347377402a"
  }

  #Azure Virtual Desktop hostpools should disable public network access
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/c25dcf31-878f-4eba-98eb-0818fdc6a334"
  }
  #Azure Virtual Desktop hostpools should disable public network access only on session hosts
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/a22065a3-3b04-46ff-b84c-2d30e5c300d0"
  }

  #Azure Virtual Desktop workspaces should disable public network access
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/87ac3038-c07a-4b92-860d-29e270a4f3cd"
  }

  #Azure Virtual Desktop service should use private link
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ca950cd7-02f7-422e-8c23-91ff40f169c1"
  }
}

