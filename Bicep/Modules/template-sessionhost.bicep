param templateSpecName string
param templateSpecDisplayName string
param location string = resourceGroup().location
param tags object = {}
param templateSpecVersion string = '1.0'

param domainJoinUserName string 
param domainToJoin string  
param hostPoolName string
param imageId string
param localAdminName string
param ouPath string
param subnetName string
param vmName string
param vnetId string
param count int
param vmSize string
param keyVaultName string
param keyVaultResourceGroup string
param hostPoolToken string


resource templateSpec 'Microsoft.Resources/templateSpecs@2021-05-01' = {
  name: templateSpecName
  location: location
  properties: {
    displayName: templateSpecDisplayName
  }
  tags: tags
}

resource templateSpec_version 'Microsoft.Resources/templateSpecs/versions@2021-05-01' = {
  parent: templateSpec
  name: templateSpecVersion
  location: location
  properties: {
    mainTemplate: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      'contentVersion': '1.0.0.0'
      'parameters': {
        'count': {
          'type': 'int'
        }
        'hostPoolToken': {
          'type': 'string'
        }
      }
      'variables': {
        'domainJoinUserSecret': 'avdDomainJoinPassword'
        'localAdminUserSecret': 'avdLocalAdminPassword'
      }
      'resources': [
        {
          'type': 'Microsoft.Resources/deployments'
          'apiVersion': '2020-10-01'
          'name': 'test'
          'properties': {
            'expressionEvaluationOptions': {
              'scope': 'inner'
            }
            'mode': 'Incremental'
            'parameters': {
              'domainJoinPassword': {
                'reference': {
                  'keyVault': {
                    'id': '[format(\'/subscriptions/{0}/resourceGroups/{1}\', subscription().subscriptionId, \'${keyVaultResourceGroup}/providers/Microsoft.KeyVault/vaults/${keyVaultName}\')]'
                  }
                  'secretName': '[variables(\'domainJoinUserSecret\')]'
                }
              }
              'domainToJoin': {
                'value': domainToJoin
              }
              'domainJoinUserName': {
                'value': domainJoinUserName
              }
              'hostPoolName': {
                'value': hostPoolName
              }
              'hostPoolToken': {
                'value': '[parameters(\'hostPoolToken\')]'
              }
              'imageId': {
                'value': imageId
              }
              'localAdminName': {
                'value': localAdminName
              }
              'localAdminPassword': {
                'reference': {
                  'keyVault': {
                    'id': '[format(\'/subscriptions/{0}/resourceGroups/{1}\', subscription().subscriptionId, \'${keyVaultResourceGroup}/providers/Microsoft.KeyVault/vaults/${keyVaultName}\')]'
                  }
                  'secretName': '[variables(\'localAdminUserSecret\')]'
                }
              }
              'ouPath': {
                'value': ouPath
              }
              'vmName': {
                'value': vmName
              }
              'vmSize': {
                'value': vmSize
              }
              'subnetName': {
                  'value': subnetName
              }
            }
            'template': {
              '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
              'contentVersion': '1.0.0.0'
              'parameters': {
                'vmName': {
                  'type': 'string'
                  'maxLength': 10
                }
                'vmSize': {
                  'type': 'string'
                }
                'tags': {
                  'type': 'object'
                  'defaultValue': {}
                }
                'domainToJoin': {
                  'type': 'string'
                }
                'domainJoinUserName': {
                  'type': 'string'
                }
                'imageId': {
                  'type': 'string'
                }
                'localAdminName': {
                  'type': 'string'
                }
                'ouPath': {
                  'type': 'string'
                }
                'location': {
                  'type': 'string'
                  'defaultValue': '[resourceGroup().location]'
                }
                'aadJoin': {
                  'type': 'bool'
                  'defaultValue': false
                }
                'count': {
                  'type': 'int'
                  'defaultValue': 1
                }
                'subnetName': {
                  'type': 'string'
                }
                'licenseType': {
                  'type': 'string'
                  'defaultValue': 'Windows_Client'
                }
                'installNVidiaGPUDriver': {
                  'type': 'bool'
                  'defaultValue': false
                }
                'localAdminPassword': {
                  'type': 'secureString'
                }
                'domainJoinPassword': {
                  'type': 'secureString'
                }
                'hostPoolName': {
                  'type': 'string'
                }
                'hostPoolToken': {
                  'type': 'string'
                }
              }
              'variables': {}
              'resources': [
                {
                  'copy': {
                    'name': 'networkInterface'
                    'count': '[length(range(0, parameters(\'count\')))]'
                  }
                  'type': 'Microsoft.Network/networkInterfaces'
                  'apiVersion': '2019-07-01'
                  'name': '[format(\'nic-{0}-{1}\', parameters(\'vmName\'), add(range(0, parameters(\'count\'))[copyIndex()], 1))]'
                  'location': '[parameters(\'location\')]'
                  'tags': '[parameters(\'tags\')]'
                  'properties': {
                    'ipConfigurations': [
                      {
                        'name': 'ipconfig1'
                        'properties': {
                          'subnet': {
                            'id': '${vnetId}/subnets/${subnetName}'
                          }
                          'privateIPAllocationMethod': 'Dynamic'
                        }
                      }
                    ]
                  }
                }
                {
                  'copy': {
                    'name': 'sessionHost'
                    'count': '[length(range(0, parameters(\'count\')))]'
                  }
                  'type': 'Microsoft.Compute/virtualMachines'
                  'apiVersion': '2021-07-01'
                  'name': '[format(\'{0}-{1}\', parameters(\'vmName\'), add(range(0, parameters(\'count\'))[copyIndex()], 1))]'
                  'location': '[parameters(\'location\')]'
                  'tags': '[parameters(\'tags\')]'
                  'identity': {
                    'type': 'SystemAssigned'
                  }
                  'properties': {
                    'osProfile': {
                      'computerName': '[format(\'{0}-{1}\', parameters(\'vmName\'), add(range(0, parameters(\'count\'))[copyIndex()], 1))]'
                      'adminUsername': '[parameters(\'localAdminName\')]'
                      'adminPassword': '[parameters(\'localAdminPassword\')]'
                    }
                    'hardwareProfile': {
                      'vmSize': '[parameters(\'vmSize\')]'
                    }
                    'storageProfile': {
                      'imageReference': {
                        'id': '[parameters(\'imageId\')]'
                      }
                    }
                    'diagnosticsProfile': {
                      'bootDiagnostics': {
                        'enabled': true
                      }
                    }
                    'licenseType': '[parameters(\'licenseType\')]'
                    'networkProfile': {
                      'networkInterfaces': [
                        {
                          'properties': {
                            'primary': true
                          }
                          'id': '[resourceId(\'Microsoft.Network/networkInterfaces\', format(\'nic-{0}-{1}\', parameters(\'vmName\'), add(range(0, parameters(\'count\'))[range(0, parameters(\'count\'))[copyIndex()]], 1)))]'
                        }
                      ]
                    }
                  }
                  'dependsOn': [
                    '[resourceId(\'Microsoft.Network/networkInterfaces\', format(\'nic-{0}-{1}\', parameters(\'vmName\'), add(range(0, parameters(\'count\'))[range(0, parameters(\'count\'))[copyIndex()]], 1)))]'
                    '[resourceId(\'Microsoft.Network/networkInterfaces\', format(\'nic-{0}-{1}\', parameters(\'vmName\'), add(range(0, parameters(\'count\'))[range(0, parameters(\'count\'))[copyIndex()]], 1)))]'
                  ]
                }
                {
                  'condition': '[not(parameters(\'aadJoin\'))]'
                  'copy': {
                    'name': 'sessionHostDomainJoin'
                    'count': '[length(range(0, parameters(\'count\')))]'
                  }
                  'type': 'Microsoft.Compute/virtualMachines/extensions'
                  'apiVersion': '2020-06-01'
                  'name': '[format(\'{0}/JoinDomain\', format(\'{0}-{1}\', parameters(\'vmName\'), add(range(0, parameters(\'count\'))[range(0, parameters(\'count\'))[copyIndex()]], 1)))]'
                  'location': '[parameters(\'location\')]'
                  'tags': '[parameters(\'tags\')]'
                  'properties': {
                    'publisher': 'Microsoft.Compute'
                    'type': 'JsonADDomainExtension'
                    'typeHandlerVersion': '1.3'
                    'autoUpgradeMinorVersion': true
                    'settings': {
                      'name': '[parameters(\'domainToJoin\')]'
                      'ouPath': '[parameters(\'ouPath\')]'
                      'user': '[parameters(\'domainJoinUserName\')]'
                      'restart': true
                      'options': 3
                    }
                    'protectedSettings': {
                      'password': '[parameters(\'domainJoinPassword\')]'
                    }
                  }
                  'dependsOn': [
                    '[resourceId(\'Microsoft.Compute/virtualMachines\', format(\'{0}-{1}\', parameters(\'vmName\'), add(range(0, parameters(\'count\'))[range(0, parameters(\'count\'))[copyIndex()]], 1)))]'
                    '[resourceId(\'Microsoft.Compute/virtualMachines\', format(\'{0}-{1}\', parameters(\'vmName\'), add(range(0, parameters(\'count\'))[range(0, parameters(\'count\'))[copyIndex()]], 1)))]'
                  ]
                }
                {
                  'condition': '[parameters(\'aadJoin\')]'
                  'copy': {
                    'name': 'sessionHostAADLogin'
                    'count': '[length(range(0, parameters(\'count\')))]'
                  }
                  'type': 'Microsoft.Compute/virtualMachines/extensions'
                  'apiVersion': '2020-06-01'
                  'name': '[format(\'{0}/AADLoginForWindows\', format(\'{0}-{1}\', parameters(\'vmName\'), add(range(0, parameters(\'count\'))[range(0, parameters(\'count\'))[copyIndex()]], 1)))]'
                  'location': '[parameters(\'location\')]'
                  'tags': '[parameters(\'tags\')]'
                  'properties': {
                    'publisher': 'Microsoft.Azure.ActiveDirectory'
                    'type': 'AADLoginForWindows'
                    'typeHandlerVersion': '1.0'
                    'autoUpgradeMinorVersion': true
                  }
                  'dependsOn': [
                    '[resourceId(\'Microsoft.Compute/virtualMachines\', format(\'{0}-{1}\', parameters(\'vmName\'), add(range(0, parameters(\'count\'))[range(0, parameters(\'count\'))[copyIndex()]], 1)))]'
                  ]
                }
                {
                  'copy': {
                    'name': 'sessionHostAVDAgent'
                    'count': '[length(range(0, parameters(\'count\')))]'
                  }
                  'type': 'Microsoft.Compute/virtualMachines/extensions'
                  'apiVersion': '2020-06-01'
                  'name': '[format(\'{0}/Microsoft.PowerShell.DSC\', format(\'{0}-{1}\', parameters(\'vmName\'), add(range(0, parameters(\'count\'))[range(0, parameters(\'count\'))[copyIndex()]], 1)))]'
                  'location': '[parameters(\'location\')]'
                  'tags': '[parameters(\'tags\')]'
                  'properties': {
                    'publisher': 'Microsoft.Powershell'
                    'type': 'DSC'
                    'typeHandlerVersion': '2.73'
                    'autoUpgradeMinorVersion': true
                    'settings': {
                      'modulesUrl': 'https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_11-22-2021.zip'
                      'configurationFunction': 'Configuration.ps1\\AddSessionHost'
                      'properties': {
                        'hostPoolName': '[parameters(\'hostPoolName\')]'
                        'registrationInfoToken': '[parameters(\'hostPoolToken\')]'
                        'aadJoin': '[parameters(\'aadJoin\')]'
                      }
                    }
                  }
                  'dependsOn': [
                    '[resourceId(\'Microsoft.Compute/virtualMachines\', format(\'{0}-{1}\', parameters(\'vmName\'), add(range(0, parameters(\'count\'))[range(0, parameters(\'count\'))[copyIndex()]], 1)))]'
                    '[resourceId(\'Microsoft.Compute/virtualMachines/extensions\', split(format(\'{0}/JoinDomain\', format(\'{0}-{1}\', parameters(\'vmName\'), add(range(0, parameters(\'count\'))[range(0, parameters(\'count\'))[range(0, parameters(\'count\'))[copyIndex()]]], 1))), \'/\')[0], split(format(\'{0}/JoinDomain\', format(\'{0}-{1}\', parameters(\'vmName\'), add(range(0, parameters(\'count\'))[range(0, parameters(\'count\'))[range(0, parameters(\'count\'))[copyIndex()]]], 1))), \'/\')[1])]'
                  ]
                }
                {
                  'condition': '[parameters(\'installNVidiaGPUDriver\')]'
                  'copy': {
                    'name': 'sessionHostGPUDriver'
                    'count': '[length(range(0, parameters(\'count\')))]'
                  }
                  'type': 'Microsoft.Compute/virtualMachines/extensions'
                  'apiVersion': '2020-06-01'
                  'name': '[format(\'{0}/InstallNvidiaGpuDriverWindows\', format(\'{0}-{1}\', parameters(\'vmName\'), add(range(0, parameters(\'count\'))[range(0, parameters(\'count\'))[copyIndex()]], 1)))]'
                  'location': '[parameters(\'location\')]'
                  'tags': '[parameters(\'tags\')]'
                  'properties': {
                    'publisher': 'Microsoft.HpcCompute'
                    'type': 'NvidiaGpuDriverWindows'
                    'typeHandlerVersion': '1.3'
                    'autoUpgradeMinorVersion': true
                    'settings': {}
                  }
                  'dependsOn': [
                    '[resourceId(\'Microsoft.Compute/virtualMachines\', format(\'{0}-{1}\', parameters(\'vmName\'), add(range(0, parameters(\'count\'))[range(0, parameters(\'count\'))[copyIndex()]], 1)))]'
                  ]
                }
              ]
            }
          }
        }
      ]
    }
  }
}
