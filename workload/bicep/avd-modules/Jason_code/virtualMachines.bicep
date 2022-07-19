param AcceleratedNetworking string
param AvailabilitySetPrefix string
param AutomationAccountName string
param Availability string
param ConfigurationName string
param DisaStigCompliance bool
param DiskEncryption bool
param DiskName string
param DiskSku string
@secure()
param DomainJoinPassword string
param DomainJoinUserPrincipalName string
param DomainName string
param DomainServices string
param EphemeralOsDisk string
param Fslogix bool
param FslogixSolution string
param HostPoolName string
param HostPoolType string
param ImageOffer string
param ImagePublisher string
param ImageSku string
param ImageVersion string
param KeyVaultName string
param Location string
param LogAnalyticsWorkspaceName string
param Monitoring bool
param NamingStandard string
param NetworkSecurityGroupName string
param NetAppFileShares array
param OuPath string
param RdpShortPath bool
param ResourceGroups array
param ScreenCaptureProtection bool
param SasToken string
param ScriptsUri string
param SessionHostCount int
param SessionHostIndex int
param StorageAccountPrefix string
param StorageCount int
param StorageIndex int
param StorageSolution string
param StorageSuffix string
param Subnet string
param Tags object
param Timestamp string
param UserAssignedIdentity string = ''
param VirtualNetwork string
param VirtualNetworkResourceGroup string
param VmName string
@secure()
param VmPassword string
param VmSize string
param VmUsername string


var AmdVmSizes = [
  'Standard_NV4as_v4'
  'Standard_NV8as_v4'
  'Standard_NV16as_v4'
  'Standard_NV32as_v4'
]
var AmdVmSize = contains(AmdVmSizes, VmSize)
var DeploymentResourceGroup = ResourceGroups[0] // Deployment Resource Group
var Intune = DomainServices == 'NoneWithIntune' ? true : false
var NvidiaVmSizes = [
  'Standard_NV6'
  'Standard_NV12'
  'Standard_NV24'
  'Standard_NV12s_v3'
  'Standard_NV24s_v3'
  'Standard_NV48s_v3'
  'Standard_NC4as_T4_v3'
  'Standard_NC8as_T4_v3'
  'Standard_NC16as_T4_v3'
  'Standard_NC64as_T4_v3'
  'Standard_NV6ads_A10_v5'
  'Standard_NV12ads_A10_v5'
  'Standard_NV18ads_A10_v5'
  'Standard_NV36ads_A10_v5'
  'Standard_NV36adms_A10_v5'
  'Standard_NV72ads_A10_v5'
]
var NvidiaVmSize = contains(NvidiaVmSizes, VmSize)
var PooledHostPool = (split(HostPoolType, ' ')[0] == 'Pooled')
var ManagementResourceGroup = ResourceGroups[2] // Management Resource Group
var VmIdentityType = (contains(DomainServices, 'None') ? ((!empty(UserAssignedIdentity)) ? 'SystemAssigned, UserAssigned' : 'SystemAssigned') : ((!empty(UserAssignedIdentity)) ? 'UserAssigned' : 'None'))
var VmIdentityTypeProperty = {
  type: VmIdentityType
}
var VmUserAssignedIdentityProperty = {
  userAssignedIdentities: {
    '${resourceId('Microsoft.ManagedIdentity/userAssignedIdentities/', UserAssignedIdentity)}': {}
  }
}
var VmIdentity = ((!empty(UserAssignedIdentity)) ? union(VmIdentityTypeProperty, VmUserAssignedIdentityProperty) : VmIdentityTypeProperty)


resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2021-03-01' = if (RdpShortPath) {
  name: NetworkSecurityGroupName // Fix name
  location: Location
  properties: {
    securityRules: [
      {
        name: 'AllowRdpShortPath'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRange: '3390'
          direction: 'Inbound'
          priority: 3390
          protocol: 'Udp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
    ]
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-05-01' = [for i in range(0, SessionHostCount): {
  name: 'nic-${NamingStandard}-${padLeft((i + SessionHostIndex), 3, '0')}'
  location: Location
  tags: Tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId(subscription().subscriptionId, VirtualNetworkResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', VirtualNetwork, Subnet)
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    enableAcceleratedNetworking: AcceleratedNetworking == 'True' ? true : false
    enableIPForwarding: false
    networkSecurityGroup: RdpShortPath ? {
      id: networkSecurityGroup.id
    } : null
  }
}]

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-03-01' = [for i in range(0, SessionHostCount): {
  name: '${VmName}${padLeft((i + SessionHostIndex), 3, '0')}'
  location: Location
  tags: Tags
  zones: Availability == 'AvailabilityZones' ? [
    string((i % 3) + 1)
  ] : null
  identity: VmIdentity
  properties: {
    availabilitySet: Availability == 'AvailabilitySet' ? {
      id: resourceId('Microsoft.Compute/availabilitySets', '${AvailabilitySetPrefix}-${(i + SessionHostIndex) / 200}')
    } : null
    hardwareProfile: {
      vmSize: VmSize
    }
    storageProfile: {
      imageReference: {
        publisher: ImagePublisher
        offer: ImageOffer
        sku: ImageSku
        version: ImageVersion
      }
      osDisk: {
        name: '${DiskName}${padLeft((i + SessionHostIndex), 3, '0')}'
        osType: 'Windows'
        createOption: 'FromImage'
        caching: EphemeralOsDisk == 'None' ? 'None' : 'ReadOnly'
        deleteOption: 'Delete'
        managedDisk: EphemeralOsDisk == 'None'? {
          storageAccountType: DiskSku
        } : null
        diffDiskSettings: EphemeralOsDisk == 'None' ? null : {
          option: 'Local'
          placement: EphemeralOsDisk
        }
      }
      dataDisks: []
    }
    osProfile: {
      computerName: '${VmName}${padLeft((i + SessionHostIndex), 3, '0')}'
      adminUsername: VmUsername
      adminPassword: VmPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: false
      }
      secrets: []
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', 'nic-${NamingStandard}-${padLeft((i + SessionHostIndex), 3, '0')}')
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
    licenseType: ((ImagePublisher == 'MicrosoftWindowsServer') ? 'Windows_Server' : 'Windows_Client')
  }
  dependsOn: [
    networkInterface
  ]
}]

