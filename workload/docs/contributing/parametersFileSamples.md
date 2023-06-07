# Contributing Guide: Parameters File Samples

[Overview](../../../CONTRIBUTING.md) | [File Structure](fileStructure.md) | [Banners](banners.md) | [Naming Standard](namingStandard.md) | [Comments](comments.md) | [Parameters File Samples](parametersFileSamples.md) | [ARM Templates](armTemplates.md) | [Documents & Diagrams](documentsDiagrams.md)

Each solution in the AVD Accelerator must contain parameters file samples to ensure customers can deploy the solution using PowerShell, Azure CLI, or other tooling.

## Files

Create the files for the solution if they don’t exist

### Baseline

**Directory**: workload/bicep/parameters

**Files**:

- deploy-baseline-min-parameters-example.json
- deploy-baseline-parameters-example.json

### Custom Image Build

**Directory**: workload/bicep/parameters

**Files**:

- deploy-custom-image-min-parameters-example.json
- deploy-custom-image-parameters-example.json

### Brownfield Deployment

**Directory**: workload/bicep/brownfield/< solution >/parameters

**Files**:

- < solution >.parameters.all.json
- < solution >.parameters.min.json

## Updates

Update the appropriate files with any new parameters.
