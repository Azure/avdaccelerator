metadata name = 'AVD Accelerator - Update Networking - NSG and Route Table'
metadata description = 'AVD Accelerator - Update Networking - NSG and Route Table'

targetScope = 'subscription'

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

@allowed([
    'Dev' // Development
    'Test' // Test
    'Prod' // Production
])
@sys.description('The name of the resource group to deploy. (Default: Dev)')
param deploymentEnvironment string = 'Test'

@sys.description('Location where to deploy compute services. (Default: eastus2)')
param avdSessionHostLocation string = 'eastus2'

@sys.description('AVD workload subscription ID, multiple subscriptions scenario. (Default: "")')
param avdWorkloadSubsId string = ''

@sys.description('Existing Azure log analytics workspace resource ID to connect to. (Default: "")')
param alaExistingWorkspaceResourceId string = ''

@sys.description('Existing virtual network subnet for AVD. (Default: "")')
param existingVnetAvdSubnetResourceId string = ''

@sys.description('Vnet resource group name')
param vnetResourceGroupName string = 'nih-arpa-h-it-vdi-nih-${toLower(deploymentEnvironment)}-rg-admin-az'

@maxLength(90)
@sys.description('AVD network resources resource group custom name. (Default: rg-avd-app1-dev-use2-network)')
param avdNetworkObjectsRgCustomName string = 'avd-nih-arpah-${toLower(deploymentEnvironment)}-use2-network'

@maxLength(80)
@sys.description('AVD network security group custom name. (Default: nsg-avd-app1-dev-use2-001)')
param avdNetworksecurityGroupCustomName string = 'avd-nih-arpah-${toLower(deploymentEnvironment)}-use2-nsg'

@maxLength(80)
@sys.description('AVD route table custom name. (Default: route-avd-app1-dev-use2-001)')
param avdRouteTableCustomName string = 'avd-nih-arpah-${toLower(deploymentEnvironment)}-use2-route'

@sys.description('The name of workload for tagging purposes. (Default: Contoso-Workload)')
param workloadNameTag string = 'AVD ${deploymentEnvironment} ARPA-H on NIH Network '

@sys.description('Reference to the size of the VM for your workloads (Default: Light)')
param workloadTypeTag string = 'Light'

@allowed([
    'Non-business'
    'Public'
    'General'
    'Confidential'
    'Highly-confidential'
])
@sys.description('Sensitivity of data hosted (Default: Non-business)')
param dataClassificationTag string = 'Non-business'

@sys.description('Department that owns the deployment, (Dafult: Contoso-AVD)')
param departmentTag string = 'ARPA-H-AVD'

@allowed([
    'Low'
    'Medium'
    'High'
    'Mission-critical'
    'Custom'
])
@sys.description('Criticality of the workload. (Default: Low)')
param workloadCriticalityTag string = 'Low'

@sys.description('Tag value for custom criticality value. (Default: Contoso-Critical)')
param workloadCriticalityCustomValueTag string = 'ARPA-H-Critical'

@sys.description('Details about the application.')
param applicationNameTag string = 'ARPA-H-AVD'

@sys.description('Service level agreement level of the worload. (Contoso-SLA)')
param workloadSlaTag string = 'ARPA-H-SLA'

@sys.description('Team accountable for day-to-day operations. (workload-admins@Contoso.com)')
param opsTeamTag string = 'workload-admins@arpa-h.gov'

@sys.description('Organizational owner of the AVD deployment. (Default: workload-owner@Contoso.com)')
param ownerTag string = 'workload-owner@arpa-h.gov'

@sys.description('Cost center of owner team. (Default: Contoso-CC)')
param costCenterTag string = 'ARPA-H-CC'

// Resource tagging
// Tag Exclude-${varAvdScalingPlanName} is used by scaling plans to exclude session hosts from scaling. Exmaple: Exclude-vdscal-eus2-app1-dev-001
var varCustomResourceTags = {
    WorkloadName: workloadNameTag
    WorkloadType: workloadTypeTag
    DataClassification: dataClassificationTag
    Department: departmentTag
    Criticality: (workloadCriticalityTag == 'Custom') ? workloadCriticalityCustomValueTag : workloadCriticalityTag
    ApplicationName: applicationNameTag
    ServiceClass: workloadSlaTag
    OpsTeam: opsTeamTag
    Owner: ownerTag
    CostCenter: costCenterTag
} 

var varAvdDefaultTags = {
    Environment: deploymentEnvironment
    ServiceWorkload: 'AVD'
    CreationTimeUTC: time
}

// Networking
// if existing vnet/subnet
// JWI:  this code is not working correctly;  it creates the nsg an rt, but updating the subnet fails
module updateSubnetNsgAndRouteTable './modules/networking-arpah/deploy.bicep' = {
    name: 'Networking-UpdateSubnet-${time}'
    params: {
        vnetResourceGroupName: vnetResourceGroupName
        existingAvdSubnetResourceId: existingVnetAvdSubnetResourceId
        networkObjectsRgName: avdNetworkObjectsRgCustomName
        avdNetworksecurityGroupName: avdNetworksecurityGroupCustomName
        avdRouteTableName: avdRouteTableCustomName
        workloadSubsId: avdWorkloadSubsId
        sessionHostLocation: avdSessionHostLocation
        tags: union(varCustomResourceTags, varAvdDefaultTags)
        alaWorkspaceResourceId: alaExistingWorkspaceResourceId
    }
}


