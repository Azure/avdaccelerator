targetScope = 'resourceGroup'

// ========== //
// Parameters //
// ========== //

@sys.description('Log analytics workspace for diagnostic logs. (Default: "")')
param alaWorkspaceResourceId string = ''

@sys.description('Details about the application.')
param applicationNameTag string = 'Contoso-App'

@sys.description('Application Security Group (ASG) for the session hosts. (Default: "")')
param asgResourceId string = ''

@sys.description('VMSS flex resource ID. (Default: "")')
param virtualMachineScaleSetResourceId string = ''

@sys.description('Source custom image ID. (Default: "")')
param customImageDefinitionId string = ''

@sys.description('Subscription ID where to deploy session hosts. (Default: )')
param computeSubscriptionId string

@sys.description('Resource Group name where to deploy session hosts. (Default: )')
param computeRgResourceGroupName string

@sys.description('Quantity of session hosts to deploy. (Default: 1)')
param count int = 1

@sys.description('The session host number to begin with for the deployment. (Default: )')
param countIndex int

@sys.description('AVD resources custom naming. (Default: false)')
param customNaming bool = false

@sys.description('Required, Eronll session hosts on Intune. (Default: false)')
param createIntuneEnrollment bool = false

@sys.description('Deploy Fslogix setup. (Default: false)')
param configureFslogix bool = false

@sys.description('Apply tags on resources and resource groups. (Default: false)')
param createResourceTags bool = false

@sys.description('Cost center of owner team. (Default: Contoso-CC)')
param costCenterTag string = 'Contoso-CC'

@sys.description('AVD disk encryption set resource ID to enable server side encyption. (Default: "")')
param diskEncryptionSetResourceId string = ''

@sys.description('Department that owns the deployment, (Dafult: Contoso-AVD)')
param departmentTag string = 'Contoso-AVD'

@allowed([
  'Non-business'
  'Public'
  'General'
  'Confidential'
  'Highly-confidential'
])
@sys.description('Sensitivity of data hosted (Default: Non-business)')
param dataClassificationTag string = 'Non-business'

@sys.description('Enables a zero trust configuration on the session host disks. (Default: false)')
param diskZeroTrust bool = false

@sys.description('Deploy AVD monitoring resources and setings. (Default: false)')
param deployMonitoring bool = false

@allowed([
  'Dev' // Development
  'Test' // Test
  'Prod' // Production
])
@sys.description('The name of the resource group to deploy. (Default: Dev)')
param deploymentEnvironment string = 'Dev'

@minLength(2)
@maxLength(4)
@sys.description('The name of the resource group to deploy. (Default: AVD1)')
param deploymentPrefix string = 'AVD1'

@sys.description('AVD session host domain join user principal name. (Default: NoUsername)')
param domainJoinUserName string = 'NoUsername'

@sys.description('OS disk type for session host. (Default: Premium_LRS)')
param diskType string = 'Premium_LRS'

@sys.description('Domain join user password keyvault secret name. (Default: domainJoinUserPassword)')
param domainJoinPasswordSecretName string = 'domainJoinUserPassword'

@sys.description('Enables accelerated Networking on the session hosts. (Default: true)')
param enableAcceleratedNetworking bool = true

@sys.description('FSLogix storage resource ID. (Default: )')
param fslogixStorageAccountName string = ''

@sys.description('FSLogix file share name. (Default: )')
param fslogixFileShareName string = ''

@sys.description('AVD Host Pool resource ID. (Default: )')
param hostPoolResourceId string

@sys.description('FQDN of on-premises AD domain, used for FSLogix storage configuration and NTFS setup. (Default: "")')
param identityDomainName string = ''

@sys.description('AVD subnet name. (Default: )')
param subnetResourceId string

@sys.description('Location where to deploy compute services. (Default: )')
param location string

@maxLength(11)
@sys.description('AVD session host prefix custom name. (Default: vmapp1duse2)')
param sessionHostCustomNamePrefix string = 'vmapp1duse2'

@sys.description('Creates an availability zone and adds the VMs to it. Cannot be used in combination with availability set nor scale set. (Default: true)')
param useAvailabilityZones bool = true

