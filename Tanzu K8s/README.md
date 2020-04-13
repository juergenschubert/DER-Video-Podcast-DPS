# Tanzu Kubernetes Space

wir wollen hier ein K8s Cluster aufbauen, welches mit vSphere Tanzu diese FCD disken benutzt und als Kubernetes ein PVC hat.  
Ziel ist es das k8s Clusten nach Aubau, dann mit DELL PowerProtect zu sichern

## Voraussetzunge von VMware     
Wir brauchen ein 6.7 U2 vSphere um dann 2 Ubuntu Server, k8s.master1 und k8s.slave1 mit k8s zu versehen

## Step 1 vSphere 6.7 U3
get vSphere 6.7 U3 running (check Hardware 15) die wir brauchen um die Ubuntu Server zu verwenden

## Step 2 Create both VM

### Create a new VM with the following properties :
Compatibility : ESXi 6.7 Update 2 and later (VM version 15)
* CPU 4 CPU(s),  
* Memory 8 GB  
* Hard disk 1 100GB  
* SCSI controller 0 VMware Paravirtual    
* Change Type VMware Paravirtual     
* SCSI Bus Sharing None  

### disk.EnableUUID=1  
    - Power off the guest.  
    - Select the guest and select Edit Settings.  
    - Select the Options tab on top.  
    - Select General under the Advanced section.  
    - Select the Configuration Parameters... on right hand side.  

Check to see if the parameter disk.EnableUUID is set, if it is there then make sure it is set to TRUE. If the parameter is not there, select Add Row and add it.  
Power on the guest. 


### To enable CBT in a virtual machine:  
    - Power off the virtual machine.    
    - Right-click the virtual machine and click Edit Settings.  
    - Click the Options tab.  
    - Click General under the Advanced section and then click Configuration Parameters.         
    - The Configuration Parameters dialog opens.  
    - Click Add Row.  
    - Add the ctkEnabled parameter and then set its value to true.  
    - Click Add Row, add scsi0:0.ctkEnabled, and set its value to true.  

Note: scsi0:0 in scsi0:0.ctkEnabled indicates the SCSI device assigned to the hard disk that is added to the virtual machine. Every hard disk added to the virtual machine is given a SCSI device that appears similar to scsi0:0, scsi0:1, or scsi 1:1. CBT is enabled (or disabled) individually on each disk.  
Power on the virtual machine.  
In the home directory of the virtual machine, verify that each disk having CBT enabled has also a vmname-ctk.vmdk file  
**Install 2 Ubuntu 18.04.4 LTS (Bionic Beaver)**  
Download des iso unter [http://releases.ubuntu.com/18.04.4/](download)  
Von CD booten und Config durchspielen  
Feste IP Adresse und hostname im DNS  
**tanzu-m1.vlab.local** und **tanzu-s1.vlab.local**  
Netzwerkconfig [https://www.thomas-krenn.com/de/wiki/Netzwerk-Konfiguration_Ubuntu_-_Netplan](https://www.thomas-krenn.com/de/wiki/Netzwerk-Konfiguration_Ubuntu_-_Netplan)   
DNS Server eintragen   
[https://datawookie.netlify.com/blog/2018/10/dns-on-ubuntu-18.04/](https://www.thomas-krenn.com/de/wiki/Netzwerk-Konfiguration_Ubuntu_-_Netplan)
  

- **Hardware 15** für die VMs, CBT und more auf beide Ubuntus anwenden. Mehr findet ihr in VMWare FCD uuid and CBT enable.pdf.  Diese Änderungen und Hardware Versionen brauchen wir und die FCD zu verwenden und dann auch einen PVC anlegen zu können ....

Natürlich können wir das auch von innerhalb der VM aus machen das cbt enablen usw. 

Tools die wir brauchen können findet ihr hier:  
**govc** is a vSphere CLI built on top of govmomi and can be downloaded here: [https://github.com/vmware/govmomi/tree/master/govc](https://fabianlee.org/2019/03/09/vmware-using-the-govc-cli-to-automate-vcenter-commands/)   
More details on the command can be found at: [https://fabianlee.org/2019/03/09/vmware-using-the-govc-cli-to-automate-vcenter-commands/](https://fabianlee.org/2019/03/09/vmware-using-the-govc-cli-to-automate-vcenter-commands/)

---
Setup steps required on all nodes The following section details the steps that are needed on both the master and worker nodes.

disk.EnableUUID=1  
The following govc commands will set the disk.EnableUUID=1 on all nodes.  

    # export GOVC_INSECURE=1  
    # export GOVC_URL='https://<VC_IP>'  
    # export GOVC_USERNAME=VC_Admin_User  
    # export GOVC_PASSWORD=VC_Admin_Passwd  

    administrator@tanzu-m1:~$ govc ls
    /Datacenter/vm
    /Datacenter/network
    /Datacenter/host
    /Datacenter/datastore
 

To retrieve all Node VMs, use the following command:  
  
    #  govc ls /Datacenter/vm
    /Datacenter/vm/cr-194
    /Datacenter/vm/tanzu-s1
    /Datacenter/vm/tanzu-m1
    /Datacenter/vm/NVE-19-2
    /Datacenter/vm/SQL
    /Datacenter/vm/Windows
    /Datacenter/vm/Linux
    /Datacenter/vm/Infrastructure
    

To use govc to enable Disk UUID, use the following command:  
  
    # govc vm.change -vm '/Datacenter/vm/tanzu-s1' -e="disk.enableUUID=1"    
    # govc vm.change -vm '/Datacenter/vm/tanzu-m1' -e="disk.enableUUID=1"  
 
 
 Further information on disk.enableUUID can be found in VMware Knowledgebase Article 52815.  

## Upgrade Virtual Machine Hardware  
VM Hardware should be at version 15 or higher.  

    # govc vm.upgrade -version=15 -vm '/Datacenter/vm/tanzu-s1'  
    # govc vm.upgrade -version=15 -vm '/Datacenter/vm/tanzu-m1'

If you do get an error like:
    
    # govc: The attempted operation cannot be performed in the current state (Powered on).  

Power the vm off  

    # govc vm.power -off -force '/Datacenter/vm/tanzu-s1'  
      Powering off VirtualMachine:vm-1296... OK  

Check the VM Hardware version after running the above command:    
  
    # govc vm.option.info '/Datacenter/vm/tanzu-s1' | grep HwVersion  
HwVersion:           15  

---  
## Setting up VMs in the Guest OS
The next step is to install the necessary Kubernetes components on the Ubuntu OS virtual machines. Some components must be installed on all of the nodes. In other cases, some of the components need only be installed on the master, and in other cases, only the workers. In each case, where the components are installed is highlighted. All installation and configuration commands should be executed with root privilege. You can switch to the root environment using the "sudo su" command. 

* Disable Swap (Both master and worker )
SSH into all K8s worker nodes and disable swap on all nodes including master node. This is a prerequisite for kubeadm.  
   # sudo su  
   # swapoff -a  
   # vi /etc/fstab ... remove any swap entry from   this file ...




   
**Weitere Tools die wir brauchen können findet ihr hier:**

kubectl for other Operating Systems [https://kubernetes.io/docs/tasks/tools/install-kubectl/]()   
tmux for other Operating Systems [https://github.com/tmux/tmux]()    