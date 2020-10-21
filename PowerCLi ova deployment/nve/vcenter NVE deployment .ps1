$vCenter = "vc.vlab.local"
$VMname = "NVE-19-2"

Connect-VIServer -protocol https -Server $vCenter -User ppdm@vsphere.local -Password Password123!

#########
# vCenter connection done
#########
#NetWorker
$ovfFile = "S:\networker\NW19.2 GA\NVE-19.2.0.112.ova"

###########
# Create ovf object
###########

$ovfConfig = Get-OvfConfiguration $ovfFile
###########
# Enter the NetWorker virtual edition configuration parameters
###########
$ovfConfig.vami.NetWorker_Virtual_Edition.ipv4.value = "192.168.1.33"
$ovfConfig.vami.NetWorker_Virtual_Edition.gatewayv4.value = "192.168.1.1"
$ovfConfig.vami.NetWorker_Virtual_Edition.DNS.value = "192.168.1.1"
$ovfConfig.vami.NetWorker_Virtual_Edition.FQDN.value = "nve-auto.vlab.local"
$ovfConfig.vami.NetWorker_Virtual_Edition.NTP.value = "192.168.1.1"
$ovfConfig.vami.NetWorker_Virtual_Edition.DDIP.value = "192.168.1.90"
$ovfConfig.vami.NetWorker_Virtual_Edition.DDBoostUseExistingUser.value ="Yes"
$ovfConfig.vami.NetWorker_Virtual_Edition.DDBoostUsername.value = "ddboost"
$ovfConfig.vami.NetWorker_Virtual_Edition.vCenterFQDN.value = "vc.vlab.local"
$ovfConfig.vami.NetWorker_Virtual_Edition.vCenterUsername.value = "ppdm@vsphere.local"
$ovfConfig.NetworkMapping.VM_Network.Value = "VM Network"
$ovfConfig.vami.NetWorker_Virtual_Edition.NVEtimezone.value = 'Europe/Berlin'
#################################

##########
# Select: vmhost, datastore, network to configure the AVE
$VMHost = Get-Cluster "Cluster" | Get-VMHost | Where-Object { $_.Name -like "esx1.vlab.local*"}
$dataStore = $VMHost | Get-Datastore  | Where-Object { $_.Name -like "nfs_datastore*"}
$Network = Get-VirtualPortGroup -Name "VM Network" -VMHost $VMHost


Write-Output "Waiting for NVE VM deployment..."
$startTime = get-date
$networkerVM = Import-VApp -Source $ovfFile -OvfConfiguration $ovfConfig -Name "$VMname" -VMHost $VMHost -Datastore $dataStore -DiskStorageFormat thin
$endTime = get-date

$DeploymentTime = $endTime - $startTime
Write-Output " ***** `nNVE deployment lasted for: $DeploymentTime`nDisconnecting from $vCenter`n**** "

##########
# working with VM
##########
#Get-VM
#
Get-VM -Name $VMname | Get-NetworkAdapter
##Get-VM -Name “ave-20” | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName “OpaqueNetworkName”
##########
###vm status
##########
Get-VMGuest -vm $VMname
##########
### start/stop vms
##########
start-vm $VMname
# shutdown-vmguest $VMname

Disconnect-VIServer -Server $vCenter -confirm:$false
