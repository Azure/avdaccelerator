
metadata name = 'AVD AMBA alerts'
metadata description = 'This module deploys avd amba alerts'
metadata owner = 'Azure/avdaccelerator'

targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@sys.description('Location where to deploy AVD management plane.')
param location string

@sys.description('AVD workload subscription ID, multiple subscriptions scenario.')
param subscriptionId string

@sys.description('create new Azure log analytics workspace.')
param deployAlaWorkspace bool

@sys.description('Exisintg Azure log analytics workspace resource.')
param alaWorkspaceId string = ''

@sys.description('AVD Resource Group Name for monitoring resources.')
param monitoringRgName string

@sys.description('AVD Resource Group Name for compute resources.')
param computeObjectsRgName string

@description('Location of needed scripts to deploy solution.')
param artifactsLocation string = 'https://raw.githubusercontent.com/Azure/azure-monitor-baseline-alerts/main/patterns/avd/scripts/'

@description('SaS token if needed for script location.')
@secure()
param artifactsLocationSasToken string = ''

@description('Telemetry Opt-Out') // Change this to true to opt out of Microsoft Telemetry
param optoutTelemetry bool = false

@sys.description('The name of the resource group to deploy. (Default: AVD1)')
param alertNamePrefix string = 'AVD'

@description('Determine if you would like to set all deployed alerts to auto-resolve.')
param autoResolveAlert bool = true

@description('The Distribution Group that will receive email alerts for AVD.')
param distributionGroup string

@description('First car of deployment type')
param deploymentEnvironment string

@description('name of host pool')
param hostPoolName string

@description('the id of the log analytics workspace')
param avdAlaWorkspaceId string

@description('resource ID of the host pool')
param hostPoolResourceID string

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

var rgResourceId = resourceId('Microsoft.Resources/resourceGroups', computeObjectsRgName)

@description('Array that has the host pool and resource group IDs')
var hostPoolInfo = [
  {
      colHostPoolName: hostPoolResourceID
      colVMResGroup: rgResourceId
      
  }
]

var HostPoolResourceIDArray = [hostPoolResourceID]


// Calling AMBA for AVD alerts
module alerting '../../../../azure-monitor-baseline-alerts/patterns/avd/templates/deploy.bicep' = { 
  name: 'Alerting-${time}'
  params: {
    _ArtifactsLocation: artifactsLocation
    _ArtifactsLocationSasToken: artifactsLocationSasToken
    optoutTelemetry: optoutTelemetry
    AlertNamePrefix: alertNamePrefix
    DistributionGroup: distributionGroup
    LogAnalyticsWorkspaceResourceId: avdAlaWorkspaceId
    ResourceGroupName: monitoringRgName
    ResourceGroupStatus: 'Existing'
    AllResourcesSameRG: false
    AutoResolveAlert: autoResolveAlert
    Environment: deploymentEnvironment
    Location: location
    AVDResourceGroupId: rgResourceId
    HostPools: HostPoolResourceIDArray
    HostPoolInfo: hostPoolInfo
    Tags: tags



  //  change path to link to actual AMBA repo

  // todo remove extra tags section and use default tags from other sectiosn

   // HostPoolInfo: ('Array of objects with the Resource ID for colHostPoolName and colVMresGroup for each Host Pool.'
   // HostPools: 'Host Pool Resource IDs (array)' (just the host pool resource ID in an array of one)
   
   // AVDResourceGroupId: (I think RG of session hosts )

  }
 
}

