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

@sys.description('Local administrator username.')
param vmLocalUserName string

@description('Required. The SKU size of the VMs.')
param skuName string

@description('Required. OS image reference. In case of marketplace images, it\'s the combination of the publisher, offer, sku, version attributes. In case of custom images it\'s the resource ID of the custom image.')
param osImage object

@description('Optional. Whether to force strictly even Virtual Machine distribution cross x-zones in case there is zone outage.')
param zoneBalance bool

@sys.description('Sets the number of fault domains for the VMSS flex.')
param faultDomainCount int

@sys.description('Tags to be applied to resources')
param tags object

// =========== //
// Variable declaration //
// =========== //

// =========== //
// Deployments //
// =========== //
// VMSS Flex.
module vmssFlex '../../../../../avm/1.0.0/res/compute/virtual-machine-scale-set/main.bicep' = [for i in range(1, count): {
    name: '${namePrefix}-${padLeft(i, 3, '0')}'
    params: {
        name: '${namePrefix}-${padLeft(i, 3, '0')}'
        location: location
        orchestrationMode: 'Flexible'
        zoneBalance: zoneBalance
        adminUsername: vmLocalUserName
        osDisk: {
            diskSizeGB: 'FromImage'
            createOption: 'FromImage'
        }
        osType: 'Windows'
        skuName: skuName
        imageReference: osImage
        availabilityZones: [1, 2, 3]
        scaleSetFaultDomain: faultDomainCount
        tags: tags
    }
}]