@sys.description('The service providing domain services for Azure Virtual Desktop. (Default: ADDS)')
param identityServiceProvider string = 'ADDS'

@sys.description('Session host VM size. (Default: Standard_D4ads_v5)')
param vmSize string = 'Standard_D4ads_v5'

@allowed([
  'Standard'
  'TrustedLaunch'
  'ConfidentialVM'
])
@sys.description('Specifies the securityType of the virtual machine. "ConfidentialVM" and "TrustedLaunch" require a Gen2 Image. (Default: TrustedLaunch)')
param securityType string = 'TrustedLaunch'

@sys.description('Specifies whether secure boot should be enabled on the virtual machine. This parameter is part of the UefiSettings. securityType should be set to TrustedLaunch or ConfidentialVM to enable UefiSettings. (Default: true)')
param secureBootEnabled bool = true

@sys.description('Specifies whether vTPM should be enabled on the virtual machine. This parameter is part of the UefiSettings. securityType should be set to TrustedLaunch or ConfidentialVM to enable UefiSettings. (Default: true)')
param vTpmEnabled bool = true

@sys.description('Set to deploy image from Azure Compute Gallery. (Default: false)')
param useSharedImage bool = false

@sys.description('VM local administrator username. (Default: )')
param vmLocalUserName string

@sys.description('Resource ID of keyvault that contains credentials. (Default: )')
param keyVaultResourceId string

@sys.description('VM local admin keyvault secret name. (Default: vmLocalUserPassword )')
param vmLocalAdminPasswordSecretName string = 'vmLocalUserPassword'

@sys.description('OU path to join AVd VMs. (Default: "")')
param sessionHostOuPath string = ''

@allowed([
  'win10_21h2'
  'win10_21h2_office'
  'win10_22h2_g2'
  'win10_22h2_office_g2'
  'win11_21h2'
  'win11_21h2_office'
  'win11_22h2'
  'win11_22h2_office'
])
@sys.description('AVD OS image SKU. (Default: win11-21h2)')
param osImage string = 'win11_22h2'

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

@sys.description('The name of workload for tagging purposes. (Default: Contoso-Workload)')
param workloadNameTag string = 'Contoso-Workload'

@allowed([
  'Light'
  'Medium'
  'High'
  'Power'
])
@sys.description('Reference to the size of the VM for your workloads (Default: Light)')
param workloadTypeTag string = 'Light'

@allowed([
  'Low'
  'Medium'
  'High'
  'Mission-critical'
  'Custom'
])
@sys.description('Criticality of the workload. (Default: Low)')
param workloadCriticalityTag string = 'Low'

@sys.description('Tag value for custom criticality value. (Default: Contoso-Critical)')
param workloadCriticalityCustomValueTag string = 'Contoso-Critical'

@sys.description('Service level agreement level of the worload. (Contoso-SLA)')
param workloadSlaTag string = 'Contoso-SLA'

@sys.description('Team accountable for day-to-day operations. (workload-admins@Contoso.com)')
param opsTeamTag string = 'workload-admins@Contoso.com'

@sys.description('Organizational owner of the AVD deployment. (Default: workload-owner@Contoso.com)')
param ownerTag string = 'workload-owner@Contoso.com'

