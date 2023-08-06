# AVD Zero Trust Policy Inititative or Set Definition

This Terraform configuration file creates a custom initiative or policy set definition for Azure Virtual Desktop (AVD) Zero Trust policies. The policy set definition includes a set of policy definitions that enforce security best practices for Azure Virtual Desktop with Zero Trust principles. Further on [AVD Zero Trust](https://learn.microsoft.com/en-us/security/zero-trust/azure-infrastructure-avd)

## Resources Deployed

The following resources will be deployed by this Terraform configuration:

**Custom-AVD AZT Policy Set:** This resource creates a custom policy intiative for AVD Zero Trust policies. The policy set definition includes the following set of policy definitions that enforce security best practices for AVD:

- Azure Virtual Desktop service should use private link
- Azure Virtual Desktop hostpools should disable public network access only on session hosts
- Azure Virtual Desktop hostpools should disable public network access
- Azure Virtual Desktop workspaces should disable public network access
- Storage accounts should disable public network access
- Storage accounts should use customer-managed key for encryption
- Storage accounts should restrict network access
Audits Storage Account for Storage File Data SMB Share Elevated Contributor RBAC role for an AVD AD groups
- Storage accounts should have infrastructure encryption
- Storage accounts should use private link
- System updates should be installed on your machines
M- anagement ports of virtual machines should be protected with just-in-time network access control
- [Preview]: Guest Attestation extension should be installed on supported Windows virtual machines
- [Preview]: vTPM should be enabled on supported virtual machines
- [Preview]: Secure Boot should be enabled on supported Windows virtual machines
- Accounts with owner permissions on Azure resources should be MFA enabled
- Accounts with read permissions on Azure resources should be MFA enabled
- Accounts with write permissions on Azure resources should be MFA enabled
- [Preview]: All Internet traffic should be routed via your deployed Azure Firewall
- Azure Defender for servers should be enabled
- Microsoft Defender for Storage (Classic) should be enabled


## Usage

To use this Terraform configuration, follow these steps:

1. Install Terraform on your local machine.
2. Clone this repository to your local machine.
3. Navigate to the directory containing the cloned repository.
4. Before deploying, confirm the correct subscription
5 Open the `main.tf` file in a text editor.
6. Run `terraform init` to initialize the Terraform working directory.
7. Run `terraform plan` to preview the changes that will be made.
8. Run `terraform apply` to apply the changes and create the policy set definition.

## Contributing

If you find a bug or have a feature request, please open an issue on the GitHub repository. Pull requests are also welcome.

