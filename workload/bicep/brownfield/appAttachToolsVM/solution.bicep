@description('Username for the Virtual Machine.')
param adminUsername string = 'vmadmin'

@description('Keyvault Option for Local Admin Password.')
param adminPassUseKv bool = false

param adminPassKv object = {}
param adminPassKvSecret string = ''

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string = newGuid()

@description('Create the VM with a Public IP to access the Virtual Machine?')
param publicIPAllowed bool = false

@description('The Windows version for the VM.')
param OSoffer string

@description('The Windows build version for the VM.')
param OSVersion string = 'win11-22h2-ent'

@description('Size of the virtual machine.')
param vmDiskType string

@description('Size of the virtual machine.')
param vmSize string = 'Standard_D2s_v5'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the virtual machine. (must be 15 characters or less)')
@maxLength(15)
param vmName string = 'vmAppAttach01'

@description('Virtual Network to attach MSIX Tools VM to.')
param VNet object = {
  name: ''
  id: ''
  location: ''
  subscriptionName: ''
}

@description('Subnet to use for MSIX VM Tools VM.')
param SubnetName string


@description('Do not change. Used for deployment purposes only.')
param Timestamp string = utcNow('u')

var PostDeployScriptURI = 'https://github.com/Azure/avdaccelerator/blob/main/workload/scripts/appAttachToolsVM/'
var VNetSub = split(VNet.id, '/')[2]
var VNetRG = split(VNet.id, '/')[4]
var VNetName = VNet.name
var KVLocalAdminSubId = split(adminPassKv.id, '/')[2]
var KVLocalAdminRG = split(adminPassKv.id, '/')[4]

resource kvVMPassword 'Microsoft.KeyVault/vaults@2023-02-01' existing = if(adminPassUseKv) {
  name: adminPassKv.name
  scope: resourceGroup(KVLocalAdminSubId, KVLocalAdminRG)
}

resource pip 'Microsoft.Network/publicIPAddresses@2022-01-01' = if(publicIPAllowed) {
  name: 'pip-${vmName}'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: 'nic-${vmName}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId(VNetSub, VNetRG, 'Microsoft.VirtualNetwork/virtualNetworks/subnets', VNetName, SubnetName)
          }
          publicIPAddress: publicIPAllowed ? {
            id: pip.id
          } : null
        }
      }
    ]
  }
}

module vmDeploy './modules/VM.bicep' = {
  name: 'linked_VMDeployment-${guid(Timestamp)}'
  params: {   
    AdminUserName: adminUsername
    AdminPassword: adminPassUseKv ? kvVMPassword.getSecret(adminPassKvSecret) : adminPassword
     Location: location
    NIC: nic.name
    OSoffer: OSoffer
    OSVersion: OSVersion
    PostDeployScriptURI: PostDeployScriptURI
    Timestamp: Timestamp
    VMDiskType: vmDiskType
    VMName: vmName
    VMSize: vmSize
  }
}
