# DDVE variables  
we need to specify the ovf file/path and analyse what values are needed for a ova deployment. You can do so with:

```
PS C:\Users\Administrator> $ovfFile = "S:\ddve\ddve-vsphere-7.3.0.5-663138\ddve-7.3.0.5-663138.ova"

PS C:\Users\Administrator> $ovfConfig = Get-OvfConfiguration $ovfFile

PS C:\Users\Administrator> $ovfconfig.ToHashTable() | ft –autosize

Name                            Value
----                            -----
IpAssignment.IpAllocationPolicy      
NetworkMapping.VM Network 1          
DeploymentOption                     
IpAssignment.IpProtocol              
NetworkMapping.VM Network 2     
```

Now let's find out how the values needs to be set
```

PS C:\Users\Administrator> $ovfConfig
=========================================
OvfConfiguration: ddve-7.3.0.5-663138.ova

   Properties:
   -----------
   DeploymentOption
   IpAssignment
   NetworkMapping
```
let's dig deeper for each option
```
PS C:\Users\Administrator> $ovfConfig.DeploymentOption


   Key                : DeploymentOption
   Value              :
   DefaultValue       : 8TB
   OvfTypeDescription : string["8TB", "16TB", "32TB", "48TB", "64TB", "96TB", "HybridOptimus", "AllFlashOptimus", "Cloud16TB",
                        "Cloud64TB", "Cloud96TB"]
   Description        : 8TB Configuration - 2CPUs, 8GB Memory
                        8TB configuration refers to the resource reservation of 1 socket with  2 cores and 8GB memory. This
                        configuration is able to support 0.5TB up to 8TB Data Domain Filesystem (DDFS) capacity.

                        16TB Configuration - 4CPUs, 16GB Memory
                        16TB configuration refers to the resource reservation of 1 socket with  4 cores and 16GB memory. This
                        configuration is able to support 0.5TB up to 16TB Data Domain Filesystem (DDFS) capacity.

                        32TB Configuration - 4CPUs, 24GB Memory
                        32TB configuration refers to the resource reservation of 1 socket with  4 cores and 24GB memory. This
                        configuration is able to support 0.5TB up to 32TB Data Domain Filesystem (DDFS) capacity.

                        48TB Configuration - 4CPUs, 36GB Memory
                        48TB configuration refers to the resource reservation of 1 socket with  4 cores and 36GB memory. This
                        configuration is able to support 0.5TB up to 48TB Data Domain Filesystem (DDFS) capacity.

                        64TB Configuration - 8CPUs, 48GB Memory
                        64TB configuration refers to the resource reservation of 1 socket with  8 cores and 48GB memory. This
                        configuration is able to support 0.5TB up to 64TB Data Domain Filesystem (DDFS) capacity.

                        96TB Configuration - 8CPUs, 64GB Memory
                        96TB configuration refers to the resource reservation of 1 socket with  8 cores and 64GB memory. This
                        configuration is able to support 0.5TB up to 96TB Data Domain Filesystem (DDFS) capacity.

                        HybridOptimus Configuration - 8CPUs, 90GB Memory
                        HybridOptimus configuration refers to the resource reservation of 1 socket with  8 cores and 90GB memory. This
                        configuration is able to support 0.5TB up to HybridOptimus Data Domain Filesystem (DDFS) capacity.

                        AllFlashOptimus Configuration - 32CPUs, 160GB Memory
                        AllFlashOptimus configuration refers to the resource reservation of 2 socket with  32 cores and 160GB memory.
                        This configuration is able to support 0.5TB up to AllFlashOptimus Data Domain Filesystem (DDFS) capacity.

                        Cloud16TB Configuration - 4CPUs, 32GB Memory
                        Cloud16TB configuration refers to the resource reservation of 1 socket with  4 cores and 32GB memory. This
                        configuration supports cloud feature. It supports Data Domain Filesystem (DDFS) capacity up to 16TB for active
                        tier and up to 32TB for cloud tier.

                        Cloud64TB Configuration - 8CPUs, 60GB Memory
                        Cloud64TB configuration refers to the resource reservation of 1 socket with  8 cores and 60GB memory. This
                        configuration supports cloud feature. It supports Data Domain Filesystem (DDFS) capacity up to 64TB for active
                        tier and up to 128TB for cloud tier.

                        Cloud96TB Configuration - 8CPUs, 80GB Memory
                        Cloud96TB configuration refers to the resource reservation of 1 socket with  8 cores and 80GB memory. This
                        configuration supports cloud feature. It supports Data Domain Filesystem (DDFS) capacity up to 96TB for active
                        tier and up to 192TB for cloud tier.
```

IPassignment
```                    
PS C:\Users\Administrator> $ovfConfig.IpAssignment
IpAllocationPolicy IpProtocol
------------------ ----------
PS C:\Users\Administrator> $ovfConfig.IpAssignment.IpAllocationPolicy


Key                : IpAssignment.IpAllocationPolicy
Value              : fixedPolicy
DefaultValue       :
OvfTypeDescription : string["dhcpPolicy", "transientPolicy", "fixedPolicy", "fixedAllocatedPolicy"]
Description        :

PS C:\Users\Administrator> $ovfConfig.IpAssignment.IpProtocol

Key                : IpAssignment.IpProtocol
Value              : IPv4
DefaultValue       :
OvfTypeDescription : string["IPv4", "IPv6"]
Description        :
```
NetWork mapping
```
PS C:\Users\Administrator> $ovfConfig.NetworkMapping

VM_Network_1 VM_Network_2
------------ ------------
```

Let's start the PowerShell script for the deplayment after you update the variables
```
PS C:\Users\Administrator> C:\Users\Administrator\Documents\vCenter DDVE Deployment.ps1

Name                           Port  User                          
----                           ----  ----                          
vc.vlab.local                  443   VSPHERE.LOCAL\Administrator   
Waiting for DDVE6 VM deployment...
 ***** DDVE6 deployment lasted for: 00:16:28.5090393
Disconnecting from vc.vlab.local
****
```
