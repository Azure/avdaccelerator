# param (
#     [string]$DeploymentStackName,
#     [string]$Location,
#     [string]$TemplateFile,
#     [string]$ParametersFile,
#     [string]$avdSessionHostCustomNamePrefix,
#     [string]$deploymentEnvironment,
#     [string]$avdWorkloadSubsId,
#     [string]$imageGallerySubscriptionId,
#     [string]$existingVnetAvdSubnetResourceId,
#     [string]$existingVnetPrivateEndpointSubnetResourceId,
#     [string]$identityDomainName, 
#     [string]$avdOuPath,
#     [string]$update_existing_stack,
#     [string]$securityPrincipalId,
#     [string]$avdHostPoolType,
#     [int]$avdDeploySessionHostsCount
# )

# if ($update_existing_stack -eq 'true') {
#     Write-Host "Updating existing stack"
#     Set-AzSubscriptionDeploymentStack -Name $DeploymentStackName -Location $Location -TemplateFile $TemplateFile -TemplateParameterFile $ParametersFile -P -ActionOnUnmanage "detachAll" -DenySettingsMode "none" `
#         -avdSessionHostCustomNamePrefix $avdSessionHostCustomNamePrefix -deploymentEnvironment $deploymentEnvironment -avdWorkloadSubsId $avdWorkloadSubsId -imageGallerySubscriptionId $imageGallerySubscriptionId `
#         -existingVnetAvdSubnetResourceId $existingVnetAvdSubnetResourceId -existingVnetPrivateEndpointSubnetResourceId $existingVnetPrivateEndpointSubnetResourceId `
#         -identityDomainName $identityDomainName -avdOuPath $avdOuPath -securityPrincipalId $securityPrincipalId -avdHostPoolType $avdHostPoolType -avdDeploySessionHostsCount $avdDeploySessionHostsCount
#     return
# } else {
#     Write-Host "Creating new stack"
#     New-AzSubscriptionDeploymentStack -Name $DeploymentStackName -Location $Location -TemplateFile $TemplateFile -TemplateParameterFile $ParametersFile -P -ActionOnUnmanage "detachAll" -DenySettingsMode "none" `
#     -avdSessionHostCustomNamePrefix $avdSessionHostCustomNamePrefix -deploymentEnvironment $deploymentEnvironment -avdWorkloadSubsId $avdWorkloadSubsId -imageGallerySubscriptionId $imageGallerySubscriptionId `
#     -existingVnetAvdSubnetResourceId $existingVnetAvdSubnetResourceId -existingVnetPrivateEndpointSubnetResourceId $existingVnetPrivateEndpointSubnetResourceId `
#     -identityDomainName $identityDomainName -avdOuPath $avdOuPath -securityPrincipalId $securityPrincipalId -avdHostPoolType $avdHostPoolType -avdDeploySessionHostsCount $avdDeploySessionHostsCount
#     return
# }

param (
    [string]$DeploymentStackName,
    [string]$Location,
    [string]$TemplateFile,
    [string]$ParametersFile,
    [string]$deploymentEnvironment,
    [string]$avdWorkloadSubsId,
    [string]$avdEnterpriseAppObjectId,
    [string]$existingVnetPrivateEndpointSubnetResourceId,
    [string]$securityPrincipalId,
    [string]$update_existing_stack,
    [string]$avdHostPoolType,
    [string]$avdWrklKvPrefixCustomName
)

if ($update_existing_stack -eq 'true') {
    Write-Host "Updating existing stack"
    Set-AzSubscriptionDeploymentStack -Name $DeploymentStackName -Location $Location -TemplateFile $TemplateFile -TemplateParameterFile $ParametersFile -ActionOnUnmanage "detachAll" -DenySettingsMode "none" `
        -deploymentEnvironment $deploymentEnvironment -avdWorkloadSubsId $avdWorkloadSubsId -avdEnterpriseAppObjectId $avdEnterpriseAppObjectId -existingVnetPrivateEndpointSubnetResourceId $existingVnetPrivateEndpointSubnetResourceId `
        -securityPrincipalId $securityPrincipalId -avdHostPoolType $avdHostPoolType -avdWrklKvPrefixCustomName $avdWrklKvPrefixCustomName
    return
} else {
    Write-Host "Creating new stack"
    New-AzSubscriptionDeploymentStack -Name $DeploymentStackName -Location $Location -TemplateFile $TemplateFile -TemplateParameterFile $ParametersFile -ActionOnUnmanage "detachAll" -DenySettingsMode "none" `
        -deploymentEnvironment $deploymentEnvironment -avdWorkloadSubsId $avdWorkloadSubsId -avdEnterpriseAppObjectId $avdEnterpriseAppObjectId -existingVnetPrivateEndpointSubnetResourceId $existingVnetPrivateEndpointSubnetResourceId `
        -securityPrincipalId $securityPrincipalId -avdHostPoolType $avdHostPoolType -avdWrklKvPrefixCustomName $avdWrklKvPrefixCustomName
    return
}
