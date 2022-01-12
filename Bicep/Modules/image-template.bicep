@secure()
param scriptUri string
param imageRegions array
param imageId string
param managedIdentityId string
param subnetId string = ''

param keyVaultName string
param certificateName string = ''

param buildDefinition object

param vnetInject bool = false
param installSslCertificate bool = false

var vnetInjectTrue = {
  osDiskSizeGB: 128
  vmSize: 'Standard_D2s_v4'
  vnetConfig: {
    subnetId: subnetId
  }
  userAssignedIdentities: [
    managedIdentityId
  ]
}

var vnetInjectFalse = {
  osDiskSizeGB: 128
  vmSize: 'Standard_D2s_v4'
  userAssignedIdentities: [
    managedIdentityId
  ]
}

var installSSLcert = [
  '$vaultUrl = "https://${keyVaultName}.vault.azure.net"'
  '$certName = "${certificateName}"'
  '$localPath = "C:\\temp"'

  '$Response = Invoke-RestMethod -Uri \'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net\' -Method GET -Headers @{Metadata="true"}'
  '$KeyVaultToken = $Response.access_token'
  'if ((Test-Path -Path $localPath) -eq $false) { New-Item -ItemType Directory -Path $localPath }'
  '$uri = $vaultUrl + "/certificates/" + $certName + "?api-version=2016-10-01"'
  '$cert = Invoke-RestMethod -Uri $uri -Method GET -Headers @{Authorization="Bearer $KeyVaultToken"}'
  '$cert.cer | New-Item -Type File -Name $certName.cer -Path $localPath'
  'Import-Certificate -FilePath $localPath\\$certName.cer -CertStoreLocation Cert:\\LocalMachine\\Root\\'  
]

var doNothing = [
  'Write-Host "Nothing to install"'
]

resource aib 'Microsoft.VirtualMachineImages/imageTemplates@2021-10-01' = {
  name: buildDefinition.name
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
        '${managedIdentityId}' :{}
    }
  }
  properties: {
    buildTimeoutInMinutes: 120
    source: {
      type: 'PlatformImage'
      publisher: buildDefinition.publisher
      offer: buildDefinition.offer
      sku: buildDefinition.sku
      version: 'latest'
    }
    customize: [
      {
        type: 'PowerShell'
        name: 'Install SSL certificate'
        runAsSystem: true
        runElevated: true
        inline: installSslCertificate ? installSSLcert : doNothing
      }
      {
        type: 'PowerShell'
        name: 'Install and Configure'
        runElevated: true
        runAsSystem: true
        scriptUri: scriptUri
      }
      {
        type: 'WindowsRestart'
        restartCheckCommand: 'write-host \'Restarting after tuning script\''
        restartTimeout: '5m'
    }
      {
        type: 'PowerShell'
        runElevated: true
        runAsSystem: true
        name: 'DeprovisioningScript'
        inline: [
          '((Get-Content -path C:\\DeprovisioningScript.ps1 -Raw) -replace \'Sysprep.exe /oobe /generalize /quiet /quit\',\'Sysprep.exe /oobe /generalize /quit /mode:vm\') | Set-Content -Path C:\\DeprovisioningScript.ps1'
         ]
      }
      {
        type: 'WindowsUpdate'
        searchCriteria: 'IsInstalled=0'
        filters: [
            'exclude:$_.Title -like "*Preview*"'
            'include:$true'
                    ]
        'updateLimit': 45
    }
    ]
    vmProfile: vnetInject ? vnetInjectTrue : vnetInjectFalse
    distribute: [
      {
        type: 'SharedImage'
        runOutputName: 'myimage'
        replicationRegions: imageRegions
        galleryImageId: imageId
      }
    ]
  }
}

output aibImageId string = aib.id
