param AdminUserName string
@secure()
param AdminPassword string
param Location string
param NIC string
param OSoffer string
param OSVersion string
param PostDeployScriptURI string
param Timestamp string
param VMDiskType string
param VMName string
param VMSize string


resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: VMName
  location: Location
  properties: {
    hardwareProfile: {
      vmSize: VMSize
    }
    osProfile: {
      computerName: VMName
      adminUsername: AdminUserName
      adminPassword: AdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: OSoffer
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: VMDiskType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', NIC)
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}

resource configVm 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
  name: 'VmExtension-PS-InstallConfigAppAttachTools'
  location: Location
  parent: vm
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    settings: {
      fileUris: [ '${PostDeployScriptURI}AppAttachVMConfig.ps1' ]
      timestamp: Timestamp
    }
    protectedSettings: {
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File AppAttachVMConfig.ps1 -VMUserName ${AdminUserName} -VMUserPassword ${AdminPassword} -PostDeployScriptURI ${PostDeployScriptURI}'
    }
  }
}
