# Tanzu Kubernetes Space

wir wollen hier ein K8s Cluster aufbauen, welches mit vSphere Tanzu diese FCD disken benutzt und als Kubernetes ein PVC hat.  
Ziel ist es das k8s Clusten nach Aubau, dann mit DELL PowerProtect zu sichern

## Voraussetzunge von VMware     
Wir brauchen ein 6.7 U2 vSphere um dann 2 Ubuntu Server, k8s.master1 und k8s.slave1 mit k8s zu versehen

## Step 1
get vSphere 6.7 U3 running (check Hardware 15) die wir brauchen um die Ubuntu Server zu verwenden

## Step 2

### Create a new VM with the following properties :
Compatibility : ESXi 6.7 Update 2 and later (VM version 15)
CPU 4 CPU(s),  
Memory 8 GB  
Hard disk 1 100GB  
SCSI controller 0 VMware Paravirtual    
Change Type VMware Paravirtual     
SCSI Bus Sharing None  

### disk.EnableUUID=1  
Power off the guest.  
Select the guest and select Edit Settings.  
Select the Options tab on top.  
Select General under the Advanced section.  
Select the Configuration Parameters... on right hand side.  
Check to see if the parameter disk.EnableUUID is set, if it is there then make sure it is set to TRUE. If the parameter is not there, select Add Row and add it.  
Power on the guest.


### To enable CBT in a virtual machine:  
Power off the virtual machine.    
Right-click the virtual machine and click Edit Settings.  
Click the Options tab.  
Click General under the Advanced section and then click Configuration Parameters. The Configuration Parameters dialog opens.  
Click Add Row.  
Add the ctkEnabled parameter and then set its value to true.  
Click Add Row, add scsi0:0.ctkEnabled, and set its value to true.  
Note: scsi0:0 in scsi0:0.ctkEnabled indicates the SCSI device assigned to the hard disk that is added to the virtual machine. Every hard disk added to the virtual machine is given a SCSI device that appears similar to scsi0:0, scsi0:1, or scsi 1:1. CBT is enabled (or disabled) individually on each disk.  
Power on the virtual machine.  
In the home directory of the virtual machine, verify that each disk having CBT enabled has also a vmname-ctk.vmdk file  
Install 2 Ubuntu 18.04.4 LTS (Bionic Beaver)    
Download des iso unter http://releases.ubuntu.com/18.04.4/  
Feste IP Adresse und hostname im DNS  

- Hardware 15 für die VMs, CBT und more auf beide Ubuntus anwenden. Mehr findet ihr in
VMWare FCD uuid and CBT enable.pdf.  Diese Änderungen und Hardware Versionen brauchen wir und die FCD zu verwenden und dann auch einen PVC anlegen zu können ....

Natürlich können wir das auch von innerhalt der VM aus machen   
