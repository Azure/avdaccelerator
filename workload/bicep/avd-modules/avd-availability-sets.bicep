targetScope = 'resourceGroup'

// ========== //
// Parameters //
// ========== //
@description('Required. Location where to deploy compute services.')
param avdSessionHostLocation string

@description('Optional. Availablity Set name.')
param avdAvailabilitySetNamePrefix string

@description('Optional. Availablity Set count.')
param availabilitySetCount int

@description('Optional. Sets the number of fault domains for the availability set.')
param avdAsFaultDomainCount int

@description('Optional. Sets the number of update domains for the availability set.')
param avdAsUpdateDomainCount int

@description('Resource Group name for the session hosts.')
param avdComputeObjectsRgName string

@description('Optional. AVD workload subscription ID, multiple subscriptions scenario.')
param avdWorkloadSubsId string

@description('Required. Tags to be applied to resources')
param avdTags object

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //

// =========== //
// Deployments //
// =========== //

// Availability set.
module avdAvailabilitySet '../../../carml/1.2.0/Microsoft.Compute/availabilitySets/deploy.bicep' = [for i in range(1, availabilitySetCount): {
    name: 'AVD-AvSet--${i}-${time}'
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
    params: {
        name: '${avdAvailabilitySetNamePrefix}-${padLeft(i, 3, '0')}'
        location: avdSessionHostLocation
        availabilitySetFaultDomain: avdAsFaultDomainCount
        availabilitySetUpdateDomain: avdAsUpdateDomainCount
        tags: avdTags
    }
}]
