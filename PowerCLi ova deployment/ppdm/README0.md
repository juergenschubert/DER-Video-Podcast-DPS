# PPDM 19.5 variables  
we need to specify the ovf file/path and analyse what values are needed for a ova deployment. You can do so with:

```
PS C:\Users\Administrator> $ovfFile = "S:\PowerProtect\19.5_GA\dellemc-ppdm-sw-19.5.0-5.ova"

PS C:\Users\Administrator> $ovfConfig = Get-OvfConfiguration $ovfFile

PS C:\Users\Administrator> $ovfconfig.ToHashTable() | ft –autosize
```

```
==============================================
OvfConfiguration: dellemc-ppdm-sw-19.5.0-5.ova

   Properties:
   -----------
   IpAssignment
   NetworkMapping
   vami
```


##IPAssignment    
```
PS C:\github\DER-Video-Podcast-DPS\PowerCLi ova deployment\101> $ovfConfig.IpAssignment  

IpProtocol  
----------  

PS C:\github\DER-Video-Podcast-DPS\PowerCLi ova deployment\101> $ovfConfig.IpAssignment.IpProtocol  


Key                : IpAssignment.IpProtocol  
Value              :   
DefaultValue       :   
OvfTypeDescription : string["IPv4"]  
Description        :   
```


##NetworkMapping  
```
PS C:\github\DER-Video-Podcast-DPS\PowerCLi ova deployment\101> $ovfConfig.NetworkMapping

VM_Network
----------

PS C:\github\DER-Video-Podcast-DPS\PowerCLi ova deployment\101> $ovfConfig.NetworkMapping.VM_Network

Key                : NetworkMapping.VM Network
Value              :
DefaultValue       :
OvfTypeDescription : string
Description        : The VM Network network
```

## vami
```
PS C:\github\DER-Video-Podcast-DPS\PowerCLi ova deployment\101> $ovfConfig.vami

brs          
---          
System.Object
####vami.brs
PS C:\github\DER-Video-Podcast-DPS\PowerCLi ova deployment\101> $ovfConfig.vami.brs


ip0      :
gateway  :
netmask0 :
DNS      :
fqdn     :


Key                : vami.ip0.brs
Value              :
DefaultValue       :
OvfTypeDescription : ip
Description        : Specify the IP address for this virtual machine.

Key                : vami.gateway.brs
Value              :
DefaultValue       :
OvfTypeDescription : ip
Description        : Specify the default gateway address for this virtual machine.

Key                : vami.netmask0.brs
Value              :
DefaultValue       :
OvfTypeDescription : string
Description        : Specify the netmask for this virtual machine.

Key                : vami.DNS.brs
Value              :
DefaultValue       :
OvfTypeDescription : string
Description        : Specify up to three domain name servers for this virtual machine, separated by commas.

Key                : vami.fqdn.brs
Value              :
DefaultValue       :
OvfTypeDescription : string(1..256)
Description        : Specify the fully qualified domain name for this virtual machine.
```
