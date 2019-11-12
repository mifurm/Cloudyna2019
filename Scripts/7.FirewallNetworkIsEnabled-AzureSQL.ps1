$subs=("9d4350c8-e11c-4007-a923-c1df11a52bab")

foreach ($sub in $subs)
{  
    Select-AzureRmSubscription -SubscriptionId $sub 
    Write-Output "Current Subscription: " $sub
    $res = Get-AzureRmResource 

    $mssqls = $res | where ResourceType -EQ "Microsoft.Sql/servers"
    
    foreach($mssql in $mssqls)
    {
      $firewallRule = $null

      $firewallRule = Get-AzureRmSqlServerFirewallRule -ServerName $mssql.Name -ResourceGroupName $mssql.ResourceGroupName
      if($firewallRule -ne $null)
      {
        foreach ($fw in $firewallRule)
        {
          if ($fw.FirewallRuleName -ne "AllowAllWindowsAzureIps")
          {
            Write-Output  "(Azure SQL Server) Firewall rule is enabled on", $mssql.Name, $fw.FirewallRuleName, $fw.StartIpAddress, $fw.EndIpAddress
          }
          else 
          {
            Write-Output  "(Azure SQL Server) Firewall rule is enabled for Azure Services", $mssql.Name  
          }
        }
      }
      else { 
        Write-Output  "(Azure SQL Server) Firewall rule is not enabled on", $mssql.Name 
      }

      $network=Get-AzureRmResource -ResourceGroupName $mssql.ResourceGroupName -ResourceType Microsoft.Sql/servers/virtualNetworkRules -ResourceName $mssql.Name -ApiVersion 2015-05-01-preview
      
      if($network.Properties -ne $null)
      {
        Write-Output "(Azure SQL Server) - Network is enabled on",$mssql.Name,"for",$network.Properties.virtualNetworkSubnetId
      }
      else 
      { 
        Write-Output "(Azure SQL Server) - Network is NOT enabled on", $mssql.Name
      }
    }
}