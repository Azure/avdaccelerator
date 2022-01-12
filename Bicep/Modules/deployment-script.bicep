param name string
param location string = resourceGroup().location
param scriptData string
param storageAccountName string
param storageAccountKey string

resource script 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: name
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: 'PT1H'
    retentionInterval: 'P1D'
    scriptContent: scriptData
    storageAccountSettings: {
      storageAccountName: storageAccountName
      storageAccountKey:storageAccountKey
    }
  }
}

output scriptId string = script.id
