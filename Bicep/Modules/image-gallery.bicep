param galleryName string
param location string = resourceGroup().location

resource imageGallery 'Microsoft.Compute/galleries@2021-07-01' = {
  name: galleryName
  location: location
}

output galleryId string = imageGallery.id
output galleryName string = imageGallery.name
