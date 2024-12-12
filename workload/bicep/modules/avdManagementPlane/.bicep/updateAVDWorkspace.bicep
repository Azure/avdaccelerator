targetScope = 'resourceGroup'
//targetScope = 'subscription'

@sys.description('Existing AVD workspace.')
param workSpaceName string

@sys.description('Existing properties')
param properties object

@sys.description('Location where to deploy AVD management plane.')
param location string

resource existingWorkspace 'Microsoft.DesktopVirtualization/workspaces@2023-11-01-preview' = {
  name: workSpaceName
  location: location
  properties: properties
}
