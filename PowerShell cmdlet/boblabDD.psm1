
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
        [ValidateScript({
            if (Test-Connection -TargetName "$($_)" -TcpPort 443)
            {
                $true
            } else {
                throw "$_ is invalid. the FQDN cannot be resolved. Please correct."   
            }
            }) 
        ]
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
        $measureObject = $DDAutoTokenValue | Measure-Object -Character;
        $counttokenchar = $measureObject.Character;

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
                [ValidateScript({
                    if (Test-Connection -TargetName "$($_)" -TcpPort 443)
                    {
                        $true
                    } else {
                        throw "$_ is invalid. the FQDN cannot be resolved. Please correct."   
                    }
                    }) 
                ]
                [string]$DDfqdn,
                [Parameter(Mandatory)]
                [ValidateScript({
                    if($DDAuthTokenValue.Length -eq 33)
                    {
                        $true
                    } else {
                        throw "$_ is invalid Authcode. Please provide a valid authcode for DataDoman"   
                    }
                    }) 
                ]
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