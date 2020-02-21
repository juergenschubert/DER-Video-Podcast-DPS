$vCenter = "vc.vlab.local"
$aveName = "ave-20-19.1"

#SURPRESS INVALID CERTIFICATE WARNINGS
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null
try
{
    Write-Host "`n[CONNECTING] to: $($vCenter)" -ForegroundColor Green
    Connect-VIServer -protocol https -Server $vCenter  -Credential (Get-Credential -Message 'Enter your vSphere admin credentials!')
}
catch {
    Write-Host "Unable to connect to: $vCenter" -ForegroundColor Red
    exit

}
#########
# vCenter connection done
#########
#avamar
$ovfFile = "S:\avamar\19_1\AVE-19.1.0.38.ova"
#$ovfFile = "S:\avamar\19_2\AVE-19.2.0.155.ovf"
#NetWorker
#$ovfFile = "S:\networker\NW19.2 GA\NVE-19.2.0.112.ova"
#PPDM
#$ovfFile = "S:\PowerProtect\19.3.0-7\dellemc-ppdm-sw-19.3.0-7.ova"

###########
# Create ovf object
###########
Connect-VIServer -protocol https -Server $vCenter -User ppdm@vsphere.local -Password Password123!
$ovfConfig = Get-OvfConfiguration $ovfFile
###########
# Enter the AVE configuration parameters
###########
#sho me the  configuration option you get from the ova
$ovfconfig.ToHashTable() | ft –autosize
########
# Avamar
#########
$ovfConfig.vami.Avamar_Virtual_Edition.DNS.Value = "192.168.1.1"
$ovfConfig.vami.Avamar_Virtual_Edition.ipv4.Value = "192.168.1.241/255.255.252.0"
$ovfConfig.vami.Avamar_Virtual_Edition.FQDN.Value = "ave-20.vlab.local"
$ovfConfig.vami.Avamar_Virtual_Edition.gatewayv4.Value = "192.168.1.1"
$ovfConfig.NetworkMapping.VM_Network.Value = "VM Network"
###########
## PowerProtect 19.3
#####$ovfConfig##########
#$ovfConfig
#$ovfConfig.NetworkMapping
#$ovfConfig.NetworkMapping.VM_Network.Value = "VM Network"
#$ovfConfig.IpAssignment
#$ovfConfig.IpAssignment.IpProtocol.value = "IPv4"
#$ovfConfig.vami
#$ovfConfig.vami.brs
#$ovfConfig.vami.brs.ip0
#$ovfConfig.vami.brs.gateway
#$ovfConfig.vami.brs.netmask0
#$ovfConfig.vami.brs.DNS
#$ovfConfig.vami.brs.fqdn
#$ovfConfig.vami.brs.ip0.value = "192.168.1.50"
#$ovfConfig.vami.brs.gateway.value = "192.168.1.1"
#$ovfConfig.vami.brs.netmask0.value = "255.255.255.0"
#$ovfConfig.vami.brs.DNS.value = "192.168.1.1"
#$ovfConfig.vami.brs.fqdn.value = "ppdm.vlab.local"
##########
#NetWorker
#########
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
#$ovfConfig.vami.NetWorker_Virtual_Edition.ipv4.value = ""
#$ovfConfig.vami.NetWorker_Virtual_Edition.ipv6.value = ""
#$ovfConfig.vami.NetWorker_Virtual_Edition.gatewayv4.value = ""
#$ovfConfig.vami.NetWorker_Virtual_Edition.gatewayv6.value = ""
#$ovfConfig.vami.NetWorker_Virtual_Edition.DNS.value = ""
#$ovfConfig.vami.NetWorker_Virtual_Edition.searchpaths.value = ""
#$ovfConfig.vami.NetWorker_Virtual_Edition.FQDN.value = ""
#$ovfConfig.vami.NetWorker_Virtual_Edition.NTP.value = ""
#$ovfConfig.vami.NetWorker_Virtual_Edition.NVEtimezone.value = ""
#$ovfConfig.vami.NetWorker_Virtual_Edition.DDIP.value = ""
#$ovfConfig.vami.NetWorker_Virtual_Edition.DDBoostUseExistingUser.value = ""
#$ovfConfig.vami.NetWorker_Virtual_Edition.DDBoostUsername.value = ""
#$ovfConfig.vami.NetWorker_Virtual_Edition.vCenterFQDN.value = ""
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

Write-Output "Waiting for AVE VM deployment..."
$startTime = get-date
$avamarVM = Import-VApp -Source $ovfFile -OvfConfiguration $ovfConfig -Name "$aveName" -VMHost $VMHost -Datastore $dataStore -DiskStorageFormat thin
$endTime = get-date

$DeploymentTime = $endTime - $startTime
Write-Output " ***** `nAVE deployment lasted for: $DeploymentTime`nDisconnecting from $vCenter`n**** "
Disconnect-VIServer -Server $vCenter -confirm:$false

##########
# working with VM
##########
#Get-VM
#
#Get-VM -Name $aveName | Get-NetworkAdapter
##Get-VM -Name $aveName | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName “OpaqueNetworkName”
##########
###vm status
##########
#Get-VMGuest -vm $aveName
##########
### start/stop vms
##########
#start-vm $aveName
#shutdown-vmguest ave-20-19.1
