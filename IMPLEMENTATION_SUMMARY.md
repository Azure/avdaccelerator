# Resource Group Topology Feature - Implementation Summary

## Overview
This implementation adds a configurable resource group topology option to the AVD Landing Zone Accelerator, allowing customers to choose between Cloud Adoption Framework-aligned multi-RG topology or a simplified single-RG topology.

## Feature Request
- **Issue**: Selectable Single 'Resource Group' Topology
- **Problem**: Some customers prefer simpler RG layouts for operations/compliance, while the current multi-RG model is by design using Cloud Adoption Framework
- **Solution**: Added configurable topology choice with a safe, minimal-change implementation

## Implementation Details

### Core Changes

#### 1. New Parameters (deploy-baseline.bicep)
```bicep
// Line ~23-28
@allowed([
  'MultiResourceGroup' // CAF aligned topology
  'SingleResourceGroup' // Simplified topology
])
param resourceGroupTopology string = 'MultiResourceGroup' // Default maintains backward compatibility

// Line ~350-352
@maxLength(90)
param avdSingleResourceGroupCustomName string = 'rg-avd-app1-dev-use2'
```

#### 2. Conditional RG Name Logic
```bicep
// Creates a single RG name variable
var varSingleResourceGroupName = avdUseCustomNaming
  ? avdSingleResourceGroupCustomName
  : 'rg-avd-${varComputeStorageResourcesNamingStandard}'

// All RG name variables now check topology and use single RG name when appropriate
var varServiceObjectsRgName = resourceGroupTopology == 'SingleResourceGroup'
  ? varSingleResourceGroupName
  : (avdUseCustomNaming ? avdServiceObjectsRgCustomName : 'rg-avd-...')
```

#### 3. Conditional RG Deployments
```bicep
// Deploy single RG when topology is SingleResourceGroup
module singleResourceGroup '...' = if (resourceGroupTopology == 'SingleResourceGroup') { ... }

// Deploy multi RGs when topology is MultiResourceGroup
module baselineNetworkResourceGroup '...' = if (resourceGroupTopology == 'MultiResourceGroup' && ...) { ... }
module baselineResourceGroups '...' = [...] if (resourceGroupTopology == 'MultiResourceGroup') { ... }
module baselineStorageResourceGroup '...' = if (resourceGroupTopology == 'MultiResourceGroup' && ...) { ... }
```

#### 4. Updated Dependencies
All module deployments now depend on both single and multi RG modules:
```bicep
dependsOn: [
  singleResourceGroup
  baselineResourceGroups
  baselineStorageResourceGroup
  ...
]
```

### Files Modified

1. **workload/bicep/deploy-baseline.bicep** (89 lines changed)
   - Added new parameters
   - Added conditional RG name logic
   - Updated RG module deployments
   - Updated dependencies

2. **workload/bicep/parameters/deploy-baseline-all.bicepparam** (2 lines added)
   - Added new parameters with default values

3. **workload/docs/getting-started-baseline.md** (34 lines added)
   - Added comprehensive documentation section explaining both topologies

4. **workload/bicep/readme.md** (49 lines added)
   - Added usage examples for single RG topology

5. **workload/bicep/parameters/deploy-baseline-single-rg.bicepparam** (new file)
   - Example parameter file for single RG deployment

6. **workload/bicep/parameters/README-single-rg.md** (new file)
   - Usage guide for single RG deployment

## Key Features

### Backward Compatibility
✅ **Fully backward compatible** - default is 'MultiResourceGroup', existing deployments unaffected

### Topology Options

#### MultiResourceGroup (Default - CAF Aligned)
```
├── rg-avd-{prefix}-{env}-{location}-service-objects  (AVD management plane)
├── rg-avd-{prefix}-{env}-{location}-pool-compute     (Session hosts)
├── rg-avd-{prefix}-{env}-{location}-network          (Networking)
└── rg-avd-{prefix}-{env}-{location}-storage          (Storage)
```

**Benefits:**
- Clear separation of concerns
- Granular RBAC per resource type
- Easier cost tracking
- CAF aligned

#### SingleResourceGroup (Simplified)
```
└── rg-avd-{prefix}-{env}-{location}  (All resources)
```

**Benefits:**
- Simpler operations
- Fewer resources to manage
- Ideal for dev/test or smaller workloads
- Simplified compliance

### Usage Examples

#### PowerShell
```powershell
New-AzSubscriptionDeployment `
  -TemplateFile "./workload/bicep/deploy-baseline.bicep" `
  -resourceGroupTopology "SingleResourceGroup" `
  ... other parameters ...
```

#### Azure CLI
```bash
az deployment sub create \
  --template-file "./workload/bicep/deploy-baseline.bicep" \
  --parameters resourceGroupTopology="SingleResourceGroup" \
  ... other parameters ...
```

## Testing & Validation

### Bicep Linting
✅ No new errors introduced
✅ Only pre-existing warnings remain (unrelated to changes)

### Logic Validation
✅ Parameter definitions correct
✅ Conditional logic working as expected
✅ RG name variables correctly assigned
✅ Module deployments conditionally executed
✅ Dependencies properly configured

### Documentation
✅ Comprehensive explanation in getting-started guide
✅ Usage examples in bicep readme
✅ Example parameter file with comments
✅ Dedicated README for example

## Design Decisions

1. **Minimal Changes**: Made surgical modifications to existing logic rather than restructuring
2. **Default Behavior**: Kept 'MultiResourceGroup' as default to maintain backward compatibility
3. **Naming Consistency**: Single RG name follows same pattern as other RG names
4. **Custom Naming**: Supports custom naming for single RG, consistent with existing custom naming feature
5. **Dependencies**: All modules depend on both single and multi RG deployments for safety

## Post-Deployment Notes

While resources are deployed to the chosen topology, customers can still:
- Manually move resources between RGs using Azure's resource move capabilities
- Reorganize resources post-deployment as needed
- Use Azure's supported move operations for eligible resource types

## Future Considerations

This implementation provides the foundation for:
- Automated post-deployment resource consolidation (future enhancement)
- Additional topology patterns if needed
- Custom topology configurations

## Validation Checklist

- [x] Bicep linting passes
- [x] Logic tested with isolated test cases
- [x] Parameter files validated
- [x] Documentation complete and accurate
- [x] Example files created and tested
- [x] Backward compatibility verified
- [x] Code review feedback addressed
- [x] All paths and references correct
