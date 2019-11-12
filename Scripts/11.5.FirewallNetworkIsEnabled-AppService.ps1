$subs=("9d4350c8-e11c-4007-a923-c1df11a52bab")

foreach ($sub in $subs)
{    
  Select-AzureRmSubscription -SubscriptionId $sub 
  Write-Output "Current Subscription: " $sub
    
  $webapps=Get-AzureRmResource -ResourceType Microsoft.Web/sites

  foreach($webapp in $webapps)
  {
    $wapp= $webapp.Name + "/virtualNetwork"
    $firewallRule = $null

    $firewallRule=Get-AzureRmResource -ResourceGroupName $webapp.ResourceGroupName -ResourceType Microsoft.Web/sites/config -ResourceName $webapp.Name -ApiVersion 2018-02-01

    $firewallRule=$firewallRule.Properties.ipSecurityRestrictions

    if($firewallRule -ne $null)
    {
      Write-Output "WebApp IP-restriction" is enabled on $webapp.Name $firewallRule.Properties.ipSecurityRestrictions
    }
    else 
    {
      Write-Output "WebApp IP-restriction" is not  enabled on $webapp.Name $firewallRule.Properties.ipSecurityRestrictions
    }

    $firewallNetowork=Get-AzureRmResource -ResourceGroupName $webapp.ResourceGroupName -ResourceType Microsoft.Web/sites/config -ResourceName $wapp -ApiVersion 2018-02-01

    $firewallNetowork=$firewallNetowork.Properties.subnetResourceId 
    if($firewallNetowork -ne $null)
    {
      Write-Output "WebApp firewall network rule:" is enabled on $webapp.Name $firewallNetowork.Properties.subnetResourceId 
    }
    else 
    {
      Write-Output "WebApp firewall network rule" is not enabled on $webapp.Name $firewallNetowork.Properties.subnetResourceId 
    }
  }
}