# Single Resource Group Topology Example

This example parameter file demonstrates how to deploy Azure Virtual Desktop with all resources consolidated into a single resource group.

## Key Differences from Multi-RG Topology

- Sets `resourceGroupTopology = 'SingleResourceGroup'`
- All resources (service objects, compute, network, storage) are deployed to one resource group
- Simplifies resource organization and management
- Ideal for dev/test environments or smaller production workloads

## Usage

### PowerShell

```powershell
$SubID = "<subscription-ID>"
$avdVmLocalUserPassword = Read-Host -Prompt "Local user password" -AsSecureString

New-AzSubscriptionDeployment `
  -Name "AVDSingleRGDeployment" `
  -Location "eastus2" `
  -TemplateParameterFile "./workload/bicep/parameters/deploy-baseline-single-rg.bicepparam" `
  -avdWorkloadSubsId $SubID `
  -avdVmLocalUserPassword $avdVmLocalUserPassword
```

### Azure CLI

```bash
SubID="<subscription-ID>"

az deployment sub create \
  --name "AVDSingleRGDeployment" \
  --location "eastus2" \
  --parameters ./workload/bicep/parameters/deploy-baseline-single-rg.bicepparam \
  --parameters avdWorkloadSubsId="$SubID"
```

## Customizing the Resource Group Name

To use a custom resource group name instead of the auto-generated name:

1. Set `avdUseCustomNaming = true`
2. Set `avdSingleResourceGroupCustomName = 'your-custom-rg-name'`

Example:
```bicep
param avdUseCustomNaming = true
param avdSingleResourceGroupCustomName = 'rg-avd-myworkload-dev'
```

## Resource Group Naming Convention

When using auto-generated names (default):
- **Format**: `rg-avd-{prefix}-{environment}-{location-acronym}`
- **Example**: `rg-avd-avd1-dev-use2`

Where:
- `{prefix}` = Value of `deploymentPrefix` parameter (e.g., "avd1")
- `{environment}` = Value of `deploymentEnvironment` parameter (e.g., "dev")
- `{location-acronym}` = Location abbreviation (e.g., "use2" for East US 2)
