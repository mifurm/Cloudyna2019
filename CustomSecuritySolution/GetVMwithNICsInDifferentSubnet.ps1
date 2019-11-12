#get all VM's
$vms = Get-AzureRmVM

#get all interfaces 
$AllNics = Get-AzureRmNetworkInterface 

Write-Output "VM's with NIC's in different subnets"
foreach ($vm in $vms) {
    #get all nics per VM
    $networkIntefaces =  $vm.NetworkProfile.NetworkInterfaces 
  
    #if more than 1 nic then lets analyze this vm
    if($networkIntefaces.Count -gt 1){
        $subnet = $null 
        foreach($networkInteface in $networkIntefaces){
            $networkIntefaceRef = $AllNics | where Id -eq $networkInteface.Id 
            foreach($subnets in  $networkIntefaceRef.IpConfigurations){ 
                $subnetnew =  $subnets.Subnet.Id 
            }
            if($subnet -eq $null){ 
                $subnet= $subnetnew
            }
            if($subnet -ne $subnetnew) 
            {
                Write-Output "Name:" $vm.Name 
                Write-Output "Location:" $vm.Location 
                Write-Output "ResourceGroup:" $vm.ResourceGroupName
                Write-Output "Subnets" $subnet.Split("subnets",2)[1], $subnetnew.Split("subnets",2)[1]
            }
            else {
                $subnet= $subnetnew 
            }
        }
    }
}