// =========== //
// Variable declaration //
// =========== //
var varDeploymentPrefixLowercase = toLower(deploymentPrefix)
var varSessionHostLocationAcronym = varLocations[varSessionHostLocationLowercase].acronym
var varDeploymentEnvironmentComputeStorage = (deploymentEnvironment == 'Dev') ? 'd' : ((deploymentEnvironment == 'Test') ? 't' : ((deploymentEnvironment == 'Prod') ? 'p' : ''))
var varSessionHostNamePrefix = customNaming ? sessionHostCustomNamePrefix : 'vm${varDeploymentPrefixLowercase}${varDeploymentEnvironmentComputeStorage}${varSessionHostLocationAcronym}'
var varLocations = loadJsonContent('../../../variables/locations.json')
var varMarketPlaceGalleryWindows = loadJsonContent('../../../variables/osMarketPlaceImages.json')
var varTimeZoneSessionHosts = varLocations[varSessionHostLocationLowercase].timeZone
var varSessionHostLocationLowercase = toLower(replace(location, ' ', ''))
var varHostpoolSubId = split(hostPoolResourceId, '/')[2]
var varHostpoolRgName = split(hostPoolResourceId, '/')[4]
var varHostPoolName = split(hostPoolResourceId, '/')[8]
var varKeyVaultSubId = split(keyVaultResourceId, '/')[2]
var varKeyVaultRgName = split(keyVaultResourceId, '/')[4]
var varKeyVaultName = split(keyVaultResourceId, '/')[8]
var varManagedDisk = empty(diskEncryptionSetResourceId) ? {
  storageAccountType: diskType
} : {
  diskEncryptionSet: {
    id: diskEncryptionSetResourceId
  }
  storageAccountType: diskType
}
var varFslogixStorageFqdn = configureFslogix ? '${fslogixStorageAccountName}.file.${environment().suffixes.storage}' : ''
var varFslogixSharePath = configureFslogix ? '\\\\${fslogixStorageAccountName}.file.${environment().suffixes.storage}\\${fslogixFileShareName}' : ''
var varBaseScriptUri = 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/'
var varSessionHostConfigurationScriptUri = '${varBaseScriptUri}scripts/Set-SessionHostConfiguration.ps1'
var varSessionHostConfigurationScript = './Set-SessionHostConfiguration.ps1'
var varAvdDefaultTags = {
  'cm-resource-parent': hostPoolResourceId
  Environment: deploymentEnvironment
  ServiceWorkload: 'AVD'
  CreationTimeUTC: time
}
var varCustomResourceTags = createResourceTags ? {
  WorkloadName: workloadNameTag
  WorkloadType: workloadTypeTag
  DataClassification: dataClassificationTag
  Department: departmentTag
  Criticality: (workloadCriticalityTag == 'Custom') ? workloadCriticalityCustomValueTag : workloadCriticalityTag
  ApplicationName: applicationNameTag
  ServiceClass: workloadSlaTag
  OpsTeam: opsTeamTag
  Owner: ownerTag
  CostCenter: costCenterTag
} : {}
// =========== //
// Deployments //
// =========== //

// Call on the hotspool
resource hostPoolGet 'Microsoft.DesktopVirtualization/hostPools@2023-09-05' existing = {
  name: varHostPoolName
  scope: resourceGroup('${varHostpoolSubId}', '${varHostpoolRgName}')
}

// Hostpool update
module hostPool '../../../../avm/1.0.0/res/desktop-virtualization/host-pool/main.bicep' = {
  scope: resourceGroup('${varHostpoolSubId}', '${varHostpoolRgName}')
  name: 'HostPool-${time}'
  params: {
    name: hostPoolGet.name
    friendlyName: hostPoolGet.properties.friendlyName
    location: hostPoolGet.location
    keyVaultResourceId: keyVaultResourceId
    hostPoolType: (hostPoolGet.properties.hostPoolType == 'Personal') ? 'Personal' : (hostPoolGet.properties.hostPoolType == 'Pooled') ? 'Pooled' : null
    startVMOnConnect: hostPoolGet.properties.startVMOnConnect
    customRdpProperty: hostPoolGet.properties.customRdpProperty
    loadBalancerType: (hostPoolGet.properties.loadBalancerType == 'BreadthFirst') ? 'BreadthFirst' : (hostPoolGet.properties.loadBalancerType == 'DepthFirst') ? 'DepthFirst' : (hostPoolGet.properties.loadBalancerType == 'Persistent') ? 'Persistent': null
    maxSessionLimit: hostPoolGet.properties.maxSessionLimit
    preferredAppGroupType: (hostPoolGet.properties.preferredAppGroupType == 'Desktop') ? 'Desktop' : (hostPoolGet.properties.preferredAppGroupType == 'RailApplications') ? 'RailApplications' : null
    personalDesktopAssignmentType: (hostPoolGet.properties.personalDesktopAssignmentType == 'Automatic') ? 'Automatic' : (hostPoolGet.properties.personalDesktopAssignmentType == 'Direct') ? 'Direct' : null
    description: hostPoolGet.properties.description
    ssoadfsAuthority: hostPoolGet.properties.ssoadfsAuthority
    ssoClientId: hostPoolGet.properties.ssoClientId
    ssoClientSecretKeyVaultPath: hostPoolGet.properties.ssoClientSecretKeyVaultPath
    validationEnvironment: hostPoolGet.properties.validationEnvironment
    ring: hostPoolGet.properties.ring
    tags: hostPoolGet.tags
    agentUpdate: hostPoolGet.properties.agentUpdate
  }
}

