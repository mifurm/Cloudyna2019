$subs=("9d4350c8-e11c-4007-a923-c1df11a52bab")

foreach ($sub in $subs)
{  
   Select-AzureRmSubscription -SubscriptionId $sub 
   Write-Output "Subscription: " $sub

    $cerRes=$null
    $cerRes = Get-AzureRmWebAppCertificate
    if ($cerRes -ne $null)
    { 
        foreach($cer in $cerRes){
            Write-Host "Certificate is in use", $cer.Name 
        }
    }
}