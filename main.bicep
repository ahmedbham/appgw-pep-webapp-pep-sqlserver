@description('Location for all resources.')
param location string = resourceGroup().location

module hubVNetModule 'modules/hubvnet.bicep' = {
  name: 'hubVNet'
}

module vNetPeerings 'modules/vnetPeers.bicep' = {
  name: 'vnetPeers'
  params: {
    hubVNetName: hubVNetModule.outputs.virtualNetworkName
    spokeVNetName: vnetModule.outputs.virtualNetworkName
  }
  dependsOn:[
    vnetModule
    hubVNetModule
  ]
}

module vnetModule 'modules/vnet.bicep' = {
  name: 'myApp'
  params: {
    location: location
    virtualNetworkName: 'vnet1'
    subnet1Name: 'AppGatewaySubnet'
    subnet2Name: 'WebAppSubnet'
    subnet3Name: 'PrivateEndpointSubnet'
    subnet4Name: 'SqlServerSubnet'
  }
}

module appServiceModule 'modules/app-service.bicep' = {
  name: 'appService'
  params: {
    location: location
    serverFarmName: 'serverFarm'
    site1_Name: 'feweb-${uniqueString(resourceGroup().id)}'
    site2_Name: 'webapi-${uniqueString(resourceGroup().id)}'
    feAppPrivateEndpointName: 'feAppPrivateEndpoint'
    apiAppPrivateEndpointName: 'apiAppPrivateEndpoint'
    virtualNetworkName: vnetModule.outputs.virtualNetworkName
    virtualNetworkId: vnetModule.outputs.virtualNetworkId
    delegationSubnet: vnetModule.outputs.subnet2Name
    privateEndpointSubnet: vnetModule.outputs.subnet3Name
  }
}

module sqlServerServiceModule 'modules/sql-server.bicep' = {
  name: 'sqlServer'
  params: {
    location: location
    sqlAdministratorLogin: 'sqldbadmin'
    sqlAdministratorLoginPassword: 'Azur3K1ck3dM3!'
    sqlServerPrivateEndpointName: 'sqlServerPrivateEndpoint'
    virtualNetworkName: vnetModule.outputs.virtualNetworkName
    virtualNetworkId: vnetModule.outputs.virtualNetworkId
    privateEndpointSubnet: vnetModule.outputs.subnet3Name
  }
}

module appGatewayModule 'modules/app-gateway.bicep' = {
  name: 'appGateway'
  params: {
    location: location
    appGatewayName: 'myAppGateway'
    webAppHostName: appServiceModule.outputs.webAppHostName
    apiAppHostName: appServiceModule.outputs.apiAppHostName
    virtualNetworkName: vnetModule.outputs.virtualNetworkName
    appGatewaySubnet: vnetModule.outputs.subnet4Name
  }
}

output appGatewayUrl string = appGatewayModule.outputs.appGatewayUrl
output webApp1Url string = appServiceModule.outputs.webApp1Url
output webApp2Url string = appServiceModule.outputs.webApp2Url
