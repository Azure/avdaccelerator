param imageDefinitionPropertiesName object
param location string
param SIGname string
@description('Optional. OS type of the image to be created.')
@allowed([
  'Windows'
  'Linux'
])
param osType string = 'Windows'

@description('Optional. This property allows the user to specify whether the virtual machines created under this image are \'Generalized\' or \'Specialized\'.')
@allowed([
  'Generalized'
  'Specialized'
])
param osState string = 'Generalized'

@description('Optional. The hypervisor generation of the Virtual Machine. Applicable to OS disks only. - V1 or V2')
@allowed([
  'V1'
  'V2'
])
param hyperVGeneration string = 'V1'

@description('Optional. The name of the gallery Image Definition publisher.')
param publisher string = 'MicrosoftWindowsServer'

@description('Optional. The name of the gallery Image Definition offer.')
param offer string = 'WindowsServer'

@description('Optional. The name of the gallery Image Definition SKU.')
param sku string = '2019-Datacenter'

@description('Optional. The minimum number of the CPU cores recommended for this image.')
@minValue(1)
@maxValue(128)
param minRecommendedvCPUs int = 1

@description('Optional. The maximum number of the CPU cores recommended for this image.')
@minValue(1)
@maxValue(128)
param maxRecommendedvCPUs int = 4

@description('Optional. The minimum amount of RAM in GB recommended for this image.')
@minValue(1)
@maxValue(4000)
param minRecommendedMemory int = 4

@description('Optional. The maximum amount of RAM in GB recommended for this image.')
@minValue(1)
@maxValue(4000)
param maxRecommendedMemory int = 16

var ImageDefinitionName = '${SIGname}/${imageDefinitionPropertiesName}'

resource imageDefinition 'Microsoft.Compute/galleries/images@2020-09-30' = {
  name: ImageDefinitionName
  location: location
  properties: {
    osType: 'Windows'
    osState: 'Generalized'
    identifier: {
      publisher: publisher
      offer: offer
      sku: sku
    }
    recommended: {
      vCPUs: {
        min: minRecommendedvCPUs
        max: maxRecommendedvCPUs
      }
      memory: {
        min: minRecommendedMemory
        max: maxRecommendedMemory
      }
    }
    hyperVGeneration: hyperVGeneration
  }
}

@description('The resource group the image was deployed into')
output resourceGroupName string = resourceGroup().name

@description('The resource ID of the image')
output resourceId string = imageDefinition.id

@description('The name of the image')
output name string = imageDefinition.name
