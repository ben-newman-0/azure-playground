@minLength(1)
@maxLength(4)
param nameEnvironment string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: 'com-log-${nameEnvironment}-neu-${uniqueString(subscription().subscriptionId)}'
  location: 'northeurope'
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 31 // Retention for 31 days is free
    workspaceCapping: {
      dailyQuotaGb: any('0.161') // 5GB free per month / 31 = 0.161
    }
    publicNetworkAccessForIngestion: 'Disabled'
    publicNetworkAccessForQuery: 'Disabled'
  }
}

resource networkWatcher 'Microsoft.Network/networkWatchers@2020-07-01' = {
  name: 'com-nw-${nameEnvironment}-neu'
  location: 'northeurope'
}
