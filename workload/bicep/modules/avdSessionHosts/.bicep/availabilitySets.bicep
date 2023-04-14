targetScope = 'resourceGroup'

// ========== //
// Parameters //
// ========== //
@description('Location where to deploy compute services.')
param sessionHostLocation string

@description('Availablity Set name.')
param availabilitySetNamePrefix string

@description('Availablity Set count.')
param availabilitySetCount int

@description('Sets the number of fault domains for the availability set.')
param availabilitySetFaultDomainCount int

@description('Sets the number of update domains for the availability set.')
param availabilitySetUpdateDomainCount int

@description('Resource Group name for the session hosts.')
param computeObjectsRgName string

@description('AVD workload subscription ID, multiple subscriptions scenario.')
param workloadSubsId string

@description('Tags to be applied to resources')
param tags object

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //

// =========== //
// Deployments //
// =========== //

// Availability set.
module availabilitySet '../../../../../carml/1.3.0/Microsoft.Compute/availabilitySets/deploy.bicep' = [for i in range(1, availabilitySetCount): {
    name: 'Availability-Set-${i}-${time}'
    scope: resourceGroup('${workloadSubsId}', '${computeObjectsRgName}')
    params: {
        name: '${availabilitySetNamePrefix}-${padLeft(i, 3, '0')}'
        location: sessionHostLocation
        availabilitySetFaultDomain: availabilitySetFaultDomainCount
        availabilitySetUpdateDomain: availabilitySetUpdateDomainCount
        tags: tags
    }
}]
