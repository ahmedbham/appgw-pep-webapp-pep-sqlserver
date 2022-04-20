@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the VNet')
param virtualNetworkName string = 'vnet1'

@description('CIDR of your VNet')
param virtualNetwork_CIDR string = '10.200.0.0/16'

@description('Name of the subnet')
param subnet1Name string = 'Subnet1'

@description('Name of the subnet')
param subnet2Name string = 'Subnet2'

@description('Name of the subnet')
param subnet3Name string = 'Subnet3'

@description('Name of the subnet')
param subnet4Name string = 'Subnet4'

@description('CIDR of your subnet')
param subnet1_CIDR string = '10.200.1.0/24'

@description('CIDR of your subnet')
param subnet2_CIDR string = '10.200.2.0/24'

@description('CIDR of your subnet')
param subnet3_CIDR string = '10.200.3.0/24'

@description('CIDR of your subnet')
param subnet4_CIDR string = '10.200.4.0/24'

@description('The administrator username of the SQL logical server')
param sqlAdministratorLogin string

@description('The administrator password of the SQL logical server.')
@secure()
param sqlAdministratorLoginPassword string

@description('Name of the Web Farm')
param serverFarmName string = 'serverfarm'

@description('Web App 1 name must be unique DNS name worldwide')
param site1_Name string = 'feweb-${uniqueString(resourceGroup().id)}'

@description('Web App 2 name must be unique DNS name worldwide')
param site2_Name string = 'webapi-${uniqueString(resourceGroup().id)}'

@description('SKU name, must be minimum P1v2')
@allowed([
  'P1v2'
  'P2v2'
  'P3v2'
])
param skuName string = 'P1v2'

@description('SKU size, must be minimum P1v2')
@allowed([
  'P1v2'
  'P2v2'
  'P3v2'
])
param skuSize string = 'P1v2'

@description('SKU family, must be minimum P1v2')
@allowed([
  'P1v2'
  'P2v2'
  'P3v2'
])
param skuFamily string = 'P1v2'

@description('Name of your Private Endpoint')
param privateEndpointName1 string = 'PrivateEndpoint1'

@description('Name of your Private Endpoint')
param privateEndpointName2 string = 'PrivateEndpoint2'

@description('Name of your Private Endpoint')
param privateEndpointName3 string = 'PrivateEndpoint3'

@description('Link name between your Private Endpoint and your Web App')
param privateLinkConnectionName1 string = 'PrivateEndpointLink1'

@description('Link name between your Private Endpoint and your Web App')
param privateLinkConnectionName2 string = 'PrivateEndpointLink2'

@description('Link name between your Private Endpoint and your Web App')
param privateLinkConnectionName3 string = 'PrivateEndpointLink3'

param appGatewayName string = 'myAppGateway'

var sqlServerName_var = 'sqlserver${uniqueString(resourceGroup().id)}'
var databaseName_var = '${sqlServerName_var}/sample-db'
var webapp_dns_name = '.azurewebsites.net'
var privateDNSZoneNameSites = 'privatelink.azurewebsites.net'
var SKU_tier = 'PremiumV2'
var privateDnsZoneNameSql = 'privatelink${environment().suffixes.sqlServerHostname}'
// var pvtendpointdnsgroupname_var = '${privateEndpointName3}/mydnsgroupname'

