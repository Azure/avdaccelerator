param computeGalleryName string
param imageDefinitionName string
param imageDefinitionIsAcceleratedNetworkSupported bool
param imageDefinitionIsHibernateSupported bool
param imageDefinitionSecurityType string
param imageOffer string
param imagePublisher string
param imageSku string
param location string
param tags object

resource gallery 'Microsoft.Compute/galleries@2022-01-03' = {
  name: computeGalleryName
  location: location
  tags: tags[?'Microsoft.Compute/galleries'] ?? {}
}

resource image 'Microsoft.Compute/galleries/images@2022-01-03' = {
  parent: gallery
  name: imageDefinitionName
  location: location
  tags: tags[?'Microsoft.Compute/galleries'] ?? {}
  properties: {
    osType: 'Windows'
    osState: 'Generalized'
    hyperVGeneration: contains(imageSku, '-g2') || contains(imageSku, 'win11-') ? 'V2' : 'V1'
    identifier: {
      publisher: imagePublisher
      offer: imageOffer
      sku: imageSku
    }
    features: imageDefinitionSecurityType == 'Standard'
      ? null
      : [
          {
            name: 'SecurityType'
            value: imageDefinitionSecurityType
          }
          {
            name: 'IsAcceleratedNetworkSupported'
            value: string(imageDefinitionIsAcceleratedNetworkSupported)
          }
          {
            name: 'IsHibernateSupported'
            value: string(imageDefinitionIsHibernateSupported)
          }
        ]
  }
}

output imageDefinitionResourceId string = image.id
