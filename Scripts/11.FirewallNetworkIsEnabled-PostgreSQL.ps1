$subs=("9d4350c8-e11c-4007-a923-c1df11a52bab")

foreach ($sub in $subs)
{    
  Select-AzureRmSubscription -SubscriptionId $sub 
  Write-Output "Current Subscription: " $sub

  $PostgreSQLs=Get-AzureRmResource -ResourceType Microsoft.DBforPostgreSQL/servers

  foreach($PostgreSQL in $PostgreSQLs)
  {
    $possql= $PostgreSQL.name 
    $firewallRule = $null
    $firewallRule=Get-AzureRmResource -ResourceGroupName $PostgreSQL.ResourceGroupName -ResourceType Microsoft.DBforPostgreSQL/servers/firewallRules -ResourceName $PostgreSQL.name -ApiVersion 2017-12-01

    if($firewallRule -ne $null)
    {
      Write-Output "PostgreSQL firewall Rule " is enabled on $PostgreSQL.name for addresses $firewallRule.Properties
    }
    else 
    {
      Write-Output "PostgreSQL firewall Rule" is not enabled on $PostgreSQL.name for addresses $firewallRule.Properties
    }
  
    $firewallNetowork=Get-AzureRmResource -ResourceGroupName $PostgreSQL.ResourceGroupName -ResourceType Microsoft.DBforPostgreSQL/servers/virtualNetworkRules -ResourceName $possql -ApiVersion 2017-12-01
    
    if($firewallNetowork -ne $null)
    {
      Write-Output "PostgreSQL Network"  is  enabled  on  $PostgreSQL.name for network $firewallNetowork.Properties.virtualNetworkSubnetId     
    }
    else 
    {
      Write-Output "PostgreSQL Network"  is not enabled  on  $PostgreSQL.name for network $firewallNetowork.Properties.virtualNetworkSubnetId
    }
  }
}