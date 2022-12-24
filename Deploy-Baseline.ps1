$avdVmLocalUserPassword = Read-Host -Prompt "Local user password" -AsSecureString
#$avdDomainJoinUserPassword = Read-Host -Prompt "Domain join password" -AsSecureString
New-AzSubscriptionDeployment `
  -Name 'AVDAccelerator-EastUS2' `
  -TemplateFile workload/bicep/deploy-baseline.bicep `
  -TemplateParameterFile workload/bicep/parameters/deploy-baseline-parameters-MSA.json `
  -avdWorkloadSubsId "6638b757-bc2e-43a8-9274-1d7e2961563d" `
  -deploymentPrefix "AVDA" `
  -avdVmLocalUserName "VMLocalAdmin" `
  -avdVmLocalUserPassword $avdVmLocalUserPassword `
  -avdIdentityServiceProvider "AAD" `
  -avdEnterpriseAppObjectId "1d978fb9-d52d-4afb-b129-e2e38b59e5ea" `
  -avdDeployMonitoring $true `
  -deployAlaWorkspace $true `
  -Location "eastus2"