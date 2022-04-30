@description('Location for all resources.')
param location string = resourceGroup().location

@description('The administrator username of the SQL logical server')
param sqlAdministratorLogin string = 'sqlsvradmin'

@description('The administrator password of the SQL logical server.')
@secure()
param sqlAdministratorLoginPassword string

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
    hubVNetName: hubVNetModule.outputs.virtualNetworkName
    spokeVNetName: vnetModule.outputs.virtualNetworkName
    delegationSubnet: vnetModule.outputs.subnet2Name
    privateEndpointSubnet: vnetModule.outputs.subnet3Name
  }
}

module sqlServerServiceModule 'modules/sql-server.bicep' = {
  name: 'sqlServer'
  params: {
    location: location
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    sqlServerPrivateEndpointName: 'sqlServerPrivateEndpoint'
    hubVNetName: hubVNetModule.outputs.virtualNetworkName
    spokeVNetName: vnetModule.outputs.virtualNetworkName
    privateEndpointSubnet: vnetModule.outputs.subnet3Name
  }
}

module appGatewayModule 'modules/app-gateway.bicep' = {
  name: 'appGateway'
  params: {
    location: location
    appGatewayName: 'myAppGateway'
    webAppHostName: appServiceModule.outputs.webAppHostName
    virtualNetworkName: vnetModule.outputs.virtualNetworkName
    appGatewaySubnet: vnetModule.outputs.subnet4Name
  }
}

output appGatewayUrl string = appGatewayModule.outputs.appGatewayUrl
output webApp1Url string = appServiceModule.outputs.webApp1Url
output webApp2Url string = appServiceModule.outputs.webApp2Url
