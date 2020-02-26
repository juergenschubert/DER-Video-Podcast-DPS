$vCenter = "vc.vlab.local"
$aveName = "ave-19-1"
$ovfFile = "S:\avamar\19_1\AVE-19.1.0.38.ova"

###########
# Create ovf object
###########
Connect-VIServer -protocol https -Server $vCenter -User ppdm@vsphere.local -Password Password123!
$ovfConfig = Get-OvfConfiguration $ovfFile
###########
# Enter the AVE configuration parameters
###########

########
# Avamar
#########
$ovfConfig.vami.Avamar_Virtual_Edition.DNS.Value = "192.168.1.1"
$ovfConfig.vami.Avamar_Virtual_Edition.ipv4.Value = "192.168.1.241/255.255.252.0"
$ovfConfig.vami.Avamar_Virtual_Edition.FQDN.Value = "ave-19-1.vlab.local"
$ovfConfig.vami.Avamar_Virtual_Edition.gatewayv4.Value = "192.168.1.1"
$ovfConfig.NetworkMapping.VM_Network.Value = "VM Network"

$VMHost = Get-Cluster "Cluster" | Get-VMHost | Where-Object { $_.Name -like "esx1.vlab.local*"}
$dataStore = $VMHost | Get-Datastore  | Where-Object { $_.Name -like "nfs_datastore*"}
$Network = Get-VirtualPortGroup -Name "VM Network" -VMHost $VMHost

$ovfconfig.ToHashTable() | ft –autosize


Write-Output "Waiting for AVE VM deployment..."
$startTime = get-date
$avamarVM = Import-VApp -Source $ovfFile -OvfConfiguration $ovfConfig -Name "$aveName" -VMHost $VMHost -Datastore $dataStore -DiskStorageFormat thin
$endTime = get-date

$DeploymentTime = $endTime - $startTime
Write-Output " ***** `nAVE deployment lasted for: $DeploymentTime`nDisconnecting from $vCenter`n**** "
Disconnect-VIServer -Server $vCenter -confirm:$false
