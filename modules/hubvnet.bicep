@description('Hub Virtual Network Address Space in CIDR format')
param addressSpace string = '10.100.0.0/16'

@description('Firewall Subnet Name')
param firewallSubnetName string = 'firewallSubnet'

@description('CIDR for firewall subnet - must be within vnet CIDR')
param firewallSubnetCIDR string = '10.100.0.0/24'

@description('DNS subnet name')
param dnsSubnetName string = 'dnsSubnet'

@description('CIDER for dns subnet - must be within vnet CIDR')
param dnsSubnetCIDR string = '10.100.1.0/24'

@description('VNet Name')
param vNetName string = 'HubVNet'

resource hubVNet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vNetName
  location: resourceGroup().location
  properties: {
    addressSpace : {
      addressPrefixes : [
        addressSpace
      ]
    }
    subnets: [
      {
        name: firewallSubnetName
        properties: {
          addressPrefix: firewallSubnetCIDR
        }
      }
      {
        name: dnsSubnetName
        properties: {
          addressPrefix: dnsSubnetCIDR
        }
      }
    ]
  }
}

output virtualNetworkName string = hubVNet.name
