# U S E  C A S E
# customer asked to find out all local user on his DataDomain. 700 DD spread all over the world
#
# let's create a PowerShell cmdlet for this - let's do it

#region where you get the content
#thanks to Mike F. Robins  mikefrobbins.com  on twitter @mikefrobbins for the template and some stolen code :-)
#The whole code can be found on my GitHub Repos
www.github.com/juergenschubert
#details @
https://raw.githubusercontent.com/juergenschubert/DER-Video-Podcast-DPS/master/PowerShell%20cmdlet/learn-Get-DDUser-Cmdlet.ps1
#endregion

#CTRL-M will toggle the wohle regio with PowerShell ISE
#CTRL K+0 and K+J will toggle with Visual Studio COde

#function to check your running environment
function Get-PSVersion {
    $PSVersionTable
}
Get-PSVersion

#region Presentation Prep
<#
PowerShell description how to design and create a DPS cmdlet
Author:  Juergen Schubert
#>
#Safety in case the entire script is run instead of a selection
Start-Sleep -Seconds 1200

#Set my working environement to C:\Demo
$Path = 'C:\Demo'
#Change into the C:\Demo folder
Set-Location -Path $Path

#CTRL- = and CTRL - PLUS will in/decrease the font size

#Create the C:\Demo Folder if it doesn't already exist
If (-not(Test-Path -Path $Path -PathType Container)) {
    New-Item -Path $Path -ItemType Directory
}

#do you have a profile?
$PROFILE


# install applets needed for the scripts
## Download Postman
explorer.exe https://www.postman.com/downloads/
## Download VisuaBasic Code
explorer.exe https://code.visualstudio.com/download
# download PowerShell latest (7.1)
explorer.exe https://github.com/PowerShell/PowerShell/releases
# 95MB 7.1 msi package
explorer.exe https://github.com/PowerShell/PowerShell/releases/download/v7.1.0/PowerShell-7.1.0-win-x64.msi
#install
msiexec.exe /package PowerShell-7.1.0-win-x64.msi /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1
#PowerShell 7 to be used
#PowerShell 7.1 is installed to $env:ProgramFiles\PowerShell\7
#The $env:ProgramFiles\PowerShell\7 folder is added to $env:PATH
#The $env:ProgramFiles\PowerShell\6 folder is deleted

### Start installation of
# Postman and Visual Studion Code
# Configure the PowerShell extension and update to the latest PowerShell Version
# Install extention and therfore  press Ctrl+P and type:
# ext install PowerShell
# ext install region-folder

# after configuration restart VisualStudio
code  

# Clone the restapi repository to your local computer
explorer.exe https://github.com/juergenschubert/DELLEMC-DPS-ReST-api

# now let's import DD 7.3 Collection and environment into Postman.

#endregion


#### let's start with the prototype:
## Query user on my DataDomain

#region figure out the ReST api call you need for that job
#find the Rest APIs for our products
##developer.dellemc.com
Start-Process -FilePath "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe" developer.dellemc.com
##develople.emc.com
Start-Process -FilePath "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe" developer.dell.com
# jump onto Postman
#change the environment var for the appropriate ddve
#figure out that the fqdn for a DD is working and can be resolved
# I haved tried with DDOS 7.2 and 7.3 without problems
Test-connection ddve-01
[System.Net.Dns]::GetHostAddresses(“ddve-01“)
$RestUrl=“ddve-01“
Test-Connection -TargetName "$($RestUrl)" -TcpPort 443

# Login and get the AuthToken
#$response = Invoke-RestMethod '//https://ddve-01:3009/rest/v1.0/auth' -Method 'POST' -Headers $headers -Body $body

# get a list of all DD local user
# $response = Invoke-RestMethod 'https://ddve-01:3009/rest/v1.0/dd-systems/0/users' -Method 'GET' -Headers $headers -Body $body
#endregion
 

# get familar with that syntax
get-help Invoke-RestMethod -ShowWindow


#region PS Scriptlet
#####
# $RestUrl = "ddve-01"
#region ps1 script - Login and get the AuthToken
$auth = @{
    username="sysadmin"
    password="Password123!"
}

