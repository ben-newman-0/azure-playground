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

  resource virtualMachineDns_customScript 'extensions@2020-12-01' = {
    name: 'CustomScript'
    location: 'northeurope'
    properties: {
      publisher: 'Microsoft.Azure.Extensions'
      type: 'CustomScript'
      typeHandlerVersion: '2.1'
      settings: {
        // Script content generated by running 'cat ./resourceGroups/nethub/dns-fwd/init.sh | base64 -w0'
        script: 'YXB0LWdldCB1cGRhdGUgJiYgYXB0LWdldCB1cGdyYWRlIC15CmFwdC1nZXQgaW5zdGFsbCAteSBiaW5kOQoKY2F0ID4gL2V0Yy9iaW5kL25hbWVkLmNvbmYub3B0aW9ucyA8PCBFT0YKb3B0aW9ucyB7CiAgZGlyZWN0b3J5ICIvdmFyL2NhY2hlL2JpbmQiOwoKICByZWN1cnNpb24geWVzOwogIGFsbG93LXF1ZXJ5IHsKICAgIDEwLjAuMC4wLzg7CiAgICAxNzIuMTYuMC4wLzEyOwogICAgMTkyLjE2OC4wLjAvMTY7CiAgICAxMjcuMC4wLjE7CiAgfTsKCiAgZm9yd2FyZGVycyB7IDE2OC42My4xMjkuMTY7IH07CiAgZm9yd2FyZCBvbmx5Owp9OwpFT0YKCnNlcnZpY2UgYmluZDkgcmVzdGFydAo='
      }
    }
  }
}
