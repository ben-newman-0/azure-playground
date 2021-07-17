@minLength(1)
@maxLength(4)
param nameEnvironment string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-07-01' = {
  name: 'nethub-vnet-${nameEnvironment}-neu-${uniqueString(subscription().subscriptionId)}'
  location: 'northeurope'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
  }
}

resource publicIPAddressVirtualNetworkGateway 'Microsoft.Network/publicIPAddresses@2020-07-01' = {
  name: 'nethub-pip-vgw-${nameEnvironment}-neu-${uniqueString(subscription().subscriptionId)}'
  location: 'northeurope'
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}
