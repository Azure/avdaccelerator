using './deploy-baseline.bicep'
param deploymentPrefix = 'g018'
param deploymentEnvironment = 'Dev'
param avdSessionHostLocation = 'eastus2'
param avdManagementPlaneLocation = 'eastus2'
param avdWorkloadSubsId = 'd12d19a9-0636-4951-90a4-339158fd57d8'
param avdVmLocalUserName = 'ADAdmin'
param avdVmLocalUserPassword = 'Gerry User 1'


param avdIdentityServiceProvider = 'ADDS'
param identityDomainName = 'avd.local'
param avdDomainJoinUserName = 'avd\\Adjoin'
param avdDomainJoinUserPassword = 'Gerry User 1'
param avdOuPath = 'OU=AVD,DC=avd,DC=local'
param existingHubVnetResourceId = '/subscriptions/d12d19a9-0636-4951-90a4-339158fd57d8/resourceGroups/AVD-AD-RG/providers/Microsoft.Network/virtualNetworks/avd1-vnet' //Sera el nombre completo del recurso?
param avdVnetworkAddressPrefixes = '192.168.0.0/16'
param vNetworkAvdSubnetAddressPrefix = '192.168.1.0/24'
param vNetworkPrivateEndpointSubnetAddressPrefix = '192.168.2.64/26'
param customDnsIps = '10.0.1.4'


param deployDDoSNetworkProtection = false
param deployPrivateEndpointKeyvaultStorage = true
param createPrivateDnsZones = true
param avdDeployMonitoring = false
param deployAlaWorkspace = false
param deployCustomPolicyMonitoring = true
param avdAlaWorkspaceDataRetention = 90
param avdDeploySessionHostsCount = 1
param avdSessionHostCountIndex = 0
param availabilityZonesCompute = false
param zoneRedundantStorage = false
param deployVmssFlex = false
param vmssFlatformFaultDomainCount = 2
param fslogixStoragePerformance = 'Premium'
param msixStoragePerformance = 'Premium'
param diskZeroTrust = false

param avdSessionHostsSize = 'Standard_D2s_v5' //'Standard_D4ads_v5'
param avdSessionHostDiskType = 'Premium_LRS'
param avdOsImage = 'win11_23h2'
param managementVmOsImage = 'winServer_2022_Datacenter_smalldisk_g2'


param createAvdFslogixDeployment = false
param avdDeployScalingPlan=false

param deployDefender = true

param enableAscForServers = true
param enableAscForStorage = true
param enableAscForKeyVault = true
param enableAscForArm = true
