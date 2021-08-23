targetScope = 'resourceGroup'

////////////////
// Parameters //
////////////////
@minLength(1)
@maxLength(4)
param nameEnvironment string

@secure()
@minLength(8)
@maxLength(128)
@description('Password to use for the SQL Server administrator account. Username will be the name of the server prepended with "adm-".')
param sqlAdminPassword string

////////////////////////
// Existing resources //
////////////////////////
// The following resources get symbolic references to existing resources,
// so we can reference their properties later.

resource commonLogAnalytics 'Microsoft.OperationalInsights/workspaces@2020-08-01' existing = {
  name: 'com-log-${nameEnvironment}-neu-${uniqueString(subscription().subscriptionId)}'
  scope: resourceGroup('com-rg-${nameEnvironment}-neu')
}

///////////////
// Resources //
///////////////

// SQL server
resource sqlServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: 'advisors-sql-${nameEnvironment}-${uniqueString(subscription().subscriptionId)}'
  location: resourceGroup().location
  properties: {
    administratorLogin: 'adm-advisors-sql-${nameEnvironment}-${uniqueString(subscription().subscriptionId)}'
    administratorLoginPassword: sqlAdminPassword
  }

  resource sqlServer_admins 'administrators@2021-02-01-preview' = {
    name: 'ActiveDirectory'
    properties: {
      administratorType: 'ActiveDirectory'
      login: 'admins'
      sid: 'cb4d6e3e-8c84-4632-b3fb-1af9ef3be1cc'
      // Azure defaults tenantId to target tenant.
      // Only defined here to stop noise in WhatIf deployments.
      tenantId: subscription().tenantId
    }
  }

  // Advisors config cannot be deployed in parallel, so use dependsOn to ensure configured in series.
  resource sqlServer_advisor_createIndex 'advisors@2014-04-01' = {
    name: 'CreateIndex'
    properties: {
      autoExecuteValue: 'Enabled'
    }
  }

  resource sqlServer_advisor_dropIndex 'advisors@2014-04-01' = {
    name: 'DropIndex'
    dependsOn: [
      sqlServer_advisor_createIndex
    ]
    properties: {
      autoExecuteValue: 'Enabled'
    }
  }

  resource sqlServer_advisor_forceLastGoodPlan 'advisors@2014-04-01' = {
    name: 'ForceLastGoodPlan'
    dependsOn: [
      sqlServer_advisor_dropIndex
    ]
    properties: {
      autoExecuteValue: 'Enabled'
    }
  }
}

// SQL databases
resource sqlServer_master 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  // Explicitly define master DB so we can set server-level diagnostic settings later.
  name: 'master'
  parent: sqlServer
  location: resourceGroup().location
}

resource sqlServer_wwi 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  name: 'advisors-sqldb-aw-${nameEnvironment}-${uniqueString(subscription().subscriptionId)}'
  parent: sqlServer
  location: resourceGroup().location
  properties: {
    sampleName: 'AdventureWorksLT'
  }
}

/////////////////
// Diagnostics //
/////////////////
// Azure defaults retentionPolicy objets to disabled.
// Only defined in logs below to stop noise in WhatIf deployments.

resource sqlServer_diagnostics 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  name: commonLogAnalytics.name
  scope: sqlServer
  properties: {
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    workspaceId: commonLogAnalytics.id
  }
}

resource sqlServer_master_diagnostics 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  name: commonLogAnalytics.name
  scope: sqlServer_master
  properties: {
    metrics: [
      {
        category: 'Basic'
        enabled: true
      }
      {
        category: 'InstanceAndAppAdvanced'
        enabled: true
      }
      {
        category: 'WorkloadManagement'
        enabled: true
      }
    ]
    logs: [
      {
        category: 'SQLInsights'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
      {
        category: 'AutomaticTuning'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
      {
        category: 'QueryStoreRuntimeStatistics'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
      {
        category: 'QueryStoreWaitStatistics'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
      {
        category: 'Errors'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
      {
        category: 'DatabaseWaitStatistics'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
      {
        category: 'Timeouts'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
      {
        category: 'Blocks'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
      {
        category: 'Deadlocks'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
    ]
    workspaceId: commonLogAnalytics.id
  }
}
