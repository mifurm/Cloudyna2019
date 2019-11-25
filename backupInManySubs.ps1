$Connection = New-Object System.Data.SQLClient.SQLConnection
$Connection.ConnectionString = ""
$Connection.Open()
$Command = New-Object System.Data.SQLClient.SQLCommand
$Command.Connection = $Connection
 
$subs=Get-AzureRmSubscription
foreach ($sub in $subs)
{  
    Set-AzureRmContext -SubscriptionId $sub.Id
    Write-Host "Current Subscription: " $sub.Id
    $vaults=Get-AzureRmRecoveryServicesVault
    foreach ($vault in $vaults)
    {
        Set-AzureRmRecoveryServicesVaultContext -Vault $vault
        $sql = "insert into subscribtiondetails values ('"+ $sub.Name+"','"+$sub.Id+"','"+$vault.Name+"',1)"
        $Command.CommandText = $sql
        $Command.ExecuteScalar()
        Write-Host "Current Backup Vault: " $vault.Name
        Write-Host "-----------------------------------------------------"
        $jobs=Get-AzureRmRecoveryServicesBackupJob -VaultId $vault.Id
        $Command2 = New-Object System.Data.SQLClient.SQLCommand
        $Command2.Connection = $Connection
        foreach ($job in $jobs)
        {
            $sql2 = "insert into jobdetails values ('3','"+$vault.Id+"','','','','','','','','','','','','','')'"
            $Command2.CommandText=$sql2;
            $Command.ExecuteScalar()
 
        }
        Write-Host "-----------------------------------------------------"
    }
}
