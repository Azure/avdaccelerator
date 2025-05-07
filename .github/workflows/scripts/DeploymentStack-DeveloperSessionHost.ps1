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
    [string]$avdHostPoolType,
    [int]$avdDeploySessionHostsCount,
    [int]$avdSessionHostCountIndex
)

$params = @{
    Name                                        = $DeploymentStackName
    Location                                    = $Location
    TemplateFile                                = $TemplateFile
    TemplateParameterFile                       = $ParametersFile
    avdSessionHostCustomNamePrefix              = $avdSessionHostCustomNamePrefix
    deploymentEnvironment                       = $deploymentEnvironment
    avdWorkloadSubsId                           = $avdWorkloadSubsId
    imageGallerySubscriptionId                  = $imageGallerySubscriptionId
    existingVnetAvdSubnetResourceId             = $existingVnetAvdSubnetResourceId
    existingVnetPrivateEndpointSubnetResourceId = $existingVnetPrivateEndpointSubnetResourceId
    identityDomainName                          = $identityDomainName
    avdOuPath                                   = $avdOuPath
    update_existing_stack                       = $update_existing_stack
    securityPrincipalId                         = $securityPrincipalId
    avdHostPoolType                             = $avdHostPoolType
    avdDeploySessionHostsCount                  = $avdDeploySessionHostsCount
    avdSessionHostCountIndex                    = $avdSessionHostCountIndex
    ActionOnUnmanage                            = "detachAll"
    DenySettingsMode                            = "none"
}

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

if ($update_existing_stack -eq 'true') {
    Write-Host "Updating existing stack"
    Set-AzSubscriptionDeploymentStack @params
}
else {
    Write-Host "Creating new stack"
    New-AzSubscriptionDeploymentStack @params
}