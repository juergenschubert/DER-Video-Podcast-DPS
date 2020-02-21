# PowerCLI ova deployment.ps1   
UseCase: need more than one ova deployment -> IDEA automate it with PowerShell

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

#### AVE Variablen  
Name                                      

vami.NTP.Avamar_Virtual_Edition              
NetworkMapping.VM Network                    
vami.gatewayv6.Avamar_Virtual_Edition        
vami.ipv6.Avamar_Virtual_Edition             
vami.DNS.Avamar_Virtual_Edition              
vami.gatewayv4.Avamar_Virtual_Edition        
vami.ipv4.Avamar_Virtual_Edition             
vami.searchpaths.Avamar_Virtual_Edition      
vami.FQDN.Avamar_Virtual_Edition  

#### NVE Werte   
Name                                                    

vami.gatewayv6.NetWorker_Virtual_Edition                     
vami.DDBoostUsername.NetWorker_Virtual_Edition             
vami.vCenterFQDN.NetWorker_Virtual_Edition                 
vami.DNS.NetWorker_Virtual_Edition                         
NetworkMapping.VM Network                                  
vami.ipv6.NetWorker_Virtual_Edition                        
vami.NTP.NetWorker_Virtual_Edition                         
vami.DDBoostUseExistingUser.NetWorker_Virtual_Edition      
vami.vCenterUsername.NetWorker_Virtual_Edition             
vami.DDIP.NetWorker_Virtual_Edition                        
vami.FQDN.NetWorker_Virtual_Edition                        
vami.gatewayv4.NetWorker_Virtual_Edition                   
vami.ipv4.NetWorker_Virtual_Edition                        
vami.NVEtimezone.NetWorker_Virtual_Edition                 
vami.searchpaths.NetWorker_Virtual_Edition

#### PPDM Werte
Name                        

NetworkMapping.VM Network      
vami.gateway.brs               
vami.DNS.brs                   
vami.ip0.brs                   
vami.netmask0.brs              
vami.fqdn.brs                  
IpAssignment.IpProtocol