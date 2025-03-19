targetScope = 'resourceGroup'

// ========== //
// Parameters //
// ========== //

param vmNames array = []
param location string = resourceGroup().location
param storageAccountResourceId string
@allowed([1, 2])
param storageAccountKey int
param timeStamp string = utcNow('yyyyMMddHHmm')

// =========== //
// Variable declaration //
// =========== //

var varKeyIndex = storageAccountKey - 1

// =========== //
// Deployments //
// =========== //

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
    name: last(split(storageAccountResourceId, '/'))
    scope: resourceGroup(split(storageAccountResourceId, '/')[2], split(storageAccountResourceId, '/')[4])
}

resource vms 'Microsoft.Compute/virtualMachines@2024-03-01' existing = [for (vm, i) in vmNames: {
    name: vm
    scope: resourceGroup()
}]

resource runCommand 'Microsoft.Compute/virtualMachines/runCommands@2023-09-01' = [for (vm, i) in vmNames: {
    location: location
    name: 'RunCommand-${vm}-${timeStamp}'
    
    parent: vms[i]
    properties: {
        source: {
            script: '''
param (
    [string]$StorageAccountName,
    [string]$StorageAccountSuffix,
    [string]$StorageAccountKey
)

Start-Process -FilePath 'cmdkey.exe' -ArgumentList "/add:$($StorageAccountName).file.$($StorageAccountSuffix) /user:localhost\$($StorageAccountName) /pass:$($StorageAccountKey)" -NoNewWindow -Wait
            '''
        }

        protectedParameters: [
            {
                name: 'StorageAccountName'
                value: last(split(storageAccountResourceId, '/'))
            }
            {
                name: 'StorageAccountSuffix'
                value: environment().suffixes.storage
            }
            {
                name: 'StorageAccountKey'
                value: storageAccount.listKeys().keys[varKeyIndex].value
            }
        ]
        timeoutInSeconds: 30
        treatFailureAsDeploymentFailure: true
    }
}]
