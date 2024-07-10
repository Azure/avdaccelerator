# Contributing Guide: Comments

[Overview](../../../CONTRIBUTING.md) | [File Structure](fileStructure.md) | [Banners](banners.md) | [Naming Standard](namingStandard.md) | [Comments](comments.md) | [Parameters File Samples](parametersFileSamples.md) | [ARM Templates](armTemplates.md) | [Documents & Diagrams](documentsDiagrams.md)

Every module and resource in the bicep files must have a comment describing its resource and if necessary, its purpose. For example, for a resource group, the following comment would be placed above the resource:

```bash
// Resource group.
module resourceGroup '../../avm/1.0.0/res/resources/resourceGroups/main.bicep' =  {
    scope: subscription(avdWorkloadSubsId)
    name: 'Deploy-${varRgName}-${time}'
    params: {
        name: varRgName
        location: avdSessionHostLocation
        enableDefaultTelemetry: false
        tags: createResourceTags ? union(varAllComputeStorageTags, varAvdCostManagementParentResourceTag) : varAvdCostManagementParentResourceTag
    }
    dependsOn: avdDeployMonitoring ? [
        monitoringDiagnosticSettings
    ] : []
}
```

Or you could provide more detail around the resource or resource group if more than one exists in the solution. For example:

```bash
// Resource group for AVD session hosts.
module resourceGroup '../../avm/1.0.0/res/resources/resourceGroups/main.bicep' =  {
    scope: subscription(avdWorkloadSubsId)
    name: 'Deploy-${varRgName}-${time}'
    params: {
        name: varRgName
        location: avdSessionHostLocation
        enableDefaultTelemetry: false
        tags: createResourceTags ? union(varAllComputeStorageTags, varAvdCostManagementParentResourceTag) : varAvdCostManagementParentResourceTag
    }
    dependsOn: avdDeployMonitoring ? [
        monitoringDiagnosticSettings
    ] : []
}
```
