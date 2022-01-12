@maxLength(10)
param vmName string
param hostPoolId string
param hostPoolToken string
param tags object = {}
param location string = resourceGroup().location
param aadJoin bool = false
param count int = 1
param vnetId string
param subnetName string
param imageId string
param localAdminName string
param vmSize string = 'Standard_D2s_v4'
param licenseType string = 'Windows_Client'
param domainToJoin string
param domainUserName string
param ouPath string
param installNVidiaGPUDriver bool = false


var hostPoolName = split(hostPoolId, '/')[8]
var hostPoolRg = split(hostPoolId, '/')[4]

resource hostPoolEx 'Microsoft.DesktopVirtualization/hostPools@2021-07-12' existing = {
  name: hostPoolName
  scope: resourceGroup(hostPoolRg)
}

@secure()
param localAdminPassword string
@secure()
param domainJoinPassword string

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-05-01' = [for i in range(0, count): {
  name: 'nic-${vmName}-${i + 1}'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${vnetId}/subnets/${subnetName}'
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}]

resource sessionHost 'Microsoft.Compute/virtualMachines@2021-07-01' = [for i in range(0, count): {
  name: '${vmName}-${i + 1}'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    osProfile: {
      computerName: '${vmName}-${i + 1}'
      adminUsername: localAdminName
      adminPassword: localAdminPassword
    }
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        id: imageId
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    licenseType: licenseType
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: networkInterface[i].id
        }
      ]
    }
  }

  dependsOn: [
    networkInterface[i]
  ]
}]

// Run this if we are not Azure AD joining the session hosts
resource sessionHostDomainJoin 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = [for i in range(0, count): if (!aadJoin) {
  name: '${sessionHost[i].name}/JoinDomain'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      name: domainToJoin
      ouPath: ouPath
      user: domainUserName
      restart: true
      options: 3
    }
    protectedSettings: {
      password: domainJoinPassword
    }
  }

  dependsOn: [
    sessionHost[i]
  ]
}]

// Run this if we are Azure AD joining the session hosts - no intune support
resource sessionHostAADLogin 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = [for i in range(0, count): if (aadJoin) {
  name: '${sessionHost[i].name}/AADLoginForWindows'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: 'AADLoginForWindows'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
  }
}]

resource sessionHostAVDAgent 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = [for i in range(0, count): {
  name: '${sessionHost[i].name}/Microsoft.PowerShell.DSC'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.73'
    autoUpgradeMinorVersion: true
    settings: {
      modulesUrl: 'https://raw.githubusercontent.com/Azure/RDS-Templates/master/ARM-wvd-templates/DSC/Configuration.zip'
      configurationFunction: 'Configuration.ps1\\AddSessionHost'
      properties: {
        hostPoolName: hostPoolName
        registrationInfoToken: hostPoolToken
        aadJoin: aadJoin
      }
    }
  }

  dependsOn: [
    sessionHostDomainJoin[i]
  ]
}]

resource sessionHostGPUDriver 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = [for i in range(0, count): if (installNVidiaGPUDriver) {
  name: '${sessionHost[i].name}/InstallNvidiaGpuDriverWindows'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.HpcCompute'
    type: 'NvidiaGpuDriverWindows'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {}
  }
}]
