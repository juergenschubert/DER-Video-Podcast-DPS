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
$ovfFile = "S:\avamar\19_1\AVE-19.1.0.38.ova"
#$ovfFile = "S:\avamar\19_2\AVE-19.2.0.155.ovf"


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
$ovfConfig.vami.Avamar_Virtual_Edition.DNS.Value = "192.168.1.1"
$ovfConfig.vami.Avamar_Virtual_Edition.ipv4.Value = "192.168.1.241/255.255.252.0"
$ovfConfig.vami.Avamar_Virtual_Edition.FQDN.Value = "ave-20.vlab.local"
$ovfConfig.vami.Avamar_Virtual_Edition.gatewayv4.Value = "192.168.1.1"
$ovfConfig.NetworkMapping.VM_Network.Value = "VM Network"
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
#Get-VM -Name “ave-20” | Get-NetworkAdapter
##Get-VM -Name “ave-20” | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName “OpaqueNetworkName”
##########
###vm status
##########
#Get-VMGuest -vm ave-20-19.2
##########
### start/stop vms
##########
#start-vm ave-20-19.2
#shutdown-vmguest ave-20-19.2
