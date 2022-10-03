targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@description('Required. Location where to deploy AVD management plane.')
param avdManagementPlaneLocation string

@description('Required. AVD workload subscription ID, multiple subscriptions scenario.')
param avdWorkloadSubsId string

@description('Required. AVD Resource Group Name for monitoring resources.')
param avdMonitoringRgName string

@description('Required.  Azure Storage Account name.')
param stgAccountForFlowLogsName string

@description('Required. Exisintg Azure log analytics workspace.')
param alaWorkspaceId string

@description('Required. Existing Azure Storage account for NSG flow logs. (Default: )')
param stgAccountForFlowLogsId string = ''

@description('Required. Tags to be applied to resources')
param avdTags object

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
// Policy Set/Initiative Definition Parameter Variables

var varPolicySetDefinitionEsDeployAzurePolicyNetworkParameters = loadJsonContent('../../policies/networking/policy-sets/parameters/policy-set-definition-es-deploy-networking.parameters.json')

// This variable contains a number of objects that load in the custom Azure Policy Set/Initiative Defintions 
// This variable contains a number of objects that load in the custom Azure Policy Set/Initiative Defintions that are provided as part of the ESLZ/ALZ reference implementation - this is automatically created in the file 'infra-as-code\bicep\modules\policy\lib\policy_set_definitions\_policySetDefinitionsBicepInput.txt' via a GitHub action, that runs on a daily schedule, and is then manually copied into this variable.
var varCustomPolicySetDefinitions = {
  name: 'policy-set-deploy-networking'
  libSetDefinition: json(loadTextContent('../../policies/networking/policy-sets/policy-set-definition-es-deploy-networking.json'))
  libSetChildDefinitions: [
    {
      definitionReferenceId: 'AVDAppGroupDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-avd-application-group'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.AVDAppGroupDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    {
      definitionReferenceId: 'AVDHostPoolsDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-avd-host-pool'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.AVDHostPoolsDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    {
      definitionReferenceId: 'AVDScalingPlansDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-avd-scaling-plan'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.AVDScalingPlansDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    {
      definitionReferenceId: 'AVDWorkspaceDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-avd-workspace'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.AVDWorkspaceDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    {
      definitionReferenceId: 'NetworkSecurityGroupsDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-network-security-group'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.NetworkSecurityGroupsDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    {
      definitionReferenceId: 'NetworkNICDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-nic'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.NetworkNICDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    {
      definitionReferenceId: 'VirtualMachinesDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-virtual-machine'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.VirtualMachinesDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    {
      definitionReferenceId: 'VirtualNetworkDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-virtual-network'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.VirtualNetworkDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    {
      definitionReferenceId: 'AzureFilesDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-azure-files'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.AzureFilesDeployDiagnosticLogDeployLogAnalytics.parameters
    }
  ]
}


// =========== //
// Deployments //
// =========== //


// Storage account for NSG flow logs. If blank value passed - then to 

// Policy definitions.


// Policy set definition.


// Policy set assignment.

// =========== //
// Outputs     //
// =========== //
