# Contributing Guide: ARM Templates

[Overview](../../../CONTRIBUTING.md) | [File Structure](fileStructure.md) | [Banners](banners.md) | [Naming Standard](namingStandard.md) | [Comments](comments.md) | [Parameters File Samples](parametersFileSamples.md) | [ARM Templates](armTemplates.md) | [Documents & Diagrams](documentsDiagrams.md)

When any changes have been made to a bicep file in the repository, the deploy-*.bicep for the solution must be compiled into JSON and be placed in the appropriate directory.

1. Install the Bicep extension in VSCode.
1. Right click on the deploy-*.bicep file for solution you are adding or modifying.
1. Select "Build ARM Template" from the menu.
1. Move the JSON file to the "arm" folder. The file for the baseline and custom image solutions must be placed in the root. The file for a brownfield deployment must be placed in the brownfield folder.
