# PowerCLI ova deployment.ps1   
UseCase: need more than one ova deployment -> IDEA automate it with PowerShell

## AVE -  automated ova deployment
## NVE - fully automated ova deployment

### requirement:    
Window 10  
vmWare PowerCli installed    
-----
Run your PowerShell and install the PowerCLI  
Install-Module -Name vmware.powercli -AllowClobber  
more to read @ https://code.vmware.com/web/tool/11.5.0/vmware-powercli
How-to can be found: https://adamtheautomator.com/download-install-vmware-powercli/

Download the ps1 file and start your Windows PowerShell ISE and open the ps1 file
walk through each line !!!

#### PPDM Werte
Name                        

NetworkMapping.VM Network      
vami.gateway.brs               
vami.DNS.brs                   
vami.ip0.brs                   
vami.netmask0.brs              
vami.fqdn.brs                  
IpAssignment.IpProtocol
