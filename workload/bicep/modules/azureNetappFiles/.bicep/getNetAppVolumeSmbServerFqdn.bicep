metadata name = 'AVD LZA storage ANF volume SMB server FQDN'
metadata description = 'This module returns the SMB server FQDN of an ANF volume.'
metadata owner = 'Azure/avdaccelerator'

targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

param netAppVolumeResourceId string

// =========== //
// Variable declaration //
// =========== //

// =========== //
// Deployments //
// =========== //

// Call on ANF account and volume to get the SMB server FQDN.
resource netAppAccount 'Microsoft.NetApp/netAppAccounts@2024-09-01' existing = {
    name: split(netAppVolumeResourceId, '/')[8]
    scope: resourceGroup(split(netAppVolumeResourceId, '/')[2], split(netAppVolumeResourceId, '/')[4])
    resource capacityPool 'capacityPools' existing = {
      name: split(netAppVolumeResourceId, '/')[10]
      resource volume 'volumes' existing = {
        name: last(split(netAppVolumeResourceId, '/'))
      }
    }      
  }

// =========== //
// Outputs //
// =========== //
output anfSmbServerFqdn string = netAppAccount::capacityPool::volume.properties.mountTargets[0].smbServerFqdn
