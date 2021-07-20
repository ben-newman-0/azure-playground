# Script that locally overrides all Azure Public DNS zone forwarders that support Private Link.
# Must be run from an elevated PowerShell prompt.
# Example: ./ForwardPrivateLinkDomains.ps1 -NameServer 10.0.0.1 -Regions ('northeurope')

[CmdletBinding()]
param (
    # IP address of the DNS server to forward requests to.
    [Parameter()]
    [String]
    $NameServer,

    # Array of Regions where resources are deployed (e.g. northeurope, uksouth).
    [Parameter()]
    [Array]
    $Regions
)

Add-DnsClientNrptRule -Namespace ".azure-automation.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".database.windows.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".sql.azuresynapse.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".sqlondemand.azuresynapse.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".dev.azuresynapse.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".blob.core.windows.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".table.core.windows.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".queue.core.windows.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".file.core.windows.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".web.core.windows.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".dfs.core.windows.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".documents.azure.com" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".mongo.cosmos.azure.com" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".cassandra.cosmos.azure.com" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".gremlin.cosmos.azure.com" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".table.cosmos.azure.com" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".postgres.database.azure.com" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".mysql.database.azure.com" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".mariadb.database.azure.com" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".vault.azure.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".vaultcore.azure.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".search.windows.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".azurecr.io" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".azconfig.io" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".servicebus.windows.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".servicebus.windows.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".azure-devices.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".servicebus.windows.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".servicebus.windows.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".eventgrid.azure.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".eventgrid.azure.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".azurewebsites.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".api.azureml.ms" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".notebooks.azure.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".instances.azureml.ms" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".aznbcontent.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".service.signalr.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".monitor.azure.com" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".oms.opinsights.azure.com" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".ods.opinsights.azure.com" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".agentsvc.azure-automation.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".cognitiveservices.azure.com" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".afs.azure.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".datafactory.azure.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".adf.azure.com" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".redis.cache.windows.net" -NameServers $NameServer
Add-DnsClientNrptRule -Namespace ".redisenterprise.cache.azure.net" -NameServers $NameServer

# Loop over region-specific private link domains.
foreach($region in $Regions) {
    Add-DnsClientNrptRule -Namespace ".$region.batch.azure.com" -NameServers $NameServer
    Add-DnsClientNrptRule -Namespace ".$region.azmk8s.io" -NameServers $NameServer
    Add-DnsClientNrptRule -Namespace ".$region.backup.windowsazure.com" -NameServers $NameServer
    Add-DnsClientNrptRule -Namespace ".$region.hypervrecoverymanager.windowsazure.com" -NameServers $NameServer
}
