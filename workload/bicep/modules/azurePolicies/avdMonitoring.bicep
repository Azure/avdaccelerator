targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@sys.description('Location where to deploy AVD management plane.')
param location string

@sys.description('AVD workload subscription ID, multiple subscriptions scenario.')
param subscriptionId string

@sys.description('Existing Azure log analytics workspace.')
param alaWorkspaceId string

@sys.description('Existing data collection rule.')
param dcrResourceId string

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var varAvdMonitoringPolicies = [
  {
    definitionId: '/providers/Microsoft.Authorization/policyDefinitions/17b3de92-f710-4cf4-aa55-0e7859f1ed7b'
    definitionParameters: {
      listOfImageIdToInclude: {
        value: []
      }
      effect: {
        value: 'Modify'
      }
    }
  }
  {
    definitionId: '/providers/Microsoft.Authorization/policyDefinitions/3aa571d2-2e4f-4e92-8a30-4312860efbe1'
    definitionParameters: {
      diagnosticSettingName: {
        value: 'setByPolicy-AVD-MonitoringPolicies'
      }
      Effect: {
        value: 'DeployIfNotExists'
      }
      resourceLocationList: {
        value: ['*']
      }
      logAnalytics: {
        value: ''
      }
    }
  }
  {
    definitionId: '/providers/Microsoft.Authorization/policyDefinitions/8ea88471-98e1-47e4-9f63-838c990ba2f4'
    definitionParameters: {
      diagnosticSettingName: {
        value: 'setByPolicy-AVD-MonitoringPolicies'
      }
      Effect: {
        value: 'DeployIfNotExists'
      }
      resourceLocationList: {
        value: ['*']
      }
      logAnalytics: {
        value: ''
      }
      categoryGroup: {
        value: 'allLogs'
      }
    }
  }
  {
    definitionId: '/providers/Microsoft.Authorization/policyDefinitions/ca817e41-e85a-4783-bc7f-dc532d36235e'
    definitionParameters: {
      scopeToSupportedImages: {
        value: true
      }
      Effect: {
        value: 'DeployIfNotExists'
      }
      listOfWindowsImageIdToInclude: {
        value: []
      }
    }
  }
  {
    definitionId: '/providers/Microsoft.Authorization/policyDefinitions/6bb23bce-54ea-4d3d-b07d-628ce0f2e4e3'
    definitionParameters: {
      diagnosticSettingName: {
        value: 'setByPolicy-AVD-MonitoringPolicies'
      }
      Effect: {
        value: 'DeployIfNotExists'
      }
      resourceLocationList: {
        value: ['*']
      }
      logAnalytics: {
        value: ''
      }
    }
  }
  {
    definitionId: '/providers/Microsoft.Authorization/policyDefinitions/eab1f514-22e3-42e3-9a1f-e1dc9199355c'
    definitionParameters: {
      scopeToSupportedImages: {
        value: true
      }
      Effect: {
        value: 'DeployIfNotExists'
      }
      listOfWindowsImageIdToInclude: {
        value: []
      }
      dcrResourceId: {
        value: ''
      }
      resourceType: {
        value: 'Microsoft.Insights/dataCollectionRules'
      }
    }
  }
  {
    definitionId: '/providers/Microsoft.Authorization/policyDefinitions/6f95136f-6544-4722-a354-25a18ddb18a7'
    definitionParameters: {
      diagnosticSettingName: {
        value: 'setByPolicy-AVD-MonitoringPolicies'
      }
      Effect: {
        value: 'DeployIfNotExists'
      }
      resourceLocationList: {
        value: ['*']
      }
      logAnalytics: {
        value: ''
      }
    }
  }
  {
    definitionId: '/providers/Microsoft.Authorization/policyDefinitions/89ca9cc7-25cd-4d53-97ba-445ca7a1f222'
    definitionParameters: {
      enableProcessesAndDependencies: {
        value: true
      }
      Effect: {
        value: 'DeployIfNotExists'
      }
      scopeToSupportedImages: {
        value: true
      }
    }
  }
]

// =========== //
// Deployments //
// =========== //

// Policy set definition.
module policySetDefinition './policySetDefinitionsSubscriptions.bicep' = {
  scope: subscription(subscriptionId)
  name: 'Policy-Set-Definition-${time}'
  params: {
    name: 'AVD-Monitoring-Policy-Set'
    description: 'AVD Monitoring Policy Set'
    displayName: 'AVD Monitoring Policy Set'
    metadata: {
      category: 'AVD Monitoring'
      version: '1.0.0'
    }
    policyDefinitions: [
      for policy in varAvdMonitoringPolicies: {
        policyDefinitionId: policy.definitionId
        parameters: policy.definitionParameters
      }
    ]
    parameters: {
      logAnalytics: {
        type: 'String'
        defaultValue: alaWorkspaceId
      }
      dcrResourceId: {
        type: 'String'
        defaultValue: dcrResourceId
      }
    }
  }
}

// // Policy set assignment.
// module policySetAssignment '../../../../avm/1.0.0/ptn/authorization/policy-assignment/modules/subscription.bicep' = {
//   scope: subscription('${subscriptionId}')
//   name: 'Policy-Set-Assignment-${time}'
//   params: {
//     location: location
//     name: 'Custom - Deploy Monitoring to AVD Landing Zone'
//     description: 'Custom - Deploy Monitoring to AVD Landing Zone'
//     displayName: 'Custom - Deploy Monitoring to AVD Landing Zone'
//     metadata: {
//       category: 'AVD Monitoring'
//       version: '1.0.0'
//     }
//     identity: 'SystemAssigned'
//     parameters: {
//       logAnalytics: {
//         value: alaWorkspaceId
//       }
//       dcrResourceId: {
//         value: dcrResourceId
//       }
//     }
//     policyDefinitionId: policySetDefinition.outputs.resourceId
//   }
// }

// // Policy set remediation.
// module policySetRemediation '../../../../avm/1.0.0/ptn/policy-insights/remediation/modules/resource-group.bicep' = [for (policyAssignmentRg, i) in varPolicyAssignmentRgs: {
//   scope: resourceGroup('${subscriptionId}', '${policyAssignmentRg.rgName}')
//   name: 'Remm-Diag-${varCustomPolicySetDefinitions.deploymentName}-${i}'
//   params: {
//     name: '${varCustomPolicySetDefinitions.deploymentName}-${i}'
//     policyAssignmentId: policySetAssignment[i].outputs.resourceId
// }
// }]

// =========== //
// Outputs     //
// =========== //
