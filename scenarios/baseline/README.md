# Getting Started

This guide is designed to help you get started with deploying AVD using the provided Bicep template(s) within this repository. Before you deploy, it is recommended to review the template(s) to understand the resources that will be deployed and the associated costs.

## Prerequisites

Prior to deploying, you need to ensure you have met the following prerequisites:

- You have already deployed an ALZ (such as the Contoso Reference Implementation).
- The user or service principal must have rights at the tenant root as described here: [EnterpriseScale-Setup](https://github.com/Azure/Enterprise-Scale/blob/main/docs/EnterpriseScale-Setup-azure.md)
- The [Microsoft.DesktopVirtualization](https://docs.microsoft.com/azure/virtual-desktop/create-host-pools-azure-marketplace?tabs=azure-portal#final-requirements) resource provider must be registered in subscription(s) to be used for deployment.
- Access to the AVD Azure Subscription(s) with owner permissions.
- If the new AVD workload will be connected (peered) with a Hub VNet, contributor permissions are required on the referenced Hub VNet.
- Azure AD Connect is already configured and users are being synced from AD DS to Azure AD
- The account used for the deployment and Domain Join cannot have MFA
- Users are synced to AAD already
- A new subscription has been created for Azure Virtual Desktop
- You have the appropriate [licenses](https://docs.microsoft.com/en-us/azure/virtual-desktop/remote-app-streaming/licensing)
- If using existing Virtual Networks, the deployment will fail if Private Endpoint policies are enabled. See the following article on disabling them: [Disable private endpoint network policy](https://docs.microsoft.com/en-us/azure/private-link/disable-private-endpoint-network-policy )

## What will be deployed
