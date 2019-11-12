
$subs=("9d4350c8-e11c-4007-a923-c1df11a52bab")

foreach ($sub in $subs)
{  
  Select-AzureRmSubscription -SubscriptionId $sub 
  Write-Output "Current Subscription: " $sub
    
  $aGs = Get-AzureRmApplicationGateway

  foreach ($ag in $aGs)
  {
    if($ag.SslCertificates -ne $null)
    {
        Write-Output Certificate exists on $ag.Name         
    }
    else 
    {
        Write-Output Certificate does not exists on $ag.Name
    }
  }
}