var applicationGatewayName_var = '${appGatewayName}-${uniqueString(resourceGroup().id)}'
var applicationGatewaySkuSize = 'Standard_v2'
var applicationGatewayTier = 'Standard_v2'
var applicationGatewayAutoScaleMinCapacity = 2
var applicationGatewayAutoScaleMaxCapacity = 5
var appGwIpConfigName = 'appGatewayIpConfigName'
var appGwFrontendPortName = 'appGatewayFrontendPort_80'
var appGwFrontendPort = 80
var appGwFrontendPortId = resourceId('Microsoft.Network/applicationGateways/frontendPorts/', applicationGatewayName_var, appGwFrontendPortName)
var appGwFrontendIpConfigName = 'appGatewayPublicFrontendIpConfig'
var appGwFrontendIpConfigId = resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations/', applicationGatewayName_var, appGwFrontendIpConfigName)
var appGwHttpSettingName = 'appGatewayHttpSetting_80'
var appGwHttpSettingId = resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection/', applicationGatewayName_var, appGwHttpSettingName)
var appGwHttpSettingProbeName = 'appGatewayHttpSettingProbe_80'
var appGwBackendAddressPoolName = 'appGatewayWebAppBackendPool'
var appGwBackendAddressPoolId = resourceId('Microsoft.Network/applicationGateways/backendAddressPools/', applicationGatewayName_var, appGwBackendAddressPoolName)
var appGwListenerName = 'appGatewayListener'
var appGwListenerId = resourceId('Microsoft.Network/applicationGateways/httpListeners/', applicationGatewayName_var, appGwListenerName)
var appGwRoutingRuleName = 'appGatewayRoutingRule'
var publicIpAddressName_var = 'myAppGatewayPublicIp-${uniqueString(resourceGroup().id)}'
var publicIpAddressSku = 'Standard'
var publicIpAddressAllocationType = 'Static'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetwork_CIDR
      ]
    }
    subnets: [
      {
        name: subnet1Name
        properties: {
          addressPrefix: subnet1_CIDR
          serviceEndpoints: [
            {
              service: 'Microsoft.Web'
              locations: [
                '*'
              ]
            }
          ]
        }
      }
      {
        name: subnet2Name
        properties: {
          addressPrefix: subnet2_CIDR
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverfarms'
              }
            }
          ]
        }
      }
      {
        name: subnet3Name
        properties: {
          addressPrefix: subnet3_CIDR
          
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: subnet4Name
        properties: {
          addressPrefix: subnet4_CIDR
        }
      }
    ]
  }
}

resource sqlServerName 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: sqlServerName_var
  location: location
  tags: {
    displayName: sqlServerName_var
  }
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: '12.0'
    publicNetworkAccess: 'Disabled'
  }
}

resource databaseName 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  name: databaseName_var
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
  tags: {
    displayName: databaseName_var
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    // edition: 'Basic'
    maxSizeBytes: 104857600
    // requestedServiceObjectiveName: 'Basic'
    sampleName: 'AdventureWorksLT'
  }
  dependsOn: [
    sqlServerName
  ]
}

resource serverFarm 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: serverFarmName
  location: location
  sku: {
    name: skuName
    tier: SKU_tier
    size: skuSize
    family: skuFamily
    capacity: 1
  }
  kind: 'app'
}

resource webApp1 'Microsoft.Web/sites@2021-03-01' = {
  name: site1_Name
  location: location
  kind: 'app'
  properties: {
    serverFarmId: serverFarm.id
    siteConfig: {
      minTlsVersion: '1.2'
      ipSecurityRestrictions: [
        {
          vnetSubnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets',virtualNetwork.name ,subnet1Name)
          action: 'Allow'
          tag: 'Default'
          priority: 200
          name: 'appGatewaySubnet'
          description: 'Isolate traffic to subnet containing Azure Application Gateway'
        }
      ]
    }
  }
}

resource webApp2 'Microsoft.Web/sites@2021-03-01' = {
  name: site2_Name
  location: location
  kind: 'app'
  properties: {
    serverFarmId: serverFarm.id
    siteConfig: {
      minTlsVersion: '1.2'
      ipSecurityRestrictions: [
        {
          vnetSubnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets',virtualNetwork.name ,subnet1Name)
          action: 'Allow'
          tag: 'Default'
          priority: 200
          name: 'appGatewaySubnet'
          description: 'Isolate traffic to subnet containing Azure Application Gateway'
        }
      ]
    }
  }
}

resource webApp2AppSettingsApp1 'Microsoft.Web/sites/config@2020-06-01' = {
  parent: webApp1
  name: 'appsettings'
  properties: {
    WEBSITE_DNS_SERVER: '168.63.129.16'
    WEBSITE_VNET_ROUTE_ALL: '1'
  }
}

resource webApp2AppSettingsApp2 'Microsoft.Web/sites/config@2020-06-01' = {
  parent: webApp2
  name: 'appsettings'
  properties: {
    WEBSITE_DNS_SERVER: '168.63.129.16'
    WEBSITE_VNET_ROUTE_ALL: '1'
  }
}

resource webApp1Binding 'Microsoft.Web/sites/hostNameBindings@2019-08-01' = {
  parent: webApp1
  name: '${webApp1.name}${webapp_dns_name}'
  properties: {
    siteName: webApp1.name
    hostNameType: 'Verified'
  }
}

resource webApp2Binding 'Microsoft.Web/sites/hostNameBindings@2019-08-01' = {
  parent: webApp2
  name: '${webApp2.name}${webapp_dns_name}'
  properties: {
    siteName: webApp2.name
    hostNameType: 'Verified'
  }
}

resource webApp1NetworkConfig 'Microsoft.Web/sites/networkConfig@2020-06-01' = {
  parent: webApp1
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets',virtualNetwork.name ,subnet2Name)
  }
}