$Con = Invoke-RestMethod -Uri "https://$($RestUrl):3009/rest/v1.0/auth" `
    -Method POST `
    -ContentType 'application/json' `
    -Body (ConvertTo-Json $auth) `
    -SkipCertificateCheck  `
    -ResponseHeadersVariable Headers

$Con 

$mytoken = @{
    'X-DD-AUTH-TOKEN'=$Headers['X-DD-AUTH-TOKEN'][0]
}
#endregion

#region ps1 script - get DD local user on my DataDomain
# $response = Invoke-RestMethod 'https://ddve-01:3009/rest/v1.0/dd-systems/0/users' -Method 'GET' -Headers $headers -Body 
# response body with the user you wanna see

$response = Invoke-RestMethod "https://$($RestUrl):3009/rest/v1.0/dd-systems/0/users" `
                -Method 'Get'  `
                -ContentType 'application/json' ` `
                -Headers $mytoken `
                -SkipCertificateCheck  `
                -ResponseHeadersVariable Headers

For ($i=0; $i -le $response.User.count; $i++) {
    write-host $response.User[$i].name -ForegroundColor Green
    }

#endregion
#endregion


# from code to function
#################


#region function  - let's create functions with variables

#region Connect-DD-JS

#region function Connect-DD-JS Login to DD

function Connect-DD-JS {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$DDfqdn,
        [Parameter(Mandatory)]
        [string]$DDUserName,
        [Parameter(Mandatory)]
        [string]$DDPassword
    )
    
    begin {

    } #END BEGIN

    process {

        $auth = @{
            username="$($DDUserName)"
            password="$($DDPassword)"
        }
    

        Write-Verbose "[DD] Username: $DDUserName"
        Write-Verbose "[DD] Password: $DDPassword"

        Write-Verbose "[DD] Login to get the access token" -InformationAction Continue
        [System.Net.ServicePointManager]::SecurityProtocol =[System.Net.SecurityProtocolType]::Tls12
        Write-Verbose "[DD] FQDN $DDfqdn"
        #LOGIN TO DD REST API
        Write-Verbose "[DD] Login to get the access token"

        $body = "{`n    `"username`": `"$($DDUserName)`",`n    `"password`": `"$DDPassword`"`n}"

        $response = Invoke-RestMethod -uri "https://$($DDfqdn):3009/api/v1.0/auth" `
            -Method 'POST' `
            -ContentType 'application/json' `
            -Body $body `
            -SkipCertificateCheck `
            -ResponseHeadersVariable Headers

            Write-Verbose "[DEBUG] response body"
            Write-Verbose $response | ConvertTo-Json
            Write-Verbose "[DEBUG] response Header"
            Write-Verbose $Headers

        $DDAutoTokenValue = $Headers['X-DD-AUTH-TOKEN'][0]
        $mytoken = @{
            'X-DD-AUTH-TOKEN'=$Headers['X-DD-AUTH-TOKEN'][0]
        }
        

        Write-Verbose "[DEBUG] X-DD-Auth-Token"
        Write-Verbose "$Headers['X-DD-AUTH-TOKEN']"
        Write-Verbose "[DEBUG] token"
        Write-Verbose $mytoken

        $global:DDAuthToken = $mytoken
        return $DDAutoTokenValue

    } # END Process
} #END Function

# See what we have created... so for in memory only
#endregion
#region Check your Connect-DD-JS function
Dir function:Connect-DD-JS

Connect-DD-JS -DDfqdn "ddve-01" -DDUserName "sysadmin" -DDPassword "Password123!"
$DDtoken = Connect-DD-JS -DDfqdn "ddve-01" -DDUserName "sysadmin" -DDPassword "Password123!"


Connect-DD-JS -DDfqdn "ddve-01" -DDUserName "sysadmin" -DDPassword "Password123!" -verbose

#endregion
#endregion


#region function Get-DDUser-JS get all existing DD User
function Get-DDUser-JS {
   [CmdletBinding()]
       param (
           [Parameter(Mandatory)]
           [string]$DDfqdn,
           [Parameter(Mandatory)]
           [string]$DDAuthTokenValue
    )
    
    begin {

    } #END BEGIN

    process {
        $RestUrl = $DDfqdn
        Write-Verbose "[DEBUG] token"
        Write-Verbose $DDAuthTokenValue
        Write-Verbose "[Debug] FQDN of the DD"
        Write-Verbose "$DDfqdn"

        $authtoken = @{
            'X-DD-AUTH-TOKEN'= $DDAuthTokenValue
        }
        $response1 = Invoke-RestMethod "https://$($RestUrl):3009/rest/v1.0/dd-systems/0/users" `
            -Method 'Get'  `
            -ContentType 'application/json' ` `
            -Headers $authtoken `
            -SkipCertificateCheck  `
            -ResponseHeadersVariable Headers1

        For ($i=0; $i -le $response1.User.count; $i++) {
              write-host $response1.User[$i].name
        }
        
        Write-Verbose "[DEBUG] Response User Count: $response1.User.count "
        Write-Verbose "[DEBUG] response body"
        Write-Verbose $response1
        Write-Verbose "[DEBUG] response Header"
        Write-Verbose $Headers1
    } #End Process
} #End Function
# See what we have created... so for in memory only
#region check the function is working
Dir function:Get-DDUser-JS
$DDtoken
Get-Help Get-DDUser-JS
Get-DDUser-JS -DDfqdn "ddve-01" -DDAuthTokenValue $DDtoken 
Get-DDUser-JS -DDfqdn "ddve-01" -DDAuthTokenValue $DDtoken -verbose
#endregion

# We've created code but nothing will show up on
get-help Connect-DD-JS
get-help Get-DDUser-JS
#endregion
#endregion



# enrich with some cmdlet like helpfile text
#################

#region Add some Help text into the function - still only in memory not a real cmdlet
#region What we need to add is:
<#
.SYNOPSIS
    Creates a new PowerShell function in the specified location.
 
.DESCRIPTION
    New-MrFunction is an advanced function that creates a new PowerShell function in the
    specified location including creating a Pester test for the new function.
 
.PARAMETER Name
    Name of the function.
 
.PARAMETER Path
    Path of the location where to create the function. This location must already exist.
 
.EXAMPLE
     New-MrFunction -Name Get-MrPSVersion -Path "$env:ProgramFiles\WindowsPowerShell\Modules\MyModule"
 
.INPUTS
    None
 
.OUTPUTS
    System.IO.FileInfo
 
.NOTES
    Author:  Juergen Schubert
    Website: http://juergenschubert.com
    Twitter: @NextGenBackup
#>
#endregion

#region Connect-DD-JS
function Connect-DD-JS {
<#
.SYNOPSIS
    Connect to a DataDomain you specify and returns the authtoken for further login
    
.DESCRIPTION
    Connect-DD-JS is a function which logs into a DataDomain with sysadmin and password 
    and returns the authtoken which can be used for other ReST api call.
 
.PARAMETER Name
    DDfqdn        DataDomain FQDN
    DDUserName    User Name for DD
    DDPassword    Password for this user
 
.PARAMETER Path
    local path

.EXAMPLE
    Connect-DD-JS -DDfqdn "ddve-01" -DDUserName "sysadmin" -DDPassword "changeme"
    
    $DDtoken = Connect-DD-JS -DDfqdn "ddve-01" -DDUserName "sysadmin" -DDPassword "changeme"
    
    Connect-DD-JS -DDfqdn "ddve-01" -DDUserName "sysadmin" -DDPassword "changeme" -verbose

.INPUTS
    System.String[]
 
.OUTPUTS
    DataDomain Auth Token
 
.NOTES
    Author:  Juergen Schubert
    Website: http://juergenschubert.com
    Twitter: @NextGenBackup
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$DDfqdn,
        [Parameter(Mandatory)]
        [string]$DDUserName,
        [Parameter(Mandatory)]
        [string]$DDPassword
    )
    
    begin {

    } #END BEGIN

    process {

        $auth = @{
            username="$($DDUserName)"
            password="$($DDPassword)"
        }
    

        Write-Verbose "[DD] Username: $DDUserName"
        Write-Verbose "[DD] Password: $DDPassword"

        Write-Verbose "[DD] Login to get the access token" -InformationAction Continue
        [System.Net.ServicePointManager]::SecurityProtocol =[System.Net.SecurityProtocolType]::Tls12
        Write-Verbose "[DD] FQDN $DDfqdn"
        #LOGIN TO DD REST API
        Write-Verbose "[DD] Login to get the access token"

        $response = Invoke-RestMethod -uri "https://$($DDfqdn):3009/api/v1.0/auth" `
            -Method 'POST' `
            -ContentType 'application/json' `
            -Body (ConvertTo-Json $auth) `
            -SkipCertificateCheck `
            -ResponseHeadersVariable Headers

        $DDAutoTokenValue = $Headers['X-DD-AUTH-TOKEN'][0]
        $mytoken = @{
            'X-DD-AUTH-TOKEN'=$Headers['X-DD-AUTH-TOKEN'][0]
        }
        

        Write-Verbose "[DEBUG] X-DD-Auth-Token"
        Write-Verbose "$Headers['X-DD-AUTH-TOKEN']"
        Write-Verbose "[DEBUG] token"
        Write-Verbose $mytoken
        Write-Verbose "[DEBUG] response body"
        Write-Verbose $response | ConvertTo-Json
        Write-Verbose "[DEBUG] response Header"
        Write-Verbose $Headers
        $global:DDAuthToken = $mytoken
        $measureObject = $DDAutoTokenValue | Measure-Object -Character;
        $counttokenchar = $measureObject.Character;
        
        return $DDAutoTokenValue

    } # END Process
} #END Function

