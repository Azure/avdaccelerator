targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@description('AVD workload subscription ID, multiple subscriptions scenario.')
param subscriptionId string

@description('Location where to deploy services.')
param location string

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
// Policy Set/Initiative Definition Parameter Variables

// This variable contains a number of objects that load in the custom Azure Policy Defintions that are provided as part of the ESLZ/ALZ reference implementation. 
var varCustomPolicyDefinitions = [
  {
    name: 'policy-definition-es-deploy-amd-gpu-driver'
    deploymentName: 'AMD-Policy'
    displayName: 'Custom - Deploy AMD GPU Driver Extension'
    libDefinition: json(loadTextContent('../../../../policies/gpu/policyDefinitions/policy-definition-es-deploy-amd-gpu-driver.json'))
  }
  {
    name: 'policy-definition-es-deploy-nvidia-gpu-driver'
    deploymentName: 'NVIDIA-Policy'
    displayName: 'Custom - Deploy Nvidia GPU Driver Extension'
    libDefinition: json(loadTextContent('../../../../policies/gpu/policyDefinitions/policy-definition-es-deploy-nvidia-gpu-driver.json'))
  }
]

// =========== //
// Deployments //
// =========== //

module policyDefinitions '../../../../../carml/1.3.0/Microsoft.Authorization/policyDefinitions/subscription/deploy.bicep' = [for customPolicyDefinition in varCustomPolicyDefinitions: {
  scope: subscription('${subscriptionId}')
  name: '${customPolicyDefinition.libDefinition.deploymentName}-${time}'
  //name: customPolicyDefinition.libDefinition.properties.displayName
  params: {
    location: location
    name: customPolicyDefinition.name
    displayName: customPolicyDefinition.libDefinition.properties.displayName
    metadata: customPolicyDefinition.libDefinition.properties.metadata
    mode: customPolicyDefinition.libDefinition.properties.mode
    parameters: customPolicyDefinition.libDefinition.properties.parameters
    policyRule: customPolicyDefinition.libDefinition.properties.policyRule
  }
}]


module gpuPolicyAssignment '../../../../../carml/1.3.0/Microsoft.Authorization/policyAssignments/subscription/deploy.bicep' = [for (policy, i) in varCustomPolicyDefinitions: {
  name: 'polassign_${policy.name}'
  params: {
    name: policy.libDefinition.properties.displayName
    location: location
    policyDefinitionId: policyDefinitions[i].outputs.resourceId
  }
  }]


