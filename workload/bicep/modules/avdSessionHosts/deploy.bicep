targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@sys.description('AVD disk encryption set resource ID to enable server side encyption.')
param diskEncryptionSetResourceId string

@sys.description('AVD subnet ID.')
param subnetId string

@sys.description('Location where to deploy compute services.')
param sessionHostLocation string

@sys.description('Virtual machine time zone.')
param timeZone string

@sys.description('AVD Session Host prefix.')
param sessionHostNamePrefix string

@sys.description('Resource Group name for the session hosts.')
param computeObjectsRgName string

@sys.description('Name of AVD service objects RG.')
param serviceObjectsRgName string

@sys.description('AVD workload subscription ID, multiple subscriptions scenario.')
param subscriptionId string

@sys.description('Quantity of session hosts to deploy.')
param deploySessionHostsCount int

@sys.description('Max VMs per availability set.')
param maxAvsetMembersCount int

@sys.description('The session host number to begin with for the deployment.')
param sessionHostCountIndex int

@sys.description('Creates an availability zone and adds the VMs to it. Cannot be used in combination with availability set nor scale set.')
param useAvailabilityZones bool

@sys.description('Availablity Set name.')
param avsetNamePrefix string

@sys.description('Create VM GPU extension policies.')
param deployGpuPolicies bool

