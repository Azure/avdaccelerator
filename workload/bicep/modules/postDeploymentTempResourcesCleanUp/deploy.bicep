// ========== //
// Parameters //
// ========== //

@description('Location where to deploy compute services.')
param location string

@description('Location for the AVD agent installation package.')
param baseScriptUri string

@description('Azure cloud.')
param azureCloudName string

@description('Virtual machine name to deploy the DSC extension to.')
param managementVmName string

@description('Script file name.')
param scriptFile string

@description('DSC package location.')
param dscAgentPackageLocation string

@description('Subscription ID.')
param subscriptionId string

@description('Service objects resource group name.')
param serviceObjectsRgName string

@description('Compute objects resource group name.')
param computeObjectsRgName string

@description('Storage objects resource group name.')
param storageObjectsRgName string

@description('Network objects resource group name.')
param networkObjectsRgName string

@description('Monitoring objects resource group name.')
param monitoringObjectsRgName string

// =========== //
// Variable declaration //
// =========== //

var varPostDeploymentTempResuorcesCleanUpScriptArgs = '-dscPath ${dscAgentPackageLocation} -subscriptionId ${subscriptionId} -serviceObjectsRgName ${serviceObjectsRgName} -computeObjectsRgName ${computeObjectsRgName} -storageObjectsRgName ${storageObjectsRgName} -networkObjectsRgName ${networkObjectsRgName} -monitoringObjectsRgName ${monitoringObjectsRgName} -azureCloudEnvironment ${azureCloudName} -managmentVmName ${managementVmName} -Verbose'

// =========== //
// Deployments //
// =========== //

// Clean up deployment temporary resources.
resource deploymentCleanUp 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  name: '${managementVmName}/DeploymentCleanUp'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: false
    settings: {}
    protectedSettings: {
      fileUris: array(baseScriptUri)
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File ${scriptFile} ${varPostDeploymentTempResuorcesCleanUpScriptArgs}'
    }
  }
}
