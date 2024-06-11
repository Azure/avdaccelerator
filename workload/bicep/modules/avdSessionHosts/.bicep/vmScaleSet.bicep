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

@sys.description('Use availability zones.')
param useAvailabilityZones bool

// @sys.description('Tags to be applied to resources')
// param tags object

// =========== //
// Variable declaration //
// =========== //

// =========== //
// Deployments //
// =========== //
resource vmssFlex 'Microsoft.Compute/virtualMachineScaleSets@2024-03-01' = [for i in range(1, count): {
    location: location
    name: '${namePrefix}-${padLeft(i, 3, '0')}'
    zones: useAvailabilityZones ? [
        '1'
        '2'
        '3'
    ]: null
    properties: {
        orchestrationMode: 'Flexible'
        zoneBalance: useAvailabilityZones ? true: false
        platformFaultDomainCount: 1
    }
    // tags: tags
}]
