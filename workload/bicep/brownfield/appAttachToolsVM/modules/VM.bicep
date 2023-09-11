param AdminUserName string
@secure()
param AdminPassword string
param Location string
param OSoffer string
param OSVersion string
param PostDeployScriptURI string
param UsePublicIP bool
param VMDiskType string
param VMName string
param VMSize string
param VMSubResId string


var IPConfig = UsePublicIP ? {
  name: 'ipconfig1'
  subnetResourceId: VMSubResId
  pipConfiguration:  {
    publicIpNameSuffix: '-pip-01'
    deleteOption: 'Delete'
  }
} : {
  name: 'ipconfig1'
  subnetResourceId: VMSubResId
}


module virtualMachine '../../../../../carml/1.3.0/Microsoft.Compute/virtualMachines/deploy.bicep' = {
  name: 'c_${VMName}_DeployAndConfig'
  params: {
    name: VMName
    location: Location
    adminUsername: AdminUserName
    adminPassword: AdminPassword
    secureBootEnabled: true
    securityType: 'TrustedLaunch'
    encryptionAtHost: false
    vTpmEnabled: true
    imageReference: {
      publisher: 'MicrosoftWindowsDesktop'
      offer: OSoffer
      sku: OSVersion
      version: 'latest'
    }
    nicConfigurations: [
      {
        nicSuffix: '${VMName}-nic-01'
        deleteOption: 'Delete'
        ipConfigurations: [ IPConfig ]
      }
    ]
    osDisk: {
      createOption: 'FromImage'
      deleteOption: 'Delete'
      managedDisk: {
        storageAccountType: VMDiskType
      }
      diskSizeGB: 127
    }
    osType: 'Windows'
    vmSize: VMSize
    extensionCustomScriptConfig: {
      enabled: true
      fileData: [
        {
          uri: '${PostDeployScriptURI}AppAttachVMConfig.ps1'
        }
      ]
    }
    extensionCustomScriptProtectedSetting: {
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File AppAttachVMConfig.ps1 -VMUserName ${AdminUserName} -VMUserPassword ${AdminPassword} -PostDeployScriptURI ${PostDeployScriptURI}'
    }
  }
}
