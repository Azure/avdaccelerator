param deploymentScriptName string
param location string
param subnetName string
param tags object
param timestamp string
param userAssignedIdentityResourceId string
param virtualNetworkName string
param virtualNetworkResourceGroupName string


resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: deploymentScriptName
  location: location
  tags: tags[?'Microsoft.Resources/deploymentScripts'] ?? {}
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityResourceId}': {}
    }
  }
  properties: {
    arguments: '-Subnet ${subnetName} -VirtualNetwork ${virtualNetworkName} -ResourceGroup ${virtualNetworkResourceGroupName}'
    azPowerShellVersion: '9.4'
    cleanupPreference: 'Always'
    forceUpdateTag: timestamp
    retentionInterval: 'PT2H'
    scriptContent: 'Param([string]$ResourceGroup, [string]$Subnet, [string]$VirtualNetwork); $VNET = Get-AzVirtualNetwork -Name $VirtualNetwork -ResourceGroupName $ResourceGroup; ($VNET | Select-Object -ExpandProperty "Subnets" | Where-Object {$_.Name -eq $Subnet}).privateLinkServiceNetworkPolicies = "Disabled"; $VNET | Set-AzVirtualNetwork'
    timeout: 'PT30M'
  }
}
