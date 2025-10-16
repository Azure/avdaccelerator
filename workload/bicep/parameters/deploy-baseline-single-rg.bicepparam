using '../deploy-baseline.bicep'

// Example parameter file demonstrating single resource group topology
// This deploys all AVD resources into a single resource group

param deploymentPrefix = 'AVD1'
param deploymentEnvironment = 'Dev'
param resourceGroupTopology = 'SingleResourceGroup'
param avdSessionHostLocation = 'eastus2'
param avdManagementPlaneLocation = 'eastus2'
param avdWorkloadSubsId = '<subscription-id>'
param avdVmLocalUserName = '<local-username>'
param avdVmLocalUserPassword = '<local-password>'
param avdIdentityServiceProvider = 'EntraIDKerberos'
param identityDomainName = '<domain-name>'
param avdSecurityGroups = []
param avdVnetworkAddressPrefixes = '10.10.0.0/16'
param vNetworkAvdSubnetAddressPrefix = '10.10.1.0/24'
param vNetworkPrivateEndpointSubnetAddressPrefix = '10.10.2.0/27'

// Optional: Customize the single resource group name
// param avdUseCustomNaming = true
// param avdSingleResourceGroupCustomName = 'rg-avd-myworkload-dev'
