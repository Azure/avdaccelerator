targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@sys.description('AVD disk encryption set resource ID to enable server side encyption. (Default: "")')
param diskEncryptionSetResourceId string = ''

@sys.description('AVD subnet ID. (Default: )')
param subnetId string

@sys.description('Location where to deploy compute services. (Default: )')
param location string

@minLength(2)
@maxLength(4)
@sys.description('The name of the resource group to deploy. (Default: AVD1)')
param deploymentPrefix string = 'AVD1'

@sys.description('AVD resources custom naming. (Default: false)')
param customNaming bool = false

// @sys.description('General session host batch identifier')
// param managedIdentityStorageResourceId int

@maxLength(11)
@sys.description('AVD session host prefix custom name. (Default: vmapp1duse2)')
param sessionHostCustomNamePrefix string = 'vmapp1duse2'

@maxLength(9)
@sys.description('AVD availability set custom name. (Default: avail)')
param avsetCustomNamePrefix string = 'avail'

@sys.description('Resource Group name for the session hosts. (Default: )')
param computeRgResourceID string

@sys.description('Quantity of session hosts to deploy. (Default: 1)')
param count int = 1

@allowed([
  'Dev' // Development
  'Test' // Test
  'Prod' // Production
])
@sys.description('The name of the resource group to deploy. (Default: Dev)')
param deploymentEnvironment string = 'Dev'

@sys.description('The session host number to begin with for the deployment. (Default: )')
param countIndex int

@sys.description('Creates an availability zone and adds the VMs to it. Cannot be used in combination with availability set nor scale set. (Default: true)')
param useAvailabilityZones bool = true

@sys.description('The service providing domain services for Azure Virtual Desktop. (Default: ADDS)')
param identityServiceProvider string = 'ADDS'

@sys.description('Required, Eronll session hosts on Intune. (Default: false)')
param createIntuneEnrollment bool = false

@sys.description('Session host VM size. (Default: Standard_D4ads_v5)')
param vmSize string = 'Standard_D4ads_v5'

@sys.description('Enables accelerated Networking on the session hosts. (Default: true)')
param enableAcceleratedNetworking bool = true

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

@sys.description('OS disk type for session host. (Default: Standard_LRS)')
param diskType string = 'Standard_LRS'

@sys.description('Set to deploy image from Azure Compute Gallery. (Default: false)')
param useSharedImage bool = false

@sys.description('Source custom image ID. (Default: "")')
param avdImageTemplateDefinitionId string = ''

@sys.description('Storage Managed Identity Resource ID.')
param storageManagedIdentityResourceId string = ''

@sys.description('Local administrator username. (Default: "")')
param vmLocalUserName string = 'avdVmLocalUserName'

@sys.description('Resource ID of keyvault that contains credentials. (Default: )')
param keyVaultResourceId string

@sys.description('VM local admin keyvault secret name. (Default: )')
param vmLocalAdminPasswordSecretName string

@sys.description('Domain join user password keyvault secret name. (Default: domainJoinUserPassword)')
param domainJoinPasswordSecretName string = 'domainJoinUserPassword'

@sys.description('FQDN of on-premises AD domain, used for FSLogix storage configuration and NTFS setup. (Default: "")')
param identityDomainName string = ''

@sys.description('AVD session host domain join user principal name. (Default: NoUsername)')
param domainJoinUserName string = 'NoUsername'

@sys.description('OU path to join AVd VMs. (Default: "")')
param sessionHostOuPath string = ''

@sys.description('Application Security Group (ASG) for the session hosts. (Default: "")')
param asgResourceId string = ''

@sys.description('AVD Host Pool resource ID. (Default: )')
param hostPoolResourceID string

@sys.description('Deploy Fslogix setup. (Default: false)')
param createAvdFslogixDeployment bool = false

@sys.description('FSLogix storage resource ID. (Default: )')
param fslogixStorageResourceId string = ''

@sys.description('FSLogix file share name. (Default: )')
param fslogixFileShareName string = ''

@sys.description('Log analytics workspace for diagnostic logs. (Default: "")')
param alaWorkspaceResourceId string = ''

@sys.description('Deploy AVD monitoring resources and setings. (Default: false)')
param deployMonitoring bool = false

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

@sys.description('Enables a zero trust configuration on the session host disks. (Default: false)')
param diskZeroTrust bool = false

@sys.description('Disk encryption set to use for zero trust setup. (Default: )')
param ztDiskEncryptionSetResourceId string = ''

@sys.description('Apply tags on resources and resource groups. (Default: false)')
param createResourceTags bool = false

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
  'Non-business'
  'Public'
  'General'
  'Confidential'
  'Highly-confidential'
])
@sys.description('Sensitivity of data hosted (Default: Non-business)')
param dataClassificationTag string = 'Non-business'

