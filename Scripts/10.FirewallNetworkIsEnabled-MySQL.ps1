$subs=("9d4350c8-e11c-4007-a923-c1df11a52bab")

foreach ($sub in $subs)
{  
  Select-AzureRmSubscription -SubscriptionId $sub 
  Write-Output "Current Subscription: " $sub
  
  $MySQLs=Get-AzureRmResource -ResourceType Microsoft.DBforMySQL/servers

  foreach($MySQL in $MySQLs)
  {
    $msql= $MySQL.name
    $firewallRule = $null
    $firewallRule=Get-AzureRmResource -ResourceGroupName $MySQL.ResourceGroupName -ResourceType Microsoft.DBforMySQL/servers/firewallRules -ResourceName $msql -ApiVersion 2017-12-01

    if($firewallRule -ne $null)
    {
      Write-Output "Azure MySQL firewall rule" is enabled  on $MySQL.name for adresses $firewallRule.Properties
    }
    else 
    {
      Write-Output "Azure MySQL firewall rule" is not enabled on $MySQL.name for adresses $firewallRule.Properties
    }
 
    $firewallNetowork = $null
    $firewallNetowork=Get-AzureRmResource  -ResourceGroupName $MySQL.ResourceGroupName -ResourceType Microsoft.DBforMySQL/servers/virtualNetworkRules -ResourceName $MySQL.name -ApiVersion 2017-12-01

    if($firewallNetowork -ne $null)
    {
      Write-Output "Azure MySQL Network " is enabled on $MySQL.name for network $firewallNetowork.Properties.virtualNetworkSubnetId
    }
    else 
    {
      Write-Output "Azure MySQL Network" is not enabled on $MySQL.name $firewallNetowork.Properties.virtualNetworkSubnetId
    }
  }
}