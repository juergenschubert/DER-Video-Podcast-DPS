
#region preparation
#thans to Mike F. Robins  mikefrobbins.com  on twitter @mikefrobbins for the template and some stolen code :-)
#The whole code can be found on my GizHub Repos
www.github.com/juergenschubert
#details @
https://raw.githubusercontent.com/juergenschubert/DER-Video-Podcast-DPS/master/PowerShell%20cmdlet/learn-Get-DDUser-Cmdlet.ps1

#CTRL-M will toggle the wohle region

#$psISE.CurrentFile.Editor.ToggleOutliningExpansion()
#function to check your running environment
function Get-PSVersion {
    $PSVersionTable
}
Get-PSVersion

PowerShell description how to design and create a DPS cmdlet
Author:  Juergen Schubert
#>
#Safety in case the entire script is run instead of a selection
Start-Sleep -Seconds 1800

#Set PowerShell ISE Zoom to 175%
$psISE.Options.Zoom = 175
$Path = 'C:\Demo'
#CTRL- MINUS and CTRL - PLUS will in/decrease the font size

#Create the C:\Demo Folder if it doesn't already exist
If (-not(Test-Path -Path $Path -PathType Container)) {
    New-Item -Path $Path -ItemType Directory
}

#Change into the C:\Demo folder
Set-Location -Path $Path

#do you have a profile?
$PROFILE


# install applets needed for the scripts

#download PowerShell 7 to be used
msiexec.exe /package PowerShell-7.1.0-win-x64.msi /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1
#PowerShell 7.1 is installed to $env:ProgramFiles\PowerShell\7
#The $env:ProgramFiles\PowerShell\7 folder is added to $env:PATH
#The $env:ProgramFiles\PowerShell\6 folder is deleted

#download visualstudio instead of ise
# download and install
explorer.exe "https://code.visualstudio.com/"
#Configure the PowerShell extension and update to the latest PowerShell Version

# after installation start VisualStudio
code  

#config the default PowerShell to  PS 7 if not done automatically
# Code user settings.json file by clicking on file > preferences > settings, select ... and then Open settings.json.
{
    "terminal.integrated.shell.windows": "c:/Program Files/PowerShell/7/pwsh.exe"
} 
#endregion

##Use Case
#DD Customer with more than 700 DDs is looking for a way to get a list of all local DD User. GUI and DD Management Center are not an option.

## Query  user on my DataDomain

#region figure out the ReST api call you need for that job
# jump onto Postman

# Login and get the AuthToken
#$response = Invoke-RestMethod '//https://ddve-02.vlab.local:3009/rest/v1.0/auth' -Method 'POST' -Headers $headers -Body $body

# Create a DD User
# $response = Invoke-RestMethod 'https://ddve-02.vlab.local:3009/rest/v1.0/dd-systems/0/users' -Method 'POST' -Headers $headers -Body $body

# assign a user to a boost user
#$response = Invoke-RestMethod 'https://ddve-02.vlab.local:3009/rest/v1.0/dd-systems/0/protocols/ddboost/users' -Method 'PUT' -Headers $headers -Body $body
#endregion
 
#figure out that the fqdn is working and can be resolved
[System.Net.Dns]::GetHostAddresses(“ddve-2.vlab.local“)
$RestUrl = “ddve-1.vlab.local“
# get familar with that syntax
get-help Invoke-RestMethod -ShowWindow


#region check and wait until DD is available
do {
    Write-Host "[TESTING]: HTTPS connectivity to DDVE { $($RestUrl):443 }" -ForegroundColor Green

    $HTTPS = Test-Connection -TargetName "$($RestUrl)" -TcpPort 22
            
    if ($HTTPS -eq $false) {
        Write-Host "[SLEEPING]: 1 Minute. Will try again"
        Get-ElapsedTime -Minutes 1
    }
}

#endregion


#region PowerShell Scriptlet
#####

#region ps1 script - Login and get the AuthToken
$auth = @{
    username = "sysadmin"
    password = "Password123!"
}

