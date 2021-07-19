@minLength(1)
@maxLength(4)
param nameEnvironment string

@minLength(1)
@secure()
param vpnClientRootPublicCertData string

@minLength(6)
@maxLength(72)
@secure()
param virtualMachineDnsAdminPassword string

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

resource networkInterfaceDns 'Microsoft.Network/networkInterfaces@2020-07-01' = {
  name: 'nethub-nic-dns-${nameEnvironment}-neu-${uniqueString(subscription().subscriptionId)}'
  location: 'northeurope'
  properties: {
    ipConfigurations: [
      {
        properties: {
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
        }
        name: 'nethub'
      }
    ]
  }
}

var virtualMachineDnsName = 'nethub-vm-dns-${nameEnvironment}-neu-${uniqueString(subscription().subscriptionId)}'
resource virtualMachineDns 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: virtualMachineDnsName
  location: 'northeurope'
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        name: 'nethub-osdisk-dns-${nameEnvironment}-neu-${uniqueString(subscription().subscriptionId)}'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    osProfile: {
      computerName: virtualMachineDnsName
      adminUsername: 'adm-dns'
      adminPassword: virtualMachineDnsAdminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaceDns.id
        }
      ]
    }
  }
  identity: {
    type: 'SystemAssigned' // Needed for AAD auth extension
  }

  resource virtualMachineDns_extensionAad 'extensions@2020-12-01' = {
    name: 'AADSSHLoginForLinux'
    location: 'northeurope'
    properties: {
      publisher: 'Microsoft.Azure.ActiveDirectory'
      type: 'AADSSHLoginForLinux'
      typeHandlerVersion: '1.0'
    }
  }
}
