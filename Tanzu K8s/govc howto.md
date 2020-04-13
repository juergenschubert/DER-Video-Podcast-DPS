#govc how to use

Tools die wir brauchen können findet ihr hier:  
**govc** is a vSphere CLI built on top of govmomi and can be downloaded here: [https://github.com/vmware/govmomi/tree/master/govc](https://fabianlee.org/2019/03/09/vmware-using-the-govc-cli-to-automate-vcenter-commands/)   
Download und copy to your Ubuntu Server, both and run the config mentioned below   
[https://fabianlee.org/2019/03/09/vmware-using-the-govc-cli-to-automate-vcenter-commands/](https://fabianlee.org/2019/03/09/vmware-using-the-govc-cli-to-automate-vcenter-commands/)


Setup steps required on all nodes The following section details the steps that are needed on both the master and worker nodes. After the installation you should get it done and can go ahead with:  

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

