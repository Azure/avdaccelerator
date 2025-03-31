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
    [string]$update_existing_stack,
    [string]$securityPrincipalId,
    [string]$avdHostPoolType
)

# $paramAzSubscriptionDeploymentStackDeployment = @{
#     Name = $DeploymentStackName
#     Location = $Location
#     TemplateFile = $TemplateFile
#     TemplateParameterFile = $ParametersFile
#     ActionOnUnmanage = "detachAll" 
#     DenySettingsMode = "none"
#     avdSessionHostCustomNamePrefix = $avdSessionHostCustomNamePrefix 
#     deploymentEnvironment = $deploymentEnvironment 
#     avdWorkloadSubsId = $avdWorkloadSubsId
#     imageGallerySubscriptionId = $imageGallerySubscriptionId
#     existingVnetAvdSubnetResourceId = $existingVnetAvdSubnetResourceId 
#     existingVnetPrivateEndpointSubnetResourceId = $existingVnetPrivateEndpointSubnetResourceId 
#     identityDomainName = $identityDomainName 
#     avdOuPath = $avdOuPath
# }

# if ($update_existing_stack -eq 'true') {
#     Write-Host "Updating existing stack"
#     Set-AzSubscriptionDeploymentStack @paramAzSubscriptionDeploymentStackDeployment -P
#     return
# } else {
#     Write-Host "Creating new stack"
#     New-AzSubscriptionDeploymentStack @paramAzSubscriptionDeploymentStackDeployment -P
#     return
# }

if ($update_existing_stack -eq 'true') {
    Write-Host "Updating existing stack"
    Set-AzSubscriptionDeploymentStack -Name $DeploymentStackName -Location $Location -TemplateFile $TemplateFile -TemplateParameterFile $ParametersFile -P -ActionOnUnmanage "detachAll" -DenySettingsMode "none" `
        -avdSessionHostCustomNamePrefix $avdSessionHostCustomNamePrefix -deploymentEnvironment $deploymentEnvironment -avdWorkloadSubsId $avdWorkloadSubsId -imageGallerySubscriptionId $imageGallerySubscriptionId `
        -existingVnetAvdSubnetResourceId $existingVnetAvdSubnetResourceId -existingVnetPrivateEndpointSubnetResourceId $existingVnetPrivateEndpointSubnetResourceId `
        -identityDomainName $identityDomainName -avdOuPath $avdOuPath -securityPrincipalId $securityPrincipalId -avdHostPoolType $avdHostPoolType
    return
} else {
    Write-Host "Creating new stack"
    New-AzSubscriptionDeploymentStack -Name $DeploymentStackName -Location $Location -TemplateFile $TemplateFile -TemplateParameterFile $ParametersFile -P -ActionOnUnmanage "detachAll" -DenySettingsMode "none" `
    -avdSessionHostCustomNamePrefix $avdSessionHostCustomNamePrefix -deploymentEnvironment $deploymentEnvironment -avdWorkloadSubsId $avdWorkloadSubsId -imageGallerySubscriptionId $imageGallerySubscriptionId `
    -existingVnetAvdSubnetResourceId $existingVnetAvdSubnetResourceId -existingVnetPrivateEndpointSubnetResourceId $existingVnetPrivateEndpointSubnetResourceId `
    -identityDomainName $identityDomainName -avdOuPath $avdOuPath -securityPrincipalId $securityPrincipalId -avdHostPoolType $avdHostPoolType
    return
}