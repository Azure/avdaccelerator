param (
    [string]$DeploymentStackName,
    [string]$Location,
    [string]$TemplateFile,
    [string]$ParametersFile,
    [string]$avdSessionHostCustomNamePrefix,
    [string]$deploymentEnvironment,
    [string]$avdWorkloadSubsId,
    [string]$imageGallerySubscriptionId,
    [string]$existingVnetAvdSubnetResourceId,
    [string]$existingVnetPrivateEndpointSubnetResourceId,
    [string]$identityDomainName, 
    [string]$avdOuPath,
    [string]$update_existing_stack
)

$paramNewAzResourceGroupDeployment = @{
    Name = $DeploymentStackName
    Location = $Location
    TemplateFile = $TemplateFile
    TemplateParameterFile = $ParametersFile
    ActionOnUnmanage = "detachAll" 
    DenySettingsMode = "none"
    avdSessionHostCustomNamePrefix = $avdSessionHostCustomNamePrefix 
    deploymentEnvironment = $deploymentEnvironment 
    avdWorkloadSubsId = $avdWorkloadSubsId
    imageGallerySubscriptionId = $imageGallerySubscriptionId
    existingVnetAvdSubnetResourceId = $existingVnetAvdSubnetResourceId 
    existingVnetPrivateEndpointSubnetResourceId = $existingVnetPrivateEndpointSubnetResourceId 
    identityDomainName = $identityDomainName 
    avdOuPath = $avdOuPath
}

if ($update_existing_stack -eq 'true') {
    Write-Host "Updating existing stack"
    Set-AzSubscriptionDeploymentStack @paramNewAzResourceGroupDeployment -P
    return
} else {
    Write-Host "Creating new stack"
    New-AzSubscriptionDeploymentStack @paramNewAzResourceGroupDeployment -P
    return
}

# if ($update_existing_stack -eq 'true') {
#     Write-Host "Updating existing stack"
#     Set-AzSubscriptionDeploymentStack -Name $DeploymentStackName -Location $Location -TemplateFile $TemplateFile -TemplateParameterFile $ParametersFile -P -ActionOnUnmanage "detachAll" -DenySettingsMode "none" `
#         -avdSessionHostCustomNamePrefix $avdSessionHostCustomNamePrefix -deploymentEnvironment $deploymentEnvironment -avdWorkloadSubsId $avdWorkloadSubsId -imageGallerySubscriptionId $imageGallerySubscriptionId `
#         -existingVnetAvdSubnetResourceId $existingVnetAvdSubnetResourceId -existingVnetPrivateEndpointSubnetResourceId $existingVnetPrivateEndpointSubnetResourceId `
#         -identityDomainName $identityDomainName -avdOuPath $avdOuPath
#     return
# } else {
#     Write-Host "Creating new stack"
#     New-AzSubscriptionDeploymentStack -Name $DeploymentStackName -Location $Location -TemplateFile $TemplateFile -TemplateParameterFile $ParametersFile -P -ActionOnUnmanage "detachAll" -DenySettingsMode "none" `
#     -avdSessionHostCustomNamePrefix $avdSessionHostCustomNamePrefix -deploymentEnvironment $deploymentEnvironment -avdWorkloadSubsId $avdWorkloadSubsId -imageGallerySubscriptionId $imageGallerySubscriptionId `
#     -existingVnetAvdSubnetResourceId $existingVnetAvdSubnetResourceId -existingVnetPrivateEndpointSubnetResourceId $existingVnetPrivateEndpointSubnetResourceId `
#     -identityDomainName $identityDomainName -avdOuPath $avdOuPath
#     return
# }