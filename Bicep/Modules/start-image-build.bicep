param name string
param location string = resourceGroup().location
param imageId string
param time string = utcNow('yyyy-MM-ddTHH:mm:ssZ')
param identityId string

resource script 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: name
  location: location
  kind: 'AzurePowerShell'
  identity: {
    userAssignedIdentities: {
      '${identityId}': {}
    }
    type: 'UserAssigned'
  }
  properties: {
    azPowerShellVersion: '6.0'
    retentionInterval: 'P1D'
    forceUpdateTag: time
    timeout: 'PT15M'
    arguments: '-imageId ${imageId}'
    scriptContent: '''
      param(
        [string] [Parameter(Mandatory=$true)] $imageId
        )

      Invoke-AzResourceAction -ResourceId $imageId -ApiVersion "2021-10-01" -Action Run -Force
      
    '''
  }
}