@sys.description('Department that owns the deployment, (Dafult: Contoso-AVD)')
param departmentTag string = 'Contoso-AVD'

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

@sys.description('Details about the application.')
param applicationNameTag string = 'Contoso-App'

@sys.description('Service level agreement level of the worload. (Contoso-SLA)')
param workloadSlaTag string = 'Contoso-SLA'

@sys.description('Team accountable for day-to-day operations. (workload-admins@Contoso.com)')
param opsTeamTag string = 'workload-admins@Contoso.com'

@sys.description('Organizational owner of the AVD deployment. (Default: workload-owner@Contoso.com)')
param ownerTag string = 'workload-owner@Contoso.com'

@sys.description('Cost center of owner team. (Default: Contoso-CC)')
param costCenterTag string = 'Contoso-CC'

@sys.description('Sets the number of fault domains for the availability set. (Default: 2)')
param avsetFaultDomainCount int = 2

@sys.description('Sets the number of update domains for the availability set. (Default: 5)')
param avsetUpdateDomainCount int = 5

// =========== //
// Variable declaration //
// =========== //
var varDeploymentPrefixLowercase = toLower(deploymentPrefix)
var varSessionHostLocationAcronym = varLocations[varSessionHostLocationLowercase].acronym
var varDeploymentEnvironmentComputeStorage = (deploymentEnvironment == 'Dev') ? 'd' : ((deploymentEnvironment == 'Test') ? 't' : ((deploymentEnvironment == 'Prod') ? 'p' : ''))
var varSessionHostNamePrefix = customNaming ? sessionHostCustomNamePrefix : 'vm${varDeploymentPrefixLowercase}${varDeploymentEnvironmentComputeStorage}${varSessionHostLocationAcronym}'
var varDeploymentEnvironmentLowercase = toLower(deploymentEnvironment)
var varComputeStorageResourcesNamingStandard = '${varDeploymentPrefixLowercase}-${varDeploymentEnvironmentLowercase}-${varSessionHostLocationAcronym}'
var varAvsetNamePrefix = customNaming ? '${avsetCustomNamePrefix}-${varComputeStorageResourcesNamingStandard}' : 'avail-${varComputeStorageResourcesNamingStandard}'
var varLocations = loadJsonContent('../../../variables/locations.json')
var varTimeZoneSessionHosts = varLocations[varSessionHostLocationLowercase].timeZone
var varSessionHostLocationLowercase = toLower(replace(location, ' ', ''))
var varMaxSessionHostsPerTemplate = 10
var varMaxSessionHostsDivisionValue = count / varMaxSessionHostsPerTemplate
var varMaxSessionHostsDivisionRemainderValue = count % varMaxSessionHostsPerTemplate
var varSessionHostBatchCount = varMaxSessionHostsDivisionRemainderValue > 0 ? varMaxSessionHostsDivisionValue + 1 : varMaxSessionHostsDivisionValue
var varMaxAvsetMembersCount = 199
var varDivisionAvsetValue = count / varMaxAvsetMembersCount
var varDivisionAvsetRemainderValue = count % varMaxAvsetMembersCount
var varAvsetCount = varDivisionAvsetRemainderValue > 0 ? varDivisionAvsetValue + 1 : varDivisionAvsetValue
var varComputeSubId = split(computeRgResourceID, '/')[2]
var varComputeRgName = split(computeRgResourceID, '/')[4]
var varHostpoolSubId = split(hostPoolResourceID, '/')[2]
var varHostpoolRgName = split(hostPoolResourceID, '/')[4]
var varHostPoolName = split(hostPoolResourceID, '/')[8]
var varKeyVaultSubId = (identityServiceProvider != 'AAD') ? split(keyVaultResourceId, '/')[2] : ''
var varKeyVaultRgName = (identityServiceProvider != 'AAD') ? split(keyVaultResourceId, '/')[4] : ''
var varKeyVaultName = (identityServiceProvider != 'AAD') ? split(keyVaultResourceId, '/')[8] : ''
var varManagedDisk = empty(diskEncryptionSetResourceId) ? {
  storageAccountType: diskType
} : {
  diskEncryptionSet: {
    id: diskEncryptionSetResourceId
  }
  storageAccountType: diskType
}
var varFslogixStorageAccountName = createAvdFslogixDeployment ? split(fslogixStorageResourceId, '/')[8] : ''
var varFslogixStorageFqdn = createAvdFslogixDeployment ? '${varFslogixStorageAccountName}.file.${environment().suffixes.storage}' : ''
var varFslogixSharePath = createAvdFslogixDeployment ? '\\\\${varFslogixStorageAccountName}.file.${environment().suffixes.storage}\\${fslogixFileShareName}' : ''
var varBaseScriptUri = 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/'
var varSessionHostConfigurationScriptUri = '${varBaseScriptUri}scripts/Set-SessionHostConfiguration.ps1'
var varSessionHostConfigurationScript = './Set-SessionHostConfiguration.ps1'
var varAllAvailabilityZones = pickZones('Microsoft.Compute', 'virtualMachines', location, 3)
var varAvdDefaultTags = {
  'cm-resource-parent': hostPoolResourceID
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
var varNicDiagnosticMetricsToEnable = [
  'AllMetrics'
]
var varMarketPlaceGalleryWindows = {
  win10_21h2: {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'windows-10'
    sku: 'win10-21h2-avd'
    version: 'latest'
  }
  win10_21h2_office: {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'office-365'
    sku: 'win10-21h2-avd-m365'
    version: 'latest'
  }
  win10_22h2_g2: {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'windows-10'
    sku: 'win10-22h2-avd-g2'
    version: 'latest'
  }
  win10_22h2_office_g2: {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'office-365'
    sku: 'win10-22h2-avd-m365-g2'
    version: 'latest'
  }
  win11_21h2: {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-11'
    sku: 'win11-21h2-avd'
    version: 'latest'
  }
  win11_21h2_office: {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'office-365'
    sku: 'win11-21h2-avd-m365'
    version: 'latest'
  }
  win11_22h2: {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-11'
    sku: 'win11-22h2-avd'
    version: 'latest'
  }
  win11_22h2_office: {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'office-365'
    sku: 'win11-22h2-avd-m365'
    version: 'latest'
  }
  winServer_2022_Datacenter: {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: '2022-datacenter-g2'
    version: 'latest'
  }
  winServer_2022_Datacenter_smalldisk_g2: {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: '2022-datacenter-smalldisk-g2'
    version: 'latest'
  }
  winServer_2022_datacenter_core: {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: '2022-datacenter-core-g2'
    version: 'latest'
  }
  winServer_2022_Datacenter_core_smalldisk_g2: {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: '2022-datacenter-core-smalldisk-g2'
    version: 'latest'
  }
}

// =========== //
// Deployments //
// =========== //

// Call on the hotspool
resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2019-12-10-preview' existing = {
  name: varHostPoolName
  scope: resourceGroup('${varHostpoolSubId}', '${varHostpoolRgName}')
}

