@minLength(1)
@maxLength(4)
param nameEnvironment string

resource networkWatcher 'Microsoft.Network/networkWatchers@2020-07-01' = {
  name: 'net-nw-${nameEnvironment}-neu-${uniqueString(subscription().subscriptionId)}'
  location: 'northeurope'
}