// call on the keyvault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: split(hostPool.outputs.keyVaultTokenSecretResourceId, '/')[8]
  scope: resourceGroup('${varKeyVaultSubId}', '${varKeyVaultRgName}')
}

// Call to the ALA workspace
resource alaWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = if (!empty(alaWorkspaceResourceId) && deployMonitoring) {
  scope: az.resourceGroup(split(alaWorkspaceResourceId, '/')[2], split(alaWorkspaceResourceId, '/')[4])
  name: last(split(alaWorkspaceResourceId, '/'))!
}

// Session hosts
@batchSize(3)
module sessionHosts '../../../../avm/1.0.0/res/compute/virtual-machine/main.bicep' = [for i in range(1, count): {
  scope: resourceGroup('${computeSubscriptionId}', '${computeRgResourceGroupName}')
  name: 'SH-${i - 1}-${time}'
  params: {
    name: '${varSessionHostNamePrefix}${padLeft((i + countIndex), 4, '0')}'
    location: location
    timeZone: varTimeZoneSessionHosts
    zone: useAvailabilityZones ? (i % 3 + 1) : 0
    managedIdentities: (identityServiceProvider == 'EntraID') ? {
      systemAssigned: true
    }: null
    encryptionAtHost: diskZeroTrust
    virtualMachineScaleSetResourceId: virtualMachineScaleSetResourceId
    osType: 'Windows'
    licenseType: 'Windows_Client'
    vmSize: vmSize
    securityType: securityType
    secureBootEnabled: secureBootEnabled
    vTpmEnabled: vTpmEnabled
    imageReference: useSharedImage ? json('{\'id\': \'${customImageDefinitionId}\'}') : varMarketPlaceGalleryWindows[osImage]
    osDisk: {
      createOption: 'FromImage'
      deleteOption: 'Delete'
      managedDisk: varManagedDisk
    }
    adminUsername: vmLocalUserName
    adminPassword: keyVault.getSecret(vmLocalAdminPasswordSecretName)
    nicConfigurations: [
      {
        name: 'nic-01-${varSessionHostNamePrefix}${padLeft((i + countIndex), 4, '0')}'
        deleteOption: 'Delete'
        enableAcceleratedNetworking: enableAcceleratedNetworking
        ipConfigurations: !empty(asgResourceId) ? [
          {
            name: 'ipconfig01'
            subnetResourceId: subnetResourceId
            applicationSecurityGroups: [
              {
                id: asgResourceId
              }
            ]
          }
        ] : [
          {
            name: 'ipconfig01'
            subnetResourceId: subnetResourceId
          }
        ]
      }
    ]
    // ADDS or EntraDS domain join.
    extensionDomainJoinPassword: (identityServiceProvider == 'ADDS' || identityServiceProvider == 'EntraDS') ? keyVault.getSecret(domainJoinPasswordSecretName) : 'domainJoinUserPassword'
    extensionDomainJoinConfig: {
      enabled: (identityServiceProvider == 'ADDS' || identityServiceProvider == 'EntraDS') ? true : false
      settings: {
        name: identityDomainName
        ouPath: !empty(sessionHostOuPath) ? sessionHostOuPath : null
        user: domainJoinUserName
        restart: 'true'
        options: '3'
      }
    }
    // Microsoft Entra ID Join.
    extensionAadJoinConfig: {
      enabled: (identityServiceProvider == 'EntraID') ? true : false
      settings: createIntuneEnrollment ? {
        mdmId: '0000000a-0000-0000-c000-000000000000'
      } : {}
    }
    tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
  }
  dependsOn: [
    keyVault
  ]
}]