# let's check what has changed
Get-Help Connect-DD-JS
Get-Help Connect-DD-JS -Examples
Get-Help Connect-DD-JS -Detailed
Get-Help Connect-DD-JS -Full
#endregion

#region Get-DDUser-JS
function Get-DDUser-JS {
<#
.SYNOPSIS
    Connect to a DataDomain you specify and returns the local User

.DESCRIPTION
    Get-DDUser-JS is a function which logs into a DataDomain with the provided authtoken 
    you shoudw received from Connect-DD-JS and returns a list of local DD user.
 
.PARAMETER Name
    DDfqdn  DataDomain FQDN
    DDtoken AuthToken for login to the DD
 
.PARAMETER Path
    local path

.EXAMPLE
    Get-DDUser-JS -DDfqdn "ddve-01" -DDAuthTokenValue $DDtoken 
    
    Get-DDUser-JS -DDfqdn "ddve-01" -DDAuthTokenValue $DDtoken -verbose

.INPUTS
    System.String[]
 
.OUTPUTS
    returns the local user name on the DataDomain System
 
.NOTES
    Author:  Juergen Schubert
    Website: http://juergenschubert.com
    Twitter: @NextGenBackup
#>
    [CmdletBinding()]
        param (
            [Parameter(Mandatory)]
            [string]$DDfqdn,
            [Parameter(Mandatory)]
            [string]$DDAuthTokenValue
     )
     
     begin {
 
     } #END BEGIN
 
     process {
         $RestUrl = $DDfqdn
         Write-Verbose "[DEBUG] token"
         Write-Verbose $DDAuthTokenValue
         Write-Verbose "[Debug] FQDN of the DD"
         Write-Verbose "$DDfqdn"
 
         $authtoken = @{
             'X-DD-AUTH-TOKEN'= $DDAuthTokenValue
         }
         $response1 = Invoke-RestMethod "https://$($RestUrl):3009/rest/v1.0/dd-systems/0/users" `
             -Method 'Get'  `
             -ContentType 'application/json' ` `
             -Headers $authtoken `
             -SkipCertificateCheck  `
             -ResponseHeadersVariable Headers1
 
         For ($i=0; $i -le $response1.User.count; $i++) {
               write-host $response1.User[$i].name
         }
         
         Write-Verbose "[DEBUG] Response User Count: $response1.User.count "
         Write-Verbose "[DEBUG] response body"
         Write-Verbose $response1
         Write-Verbose "[DEBUG] response Header"
         Write-Verbose $Headers1
     } #End Process
 } #End Function

