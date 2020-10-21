# PowerCLI ova deployment 101
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

The vCenter_Deployment.ps1 Powershell is helping you to find the right ovf properties you are will use in your automation upfront so you know better what to use and how to fill the values .  
