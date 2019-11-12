$subs=("9d4350c8-e11c-4007-a923-c1df11a52bab")

foreach ($sub in $subs)
{  
    Select-AzureRmSubscription -SubscriptionId $sub 
    Write-Host "Current Subscription: " $sub
    $res = Get-AzureRmResource 

    #check stroage accounts

    $storages = $res | where ResourceType -EQ "Microsoft.Storage/storageAccounts"

    foreach($storage in $storages)
    {
      $storageRule = Get-AzureRmStorageAccountNetworkRuleSet -ResourceGroupName $storage.ResourceGroupName -AccountName $storage.name
 
      $enable=$storageRule.DefaultAction
       
      if($enable -eq "Deny")
      {
        Write-Output "Azure Storage - Storage firewall rule is enabled on",$storage.name, $storageRule.Bypass, $sotrageRule.DefaultAction
      }
      else 
      {
        Write-Output "Azure Storage - Storage firewall rule is not enabled on",$storage.name 
      }

      if($storageRule.VirtualNetworkRules -ne $null)
      {
        foreach ($rule in $storageRule.VirtualNetworkRules)
        {
          Write-Output "Azure Storage - Storage Network is enabled on",$storage.name,$rule 
        }
      }
      else 
      {
        Write-Output "Azure Storage - Storage Network is not enabled on",$storage.name 
      }
    }
}