# let's check what has changed
Get-Help Get-DDUser-JS
Get-Help Get-DDUser-JS -Examples
Get-Help Get-DDUser-JS -Detailed
Get-Help Get-DDUser-JS -Full
#endregion

#endregion
 


# let's create the boblab cmdlet
#################
#region create the boblet cmdlet


#region Theory of a cmdlet
$Path ="c:\Demo"
#Create a directory for the script module
New-Item -Path $Path -Name MyModule -ItemType Directory

#Create the script module (PSM1 file) using the Out-File cmdlet
Out-File -FilePath $Path\MyModule\MyModule.psm1

Set-Content -Path "$Path\MyModule\MyModule.psm1" -Value @'
function Get-JSPSVersion {
    $PSVersionTable
}

function Get-JSComputerName {
    $env:COMPUTERNAME
}
'@
#Try to call one of the functions
Get-JSComputerName

#In order to take advantage of module autoloading, a script module needs to be saved in a folder with the same base name as the PSM1
#file and in a location specified in $env:PSModulePath

#Show where the module currently resides at
explorer.exe $Path\MyModule

#Show the PSModulePath on my computer
$env:PSModulePath -split ';'

#Show the default locations that exist in the PSModulePath
($env:PSModulePath -split ';').Where({$_ -like '*WindowsPowerShell*'})

