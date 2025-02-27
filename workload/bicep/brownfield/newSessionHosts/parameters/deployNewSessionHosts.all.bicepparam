using '../deployNewSessionHosts.bicep'

param location = ''
param computeRgResourceGroupName = ''
param deploymentPrefix = 'AVD1'
param deploymentEnvironment = 'Dev'
param hostPoolResourceId = ''
param customNaming = false
param sessionHostCustomNamePrefix = ''
param count = 1
param countIndex = 0
param diskType = 'Premium_LRS'
param customOsDiskSizeGB = 0
param vmSize = 'Standard_D4ads_v5'
param enableAcceleratedNetworking = true
param availability = 'None'
param availabilityZones = [
  '1'
  '2'
  '3'
]
param useSharedImage = false
param mpImageOffer = 'Office-365'
param mpImageSku = 'win11-24h2-avd-m365'
param customImageDefinitionId = ''
param asgResourceId = ''
param securityType = 'TrustedLaunch'
param secureBootEnabled = true
param vTpmEnabled = true
param encryptionAtHost = false
param diskEncryptionSetResourceId = ''
param deployAntiMalwareExt = true
param identityServiceProvider = 'ADDS'
param createIntuneEnrollment = false
param identityDomainName = ''
param sessionHostOuPath = ''
param domainJoinUserPrincipalName = ''
param keyVaultResourceId = ''
param subnetResourceId = ''
param enableMonitoring = false
param dataCollectionRuleId = ''
param configureFslogix = false
param fslogixStorageAccountResourceId = ''
param fslogixFileShareName = ''
param createResourceTags = false
param applicationNameTag = ''
param costCenterTag = ''
param dataClassificationTag = ''
param departmentTag = ''
param opsTeamTag = ''
param ownerTag = ''
param workloadNameTag = ''
param workloadTypeTag = ''
param workloadCriticalityTag = ''
param workloadCriticalityCustomValueTag = ''
param workloadSlaTag = ''

