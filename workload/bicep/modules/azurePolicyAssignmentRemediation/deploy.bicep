targetScope = 'resourceGroup'

// ========== //
// Parameters //
// ========== //

@sys.description('Location where to deploy compute services.')
param deploymentName string

@sys.description('AVD workload subscription ID, multiple subscriptions scenario.')
param policyAssignmentId string

// =========== //
// Variable declaration //
// =========== //

// =========== //
// Deployments //
// =========== //
// call on the keyvault.

// Policy Remediation Task for Zero Trust.
resource ztPolicyComputeRemediationTask 'Microsoft.PolicyInsights/remediations@2021-10-01' = {
    name: deploymentName
    properties: {
        failureThreshold: {
            percentage: 1
        }
        parallelDeployments: 10
        policyAssignmentId: policyAssignmentId
        resourceCount: 500
    }
    dependsOn: []
}