#Current user path
($env:PSModulePath -split ';').Where({$_ -like "*WindowsPowerShell*"})[0]

#All user path (added in PowerShell verison 4.0)
($env:PSModulePath -split ';').Where({$_ -like "*WindowsPowerShell*"})[1]

#No user modules should be placed in the Windows\System32 path. Only Microsot should place modules there.
($env:PSModulePath -split ';').Where({$_ -like "*WindowsPowerShell*"})[2]

#If the PSModuleAutoLoadingPreference has been changed from the default, it can impact module autoloading.
$PSModuleAutoloadingPreference

#show the helpfile in a external window
help about_Preference_Variables -showwindow

#enable autoload of all modules in the module path 
$PSModuleAutoLoadingPreference = 'All'

# check the module path again
$env:PSModulePath

#see what we have here - check if that one exists
explorer.exe $env:ProgramFiles\WindowsPowerShell\Modules

#Create a directory for the script module if not there
New-Item -Path $env:ProgramFiles -Name WindowsPowerShell -ItemType Directory
New-Item -Path $env:ProgramFiles\WindowsPowerShell -Name Modules -ItemType Directory


#Move our newly created module to a location MyModule that exist in $env:PSModulePath
Move-Item -Path $Path\MyModule -Destination $env:ProgramFiles\WindowsPowerShell\Modules
#let's see if it is there
explorer.exe $env:ProgramFiles\WindowsPowerShell\Modules\MyModule
#Try to call one of the functions
Get-JSComputerName
Get-Command -Module MyModule

#endregion


# OKAY now let's go with our code

#region let's create our own boblab cmdlet
#Create a directory bob for the script module in our devpath
New-Item -Path $Path -Name boblab -ItemType Directory

#Create the script module (PSM1 file) using the Out-File cmdlet
Out-File -FilePath $Path\boblab\boblab.psm1