@sys.description('Required, The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@sys.description('Required, Eronll session hosts on Intune.')
param createIntuneEnrollment bool

@sys.description('This property can be used by user in the request to enable or disable the Host Encryption for the virtual machine. This will enable the encryption for all the disks including Resource/Temp disk at host itself. For security reasons, it is recommended to set encryptionAtHost to True. Restrictions: Cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
param encryptionAtHost bool

@sys.description('Session host VM size.')
param sessionHostsSize string

@sys.description('Enables accelerated Networking on the session hosts.')
param enableAcceleratedNetworking bool

@sys.description('Specifies the securityType of the virtual machine. Must be TrustedLaunch or ConfidentialVM enable UefiSettings.')
param securityType string

@sys.description('Specifies whether secure boot should be enabled on the virtual machine. This parameter is part of the UefiSettings. securityType should be set to TrustedLaunch to enable UefiSettings.')
param secureBootEnabled bool

@sys.description('Specifies whether virtual TPM should be enabled on the virtual machine. This parameter is part of the UefiSettings.  securityType should be set to TrustedLaunch to enable UefiSettings.')
param vTpmEnabled bool

@sys.description('OS disk type for session host.')
param sessionHostDiskType string

@sys.description('Market Place OS image.')
param marketPlaceGalleryWindows object

@sys.description('Set to deploy image from Azure Compute Gallery.')
param useSharedImage bool

@sys.description('Source custom image ID.')
param avdImageTemplateDefinitionId string

@sys.description('Storage Managed Identity Resource ID.')
param storageManagedIdentityResourceId string

@sys.description('Local administrator username.')
param vmLocalUserName string

@sys.description('Name of keyvault that contains credentials.')
param wrklKvName string

@sys.description('AD domain name.')
param identityDomainName string

@sys.description('AVD session host domain join credentials.')
param domainJoinUserName string

@sys.description('OU path to join AVd VMs.')
param sessionHostOuPath string

@sys.description('Application Security Group (ASG) for the session hosts.')
param asgResourceId string

@sys.description('AVD Host Pool name.')
param hostPoolName string

@sys.description('Location for the AVD agent installation package.')
param avdAgentPackageLocation string

@sys.description('Deploy Fslogix setup.')
param createAvdFslogixDeployment bool

@sys.description('FSlogix configuration script file name.')
param fsLogixScript string

@sys.description('Configuration arguments for FSlogix.')
param fsLogixScriptArguments string

@sys.description('Path for the FSlogix share.')
param fslogixSharePath string

@sys.description('URI for FSlogix configuration script.')
param fslogixScriptUri string

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Log analytics workspace for diagnostic logs.')
param alaWorkspaceResourceId string

@sys.description('Diagnostic logs retention.')
param diagnosticLogsRetentionInDays int

@sys.description('Deploy AVD monitoring resources and setings. (Default: true)')
param deployMonitoring bool

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var varMaxSessionHostsPerTemplateDeployment = 10 // max number of session hosts that can be deployed from the avd-session-hosts.bicep file in each batch / for loop. Math: (800 - <Number of Static Resources>) / <Number of Looped Resources> 
var varDivisionValue = deploySessionHostsCount / varMaxSessionHostsPerTemplateDeployment // This determines if any full batches are required.
var varDivisionRemainderValue = deploySessionHostsCount % varMaxSessionHostsPerTemplateDeployment // This determines if any partial batches are required.
var varSessionHostBatchCount = varDivisionRemainderValue > 0 ? varDivisionValue + 1 : varDivisionValue // This determines the total number of batches needed, whether full and / or partial.

// =========== //
// Deployments //
// =========== //

// Call on the hotspool.
resource getHostPool 'Microsoft.DesktopVirtualization/hostPools@2019-12-10-preview' existing = {
  name: hostPoolName
  scope: resourceGroup('${subscriptionId}', '${serviceObjectsRgName}')
}

// Session hosts.
@batchSize(3)
module sessionHosts './.bicep/avdSessionHosts.bicep' = [for i in range(1, varSessionHostBatchCount): {
  scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
  name: 'AVD-SH-Batch-${i-1}-${time}'
  params: {
    diskEncryptionSetResourceId: diskEncryptionSetResourceId 
    avdAgentPackageLocation: avdAgentPackageLocation
    timeZone: timeZone
    asgResourceId: asgResourceId
    avsetNamePrefix: avsetNamePrefix
    maxAvsetMembersCount: maxAvsetMembersCount
    computeObjectsRgName: computeObjectsRgName
    domainJoinUserName: domainJoinUserName
    wrklKvName: wrklKvName
    serviceObjectsRgName: serviceObjectsRgName
    hostPoolName: hostPoolName
    identityDomainName: identityDomainName
    imageTemplateDefinitionId: avdImageTemplateDefinitionId
    sessionHostOuPath: sessionHostOuPath
    sessionHostsCount: i == varSessionHostBatchCount && varDivisionRemainderValue > 0 ? varDivisionRemainderValue : varMaxSessionHostsPerTemplateDeployment
    sessionHostCountIndex: i == 1 ? sessionHostCountIndex : (((i - 1) * varMaxSessionHostsPerTemplateDeployment) + sessionHostCountIndex)
    sessionHostDiskType: sessionHostDiskType
    sessionHostLocation: sessionHostLocation
    sessionHostNamePrefix: sessionHostNamePrefix
    sessionHostsSize: sessionHostsSize
    enableAcceleratedNetworking: enableAcceleratedNetworking
    securityType: securityType
    secureBootEnabled: secureBootEnabled
    vTpmEnabled: vTpmEnabled
    subnetId: subnetId
    useAvailabilityZones: useAvailabilityZones
    vmLocalUserName: vmLocalUserName
    subscriptionId: subscriptionId
    encryptionAtHost: encryptionAtHost
    createAvdFslogixDeployment: createAvdFslogixDeployment
    storageManagedIdentityResourceId: storageManagedIdentityResourceId
    fsLogixScriptFile: fsLogixScript
    fsLogixScriptArguments: fsLogixScriptArguments
    fslogixSharePath: fslogixSharePath
    fslogixScriptUri: fslogixScriptUri
    hostPoolToken: getHostPool.properties.registrationInfo.token
    marketPlaceGalleryWindows: marketPlaceGalleryWindows
    useSharedImage: useSharedImage
    identityServiceProvider: identityServiceProvider
    createIntuneEnrollment: createIntuneEnrollment
    tags: tags
    deployMonitoring: deployMonitoring
    alaWorkspaceResourceId: alaWorkspaceResourceId
    diagnosticLogsRetentionInDays: diagnosticLogsRetentionInDays
  }
}]

// VM GPU extension policies.
module gpuPolicies './.bicep/azurePolicyGpuExtensions.bicep' = if (deployGpuPolicies) {
  scope: subscription('${subscriptionId}')
  name: 'GPU-VM-Extensions-${time}'
  params: {
    computeObjectsRgName: computeObjectsRgName
    location: sessionHostLocation
    subscriptionId: subscriptionId
  }
  dependsOn: []
}
