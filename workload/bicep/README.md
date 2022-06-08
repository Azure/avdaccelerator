# PowerShell and Azure CLI deployments

## Optional: Custom Image Build deployment

### Azure CLI

```bash

```

### PowerShell

```powershell
$avdVmLocalUserPassword = Read-Host -Prompt "Local user password" -AsSecureString
$avdDomainJoinUserPassword = Read-Host -Prompt "Domain join password" -AsSecureString
New-AzSubscriptionDeployment `
  -TemplateFile workload/bicep/deploy-baseline.bicep `
  -TemplateParameterFile workload/bicep/parameters/deploy-baseline-parameters-example.json `
  -avdWorkloadSubsId <subscriptionId> `
  -deploymentPrefix <deploymentPrefix> `
  -avdVmLocalUserName <localUserName> `
  -avdVmLocalUserPassword $localUserPassword `
  -avdIdentityDomainName <domainJoinUserName> `
  -avdDomainJoinUserPassword $domainJoinUserPassword `
  -avdDomainJoinUserName <domainName>  `
  -existingHubVnetResourceId <hubVnet ResourceId>  `
  -customDnsIps <customDNSservers>  `
  -avdEnterpriseAppObjectId <wvdAppObjectId> `
  -Location eastus2
```

## AVD Accelerator Baseline

### Azure CLI

```bash

```

### PowerShell

```powershell
New-AzSubscriptionDeployment `
  -TemplateFile workload/bicep/deploy-custom-image.bicep `
  -TemplateParameterFile workload/bicep/parameters/deploy-custom-image-parameters-example.json `
  -avdSharedServicesSubId <subscriptionId> `
  -deploymentPrefix <deploymentPrefix> `
  -Location eastus2
```

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit [https://cla.opensource.microsoft.com](https://cla.opensource.microsoft.com).

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
