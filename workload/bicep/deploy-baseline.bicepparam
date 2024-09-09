using './deploy-baseline.bicep'
param deploymentPrefix = 'AVD4'
param avdSessionHostLocation = 'eastus2'
param avdManagementPlaneLocation = 'eastus2'
param avdWorkloadSubsId = '40879978-1a98-4dcd-b600-8e1c8696fe68'
param avdEnterpriseAppObjectId = '10e443a6-dec8-4439-8ea1-626be770a0da'
param avdVmLocalUserName = 'avdadmin'
param avdVmLocalUserPassword = 'azureadmin.123#'
param avdIdentityServiceProvider = 'EntraID'
param createAvdVnet = true
param avdVnetworkAddressPrefixes = '10.10.0.0/23'
param vNetworkAvdSubnetAddressPrefix = '10.10.0.0/24'
param deployPrivateEndpointKeyvaultStorage = false
param createPrivateDnsZones = false
param createAvdFslogixDeployment = false
param avdDeploySessionHosts = true
param avdDeployMonitoring = true
param deployAlaWorkspace = false
param alaExistingWorkspaceResourceId = '/subscriptions/40879978-1a98-4dcd-b600-8e1c8696fe68/resourceGroups/DefaultResourceGroup-EUS/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-40879978-1a98-4dcd-b600-8e1c8696fe68-EUS'
param availabilityZonesCompute = false

