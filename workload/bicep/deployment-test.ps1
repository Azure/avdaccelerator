#$avdVmLocalUserPassword = Read-Host -Prompt "Local user password" -AsSecureString
#$avdDomainJoinUserPassword = Read-Host -Prompt "Domain join password" -AsSecureString

$Location = 'southcentralus'
$VNETCIDR = '10.23.0.0/23'
$AVDCIDR = '10.23.0.0/24'
$PECIDR = '10.23.1.0/27'
$Prefix = 'ig73'
New-AzSubscriptionDeployment `
-TemplateFile 'C:\Users\dcontreras\Downloads\avdaccelerator\avdaccelerator\workload\bicep\deploy-baseline.bicep' `
-TemplateParameterFile 'C:\Users\dcontreras\Downloads\avdaccelerator\avdaccelerator\workload\bicep\parameters\deploy-baseline-parameters-example.json' `
-name $Prefix `
-deploymentPrefix $Prefix `
-avdVnetworkAddressPrefixes $VNETCIDR `
-vNetworkAvdSubnetAddressPrefix $AVDCIDR `
-vNetworkPrivateEndpointSubnetAddressPrefix $PECIDR `
-location $Location `
-avdWorkloadSubsId 'a7bc841f-34c0-4214-9469-cd463b66de35' `
-avdEnterpriseAppObjectId '486795c7-d929-4b48-a99e-3c5329d4ce86' `
-avdVmLocalUserName 'd2lsolutions' `
-avdVmLocalUserPassword $avdVmLocalUserPassword `
-avdIdentityDomainName 'd2lsolutions.com' `
-avdDomainJoinUserName 'wvdadmin@d2lsolutions.com' `
-avdDomainJoinUserPassword $avdDomainJoinUserPassword `
-existingHubVnetResourceId '/subscriptions/947a3882-0d71-45e4-9a84-ede9dccd19fe/resourceGroups/d2l-network-eastus-is01/providers/Microsoft.Network/virtualNetworks/d2l-default-eastus'  `
-avdVnetPrivateDnsZoneFilesId '/subscriptions/bf8ce47f-27f8-4e3d-9fce-ef902d0c2845/resourceGroups/d2l-dns-global-cs01/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net' `
-avdVnetPrivateDnsZoneKeyvaultId '/subscriptions/947a3882-0d71-45e4-9a84-ede9dccd19fe/resourceGroups/d2l-network-eastus-is01/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net' `
-avdHostPoolType 'Pooled' `
-avdSessionHostLocation $Location `
-avdManagementPlaneLocation $Location `
-avdDeploySessionHostsCount '4' `
-avdIdentityServiceProvider 'ADDS' `
-customDnsIps '10.40.135.4' `
-securityType 'Standard' `
-fslogixStoragePerformance 'Premium' `
-msixStoragePerformance 'Premium' `
-avdApplicationGroupIdentityType 'User' `
-avdApplicationGroupIdentitiesIds '93e03feb-fc7f-4431-988e-3ec4ccfce68f' `
-deployAlaWorkspace $true `
-deployCustomPolicyMonitoring $false `
-avdDeployMonitoring $false `
-createAvdFslogixDeployment $true `
-createMsixDeployment $true `
-secureBootEnabled $true `
-vTpmEnabled $true `
-avdUseAvailabilityZones $false `
-avdVnetPrivateDnsZone $true `
-avdDeployScalingPlan $true `
-avdDeploySessionHosts $true `
-createAvdVnet $true `
-avdDeployRappGroup $true `
-verbose