resource extension_MicrosoftMonitoringAgent 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = [for i in range(0, SessionHostCount): if(Monitoring) {
  name: '${VmName}${padLeft((i + SessionHostIndex), 3, '0')}/MicrosoftMonitoringAgent'
  location: Location
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'MicrosoftMonitoringAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: {
      workspaceId: Monitoring ? reference(resourceId(ManagementResourceGroup, 'Microsoft.OperationalInsights/workspaces', LogAnalyticsWorkspaceName), '2015-03-20').customerId : null
    }
    protectedSettings: {
      workspaceKey: Monitoring ? listKeys(resourceId(ManagementResourceGroup, 'Microsoft.OperationalInsights/workspaces', LogAnalyticsWorkspaceName), '2015-03-20').primarySharedKey : null
    }
  }
  dependsOn: [
    virtualMachine
  ]
}]

resource extension_CustomScriptExtension 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = [for i in range(0, SessionHostCount): {
  name: '${VmName}${padLeft((i + SessionHostIndex), 3, '0')}/CustomScriptExtension'
  location: Location
  tags: Tags
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        '${ScriptsUri}Set-SessionHostConfiguration.ps1${SasToken}'
      ]
      timestamp: Timestamp
    }
    protectedSettings: {
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File Set-SessionHostConfiguration.ps1 -AmdVmSize ${AmdVmSize} -DisaStigCompliance ${DisaStigCompliance} -DomainName ${DomainName} -DomainServices ${DomainServices} -Environment ${environment().name} -FSLogix ${Fslogix} -FslogixSolution ${FslogixSolution} -HostPoolName ${HostPoolName} -HostPoolRegistrationToken ${reference(resourceId(ManagementResourceGroup, 'Microsoft.DesktopVirtualization/hostpools', HostPoolName), '2019-12-10-preview').registrationInfo.token} -ImageOffer ${ImageOffer} -ImagePublisher ${ImagePublisher} -NetAppFileShares ${NetAppFileShares} -NvidiaVmSize ${NvidiaVmSize} -PooledHostPool ${PooledHostPool} -RdpShortPath ${RdpShortPath} -ScreenCaptureProtection ${ScreenCaptureProtection} -StorageAccountPrefix ${StorageAccountPrefix} -StorageCount ${StorageCount} -StorageIndex ${StorageIndex} -StorageSolution ${StorageSolution} -StorageSuffix ${StorageSuffix}'
    }
  }
  dependsOn: [
    virtualMachine
  ]
}]

resource extension_JsonADDomainExtension 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = [for i in range(0, SessionHostCount): if (contains(DomainServices, 'ActiveDirectory')) {
  name: '${VmName}${padLeft((i + SessionHostIndex), 3, '0')}/JsonADDomainExtension'
  location: Location
  tags: Tags
  properties: {
    forceUpdateTag: Timestamp
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      Name: DomainName
      User: DomainJoinUserPrincipalName
      Restart: 'true'
      Options: '3'
      OUPath: OuPath
    }
    protectedSettings: {
      Password: DomainJoinPassword
    }
  }
  dependsOn: [
    virtualMachine
    extension_CustomScriptExtension
  ]
}]

resource extension_AADLoginForWindows 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = [for i in range(0, SessionHostCount): if (contains(DomainServices, 'None')) {
  name: '${VmName}${padLeft((i + SessionHostIndex), 3, '0')}/AADLoginForWindows'
  location: Location
  tags: Tags
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: 'AADLoginForWindows'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: Intune ? {
      mdmId: '0000000a-0000-0000-c000-000000000000'
    } : json('null')
  }
  dependsOn: [
    virtualMachine
    extension_CustomScriptExtension
  ]
}]

