$subs=("9d4350c8-e11c-4007-a923-c1df11a52bab")

foreach ($sub in $subs)
{
    $sas = Get-AzureRMStorageAccount 
    foreach($sa in $sAs){
        $sa.Id
        #nie można zweryfikować czy wszystko jest wyłączone lub włączone trzeba werfykiwować pojedyńczo blob, files, queue i table i jednostkę czasu też Hour, Minute
        $blobPolicy =  Get-AzureStorageServiceProperty -ServiceType Blob  -Context $sa.Context
        $tablePolicy =  Get-AzureStorageServiceProperty -ServiceType Table  -Context $sa.Context
        $QueuePolicy =  Get-AzureStorageServiceProperty -ServiceType Queue  -Context $sa.Context
        $FilePolicy =  Get-AzureStorageServiceProperty -ServiceType File  -Context $sa.Context

        $blobMinutePolicy = $blobPolicy.HourMetrics.MetricsLevel
        $blobHourPolicy = $blobPolicy.MinuteMetrics.MetricsLevel

        $tableMinutePolicy = $tablePolicy.HourMetrics.MetricsLevel
        $tableHourPolicy = $tablePolicy.MinuteMetrics.MetricsLevel

        $QueueMinutePolicy = $QueuePolicy.HourMetrics.MetricsLevel
        $QueueHourPolicy = $QueuePolicy.MinuteMetrics.MetricsLevel

        $FileMinutePolicy = $FilePolicy.HourMetrics.MetricsLevel
        $FileHourPolicy = $FilePolicy.MinuteMetrics.MetricsLevel

        #None - Wyłączone 
        #Service - log prawdopodobnie tylko usunięć
        #Api - log tylko zapytań api 
        #ServiceAndApi - Full log 
        if( $blobMinutePolicy -eq "None" -and $tableMinutePolicy -eq "None" -and $QueueMinutePolicy -eq "None" -and $FileMinutePolicy -eq "None")
        {
            if( $blobHourPolicy -eq "None" -and $tableHourPolicy -eq "None" -and $QueueHourPolicy -eq "None" -and $FileHourPolicy -eq "None" )
            {
                #Wszystko jest wyłączone 
                $sa.Id
            }
        }
                
        #Get-AzureStorageServiceProperty -ServiceType Blob  -Context $sa.Context
    }
}