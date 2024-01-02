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

var PostDeployScriptURI = 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/scripts/appAttachToolsVM/'
var VNetSub = split(VNet.id, '/')[2]
var VNetRG = split(VNet.id, '/')[4]  
var VNetName = VNet.name
var KVLocalAdminSubId = adminPassUseKv ? split(adminPassKv.id, '/')[2] : ''
var KVLocalAdminRG = adminPassUseKv ? split(adminPassKv.id, '/')[4] : ''

resource kvVMPassword 'Microsoft.KeyVault/vaults@2023-02-01' existing = if(adminPassUseKv) {
  name: adminPassKv.name
  scope: resourceGroup(KVLocalAdminSubId, KVLocalAdminRG)
}

module vmDeploy './modules/VM.bicep' = {
  name: 'linked_${vmName}_Deployment'
  params: {   
    AdminUserName: adminUsername
    AdminPassword: adminPassUseKv ? kvVMPassword.getSecret(adminPassKvSecret) : adminPassword
    Location: location
    OSoffer: OSoffer
    OSVersion: OSVersion
    PostDeployScriptURI: PostDeployScriptURI
    UsePublicIP: publicIPAllowed
    VMDiskType: vmDiskType
    VMName: vmName
    VMSubResId: resourceId(VNetSub, VNetRG, 'Microsoft.VirtualNetwork/virtualNetworks/subnets', VNetName, SubnetName)
    VMSize: vmSize
  }
}

