using './deploy-baseline.bicep'

param deploymentPrefix = 'e010'
param deploymentEnvironment = 'Dev'
param avdSessionHostLocation = ''
param avdManagementPlaneLocation = ''
param avdWorkloadSubsId = ''
param avdVmLocalUserName = ''
param avdVmLocalUserPassword = ''
param avdIdentityServiceProvider = 'ADDS'
param identityDomainName = 'none'
param avdDomainJoinUserName = 'none'
param avdDomainJoinUserPassword = 'none'
param createAvdVnet = false
param existingVnetAvdSubnetResourceId = ''
param deployPrivateEndpointKeyvaultStorage = false
param deployAvdPrivateLinkService = false
param createPrivateDnsZones = false
param createAvdFslogixDeployment = true
param avdDeploySessionHosts = false

