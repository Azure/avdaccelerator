# Contributing Guide: Naming Standard

[Overview](../../../CONTRIBUTING.md) | [File Structure](fileStructure.md) | [Banners](banners.md) | [Naming Standard](namingStandard.md) | [Comments](comments.md) | [Parameters File Samples](parametersFileSamples.md) | [ARM Templates](armTemplates.md) | [Documents & Diagrams](documentsDiagrams.md)

## Bicep

### Parameters

- Start with a lowercase letter.
- Use camel casing for each new word in the name.

### Variables

- Start with “var”.
- Use camel casing for each new word in the name.

### Modules

- Symbolic name:
- Start with a lowercase letter.
- Use camel casing for each new word.
- Describe the collective resources that are deployed within it.

### Deployment Name

- Use normal casing.
- Each word is separated by a hyphen.
- Value should end with the time parameter to differentiate from other deployments.
- Resources:
- Use CARML modules when possible but it is not mandatory, especially when prohibitive.

### Symbolic Name

- Start with a lowercase letter.
- Use camel casing for each new word.
- Describe the resource that is defined within it.
- Resource name: ensure the name is being captured through custom naming.

## Documentation

Update the following files with names for any new resources:

- workload/docs/resource-naming.md
- workload/docs/diagrams/avd-accelerator-resource-organization-naming.vsdx