// Add antimalware extension to session host.
module sessionHostsAntimalwareExtension '../../../../avm/1.0.0/res/compute/virtual-machine/extension/main.bicep' = [for i in range(1, count): {
  scope: resourceGroup('${computeSubscriptionId}', '${computeRgResourceGroupName}')
  name: 'SH-Antimal-${i - 1}-${time}'
  params: {
    location: location
    virtualMachineName: '${varSessionHostNamePrefix}${padLeft((i + countIndex), 4, '0')}'
    name: 'MicrosoftAntiMalware'
    publisher: 'Microsoft.Azure.Security'
    type: 'IaaSAntimalware'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: false
    settings: {
      AntimalwareEnabled: true
      RealtimeProtectionEnabled: 'true'
      ScheduledScanSettings: {
        isEnabled: 'true'
        day: '7' // Day of the week for scheduled scan (1-Sunday, 2-Monday, ..., 7-Saturday)
        time: '120' // When to perform the scheduled scan, measured in minutes from midnight (0-1440). For example: 0 = 12AM, 60 = 1AM, 120 = 2AM.
        scanType: 'Quick' //Indicates whether scheduled scan setting type is set to Quick or Full (default is Quick)
      }
      Exclusions: configureFslogix ? {
        Extensions: '*.vhd;*.vhdx'
        Paths: '"%ProgramFiles%\\FSLogix\\Apps\\frxdrv.sys;%ProgramFiles%\\FSLogix\\Apps\\frxccd.sys;%ProgramFiles%\\FSLogix\\Apps\\frxdrvvt.sys;%TEMP%\\*.VHD;%TEMP%\\*.VHDX;%Windir%\\TEMP\\*.VHD;%Windir%\\TEMP\\*.VHDX;${varFslogixSharePath}\\*\\*.VHD;${varFslogixSharePath}\\*\\*.VHDX'
        Processes: '%ProgramFiles%\\FSLogix\\Apps\\frxccd.exe;%ProgramFiles%\\FSLogix\\Apps\\frxccds.exe;%ProgramFiles%\\FSLogix\\Apps\\frxsvc.exe'
      } : {}
    }
  }
  dependsOn: [
    sessionHosts
  ]
}]

// Add monitoring extension to session host
module monitoring '../../../../avm/1.0.0/res/compute/virtual-machine/extension/main.bicep' = [for i in range(1, count): if (deployMonitoring) {
  scope: resourceGroup('${computeSubscriptionId}', '${computeRgResourceGroupName}')
  name: 'SH-Mon-${i - 1}-${time}'
  params: {
    location: location
    virtualMachineName: '${varSessionHostNamePrefix}${padLeft((i + countIndex), 4, '0')}'
    name: 'MicrosoftMonitoringAgent'
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'MicrosoftMonitoringAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: false
    settings: {
      workspaceId: !empty(alaWorkspaceResourceId) ? reference(alaWorkspace.id, alaWorkspace.apiVersion).customerId : ''
    }
    protectedSettings: {
      workspaceKey: !empty(alaWorkspaceResourceId) ? alaWorkspace.listKeys().primarySharedKey : ''
    }
  }
  dependsOn: [
    sessionHostsAntimalwareExtension
    alaWorkspace
  ]
}]

// Apply AVD session host configurations
module sessionHostConfiguration '../../modules/avdSessionHosts/.bicep/configureSessionHost.bicep' = [for i in range(1, count): {
  scope: resourceGroup('${computeSubscriptionId}', '${computeRgResourceGroupName}')
  name: 'SH-Config-${i}-${time}'
  params: {
    location: location
    name: '${varSessionHostNamePrefix}${padLeft((i + countIndex), 4, '0')}'
    hostPoolToken: keyVault.getSecret('hostPoolRegistrationToken')
    baseScriptUri: varSessionHostConfigurationScriptUri
    scriptName: varSessionHostConfigurationScript
    fslogix: configureFslogix
    identityDomainName: identityDomainName
    vmSize: vmSize
    fslogixFileShare: varFslogixSharePath
    fslogixStorageFqdn: varFslogixStorageFqdn
    identityServiceProvider: identityServiceProvider
  }
  dependsOn: [
    sessionHosts
    monitoring
    hostPool
  ]
}]