$Con = Invoke-RestMethod -Uri "https://$($RestUrl):3009/rest/v1.0/auth" `
    -Method POST `
    -ContentType 'application/json' `
    -Body (ConvertTo-Json $auth) `
    -SkipCertificateCheck  `
    -ResponseHeadersVariable Headers
$Con
$mytoken = @{
    'X-DD-AUTH-TOKEN$' = $Headers['X-DD-AUTH-TOKEN'][0]
}
#endregion

#region ps1 script - get DD local user on my DataDomain
# $response = Invoke-RestMethod 'https://ddve-2.vlab.local:3009/rest/v1.0/dd-systems/0/users' -Method 'GET' -Headers $headers -Body 
#body with the user you wanna create

$response = Invoke-RestMethod "https://$($RestUrl):3009/rest/v1.0/dd-systems/0/users" `
    -Method 'Get'  `
    -ContentType 'application/json' ` `
    -Headers $mytoken `
    -SkipCertificateCheck  `
    -ResponseHeadersVariable Headers

For ($i = 0; $i -le $response.User.count; $i++) {
    write-host $response.User[$i].name
}

#endregion
#endregion

#################
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
            username = "$($DDUserName)"
            password = "$($DDPassword)"
        }
    

        Write-Verbose "[DD] Username: $DDUserName"
        Write-Verbose "[DD] Password: $DDPassword"

        Write-Verbose "[DD] Login to get the access token" -InformationAction Continue
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
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
            'X-DD-AUTH-TOKEN' = $Headers['X-DD-AUTH-TOKEN'][0]
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

# See what we have created... so for in memory only
#endregion
#region Check your Connect-DD-JS function
Dir function:Connect-DD-JS

Connect-DD-JS -DDfqdn "ddve-1.vlab.local" -DDUserName "sysadmin" -DDPassword "changeme"
$DDtoken = Connect-DD-JS -DDfqdn "ddve-1.vlab.local" -DDUserName "sysadmin" -DDPassword "changeme"


Connect-DD-JS -DDfqdn "ddve-1.vlab.local" -DDUserName "sysadmin" -DDPassword "changeme" -verbose

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
            'X-DD-AUTH-TOKEN' = $DDAuthTokenValue
        }
        $response1 = Invoke-RestMethod "https://$($RestUrl):3009/rest/v1.0/dd-systems/0/users" `
            -Method 'Get'  `
            -ContentType 'application/json' ` `
            -Headers $authtoken `
            -SkipCertificateCheck  `
            -ResponseHeadersVariable Headers1

        For ($i = 0; $i -le $response1.User.count; $i++) {
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
Dir function:Get-DDUser-JS
$DDtoken
Get-Help Get-DDUser-JS
Get-DDUser-JS -DDfqdn "ddve-1.vlab.local" -DDAuthTokenValue $DDtoken 
Get-DDUser-JS -DDfqdn "ddve-1.vlab.local" -DDAuthTokenValue $DDtoken -verbose


# We've created code but nothing will show up on
get-help Connect-DD-JS
#endregion
#endregion


#################
# enrich with some cmdlet with helpfile text
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
    DDfqdn  DataDomain FQDN
    DDUserName    User Name for DD
    DDPassword    Password for this user
 
.PARAMETER Path
    local path

.EXAMPLE
    Connect-DD-JS -DDfqdn "ddve-1.vlab.local" -DDUserName "sysadmin" -DDPassword "changeme"
    
    $DDtoken = Connect-DD-JS -DDfqdn "ddve-1.vlab.local" -DDUserName "sysadmin" -DDPassword "changeme"
    
    Connect-DD-JS -DDfqdn "ddve-1.vlab.local" -DDUserName "sysadmin" -DDPassword "changeme" -verbose

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
            username = "$($DDUserName)"
            password = "$($DDPassword)"
        }
    

        Write-Verbose "[DD] Username: $DDUserName"
        Write-Verbose "[DD] Password: $DDPassword"

        Write-Verbose "[DD] Login to get the access token" -InformationAction Continue
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
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
            'X-DD-AUTH-TOKEN' = $Headers['X-DD-AUTH-TOKEN'][0]
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

# let's check what has changed
Get-Help  Connect-DD-JS
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
    Get-DDUser-JS -DDfqdn "ddve-1.vlab.local" -DDAuthTokenValue $DDtoken 
    
    Get-DDUser-JS -DDfqdn "ddve-1.vlab.local" -DDAuthTokenValue $DDtoken -verbose

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
            'X-DD-AUTH-TOKEN' = $DDAuthTokenValue
        }
        $response1 = Invoke-RestMethod "https://$($RestUrl):3009/rest/v1.0/dd-systems/0/users" `
            -Method 'Get'  `
            -ContentType 'application/json' ` `
            -Headers $authtoken `
            -SkipCertificateCheck  `
            -ResponseHeadersVariable Headers1
 
        For ($i = 0; $i -le $response1.User.count; $i++) {
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

#region create the boblab cmdlet both function
function Connect-DD-JS {
    <#
.SYNOPSIS
    Connect to a DataDomain you specify and returns the authtoken for further login
    
.DESCRIPTION
    Connect-DD-JS is a function which logs into a DataDomain with sysadmin and password 
    and returns the authtoken which can be used for other ReST api call.
 
.PARAMETER Name
    DDfqdn  DataDomain FQDN
    DDUserName    User Name for DD
    DDPassword    Password for this user
 
.PARAMETER Path
    local path

.EXAMPLE
    Connect-DD-JS -DDfqdn "ddve-1.vlab.local" -DDUserName "sysadmin" -DDPassword "changeme"
    
    $DDtoken = Connect-DD-JS -DDfqdn "ddve-1.vlab.local" -DDUserName "sysadmin" -DDPassword "changeme"
    
    Connect-DD-JS -DDfqdn "ddve-1.vlab.local" -DDUserName "sysadmin" -DDPassword "changeme" -verbose

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
            username = "$($DDUserName)"
            password = "$($DDPassword)"
        }
    

        Write-Verbose "[DD] Username: $DDUserName"
        Write-Verbose "[DD] Password: $DDPassword"

        Write-Verbose "[DD] Login to get the access token" -InformationAction Continue
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
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
            'X-DD-AUTH-TOKEN' = $Headers['X-DD-AUTH-TOKEN'][0]
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
    Get-DDUser-JS -DDfqdn "ddve-1.vlab.local" -DDAuthTokenValue $DDtoken 
    
    Get-DDUser-JS -DDfqdn "ddve-1.vlab.local" -DDAuthTokenValue $DDtoken -verbose

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
            'X-DD-AUTH-TOKEN' = $DDAuthTokenValue
        }
        $response1 = Invoke-RestMethod "https://$($RestUrl):3009/rest/v1.0/dd-systems/0/users" `
            -Method 'Get'  `
            -ContentType 'application/json' ` `
            -Headers $authtoken `
            -SkipCertificateCheck  `
            -ResponseHeadersVariable Headers1
 
        For ($i = 0; $i -le $response1.User.count; $i++) {
            write-host $response1.User[$i].name
        }
         
        Write-Verbose "[DEBUG] Response User Count: $response1.User.count "
        Write-Verbose "[DEBUG] response body"
        Write-Verbose $response1
        Write-Verbose "[DEBUG] response Header"
        Write-Verbose $Headers1
    } #End Process
} #End Function

# OKAY now let's go with our code

#Create a directory bob for the script module in our devpath
New-Item -Path $Path -Name boblab -ItemType Directory

#Create the script module (PSM1 file) using the Out-File cmdlet
Out-File -FilePath $Path\boblab\boblab.psm1

#let's now start the new new module in a new editor window
code $Path\boblab\boblab.psm1

#Copy and paste both created function into the new file
#save it

#import the module
Import-Module $Path\boblab\boblab.psm1 -Force

## Go to C:\Users\<NT ID>\Documents\WindowsPowerShell\Modules\
# Import-Module boblab
# Import-Module C:\Users\<NT ID>\Documents\WindowsPowerShell\Modules\boblab\boblab.psm1 -Force
# Check if we do see both functions / now cmdlets
Get-Command -module boblab

# when your autoload doesn't work import by hand
Import-Module -Name boblab -Force

#endregion


#################
# We've created code, build a function which is cmdlet like but NO error handling
#################


get-command Connect-DD-JS
#region get the get-command show no version fix this

#endregion

 


##########################
# let's create the boblab cmdlet
#################
#region create the boblet cmdlet
#endregion

# OKAY now let's go with our code

#region let's create our own boblab cmdlet
#Create a directory bob for the script module in our devpath
New-Item -Path $Path -Name boblab -ItemType Directory

#Create the script module (PSM1 file) using the Out-File cmdlet
Out-File -FilePath $Path\boblab\boblab.psm1

#let's now start the new new module in a new editor window
code $Path\boblab\boblab.psm1

#Copy and paste both created function into the new file
#save it

#Move our newly created boblab module to a location that exist in $env:PSModulePath
Move-Item -Path $Path\boblab -Destination $env:ProgramFiles\WindowsPowerShell\Modules

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
#endregion


#################
# We've created code, build a function which is cmdlet like but NO error handling
#################


get-command Connect-DD-JS
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