#region code snipeit to create content for boblab.psm1
Set-Content -Path "$Path\boblab\boblab.psm1" -Value @'
function Connect-DD-JS {
    <#
    .SYNOPSIS
        Connect to a DataDomain you specify and returns the authtoken for further login
        
    .DESCRIPTION
        Connect-DD-JS is a function which logs into a DataDomain with sysadmin and password 
        and returns the authtoken which can be used for other ReST api call.
     
    .PARAMETER Name
        DDfqdn        DataDomain FQDN
        DDUserName    User Name for DD
        DDPassword    Password for this user
     
    .PARAMETER Path
        local path
    
    .EXAMPLE
        Connect-DD-JS -DDfqdn "ddve-01" -DDUserName "sysadmin" -DDPassword "changeme"
        
        $DDtoken = Connect-DD-JS -DDfqdn "ddve-01" -DDUserName "sysadmin" -DDPassword "changeme"
        
        Connect-DD-JS -DDfqdn "ddve-01" -DDUserName "sysadmin" -DDPassword "changeme" -verbose
    
    .INPUTS
        System.String[]
     
    .OUTPUTS
        DataDomain Auth Token
     
    .NOTES
        Author:  Juergen Schubert
        Website: http://juergenschubert.com
        Twitter: @NextGenBackup
    #>
        [CmdletBinding()]
        param (
            [Parameter(Mandatory)]
            [string]$DDfqdn,
            [Parameter(Mandatory)]
            [string]$DDUserName,
            [Parameter(Mandatory)]
            [string]$DDPassword
        )
        
        begin {
    
        } #END BEGIN
    
        process {
    
            $auth = @{
                username="$($DDUserName)"
                password="$($DDPassword)"
            }
        
    
            Write-Verbose "[DD] Username: $DDUserName"
            Write-Verbose "[DD] Password: $DDPassword"
    
            Write-Verbose "[DD] Login to get the access token" -InformationAction Continue
            [System.Net.ServicePointManager]::SecurityProtocol =[System.Net.SecurityProtocolType]::Tls12
            Write-Verbose "[DD] FQDN $DDfqdn"
            #LOGIN TO DD REST API
            Write-Verbose "[DD] Login to get the access token"
    
            $response = Invoke-RestMethod -uri "https://$($DDfqdn):3009/api/v1.0/auth" `
                -Method 'POST' `
                -ContentType 'application/json' `
                -Body (ConvertTo-Json $auth) `
                -SkipCertificateCheck `
                -ResponseHeadersVariable Headers
    
            $DDAutoTokenValue = $Headers['X-DD-AUTH-TOKEN'][0]
            $mytoken = @{
                'X-DD-AUTH-TOKEN'=$Headers['X-DD-AUTH-TOKEN'][0]
            }
            
    
            Write-Verbose "[DEBUG] X-DD-Auth-Token"
            Write-Verbose "$Headers['X-DD-AUTH-TOKEN']"
            Write-Verbose "[DEBUG] token"
            Write-Verbose $mytoken
            Write-Verbose "[DEBUG] response body"
            Write-Verbose $response | ConvertTo-Json
            Write-Verbose "[DEBUG] response Header"
            Write-Verbose $Headers
            $global:DDAuthToken = $mytoken
            
            return $DDAutoTokenValue
    
        } # END Process
    } #END Function

function Get-DDUser-JS {
    <#
    .SYNOPSIS
        Connect to a DataDomain you specify and returns the local User
    
    .DESCRIPTION
        Get-DDUser-JS is a function which logs into a DataDomain with the provided authtoken 
        you shoudw received from Connect-DD-JS and returns a list of local DD user.
     
    .PARAMETER Name
        DDfqdn  DataDomain FQDN
        DDtoken AuthToken for login to the DD
     
    .PARAMETER Path
        local path
    
    .EXAMPLE
        Get-DDUser-JS -DDfqdn "ddve-01" -DDAuthTokenValue $DDtoken 
        
        Get-DDUser-JS -DDfqdn "ddve-01" -DDAuthTokenValue $DDtoken -verbose
    
    .INPUTS
        System.String[]
     
    .OUTPUTS
        returns the local user name on the DataDomain System
     
    .NOTES
        Author:  Juergen Schubert
        Website: http://juergenschubert.com
        Twitter: @NextGenBackup
    #>
        [CmdletBinding()]
            param (
                [Parameter(Mandatory)]
                [string]$DDfqdn,
                [Parameter(Mandatory)]
                [string]$DDAuthTokenValue
         )
         
         begin {
     
         } #END BEGIN
     
         process {
             $RestUrl = $DDfqdn
             Write-Verbose "[DEBUG] token"
             Write-Verbose $DDAuthTokenValue
             Write-Verbose "[Debug] FQDN of the DD"
             Write-Verbose "$DDfqdn"
     
             $authtoken = @{
                 'X-DD-AUTH-TOKEN'= $DDAuthTokenValue
             }
             $response1 = Invoke-RestMethod "https://$($RestUrl):3009/rest/v1.0/dd-systems/0/users" `
                 -Method 'Get'  `
                 -ContentType 'application/json' ` `
                 -Headers $authtoken `
                 -SkipCertificateCheck  `
                 -ResponseHeadersVariable Headers1
     
             For ($i=0; $i -le $response1.User.count; $i++) {
                   write-host $response1.User[$i].name
             }
             
             Write-Verbose "[DEBUG] Response User Count: $response1.User.count "
             Write-Verbose "[DEBUG] response body"
             Write-Verbose $response1
             Write-Verbose "[DEBUG] response Header"
             Write-Verbose $Headers1
         } #End Process
     } #End Function
'@
#endregion

#Or the other approach - let's now start the new new module in a new editor window
code $Path\boblab\boblab.psm1
#Copy and paste both created function into the new file
#save it

explorer.exe $env:ProgramFiles\WindowsPowerShell\Modules
#Move our newly created boblab module to a location that exist in $env:PSModulePath
Move-Item -Path $Path\boblab -Destination $env:ProgramFiles\WindowsPowerShell\Modules -force

# Check if we do see both functions / now cmdlets
Get-Command -module boblab

# when your autoload doesn't work import by hand
Import-Module -Name boblab -Force
#remove the module


#endregion

#Show the commands that are part of boblab
Get-Command -Module boblab
Get-Module -Name boblab

#Show the count of the commands that are part of MyModule
(Get-Command -Module boblab).count

# show some examples

Dir function:Connect-DD-JS

$DDtoken = Connect-DD-JS -DDfqdn "ddve-01" -DDUserName "sysadmin" -DDPassword "Password123!"

Dir function:Get-DDUser-JS
$DDtoken
Get-Help Get-DDUser-JS
Get-DDUser-JS -DDfqdn "ddve-01" -DDAuthTokenValue $DDtoken 
#endregion


# We've created code, build a function which is cmdlet like but NO error handling
#################

#region add errorhandling
## please validate the DD FQDN does exist
function Connect-DD-JS {
    <#
    .SYNOPSIS
        Connect to a DataDomain you specify and returns the authtoken for further login
        
    .DESCRIPTION
        Connect-DD-JS is a function which logs into a DataDomain with sysadmin and password 
        and returns the authtoken which can be used for other ReST api call.
     
    .PARAMETER Name
        DDfqdn        DataDomain FQDN
        DDUserName    User Name for DD
        DDPassword    Password for this user
     
    .PARAMETER Path
        local path
    
    .EXAMPLE
        Connect-DD-JS -DDfqdn "ddve-01" -DDUserName "sysadmin" -DDPassword "changeme"
        
        $DDtoken = Connect-DD-JS -DDfqdn "ddve-01" -DDUserName "sysadmin" -DDPassword "changeme"
        
        Connect-DD-JS -DDfqdn "ddve-01" -DDUserName "sysadmin" -DDPassword "changeme" -verbose
    
    .INPUTS
        System.String[]
     
    .OUTPUTS
        DataDomain Auth Token
     
    .NOTES
        Author:  Juergen Schubert
        Website: http://juergenschubert.com
        Twitter: @NextGenBackup
    #>
        [CmdletBinding()]
        param (
            [Parameter(Mandatory)]
            [string]$DDfqdn,
            [Parameter(Mandatory)]
            [string]$DDUserName,
            [Parameter(Mandatory)]
            [string]$DDPassword
        )
        
        begin {
    
        } #END BEGIN
    
        process {
    
            $auth = @{
                username="$($DDUserName)"
                password="$($DDPassword)"
            }
        
    
            Write-Verbose "[DD] Username: $DDUserName"
            Write-Verbose "[DD] Password: $DDPassword"
    
            Write-Verbose "[DD] Login to get the access token" -InformationAction Continue
            [System.Net.ServicePointManager]::SecurityProtocol =[System.Net.SecurityProtocolType]::Tls12
            Write-Verbose "[DD] FQDN $DDfqdn"
            #LOGIN TO DD REST API
            Write-Verbose "[DD] Login to get the access token"
    
            $response = Invoke-RestMethod -uri "https://$($DDfqdn):3009/api/v1.0/auth" `
                -Method 'POST' `
                -ContentType 'application/json' `
                -Body (ConvertTo-Json $auth) `
                -SkipCertificateCheck `
                -ResponseHeadersVariable Headers
    
            $DDAutoTokenValue = $Headers['X-DD-AUTH-TOKEN'][0]
            $mytoken = @{
                'X-DD-AUTH-TOKEN'=$Headers['X-DD-AUTH-TOKEN'][0]
            }
            
    
            Write-Verbose "[DEBUG] X-DD-Auth-Token"
            Write-Verbose "$Headers['X-DD-AUTH-TOKEN']"
            Write-Verbose "[DEBUG] token"
            Write-Verbose $mytoken
            Write-Verbose "[DEBUG] response body"
            Write-Verbose $response | ConvertTo-Json
            Write-Verbose "[DEBUG] response Header"
            Write-Verbose $Headers
            $global:DDAuthToken = $mytoken
            
            return $DDAutoTokenValue
    
        } # END Process
    } #END Function


