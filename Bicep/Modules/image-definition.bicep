
param imageName string
param imageGalleryName string
param location string = resourceGroup().location
param osType string
param osState string
param offer string
param publisher string
param sku string

resource imageGallery 'Microsoft.Compute/galleries@2021-07-01' existing = {
  name: imageGalleryName
}

resource imageDef 'Microsoft.Compute/galleries/images@2021-07-01' = {
  name: imageName
  location: location
  parent: imageGallery
  properties: {
    osType: osType
    osState: osState
    identifier: {
      offer: offer
      publisher: publisher
      sku: sku
    }
  }
}

output imageId string = imageDef.id
