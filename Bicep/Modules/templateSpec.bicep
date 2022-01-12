param templateSpecName string
param templateSpecDisplayName string
param location string = resourceGroup().location
param templateSpecVersion string = '1.0'
param armTemplate object

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
    mainTemplate: armTemplate
  }
  tags: {}
}
