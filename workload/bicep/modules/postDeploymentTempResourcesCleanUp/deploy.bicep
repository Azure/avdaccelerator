// ========== //
// Parameters //
// ========== //

@sys.description('Location where to deploy compute services.')
param location string

@sys.description('Location for the AVD agent installation package.')
param baseScriptUri string

@sys.description('Azure cloud.')
param azureCloudName string

@sys.description('Virtual machine name to deploy the DSC extension to.')
param managementVmName string

@sys.description('Script file name.')
param scriptFile string

@sys.description('DSC package location.')
param dscAgentPackageLocation string

@sys.description('Subscription ID.')
param subscriptionId string

@sys.description('Service objects resource group name.')
param serviceObjectsRgName string

@sys.description('Compute objects resource group name.')
param computeObjectsRgName string

@sys.description('Storage objects resource group name.')
param storageObjectsRgName string

@sys.description('Network objects resource group name.')
param networkObjectsRgName string

@sys.description('Monitoring objects resource group name.')
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
