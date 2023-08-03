targetScope = 'resourceGroup'

// ========== //
// Parameters //
// ========== //
@sys.description('Location where to deploy compute services.')
param location string

@sys.description('Availablity Set name.')
param namePrefix string

@sys.description('Availablity Set count.')
param count int

@sys.description('Sets the number of fault domains for the availability set.')
param faultDomainCount int

@sys.description('Sets the number of update domains for the availability set.')
param updateDomainCount int

@sys.description('Tags to be applied to resources')
param tags object

// =========== //
// Variable declaration //
// =========== //

// =========== //
// Deployments //
// =========== //
// Availability set.
module availabilitySet '../../../../../carml/1.3.0/Microsoft.Compute/availabilitySets/deploy.bicep' = [for i in range(1, count): {
    name: '${namePrefix}-${padLeft(i, 3, '0')}'
    params: {
        name: '${namePrefix}-${padLeft(i, 3, '0')}'
        location: location
        availabilitySetFaultDomain: faultDomainCount
        availabilitySetUpdateDomain: updateDomainCount
        tags: tags
    }
}]



