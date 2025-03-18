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
    [string]$update_existing_stack
)

if ($update_existing_stack -eq 'true') {
    Write-Host "Updating existing stack"
    Set-AzSubscriptionDeploymentStack -Name $DeploymentStackName -Location $Location -TemplateFile $TemplateFile -TemplateParameterFile $ParametersFile -P -ActionOnUnmanage "detachAll" -DenySettingsMode "none" `
        -deploymentEnvironment $deploymentEnvironment -avdWorkloadSubsId $avdWorkloadSubsId -avdEnterpriseAppObjectId $avdEnterpriseAppObjectId -existingVnetPrivateEndpointSubnetResourceId $existingVnetPrivateEndpointSubnetResourceId `
        -securityPrincipalId $securityPrincipalId
    return
} else {
    Write-Host "Creating new stack"
    New-AzSubscriptionDeploymentStack -Name $DeploymentStackName -Location $Location -TemplateFile $TemplateFile -TemplateParameterFile $ParametersFile -P -ActionOnUnmanage "detachAll" -DenySettingsMode "none" `
        -deploymentEnvironment $deploymentEnvironment -avdWorkloadSubsId $avdWorkloadSubsId -avdEnterpriseAppObjectId $avdEnterpriseAppObjectId -existingVnetPrivateEndpointSubnetResourceId $existingVnetPrivateEndpointSubnetResourceId `
        -securityPrincipalId $securityPrincipalId
    return
}