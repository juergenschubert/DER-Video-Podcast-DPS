# Update-Module -force

# update help
# update-help -force

# Install PowerCLI
# Install-Module -Name vmware.powercli -AllowClobber
$vCenter = "vc.vlab.local"
$VMname = "DDVE6"

# just in case you a having issues with connect-VIServer
# Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $true
# Set-PowerCLIConfiguration -Scope User -InvalidCertificateAction ignore

Connect-VIServer -protocol https -Server $vCenter -User administrator@vsphere.local -Password Password123!

#########
# vCenter connection done
#########
#ddve ovf File
$ovfFile = "S:\ddve\ddve-vsphere-7.3.0.5-663138\ddve-7.3.0.5-663138.ova"

###########
# Create ovf object
###########
$ovfConfig = Get-OvfConfiguration $ovfFile

###########
# Enter the DDVE configuration parameters
###########
$ovfConfig.DeploymentOption.value = "8TB"
$ovfConfig.IpAssignment.IpProtocol.value = "IPv4"
$ovfConfig.IpAssignment.IpAllocationPolicy.Value = "fixedPolicy"
$ovfConfig.NetworkMapping.VM_Network_1.value = "VM Network"
$ovfConfig.NetworkMapping.VM_Network_2.value = "VM Network"

##########
# Select: vmhost, datastore, network to configure the DDVE
$VMHost = Get-Cluster "Cluster" | Get-VMHost | Where-Object { $_.Name -like "esx1.vlab.local*"}
$dataStore = $VMHost | Get-Datastore  | Where-Object { $_.Name -like "nfs_datastore*"}
$Network = Get-VirtualPortGroup -Name "VM Network" -VMHost $VMHost

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
