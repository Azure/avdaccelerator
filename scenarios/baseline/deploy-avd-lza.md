# Deploy Azure Virtual Desktop Landing Zone Accelerator

## How to deploy this reference implementation

### Planning

This section covers the high-level steps for planning an AVD deployment and the decisions that need to be made. The deployment will use the Microsoft provided Bicep/PowerShell/Azure CLI templates from this repository and the customer provided configuration files that contain the system specific information.

This AVD accelerator supports deployment into greenfield scenarios (no Azure infrastructure components exist) or brownfield scenarios (some Azure infrastructure components exist).

### Greenfield deployment

In the Greenfield scenario, no Azure infrastructure components for AVD on Azure deployment exist prior to deploying. The automation framework will create an AVD workload in the desired Azure region, create a VNet or reuse an existing VNet and configure basic connectivity.
It is important to consider the life cycle of each of these components. If you want to deploy these items individually or via separate executions, then please see the Brownfield Deployment section.
The AVD Green Field template provides a complete AVD landing zone reference implementation within a single template.

### Brownfield deployment

In the Brownfield scenario, the automation framework will deploy the solution using existing Azure VNet, allowing you to create a new AVD workload and utilize and integrate existing Azure resources.

### Deployment Flow

The deployment flow has three steps:

1. AVD shared services including image builder, images, managed identity, compute gallery
2. AVD workload including compute (session hosts), service objects. Session hosts will be joined to a specified AD DS, host pool, and workspace.
3. Connectivity for the AVD session hosts including NSG, ASG, network

### Single or Multiple subscriptions deployment

It recommended to deploy in two subscriptions for scalability and separation of resources due to the purpose and lifecycle of the related Azure resources, however the use of a single subscription is also accepted:

1.A subscription for the AVD Landing zone workload specific resources (VMs, AVD Service objects, etc.) as these resources represent the actual AVD resources that are deployed.
2.AVD Shared Services Landing Zone for shared platform resources (compute gallery, key vaults, storage, etc.) as these are resources used to deploy the actual AVD workload.

### AVD Landing Zone: Greenfield Deployment

Greenfield deployment of AVD Landing Zone is suitable for those customers who are looking at brand new installation. By using this reference implementation, these customers can deploy AVD using suggested configuration from Microsoft. Customers can add new configuration or modify deployed configuration to meet their very specific requirement.

## AVD landing zone deployment walk through

- Azure core setup blade
  - Subscription - allows you to select a subscription in which the accelerator is going to deploy the resources.
  - Region – Desired Azure Region to be used for the deployment
  - Deployment prefix – A prefix of maximum 4 characters that will be appended to the names of Resource Groups and Azure Resources within the Resource Groups.
- Management plane blade
  - Deployment location:
  - Host pool settings:
  - Load balancing method:
  - Max sessions:
  - Create remote app group:
  - Start VM on connect:
  - AVD enterprise application ObjectID:
- Session hosts blade
  - Deploy sessions hosts:
  - Use availability zones:
  - Azure Files share SKU:
  - FSLogix file share size
  - VM size:
  - VM count:
  - OS disk type:
  - OS image source:
  - OS version:
- Identity blade
  - Domain:
  - OU path:
  - Domain Join credentials
    - Username:
    - Password:
  - Session host local admin credentials
    - Username:
    - Password:
- Network connectivity blade
  - Virtual network:
  - VNet address range:
  - VNet DNS servers:
  - Existing hub VNet peering
    - Virtual Network:
    - VNet Gateway on hub:
- Review + create blade

## Next Steps

You should assign specific roles, including AVD-specific roles based on your organization’s policies.
Preferably enable NSG Flow logs, unless it is not required.

## Known Issues

Please report issues using GitHub.
