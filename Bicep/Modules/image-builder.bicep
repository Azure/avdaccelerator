param inlineScripts array
param imageRegions array
param imageName string
param imageId string 
param managedIdentityId string

param publisher string
param offer string
param sku string

resource aib 'Microsoft.VirtualMachineImages/imageTemplates@2021-10-01' = {
  name: imageName
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
      publisher: publisher
      offer: offer
      sku: sku
      version: 'latest'
    }
    customize: [
      {
        type: 'PowerShell'
        name: 'Install Software'
        inline: inlineScripts
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
    vmProfile: {
      osDiskSizeGB: 128
      vmSize: 'Standard_D2s_v4'
    }
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
