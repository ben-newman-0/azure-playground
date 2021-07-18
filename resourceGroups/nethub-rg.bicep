@minLength(1)
@maxLength(4)
param nameEnvironment string

@minLength(1)
@secure()
param vpnClientRootPublicCertData string

var virtualNetworkGatewayName = 'nethub-vgw-${nameEnvironment}-neu-${uniqueString(subscription().subscriptionId)}'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-07-01' = {
  name: 'nethub-vnet-${nameEnvironment}-neu-${uniqueString(subscription().subscriptionId)}'
  location: 'northeurope'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        properties: {
          addressPrefix: '10.1.0.0/24'
        }
        name: 'nethub-snet-nethub-${nameEnvironment}-neu-${uniqueString(subscription().subscriptionId)}'
      }
      {
        properties: {
          addressPrefix: '10.1.1.0/24'
        }
        name: 'GatewaySubnet'
      }
    ]
  }
}

resource publicIPAddressVirtualNetworkGateway 'Microsoft.Network/publicIPAddresses@2020-07-01' = {
  name: 'nethub-pip-vgw-${nameEnvironment}-neu-${uniqueString(subscription().subscriptionId)}'
  location: 'northeurope'
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic' // Basic VGW SKU requires Dynamic
    publicIPAddressVersion: 'IPv4'
  }
}

resource virtualNetworkGateway 'Microsoft.Network/virtualNetworkGateways@2020-07-01' = {
  name: virtualNetworkGatewayName
  location: 'northeurope'
  properties: {
    ipConfigurations: [
      {
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddressVirtualNetworkGateway.id
          }
          subnet: {
            id: virtualNetwork.properties.subnets[1].id
          }
        }
        name: 'default'
      }
    ]
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    vpnGatewayGeneration: 'Generation1'
    enableBgp: false
    sku: {
      name: 'Basic'
      tier: 'Basic'
    }
    vpnClientConfiguration: {
      vpnClientAddressPool: {
        addressPrefixes: [
          '10.2.0.0/24'
        ]
      }
      vpnClientRootCertificates: [
        {
          properties: {
            publicCertData: vpnClientRootPublicCertData
          }
          name: virtualNetworkGatewayName
        }
      ]
      vpnClientProtocols: [
        'SSTP'
      ]
    }
  }
}