// call on the keyvault
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = if (identityServiceProvider != 'AAD') {
  name: varKeyVaultName
  scope: resourceGroup('${varKeyVaultSubId}', '${varKeyVaultRgName}')
}

// Call to the ALA workspace
resource alaWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (!empty(alaWorkspaceResourceId) && deployMonitoring) {
  scope: az.resourceGroup(split(alaWorkspaceResourceId, '/')[2], split(alaWorkspaceResourceId, '/')[4])
  name: last(split(alaWorkspaceResourceId, '/'))!
}

// Availability set
module availabilitySet '../../modules/avdSessionHosts/.bicep/availabilitySets.bicep' = if (!useAvailabilityZones) {
  name: 'AVD-Availability-Set-${time}'
  scope: resourceGroup('${varComputeSubId}', '${varComputeRgName}')
  params: {
    namePrefix: varAvsetNamePrefix
    location: location
    count: varAvsetCount
    faultDomainCount: avsetFaultDomainCount
    updateDomainCount: avsetUpdateDomainCount
    tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
  }
  dependsOn: []
}

// Session hosts
@batchSize(3)
module sessionHosts '../../../../carml/1.3.0/Microsoft.Compute/virtualMachines/deploy.bicep' = [for i in range(1, count): {
  scope: resourceGroup('${varComputeSubId}', '${varComputeRgName}')
  name: 'SH-${i - 1}-${time}'
  params: {
    name: '${varSessionHostNamePrefix}${padLeft((i + countIndex), 4, '0')}'
    location: location
    timeZone: varTimeZoneSessionHosts
    systemAssignedIdentity: (identityServiceProvider == 'AAD') ? true : false
    availabilityZone: useAvailabilityZones ? take(skip(varAllAvailabilityZones, i % length(varAllAvailabilityZones)), 1) : []
    encryptionAtHost: diskZeroTrust
    availabilitySetResourceId: useAvailabilityZones ? '' : '/subscriptions/${varComputeSubId}/resourceGroups/${varComputeRgName}/providers/Microsoft.Compute/availabilitySets/${varAvsetNamePrefix}-${padLeft(((1 + (i + countIndex) / varMaxAvsetMembersCount)), 3, '0')}'
    osType: 'Windows'
    licenseType: 'Windows_Client'
    vmSize: vmSize
    securityType: securityType
    secureBootEnabled: secureBootEnabled
    vTpmEnabled: vTpmEnabled
    imageReference: useSharedImage ? json('{\'id\': \'${avdImageTemplateDefinitionId}\'}') : varMarketPlaceGalleryWindows[osImage]
    osDisk: {
      createOption: 'fromImage'
      deleteOption: 'Delete'
      diskSizeGB: 128
      managedDisk: varManagedDisk
    }
    adminUsername: vmLocalUserName
    adminPassword: keyVault.getSecret(vmLocalAdminPasswordSecretName)
    nicConfigurations: [
      {
        nicSuffix: 'nic-01-'
        deleteOption: 'Delete'
        enableAcceleratedNetworking: enableAcceleratedNetworking
        ipConfigurations: !empty(asgResourceId) ? [
          {
            name: 'ipconfig01'
            subnetResourceId: subnetId
            applicationSecurityGroups: [
              {
                id: asgResourceId
              }
            ]
          }
        ] : [
          {
            name: 'ipconfig01'
            subnetResourceId: subnetId
          }
        ]
      }
    ]
    // ADDS or AADDS domain join.
    extensionDomainJoinPassword: (identityServiceProvider != 'AAD') ? keyVault.getSecret(domainJoinPasswordSecretName) : 'domainJoinUserPassword'
    extensionDomainJoinConfig: {
      enabled: (identityServiceProvider == 'AAD') ? false : true
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
      enabled: (identityServiceProvider == 'AAD') ? true : false
      settings: createIntuneEnrollment ? {
        mdmId: '0000000a-0000-0000-c000-000000000000'
      } : {}
    }
    nicdiagnosticMetricsToEnable: deployMonitoring ? varNicDiagnosticMetricsToEnable : []
    diagnosticWorkspaceId: deployMonitoring ? alaWorkspaceResourceId : ''
    tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
  }
  dependsOn: [
    keyVault
  ]
}]

