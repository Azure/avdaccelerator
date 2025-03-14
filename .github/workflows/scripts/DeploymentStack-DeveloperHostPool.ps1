param (
    [string]$DeploymentStackName,
    [string]$Location,
    [string]$TemplateFile,
    [string]$ParametersFile,
    [string]$avdSessionHostCustomNamePrefix,
    [string]$deploymentEnvironment,
    [string]$avdWorkloadSubsId,
    [string]$imageGallerySubscriptionId,
    [string]$avdEnterpriseAppObjectId,
    [string]$existingVnetAvdSubnetResourceId,
    [string]$existingVnetPrivateEndpointSubnetResourceId,
    [string]$identityDomainName, 
    [string]$avdOuPath,
    [string]$securityPrincipalId
)

New-AzSubscriptionDeploymentStack -Name $DeploymentStackName -Location $Location -TemplateFile $TemplateFile -TemplateParameterFile $ParametersFile -P -ActionOnUnmanage "detachAll" -DenySettingsMode "none" `
    -avdSessionHostCustomNamePrefix $avdSessionHostCustomNamePrefix -deploymentEnvironment $deploymentEnvironment -avdWorkloadSubsId $avdWorkloadSubsId -imageGallerySubscriptionId $imageGallerySubscriptionId `
    -avdEnterpriseAppObjectId $avdEnterpriseAppObjectId -existingVnetAvdSubnetResourceId $existingVnetAvdSubnetResourceId -existingVnetPrivateEndpointSubnetResourceId $existingVnetPrivateEndpointSubnetResourceId `
    -identityDomainName $identityDomainName -avdOuPath $avdOuPath -securityPrincipalId $securityPrincipalId