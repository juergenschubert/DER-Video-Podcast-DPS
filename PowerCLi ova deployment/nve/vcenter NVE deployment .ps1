$vCenter = "vc.vlab.local"
$aveName = "NVE-19-2"

Connect-VIServer -protocol https -Server $vCenter -User ppdm@vsphere.local -Password Password123!

#########
# vCenter connection done
#########
#NetWorker
$ovfFile = "S:\networker\NW19.2 GA\NVE-19.2.0.112.ova"

###########
# Create ovf object
###########
Connect-VIServer -protocol https -Server $vCenter -User ppdm@vsphere.local -Password Password123!
$ovfConfig = Get-OvfConfiguration $ovfFile
###########
# Enter the AVE configuration parameters
###########
#show me the  configuration option you get from the ova
$ovfconfig.ToHashTable() | ft –autosize

##########
#IF you have no Idea what variables to use and what they are used for a NetWorker deployment #########
#$ovfConfig
#$ovfConfig.NetworkMapping.VM_Network
#$ovfConfig.NetworkMapping.VM_Network.Value = "VM Network"
#$ovfConfig.vami
#$ovfConfig.vami.NetWorker_Virtual_Edition
#$ovfConfig.vami.NetWorker_Virtual_Edition.ipv4
#$ovfConfig.vami.NetWorker_Virtual_Edition.ipv6
#$ovfConfig.vami.NetWorker_Virtual_Edition.gatewayv4
#$ovfConfig.vami.NetWorker_Virtual_Edition.gatewayv6
#$ovfConfig.vami.NetWorker_Virtual_Edition.DNS
#$ovfConfig.vami.NetWorker_Virtual_Edition.searchpaths
#$ovfConfig.vami.NetWorker_Virtual_Edition.FQDN
#$ovfConfig.vami.NetWorker_Virtual_Edition.NTP
#$ovfConfig.vami.NetWorker_Virtual_Edition.NVEtimezone
#$ovfConfig.vami.NetWorker_Virtual_Edition.DDIP
#$ovfConfig.vami.NetWorker_Virtual_Edition.DDBoostUseExistingUser
#$ovfConfig.vami.NetWorker_Virtual_Edition.DDBoostUsername    
#$ovfConfig.vami.NetWorker_Virtual_Edition.vCenterFQDN
$ovfConfig.vami.NetWorker_Virtual_Edition.ipv4.value = "192.168.1.33"
#$ovfConfig.vami.NetWorker_Virtual_Edition.ipv6.value = ""
$ovfConfig.vami.NetWorker_Virtual_Edition.gatewayv4.value = "192.168.1.1"
#$ovfConfig.vami.NetWorker_Virtual_Edition.gatewayv6.value = ""
$ovfConfig.vami.NetWorker_Virtual_Edition.DNS.value = "192.168.1.1"
#$ovfConfig.vami.NetWorker_Virtual_Edition.searchpaths.value = ""
$ovfConfig.vami.NetWorker_Virtual_Edition.FQDN.value = "nve-auto.vlab.local"
$ovfConfig.vami.NetWorker_Virtual_Edition.NTP.value = "192.168.1.1"
$ovfConfig.vami.NetWorker_Virtual_Edition.NVEtimezone.value = ""
$ovfConfig.vami.NetWorker_Virtual_Edition.DDIP.value = "192.168.1.90"
$ovfConfig.vami.NetWorker_Virtual_Edition.DDBoostUseExistingUser.value ="Yes"
$ovfConfig.vami.NetWorker_Virtual_Edition.DDBoostUsername.value = "ddboost"
$ovfConfig.vami.NetWorker_Virtual_Edition.vCenterFQDN.value = "vc.vlab.local"                           
$ovfConfig.vami.NetWorker_Virtual_Edition.vCenterUsername.value = "ppdm@vsphere.local"
$ovfConfig.NetworkMapping.VM_Network.Value = "VM Network"
$ovfConfig.vami.NetWorker_Virtual_Edition.NVEtimezone.value = 'Europe/Berlin'
#################################

#show me the  configuration option you get from the ova
$ovfconfig.ToHashTable() | ft –autosize
##########
# Select: vmhost, datastore, network to configure the AVE
$VMHost = Get-Cluster "Cluster" | Get-VMHost | Where-Object { $_.Name -like "esx1.vlab.local*"}
$dataStore = $VMHost | Get-Datastore  | Where-Object { $_.Name -like "nfs_datastore*"}
$Network = Get-VirtualPortGroup -Name "VM Network" -VMHost $VMHost
##############
# debug the variables if needed
#Write-Output $VMHost
#Write-Output $dataStore
#Write-Output $Network
#Get-VM
#####################

Write-Output "Waiting for AVE VM deployment..."
$startTime = get-date
$avamarVM = Import-VApp -Source $ovfFile -OvfConfiguration $ovfConfig -Name "$aveName" -VMHost $VMHost -Datastore $dataStore -DiskStorageFormat thin
$endTime = get-date

$DeploymentTime = $endTime - $startTime
Write-Output " ***** `nNVE deployment lasted for: $DeploymentTime`nDisconnecting from $vCenter`n**** "

##########
# working with VM
##########
#Get-VM
#
Get-VM -Name $aveName | Get-NetworkAdapter
##Get-VM -Name “ave-20” | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName “OpaqueNetworkName”
##########
###vm status
##########
Get-VMGuest -vm $aveName
##########
### start/stop vms
##########
start-vm $aveName
# shutdown-vmguest $aveName

Disconnect-VIServer -Server $vCenter -confirm:$false