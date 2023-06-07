# Contributors Guide: File Structure

[Overview](../../../CONTRIBUTING.md) | [File Structure](fileStructure.md) | [Banners](contributing/banners.md) | [Naming Standard](namingStandard.md) | [Comments](comments.md) | [Parameters File Samples](parametersFileSamples.md) | [ARM Templates](armTemplates.md) | [Documents & Diagrams](documentsDiagrams.md)

Depending on the contribution, specific files should either be either updated or added to follow the established heirarchy and structure.

## Baseline

- workload/arm/deploy-basline.json
- workload/bicep
  - modules/< functionality >
    - .bicep (contains additional module files needed for functionality)
    - deploy.bicep
  - parameters
    - deploy-baseline-min-parameters-example.json
    - deploy-baseline-parameters-example.json
  - deploy-baseline.bicep
  - readme.md
- workload/portal-ui/portal-ui-baseline.json

## Custom Image Build

- workload/arm/deploy-custom-image.json
- workload/bicep
  - modules/< functionality >
    - .bicep (contains additional module files needed for functionality)
    - deploy.bicep
  - parameters
    - deploy-custom-image-min-parameters-example.json
    - deploy-custom-image-parameters-example.json
  - deploy-baseline.bicep
  - readme.md
- workload/portal-ui/portal-ui-baseline.json

## Brownfield Deployment

- workload/arm/brownfield/deploy< solution >.json
- workload/bicep/brownfield/< solution >
  - modules
  - parameters
    - < solution >.parameters.all.json
    - < solution >.parameters.min.json
  - references
  - deploy.bicep
  - readme.md
- workload/portal-ui/brownfield/portalUi< solution >.json