resource webApp2NetworkConfig 'Microsoft.Web/sites/networkConfig@2020-06-01' = {
  parent: webApp2
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets',virtualNetwork.name ,subnet2Name)
  }
}

resource privateEndpoint1 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: privateEndpointName1
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets',virtualNetwork.name ,subnet3Name)
    }
    privateLinkServiceConnections: [
      {
        name: privateLinkConnectionName1
        properties: {
          privateLinkServiceId: webApp1.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource privateEndpoint2 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: privateEndpointName2
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets',virtualNetwork.name ,subnet3Name)
    }
    privateLinkServiceConnections: [
      {
        name: privateLinkConnectionName2
        properties: {
          privateLinkServiceId: webApp2.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource privateEndpoint3 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: privateEndpointName3
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets',virtualNetwork.name ,subnet3Name)
    }
    privateLinkServiceConnections: [
      {
        name: privateLinkConnectionName3
        properties: {
          privateLinkServiceId: sqlServerName.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}

resource privateDnsZonesSql 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateDnsZoneNameSql
  location: 'global'
  dependsOn: [
    virtualNetwork
  ]
}

resource privateDnsZoneLinkSql 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privateDnsZonesSql
  name: '${privateDnsZonesSql.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource privateDnsZoneGroupSql 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  parent: privateEndpoint3
  name: 'dnsgroupnameSql'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZonesSql.id
        }
      }
    ]
  }
}

resource privateDnsZonesSites 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateDNSZoneNameSites
  location: 'global'
  dependsOn: [
    virtualNetwork
  ]
}

resource privateDnsZoneLinkSites 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privateDnsZonesSites
  name: '${privateDnsZonesSites.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource privateDnsZoneGroupSites1 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  parent: privateEndpoint1
  name: 'dnsgroupnamesite1'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZonesSites.id
        }
      }
    ]
  }
}

resource privateDnsZoneGroupSites2 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  parent: privateEndpoint2
  name: 'dnsgroupnamesite2'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZonesSites.id
        }
      }
    ]
  }
}

resource publicIpAddressName 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
  name: publicIpAddressName_var
  location: location
  sku: {
    name: publicIpAddressSku
  }
  properties: {
    publicIPAllocationMethod: publicIpAddressAllocationType
    dnsSettings: {
      domainNameLabel: toLower('lazardahmedbham1')
    }
  }
}

resource applicationGatewayName 'Microsoft.Network/applicationGateways@2020-05-01' = {
  name: applicationGatewayName_var
  location: location
  properties: {
    sku: {
      name: applicationGatewaySkuSize
      tier: applicationGatewayTier
    }
    gatewayIPConfigurations: [
      {
        name: appGwIpConfigName
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets',virtualNetwork.name ,subnet1Name)
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: appGwFrontendIpConfigName
        properties: {
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses',publicIpAddressName.name)
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: appGwFrontendPortName
        properties: {
          port: appGwFrontendPort
        }
      }
    ]
    backendAddressPools: [
      {
        name: appGwBackendAddressPoolName
        properties: {
          backendAddresses: [
            {
              fqdn: webApp1.properties.hostNames[0]
            }
            {
              fqdn: webApp2.properties.hostNames[0]
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: appGwHttpSettingName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 20
          pickHostNameFromBackendAddress: true
        }
      }
    ]
    httpListeners: [
      {
        name: appGwListenerName
        properties: {
          frontendIPConfiguration: {
            id: appGwFrontendIpConfigId
          }
          frontendPort: {
            id: appGwFrontendPortId
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: appGwRoutingRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: appGwListenerId
          }
          backendAddressPool: {
            id: appGwBackendAddressPoolId
          }
          backendHttpSettings: {
            id: appGwHttpSettingId
          }
        }
      }
    ]
    enableHttp2: true
    probes: [
      {
        name: appGwHttpSettingProbeName
        properties: {
          interval: 30
          minServers: 0
          path: '/'
          protocol: 'Http'
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
        }
      }
    ]
    autoscaleConfiguration: {
      minCapacity: applicationGatewayAutoScaleMinCapacity
      maxCapacity: applicationGatewayAutoScaleMaxCapacity
    }
  }
}

output appGatewayUrl string = 'http://${publicIpAddressName.properties.dnsSettings.fqdn}/'
output webApp1Url string = 'http://${webApp1.properties.hostNames[0]}/'
output webApp2Url string = 'http://${webApp2.properties.hostNames[0]}/'
