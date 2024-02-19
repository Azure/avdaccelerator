using '../deploy-baseline.bicep'

param deploymentPrefix = 'AVD1'
param avdWorkloadSubsId = '<<subscriptionId>>' // value needs to be provided
param avdVmLocalUserName = '<<localUserName>>' // value needs to be provided
param avdVmLocalUserPassword = '<<localUserPassword>>' // value needs to be provided
param identityDomainName = 'none' // value needs to be provided when using ADDS or EntraDS as identity service provider
param avdDomainJoinUserName = '<<DomainJoinUserName>>' // Value needs to be provided when using ADDS or ADDDS as identity service provider
param avdDomainJoinUserPassword = '<<DomainJoinUserPassword>>' // Value needs to be provided when using ADDS or ADDDS as identity service provider
param customDnsIps = '<<customDnsIp>>' // value needs to be provided when creating new AVD vNet and using ADDS or EntraDS identity service providers
