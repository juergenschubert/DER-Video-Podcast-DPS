$vCenter = "vc.vlab.local"
$VMname = "PPDM19.5.0-5"
$ovfFile = "S:\PowerProtect\19.5_GA\dellemc-ppdm-sw-19.5.0-5.ova"

Connect-VIServer -protocol https -Server $vCenter -User administrator@vsphere.local -Password Password123!
#Connect-VIServer -protocol https -Server vc.vlab.local -User administrator@vsphere.local -Password Password123!

#########
# vCenter connection done
#########

###########
# Create ovf object
###########
$ovfConfig = Get-OvfConfiguration $ovfFile

###########
# Enter the DDVE configuration parameters
###########
$ovfConfig.IpProtocol.value = "IPv4"
$ovfConfig.VM Network.value = "VM Network"

$ovfConfig.ip0.brs.value = "192.168.1.55"
$ovfConfig.gateway.brs.value = "192.168.1.1"
$ovfConfig.netmask0.brs.Value = "255.255.255.0"
$ovfConfig.DNS.brs.value = "192.168.1.1"
$ovfConfig.fqdn.brs.value = "ppdm1.vlab.local"

##########
# Select: vmhost, datastore, network to configure the DDVE
########
$VMHost = Get-Cluster "Cluster" | Get-VMHost | Where-Object { $_.Name -like "esx1.vlab.local*"}
$dataStore = $VMHost | Get-Datastore  | Where-Object { $_.Name -like "nfs_datastore*"}
$Network = Get-VirtualPortGroup -Name "VM Network" -VMHost $VMHost

#####
# check all values are ok
########
$ovfconfig.ToHashTable() | ft –autosize

########
# start the deployment
########
Write-Output "Waiting for DDVE6 VM deployment..."
$startTime = get-date
$ddveVM = Import-VApp -Source $ovfFile -OvfConfiguration $ovfConfig -Name "$VMname" -VMHost $VMHost -Datastore $dataStore -DiskStorageFormat thin
$endTime = get-date

$DeploymentTime = $endTime - $startTime
Write-Output " ***** `DDVE6 deployment lasted for: $DeploymentTime`nDisconnecting from $vCenter`n**** "

##########
# working with VM
##########
start-vm $VMname


Disconnect-VIServer -Server $vCenter -confirm:$false
