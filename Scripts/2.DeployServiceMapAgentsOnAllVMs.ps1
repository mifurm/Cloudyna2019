$version = "9.4"
$ExtPublisher = "Microsoft.Azure.Monitoring.DependencyAgent"
$OsExtensionMap = @{ "Windows" = "DependencyAgentWindows"; "Linux" = "DependencyAgentLinux" }
#choose propoer sec group

$rgs=Get-AzureRmResourceGroup
foreach ($rg in $rgs)
{
    Get-AzureRmVM -ResourceGroupName $rg.ResourceGroupName |
    ForEach-Object {
        ""
        $name = $_.Name
        $os = $_.StorageProfile.OsDisk.OsType
        $location = $_.Location
        $vmRmGroup = $_.ResourceGroupName
        If ($name -notlike 'kali*'){
        "${name}: ${os} (${location})"
        Date -Format o
        $ext = $OsExtensionMap.($os.ToString())
        $result = Set-AzureRmVMExtension -ResourceGroupName $vmRmGroup -VMName $name -Location $location `
        -Publisher $ExtPublisher -ExtensionType $ext -Name "DependencyAgent" -TypeHandlerVersion $version
        $result.IsSuccessStatusCode
        }
    }
}