## please validat that the token has 33 char
## please validate the DD FQDN does exist with ValidateScript
## please also enable piplie with parameter(ValueFromPipeline)
function Get-DDUser-JS {
    <#
    .SYNOPSIS
        Connect to a DataDomain you specify and returns the local User
    
    .DESCRIPTION
        Get-DDUser-JS is a function which logs into a DataDomain with the provided authtoken 
        you shoudw received from Connect-DD-JS and returns a list of local DD user.
     
    .PARAMETER Name
        DDfqdn  DataDomain FQDN
        DDtoken AuthToken for login to the DD
     
    .PARAMETER Path
        local path
    
    .EXAMPLE
        Get-DDUser-JS -DDfqdn "ddve-01" -DDAuthTokenValue $DDtoken 
        
        Get-DDUser-JS -DDfqdn "ddve-01" -DDAuthTokenValue $DDtoken -verbose
    
    .INPUTS
        System.String[]
     
    .OUTPUTS
        returns the local user name on the DataDomain System
     
    .NOTES
        Author:  Juergen Schubert
        Website: http://juergenschubert.com
        Twitter: @NextGenBackup
    #>
        [CmdletBinding()]
            param (
                [Parameter(Mandatory,HelpMessage='Please enter any FQDN of your DataDomain')]
                [ValidateScript({(Test-NetConnection -ComputerName $DDfqdn -Port 443).TcpTestSucceeded})]
                [ValidateNotNullOrEmpty()]
                [string]$DDfqdn,
                [Parameter(Mandatory,HelpMessage='Enter an DD Auth token!')]
                [Parameter(ValueFromPipeline)]
                [ValidateLength(33,33)]
                [string]$DDAuthTokenValue
         )
         
         begin {
     
         } #END BEGIN
     
         process {
             $RestUrl = $DDfqdn
             Write-Verbose "[DEBUG] token"
             Write-Verbose $DDAuthTokenValue
             Write-Verbose "[Debug] FQDN of the DD"
             Write-Verbose "$DDfqdn"
     
             $authtoken = @{
                 'X-DD-AUTH-TOKEN'= $DDAuthTokenValue
             }
             $response1 = Invoke-RestMethod "https://$($RestUrl):3009/rest/v1.0/dd-systems/0/users" `
                 -Method 'Get'  `
                 -ContentType 'application/json' ` `
                 -Headers $authtoken `
                 -SkipCertificateCheck  `
                 -ResponseHeadersVariable Headers1
     
             For ($i=0; $i -le $response1.User.count; $i++) {
                   write-host $response1.User[$i].name
             }
             
             Write-Verbose "[DEBUG] Response User Count: $response1.User.count "
             Write-Verbose "[DEBUG] response body"
             Write-Verbose $response1
             Write-Verbose "[DEBUG] response Header"
             Write-Verbose $Headers1
         } #End Process
     } #End Function

