using './deploy-baseline.bicep'
param deploymentPrefix = 'AVD4'
param avdSessionHostLocation = 'eastus2'
param avdManagementPlaneLocation = 'eastus2'
param avdWorkloadSubsId = ''***REMOVED***''
param avdEnterpriseAppObjectId = ''***REMOVED***''
param avdVmLocalUserName = ''***REMOVED***''
param avdVmLocalUserPassword = ''***REMOVED***''
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
param alaExistingWorkspaceResourceId = '/subscriptions/'***REMOVED***'/resourceGroups/DefaultResourceGroup-EUS/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-'***REMOVED***'-EUS'
param availabilityZonesCompute = false

