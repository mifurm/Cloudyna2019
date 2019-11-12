#list of Subscriptions
$subs=("9d4350c8-e11c-4007-a923-c1df11a52bab")

foreach ($sub in $subs)
{  
    Select-AzureRmSubscription -SubscriptionId $sub 
    Write-Host "Current Subscription: " $sub

    $resAll =  Get-AzureRmResource
    #choose proper Log Analytics workspace
    $insigts = "logana01mf" 
    $ResToLog = $resAll | where { $_.ResourceType -Match "Microsoft.KeyVault/vaults" -or $_.ResourceType -Match "Microsoft.Network/networkSecurityGroups" -or $_.ResourceType -Match "Microsoft.Compute/virtualMachine" -or $_.ResourceType -Match "Microsoft.Storage/storageAccounts"}

    $storages = Get-AzureRMStorageAccount
    foreach($storage in $storages)
    {
        Set-AzureStorageServiceMetricsProperty -ServiceType Blob -MetricsType Hour -MetricsLevel ServiceAndApi -PassThru -RetentionDays 10 -Version 1.0 -Context $storage.Context
    }

    $resAll =  Get-AzureRmResource
    $ResToLog = $resAll | where { $_.ResourceType -Match "Microsoft.Network/networkSecurityGroups" }

    foreach($res in $ResToLog)
    {
        $LogSettings =  Get-AzureRmDiagnosticSetting -ResourceId $res.ResourceId
        Set-AzureRmDiagnosticSetting -ResourceId $res.ResourceId -WorkspaceId $insigts.ResourceId -Enabled $true
    }
}

Register-AzResourceProvider -ProviderNamespace Microsoft.Insights

$NW = Get-AzNetworkWatcher -ResourceGroupName NetworkWatcherRg -Name NetworkWatcher_westcentralus
$nsg = Get-AzNetworkSecurityGroup -ResourceGroupName nsgRG -Name nsgName
$storageAccount = Get-AzStorageAccount -ResourceGroupName StorageRG -Name contosostorage123
Get-AzNetworkWatcherFlowLogStatus -NetworkWatcher $NW -TargetResourceId $nsg.Id

#Traffic Analytics Parameters
$workspaceResourceId = "/subscriptions/9d4350c8-e11c-4007-a923-c1df11a52bab/resourcegroups/trafficanalyticsrg/providers/microsoft.operationalinsights/workspaces/taworkspace"
$workspaceGUID = "cccccccc-cccc-cccc-cccc-cccccccccccc"
$workspaceLocation = "westeurope"

#Configure Version 1 Flow Logs
Set-AzNetworkWatcherConfigFlowLog -NetworkWatcher $NW -TargetResourceId $nsg.Id -StorageAccountId $storageAccount.Id -EnableFlowLog $true -FormatType Json -FormatVersion 1

#Configure Version 2 Flow Logs, and configure Traffic Analytics
Set-AzNetworkWatcherConfigFlowLog -NetworkWatcher $NW -TargetResourceId $nsg.Id -StorageAccountId $storageAccount.Id -EnableFlowLog $true -FormatType Json -FormatVersion 2

#Configure Version 2 FLow Logs with Traffic Analytics Configured
Set-AzNetworkWatcherConfigFlowLog -NetworkWatcher $NW -TargetResourceId $nsg.Id -StorageAccountId $storageAccount.Id -EnableFlowLog $true -FormatType Json -FormatVersion 2 -EnableTrafficAnalytics -WorkspaceResourceId $workspaceResourceId -WorkspaceGUID $workspaceGUID -WorkspaceLocation $workspaceLocation

#Query Flow Log Status
Get-AzNetworkWatcherFlowLogStatus -NetworkWatcher $NW -TargetResourceId $nsg.Id