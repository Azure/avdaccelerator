using './deploy.bicep'

param workloadSubsId = ''
param storageObjectsRgName = ''
param serviceObjectsRgName = ''
param anfAccountName = ''
param anfCapacityPoolName = ''
param anfVolumeName = ''
param anfSubnetId = ''
param dnsServers = ''
param location = ''
param identityDomainName = ''
param wrklKvName = ''
param domainJoinUserName = ''
param anfPerformance = ''
param capacityPoolSize = 4
param volumeSize = 0
param tags = {}
param time = ? /* TODO : please fix the value assigned to this parameter `utcNow()` */
param storagePurpose = ''
param ouStgPath = ''