resource extension_AmdGpuDriverWindows 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = [for i in range(0, SessionHostCount): if(AmdVmSize) {
  name: '${VmName}${padLeft((i + SessionHostIndex), 3, '0')}/AmdGpuDriverWindows'
  location: Location
  tags: Tags
  properties: {
    publisher: 'Microsoft.HpcCompute'
    type: 'AmdGpuDriverWindows'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: {}
  }
  dependsOn: [
    virtualMachine
    extension_JsonADDomainExtension
    extension_AADLoginForWindows
  ]
}]

resource extension_NvidiaGpuDriverWindows 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = [for i in range(0, SessionHostCount): if (NvidiaVmSize) {
  name: '${VmName}${padLeft((i + SessionHostIndex), 3, '0')}/NvidiaGpuDriverWindows'
  location: Location
  tags: Tags
  properties: {
    publisher: 'Microsoft.HpcCompute'
    type: 'NvidiaGpuDriverWindows'
    typeHandlerVersion: '1.2'
    autoUpgradeMinorVersion: true
    settings: {}
  }
  dependsOn: [
    virtualMachine
    extension_JsonADDomainExtension
    extension_AADLoginForWindows
  ]
}]

resource extension_AzureDiskEncryption 'Microsoft.Compute/virtualMachines/extensions@2017-03-30' = [for i in range(0, SessionHostCount): if(DiskEncryption) {
  name: '${VmName}${padLeft((i + SessionHostIndex), 3, '0')}/AzureDiskEncryption'
  location: Location
  properties: {
    publisher: 'Microsoft.Azure.Security'
    type: 'AzureDiskEncryption'
    typeHandlerVersion: '2.2'
    autoUpgradeMinorVersion: true
    forceUpdateTag: Timestamp
    settings: {
      EncryptionOperation: 'EnableEncryption'
      KeyVaultURL: DiskEncryption ? reference(resourceId(ManagementResourceGroup, 'Microsoft.KeyVault/vaults', KeyVaultName), '2016-10-01', 'Full').properties.vaultUri : null
      KeyVaultResourceId: resourceId(ManagementResourceGroup, 'Microsoft.KeyVault/vaults', KeyVaultName)
      KeyEncryptionKeyURL: DiskEncryption ? reference(resourceId(DeploymentResourceGroup, 'Microsoft.Resources/deploymentScripts', 'ds-${NamingStandard}-bitlockerKek'), '2019-10-01-preview', 'Full').properties.outputs.text : null
      KekVaultResourceId: resourceId(ManagementResourceGroup, 'Microsoft.KeyVault/vaults', KeyVaultName)
      KeyEncryptionAlgorithm: 'RSA-OAEP'
      VolumeType: 'All'
      ResizeOSDisk: false
    }
  }
  dependsOn: [
    extension_AmdGpuDriverWindows
    extension_NvidiaGpuDriverWindows
  ]
}]

resource extension_DSC 'Microsoft.Compute/virtualMachines/extensions@2019-07-01' = [for i in range(0, SessionHostCount): if(DisaStigCompliance) {
  name: '${VmName}${padLeft((i + SessionHostIndex), 3, '0')}/DSC'
  location: Location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.77'
    autoUpgradeMinorVersion: true
    protectedSettings: {
      Items: {
        registrationKeyPrivate: DisaStigCompliance ? listKeys(resourceId(ManagementResourceGroup, 'Microsoft.Automation/automationAccounts', AutomationAccountName), '2018-06-30').Keys[0].value : null
      }
    }
    settings: {
      Properties: [
        {
          Name: 'RegistrationKey'
          Value: {
            UserName: 'PLACEHOLDER_DONOTUSE'
            Password: 'PrivateSettingsRef:registrationKeyPrivate'
          }
          TypeName: 'System.Management.Automation.PSCredential'
        }
        {
          Name: 'RegistrationUrl'
          Value: DisaStigCompliance ? reference(resourceId(ManagementResourceGroup, 'Microsoft.Automation/automationAccounts', AutomationAccountName), '2018-06-30').registrationUrl : null
          TypeName: 'System.String'
        }
        {
          Name: 'NodeConfigurationName'
          Value: '${ConfigurationName}.localhost'
          TypeName: 'System.String'
        }
        {
          Name: 'ConfigurationMode'
          Value: 'ApplyandAutoCorrect'
          TypeName: 'System.String'
        }
        {
          Name: 'RebootNodeIfNeeded'
          Value: true
          TypeName: 'System.Boolean'
        }
        {
          Name: 'ActionAfterReboot'
          Value: 'ContinueConfiguration'
          TypeName: 'System.String'
        }
        {
          Name: 'Timestamp'
          Value: Timestamp
          TypeName: 'System.String'
        }
      ]
    }
  }
  dependsOn: [
    extension_AzureDiskEncryption
  ]
}]
