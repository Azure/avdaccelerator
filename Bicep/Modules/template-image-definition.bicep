param templateSpecName string
param templateSpecDisplayName string
param location string = resourceGroup().location
param templateSpecVersion string = '1.0'
param managedIdentityId string

@secure()
param scriptUri string = ''
param imageId string
param buildDefinition object
param imageRegions array

resource templateSpec 'Microsoft.Resources/templateSpecs@2021-05-01' = {
  name: templateSpecName
  location: location
  properties: {
    displayName: templateSpecDisplayName
  }
  tags: {}
}

resource templateSpec_version 'Microsoft.Resources/templateSpecs/versions@2021-05-01' = {
  parent: templateSpec
  name: templateSpecVersion
  location: location
  properties: {
    mainTemplate: {
        '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
        contentVersion: '1.0.0.0'
        parameters: {
          scriptUri: {
            type: 'secureString'
          }
          imageRegions: {
            type: 'array'
            defaultValue: imageRegions
          }
          imageId: {
            type: 'string'
            defaultValue: imageId
          }
          managedIdentityId: {
            type: 'string'
            defaultValue: managedIdentityId
            
          }
          buildDefinition: {
            type: 'object'
            defaultValue: buildDefinition
          }
        }
        resources: [
          {
            type: 'Microsoft.VirtualMachineImages/imageTemplates'
            apiVersion: '2020-02-14'
            name: '[parameters(\'buildDefinition\').name]'
            location: '[resourceGroup().location]'
            identity: {
              type: 'UserAssigned'
              userAssignedIdentities: {
                '[parameters(\'managedIdentityId\')]': {}
              }
            }
            properties: {
              buildTimeoutInMinutes: 120
              source: {
                type: 'PlatformImage'
                publisher: '[parameters(\'buildDefinition\').publisher]'
                offer: '[parameters(\'buildDefinition\').offer]'
                sku: '[parameters(\'buildDefinition\').sku]'
                version: 'latest'
              }
              customize: [
                {
                  type: 'PowerShell'
                  name: 'Install and Configure'
                  scriptUri: '[parameters(\'scriptUri\')]'
                }
                {
                  type: 'WindowsUpdate'
                  searchCriteria: 'IsInstalled=0'
                  filters: [
                    'exclude:$_.Title -like \'*Preview*\''
                    'include:$true'
                  ]
                  updateLimit: 45
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
                  replicationRegions: '[parameters(\'imageRegions\')]'
                  galleryImageId: '[parameters(\'imageId\')]'
                }
              ]
            }
          }
        ]
    }
  }
  tags: {}
}
