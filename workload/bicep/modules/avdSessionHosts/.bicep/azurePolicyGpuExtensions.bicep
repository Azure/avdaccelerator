targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@description('Location where to deploy compute services.')
param location string

@description('AVD workload subscription ID, multiple subscriptions scenario.')
param subscriptionId string

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
// Policy Set/Initiative Definition Parameter Variables

// This variable contains a number of objects that load in the custom Azure Policy Defintions that are provided as part of the ESLZ/ALZ reference implementation. 
var varCustomPolicyDefinitions = [
    {
      deploymentName: 'AMD-Policy'
      libDefinition: json(loadTextContent('../../../../policies/gpu/policyDefinitions/policy-definition-es-deploy-amd-gpu-driver.json'))
    }
    {
      deploymentName: 'Nvidia-Policy'
      libDefinition: json(loadTextContent('../../../../policies/gpu/policyDefinitions/policy-definition-es-deploy-nvidia-gpu-driver.json'))
    }
]
// =========== //
// Deployments //
// =========== //
// call on the keyvault.

// Policy Definition for GPU extensions.
module gpuPolicyDefinitions '../../../../../carml/1.3.0/Microsoft.Authorization/policyDefinitions/subscription/deploy.bicep' = [for customPolicyDefinition in varCustomPolicyDefinitions: {
    scope: subscription('${subscriptionId}')
    name: 'Policy-Defin-${customPolicyDefinition.deploymentName}-${time}'
    params: {
        description: customPolicyDefinition.libDefinition.properties.description
        displayName: customPolicyDefinition.libDefinition.properties.displayName
        location: location
        name: customPolicyDefinition.libDefinition.name
        metadata: customPolicyDefinition.libDefinition.properties.metadata
        mode: customPolicyDefinition.libDefinition.properties.mode
        parameters: customPolicyDefinition.libDefinition.properties.parameters
        policyRule: customPolicyDefinition.libDefinition.properties.policyRule
    }
}]

// Policy Assignment for GPU extensions.
module gpuPolicyAssignments '../../../../../carml/1.3.0/Microsoft.Authorization/policyAssignments/subscription/deploy.bicep' = [for (customPolicyDefinition, i) in varCustomPolicyDefinitions: {
    scope: subscription('${subscriptionId}')
    name: 'Policy-Assign-${customPolicyDefinition.deploymentName}-${time}' 
    params: {
        name: customPolicyDefinition.libDefinition.name
        displayName: customPolicyDefinition.libDefinition.properties.displayName
        description: customPolicyDefinition.libDefinition.properties.description
        identity: 'SystemAssigned'
        location: location
        policyDefinitionId: gpuPolicyDefinitions[i].outputs.resourceId
    }
}]

// Policy Remediation Task for GPU extensions.
resource gpuPolicyRemediationTask 'Microsoft.PolicyInsights/remediations@2021-10-01' = [for (customPolicyDefinition, i) in varCustomPolicyDefinitions: {
    name: 'Policy-Remed-${customPolicyDefinition.deploymentName}-${time}'
    properties: {
        failureThreshold: {
            percentage: 1
          }
          parallelDeployments: 10
          policyAssignmentId: gpuPolicyAssignments[i].outputs.resourceId
          resourceCount: 500
    }
}]

// =========== //
// Outputs //
// =========== //

