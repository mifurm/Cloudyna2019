###
# This code is dedicted to work with Azure Automation
# It requires SPN 
###

$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

$rgs = Get-AzureRmResourceGroup
foreach ($rg in $rgs)
{
  if ($rg.Tags.Count -ne 0)
  {
    $rgName = $rg.ResourceGroupName
    $msg="ResourceGroupName: $rgName"
    Write-Output $msg
    $resource=Get-AzureRmResource | where {$_.ResourceGroupName -eq $rg.ResourceGroupName}
    #Go through all resources to check this
    foreach ($rs in $resource)
    {
          $rsName = $rs.Name
          $msg="Writing ResourceTags for resource: $rsName "
          Write-Output $msg
          $tagsCount = $rs.Tags.Count
          $msg = "#Tags before: $tagsCount"
          Write-Output $msg
          Try
          {
            #Get all tags for specific resource
            $resourcetags = (Get-AzureRmResource -ResourceId $rs.ResourceId).Tags
            $msg = "Efective Tags" 
            Write-Output $msg
            $resourcetags
            
            #house keeping - if the resource already contains a TAG, then let's remove it so the update will go fine
            foreach ($key in $rg.Tags.Keys)
            {
                Write-Output "Particualr Key"
                $key
                Write-Output "All the Keys"
                $rg.Tags.Keys
                if (($resourcetags) -AND ($resourcetags.ContainsKey($key))) 
                { 
                  $resourcetags.Remove($key) 
                }
            } 

            $resourcetags += $rg.Tags; 
            #Set all tags to resource
            $output=Set-AzureRmResource -ResourceId $rs.ResourceId -Tag $resourcetags -Force 
          }
          Catch
          {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $rsName = $rs.Name
            Write-Output $ErrorMessage
            Write-Output $FailedItem 
            #there are hidden resources and some other resources which may have problems with accepting tags
            $msg = "There was a problem writing Tags to resource: $rsName"
            Write-Output $msg
          }
          $tagsCount = $output.Tags.Count
          $msg = "#Tags after: $tagsCount"
          Write-Output $msg
    }
  }
}