#endregion

#region get the get-command show no version fix this
#endregion


#region Cleanup

Get-Item -Path Function:\Connect-DD-JS
Get-ChildItem -Path Function:\Connect-DD-JS
 
# Remove
Remove-Item -Path Function:\Connect-DD-JS

Set-Location -Path C:\
$Path = 'C:\Demo'
Remove-Module -Name MyModule -ErrorAction SilentlyContinue
Remove-Item -Path "$Path\Get-JSPSVersion.ps1", "$Path\Get-JSComputerName.ps1" -ErrorAction SilentlyContinue
Remove-Item -Path $env:ProgramFiles\WindowsPowerShell\Modules\MyModule -Recurse -Confirm:$false -ErrorAction SilentlyContinue
#JSToolkit
Remove-Module -Name JSToolkit -ErrorAction SilentlyContinue
#boblab
New-Item -Path $Path -Name backup -ItemType Directory
Move-Item -Path $env:ProgramFiles\WindowsPowerShell\Modules\boblab -Destination $Path\backup
Remove-Module -Name boblab -Force
Get-Command -module boblab
Uninstall-Module -Name boblab
Remove-Item -Path $env:ProgramFiles\WindowsPowerShell\Modules\boblab -Recurse -Confirm:$false -ErrorAction SilentlyContinue
Remove-Module -Name boblab -ErrorAction SilentlyContinue
#endregion
