$subs=("9d4350c8-e11c-4007-a923-c1df11a52bab")

#Get all resources without tags
foreach ($sub in $subs)
{
    $resources =  Get-AzureRmResource
    foreach ($resource in $resources)
    {
        if($resource.Tags -and $resource.Tags.Count -eq 0 )
        { 
            #list all resources without any tag
            Write-Output $resource.Name $resource.ResourceType
        }
    }
}

$subs=("9d4350c8-e11c-4007-a923-c1df11a52bab")
#Get all resource groups without tags
foreach ($sub in $subs)
{
    $resourceGroups =  Get-AzureRmResourceGroup
    foreach ($rg in $resourceGroups)
    {
        if($rg.Tags.Count -eq 0 )
        { 
            #list all resources without any tag
            Write-Output $rg.ResourceGroupName 
        }
    }
}