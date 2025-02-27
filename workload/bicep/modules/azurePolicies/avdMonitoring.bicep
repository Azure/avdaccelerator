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
param dataCollectionRuleId string

@sys.description('AVD Resource Group Name for the compute resources.')
param computeObjectsRgName string

@sys.description('AVD Resource Group Name for the service objects.')
param serviceObjectsRgName string

@sys.description('AVD Resource Group Name for the network resources.')
param networkObjectsRgName string

@sys.description('AVD Resource Group Name for the storage resources.')
param storageObjectsRgName string

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
// Target RGs for policy assignment
var varComputeServObjRgs = [
  {
    rgName: computeObjectsRgName
  }
  {
    rgName: serviceObjectsRgName
  }
]
var varNetworkObjRgs = !empty(networkObjectsRgName) ? [
  {
    rgName: networkObjectsRgName
  }
] : []
var varStorageObjRgs = !empty(storageObjectsRgName) ? [
  {
    rgName: storageObjectsRgName
  }
] : []
var varPolicyAssignmentRgs = union(varComputeServObjRgs, varNetworkObjRgs, varStorageObjRgs)
var varAvdMonitoringPolicies = [
  {
    definitionId: '/providers/Microsoft.Authorization/policyDefinitions/17b3de92-f710-4cf4-aa55-0e7859f1ed7b'
    // definitionParameters: {
      listOfImageIdToInclude: {
        value: []
      }
      effect: {
        value: 'Modify'
      }
    // }
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
        value: '*'
      }
      logAnalytics: {
        value: alaWorkspaceId
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
        value: '*'
      }
      logAnalytics: {
        value: alaWorkspaceId
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
        value: '*'
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
        value: '*'
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
        value: '*'
      }
      logAnalytics: {
        value: alaWorkspaceId
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
module policySetDefinitions './policySetDefinitionsSubscriptions.bicep' = {
  scope: subscription('${subscriptionId}')
  name: 'Policy-Set-Definition-${time}'
  params: {
    name: 'AVD-Monitoring-Policy-Set'
    description: 'AVD Monitoring Policy Set'
    displayName: 'AVD Monitoring Policy Set'
    metadata: {
      category: 'AVD Monitoring'
      version: '1.0.0'
    }
    identity: 'SystemAssigned'

    parameters: varCustomPolicySetDefinitions.libSetDefinition.properties.parameters
    policyDefinitions: [for policySetDef in varCustomPolicySetDefinitions.libSetChildDefinitions: {
      policyDefinitionReferenceId: policySetDef.definitionReferenceId
      policyDefinitionId: policySetDef.definitionId
      parameters: policySetDef.definitionParameters
    }]
    policyDefinitionGroups: []
  }
  dependsOn: [
    policyDefinitions
  ]
}

// Policy set assignment.
module policySetAssignment '../../../../avm/1.0.0/ptn/authorization/policy-assignment/modules/resource-group.bicep' = [for policyAssignmentRg in varPolicyAssignmentRgs: {
  scope: resourceGroup('${subscriptionId}', '${policyAssignmentRg.rgName}')
  name: 'Policy-Set-Assignment-${time}'
  params: {
    location: location
    name: varCustomPolicySetDefinitions.libSetDefinition.name
    description: varCustomPolicySetDefinitions.libSetDefinition.properties.description
    displayName: varCustomPolicySetDefinitions.libSetDefinition.properties.displayName
    metadata: varCustomPolicySetDefinitions.libSetDefinition.properties.metadata
    identity: 'SystemAssigned'
    roleDefinitionIds: [
      '/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
      '/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
    ]
    parameters: {
      logAnalytics: {
        value: alaWorkspaceId
      }
    }
    policyDefinitionId: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/policySetDefinitions/policy-set-deploy-avd-diagnostics-to-log-analytics'
  }
  dependsOn: [
    policySetDefinitions
  ]
}]

// Policy set remediation.
module policySetRemediation '../../../../avm/1.0.0/ptn/policy-insights/remediation/modules/resource-group.bicep' = [for (policyAssignmentRg, i) in varPolicyAssignmentRgs: {
  scope: resourceGroup('${subscriptionId}', '${policyAssignmentRg.rgName}')
  name: 'Remm-Diag-${varCustomPolicySetDefinitions.deploymentName}-${i}'
  params: {
    name: '${varCustomPolicySetDefinitions.deploymentName}-${i}'
    policyAssignmentId: policySetAssignment[i].outputs.resourceId
}
}]

// =========== //
// Outputs     //
// =========== //