// Add antimalware extension to session host.
module sessionHostsAntimalwareExtension '../../../../carml/1.3.0/Microsoft.Compute/virtualMachines/extensions/deploy.bicep' = [for i in range(1, count): {
  scope: resourceGroup('${varComputeSubId}', '${varComputeRgName}')
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
      Exclusions: createAvdFslogixDeployment ? {
        Extensions: '*.vhd;*.vhdx'
        Paths: '"%ProgramFiles%\\FSLogix\\Apps\\frxdrv.sys;%ProgramFiles%\\FSLogix\\Apps\\frxccd.sys;%ProgramFiles%\\FSLogix\\Apps\\frxdrvvt.sys;%TEMP%\\*.VHD;%TEMP%\\*.VHDX;%Windir%\\TEMP\\*.VHD;%Windir%\\TEMP\\*.VHDX;${varFslogixSharePath}\\*\\*.VHD;${varFslogixSharePath}\\*\\*.VHDX'
        Processes: '%ProgramFiles%\\FSLogix\\Apps\\frxccd.exe;%ProgramFiles%\\FSLogix\\Apps\\frxccds.exe;%ProgramFiles%\\FSLogix\\Apps\\frxsvc.exe'
      } : {}
    }
    enableDefaultTelemetry: false
  }
  dependsOn: [
    sessionHosts
  ]
}]

// Add monitoring extension to session host
module monitoring '../../../../carml/1.3.0/Microsoft.Compute/virtualMachines/extensions/deploy.bicep' = [for i in range(1, count): if (deployMonitoring) {
  scope: resourceGroup('${varComputeSubId}', '${varComputeRgName}')
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
    enableDefaultTelemetry: false
  }
  dependsOn: [
    sessionHostsAntimalwareExtension
    alaWorkspace
  ]
}]

// Apply AVD session host configurations
module sessionHostConfiguration '../../modules/avdSessionHosts/.bicep/configureSessionHost.bicep' = [for i in range(1, count): {
  scope: resourceGroup('${varComputeSubId}', '${varComputeRgName}')
  name: 'SH-Config-${i}-${time}'
  params: {
    location: location
    name: '${varSessionHostNamePrefix}${padLeft((i + countIndex), 4, '0')}'
    hostPoolToken: hostPool.properties.registrationInfo.token //hostPool.properties.registrationInfo.token
    baseScriptUri: varSessionHostConfigurationScriptUri
    scriptName: varSessionHostConfigurationScript
    fslogix: createAvdFslogixDeployment
    identityDomainName: identityDomainName
    vmSize: vmSize
    fslogixFileShare: varFslogixSharePath
    fslogixStorageFqdn: varFslogixStorageFqdn
    identityServiceProvider: identityServiceProvider
  }
  dependsOn: [
    sessionHosts
    monitoring
  ]
}]
