<#
    Copyright (c) 2018 Shane Hoey

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#>

class ipphoneDevice {
    [string]$ipphone
    [string]$macaddress
    [string]$serialnumber
    [pscredential]$ippCredential
    [pscredential]$sipCredential
    [string]$sipAddress
    
    ipphoneDevice ([string]$ipphone, [string]$macaddress, [string]$serialnumber,[pscredential]$ippCredential,[pscredential]$sipCredential,[string]$sipAddress) 
    {
        $this.ipphone         =  $ipphone
        $this.macaddress      =  $macaddress
        $this.serialnumber    =  $serialnumber
        $this.ippCredential   =  $ippCredential
        $this.sipCredential   =  $sipCredential
        $this.sipAddress      =  $sipAddress
    }

    ipphoneDevice ([string]$ipphone) 
    {
      $this.ipphone     = $ipphone
    }
  }
 
try{
    #Usage Statistics please refer to https://docs.shanehoey.com/terms
    $usage = (invoke-webrequest -uri "https://api.shanehoey.com/count/ipphone/" -Method Get -ErrorAction SilentlyContinue).content | convertfrom-json
    #Version Check
    [System.Version]$current = (Get-Module ipphone).version.tostring()
    [System.Version]$release = $usage.count.release
    if ($current -lt $release) {Write-verbose "New Development of Module available on github -> $current -> $release" -verbose}
} 
catch{ }

Write-Verbose -Message "The 'ipphone PowerShell Module' is still experimental." -Verbose
Write-Verbose -Message "If you encounter an issue using ipphone PowerShell Module please review or create an issue at" -verbose
Write-Verbose -Message "https://github.com/shanehoey/ipphones/issues" -Verbose

function Set-ipphoneTrustAllCertPolicy 
{
    [CmdletBinding(SupportsShouldProcess = $true,  ConfirmImpact = 'High' )]
    param()
    
    #Exist when core detected 
    if ($PSEdition -eq "Core")
    {
        Write-Warning "PowerShell Core should only use the -SkipCertificateCheck Parameter" -WarningAction Continue
    }
    else
    {   
        if (([System.Net.ServicePointManager]::SecurityProtocol).tostring() -notlike "*Tls12*" ) 
        {
            Write-Warning "Set TLS1.2 as default Security Protocol to current shell"  -WarningAction Continue
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls12'
            $settls = $true
        }
        
        if (([System.Net.ServicePointManager]::CertificatePolicy).GetType().name -eq "DefaultCertPolicy") 
        { 
            Write-Warning "Added TrustAllCertsPolicy to current shell"  -WarningAction Continue
            Add-Type -TypeDefinition @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
            [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
            $setcert = $true
           
        }

        if ($settls -or $setcert) { Write-Warning "Exit PowerShell to revert these changes" -WarningAction Continue }
    
    }
}


function Test-ipphoneICMP
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'medium')]
    param(

        [Parameter(Mandatory = $true,    ParameterSetName = 'default' )]
        [string]$ipphone
    )
      
    try 
    {
        test-connection -ComputerName $ipphone -Count 1 -Quiet
    }
    catch 
    {
        $false
    }

}


function Test-ipphoneWeb
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'medium')]
    param(

        [Parameter(Mandatory = $true,    ParameterSetName = 'default' )]
        [string]$ipphone
    )
      
    try 
    {
        $result = Invoke-WebRequest -uri "http://$ipphone/" -UseBasicParsing
        if ($result.content -like "*mainform.cgi?go=mainframe.htm*") { $true } 
        else 
        {$false}
    }
    catch 
    {
        $false
    }

}


function Test-ipphoneTrustCertPolicy 
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'medium')]
    param(

        [Parameter(Mandatory = $true,    ParameterSetName = 'default' )]
        [string]$ipphone
    )
      
    try 
    {
        $result = Invoke-WebRequest -uri "https://$ipphone/" -UseBasicParsing 
        if ($result.statuscode -eq "200") {$true} else {$false}
    }
    catch 
    {
        $false
    }

}


Function Invoke-ipphoneWebRequest 
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'medium')]
    param(

        [Parameter(Mandatory = $true,    ParameterSetName='default')]
        [string]$ipphone,
            
        [Parameter(Mandatory = $true,    ParameterSetName='default')]
        [string]$action,

        [Parameter(Mandatory = $false,    ParameterSetName='default')]
        [ValidateSet('Get', 'Put','Post','Delete')]
        [string]$method = "Get",

        [Parameter(Mandatory = $false,    ParameterSetName='default')]
        [Microsoft.PowerShell.Commands.WebRequestSession]$websession,

        [Parameter(Mandatory = $false,    ParameterSetName='default')]
        $body,
    
        [Parameter(Mandatory = $false,    ParameterSetName='default')]
        [string]$ContentType,

        [Parameter(Mandatory = $false,    ParameterSetName='default')]
        [switch]$returnobject,
        
        [Parameter(Mandatory = $false,    ParameterSetName='default')]
        [ValidateSet('http', 'https')]
        [string]$http = "https",

        [Parameter(Mandatory = $false,    ParameterSetName='default')]
        [switch]$SkipCertificateCheck
    )
    
    Process 
    { 
        try 
        {       
            $Parameters = @{ }
            $Parameters.Uri = "$($http)://$($ipphone)$($Action)"
            $Parameters.Method = $Method 
            if ($PSBoundParameters.WebSession -is [Microsoft.PowerShell.Commands.WebRequestSession])
            {
                $Parameters.WebSession = $WebSession
            }
            else  
            {
                $Parameters.SessionVariable = "WebSession"
            } 
            if ($PSBoundParameters.body) 
            {
                $Parameters.Body = $Body
            }
            if ($PSBoundParameters.ContentType)
            {
                $Parameters.ContentType  = $ContentType
            }
       

            if ($psboundparameters.SkipCertificateCheck) 
            { 
                Switch ($PSEdition)
                {
                    "Desktop"
                    {   
                        Write-Verbose "PSEdition Desktop"
                        if (!(test-ipphonetrustcertpolicy)) { write-warning "As a workaround to SSL cert run set-ipphonetrustallcertpolicy before continuing" -WarningAction Stop }  

                        $result = Invoke-WebRequest @parameters -useragent "ipphone PowerShell/$($psversiontable.psedition)/$($psversiontable.psversion)" -ErrorAction Stop 
                        $script:ippWebSession = $websession
                    }
                    "Core"
                    {
                        Write-Verbose "PSEdition Core"
                        $result = Invoke-WebRequest @parameters -useragent "ipphone PowerShell/$($psversiontable.psedition)/$($psversiontable.psversion)" -skipcertificatecheck -ErrorAction Stop 
                        $script:ippWebSession = $websession
                    }
                }
            }
            else 
            {
                $result = Invoke-WebRequest @parameters -ErrorAction Stop 
                $script:ippWebSession = $websession
            }
        
            if ($PSBoundParameters.returnobject) 
            {
                $result
            }
        
        }
        catch [System.Net.WebException]
        {
            if ($psitem.exception.message -eq "The underlying connection was closed: An unexpected error occurred on a send.")
            {
                Write-warning "[Error] - try re-running the last with -skipcertificatecheck parameter or Set-ipphoneTrustAllCertPolicy"
            }
        }
        catch 
        {
            Write-Warning -Message "[Error] - $_.Exception"
        }
    }
}
  
Function Get-ipphoneWebSession 
{

    [CmdletBinding(ConfirmImpact = 'low')]

    param()
    Process 
    { 
        $ippWebSession
    }
  }

function new-ipphonewebsession
{

    [CmdletBinding( ConfirmImpact = 'medium', DefaultParameterSetName = "default" )]
    param(

        [Parameter( Mandatory = $true, ParameterSetName = 'default' )]
        [string]$ipphone,
            
        [Parameter( Mandatory = $false, ParameterSetName = 'default' )]
        [switch]$returnobject,

        [Parameter(Mandatory = $false,    ParameterSetName='default')]
        [switch]$SkipCertificateCheck

    )

    process 
    { 
        try 
        {  

            $parameters = @{}
            $parameters.ipphone = $ipphone
            $parameters.action = "/"
            if ($PSBoundParameters.SkipCertificateCheck)
            {
                    $parameters.SkipCertificateCheck = $true
            }

            $result = invoke-ipphoneWebRequest @parameters -returnobject

            if ($result.statuscode -eq 200) 
            { 
                if ($result.rawcontent -like "*URL=mainform.cgi?go=mainframe.htm*") 
                {
                    $ippWebSession
                }
                else 
                {
                    throw
                }
            }
            else 
            {
                throw 
            } 

        }
        catch 
        {
            if(!(test-ipphoneTrustCertPolicy -ipphone $ipphone)){throw 'SSL Trust Certificate Policy'}
        }
    }
}


function Test-ipphoneConnection
{

    [CmdletBinding(ConfirmImpact = 'low',DefaultParameterSetName="default")]
    param(
  
        [Parameter(Mandatory = $true,    ParameterSetName='default')]
        [string]$ipphone,

        [Parameter(Mandatory = $true,    ParameterSetName='default')]
        [Microsoft.PowerShell.Commands.WebRequestSession]$websession

    )

    process 
    { 
            $Parameters = @{ }
            $Parameters.ipphone = $ipphone
            $Parameters.action = "/login.cgi"
            $Parameters.WebSession = $WebSession
                       
            $result = Invoke-ipphoneWebRequest @parameters -returnobject

            if ($result.content -like "*/mainform.cgi?go=mainframe.htm*") { $true } 
            elseif ($result.content -like "*Web Login*") { $false }
            elseif ($result.content -like "*Login failed*") { $false }
            else { $false }

        
    }

}

function Connect-ipphone
{

    [CmdletBinding(ConfirmImpact = 'low',DefaultParameterSetName="credential")]
    param(
  
        [Parameter(Mandatory = $true,    ParameterSetName='credential')]
        [Parameter(Mandatory = $true,    ParameterSetName='securestring')]
        [Parameter(Mandatory = $true,    ParameterSetName='string')]
        [string]$ipphone,
            
        [Parameter(Mandatory = $true,    ParameterSetName='securestring')]
        [Parameter(Mandatory = $true,    ParameterSetName='string')]
        [string]$username,

        [Parameter(Mandatory = $true,    ParameterSetName='securestring')]
        [securestring]$password,

        [Parameter(Mandatory = $true,    ParameterSetName='string')]
        [string]$passwordtext,

        [Parameter(Mandatory = $true,    ParameterSetName='credential')]
        [pscredential]$credential,

        [Parameter(Mandatory = $true,    ParameterSetName='credential')]
        [Parameter(Mandatory = $true,    ParameterSetName='securestring')]
        [Parameter(Mandatory = $true,    ParameterSetName='string')]
        [Microsoft.PowerShell.Commands.WebRequestSession]$websession,

        [Parameter(Mandatory = $false,    ParameterSetName='credential')]
        [Parameter(Mandatory = $false,    ParameterSetName='securestring')]
        [Parameter(Mandatory = $false,    ParameterSetName='string')]
        [switch]$returnobject,

        [Parameter(Mandatory = $false,    ParameterSetName='default')]
        [switch]$SkipCertificateCheck

    )



    process 
    { 

            $Parameters = @{ }
            $Parameters.ipphone = $ipphone
            $Parameters.action = "/login.cgi"
            $Parameters.Method ="post"
            $parameters.ContentType = "application/x-www-form-urlencoded" 
            if ($PSBoundParameters.password)     { $credential = New-Object System.Management.Automation.PSCredential ($username, $password) }
            if ($PSBoundParameters.passwordtext) { $credential = New-Object System.Management.Automation.PSCredential ($username, (ConvertTo-SecureString $passwordtext -AsPlainText -Force)) }
            $parameters.body = @{user="$($credential.username)";psw="$([Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($credential.GetNetworkCredential().password)))" } 
            if ($PSBoundParameters.WebSession -is [Microsoft.PowerShell.Commands.WebRequestSession])
            {
                $Parameters.WebSession = $WebSession
            }
            if ($PSBoundParameters.SkipCertificateCheck)
            {
                    $parameters.SkipCertificateCheck = $true
            }

            $result = Invoke-ipphoneWebRequest @parameters -returnobject

            if ($result.content -like "*Login failed*") { write-warning "Incorrect username or password"  }

            if($PSBoundParameters.returnobject) 
            {    
                $result 
            }
        
    }

  }

function Invoke-ipphoneReboot
{

    [CmdletBinding(ConfirmImpact = 'low',DefaultParameterSetName="default")]
    param(
  
        [Parameter(Mandatory = $true,    ParameterSetName='default')]
        [string]$ipphone,

        [Parameter(Mandatory = $true,    ParameterSetName='default')]
        [Microsoft.PowerShell.Commands.WebRequestSession]$websession
    )

    process 
    { 

        $Parameters = @{ }
        $Parameters.ipphone = $ipphone
        $Parameters.action = "/mainform.cgi/reboot.htm"
        $Parameters.Method ="post"
        $parameters.body = @{ REBOOT = 2 }
        $parameters.contenttype = "application/x-www-form-urlencoded" 
        $parameters.webSession = $websession 

        $result = Invoke-ipphoneWebRequest @parameters -returnobject

        if($PSBoundParameters.returnobject) 
            {    
                $result 
            }
        
    }

  }


function Invoke-ipphoneReset
{

    [CmdletBinding(ConfirmImpact = 'low',DefaultParameterSetName="default")]
    param(
  
        [Parameter(Mandatory = $true,    ParameterSetName='default')]
        [string]$ipphone,
            
        [Parameter(Mandatory = $true,    ParameterSetName='default')]
        [Microsoft.PowerShell.Commands.WebRequestSession]$websession
    )

    process 
    { 

        $Parameters = @{ }
        $Parameters.ipphone = $ipphone
        $Parameters.action = "/mainform.cgi/reset.htm"
        $Parameters.Method ="post"
        $parameters.body = @{ CONFIG = 2 }
        $parameters.contenttype = "application/x-www-form-urlencoded" 
        $parameters.webSession = $websession 

        $result = Invoke-ipphoneWebRequest @parameters -returnobject

        if($PSBoundParameters.returnobject) 
            {    
                $result 
            }
        
    }

  }

function Get-ipphoneMacAddress
{

    [CmdletBinding(ConfirmImpact = 'low',DefaultParameterSetName="default")]
    param(
  
        [Parameter(Mandatory = $true,    ParameterSetName='default')]
        [string]$ipphone,
            
        [Parameter(Mandatory = $true,    ParameterSetName='default')]
        [Microsoft.PowerShell.Commands.WebRequestSession]$websession
    )

    process 
    { 

        $Parameters = @{ }
        $Parameters.ipphone = $ipphone
        $Parameters.action = "/mainform.cgi/network_status.htm"
        $parameters.webSession = $websession 

        $result = Invoke-ipphoneWebRequest @parameters -returnobject
        if ($result.statuscode -eq 200) {
            $macaddress = [Regex]::new('([0-9A-F]{2}[:-]){5}([0-9A-F]{2})')
            $matches = $macaddress.Matches($result)
            $matches.Value.replace('-','').replace(':','')
        }
        
    }

  }

  function Get-ipphoneStatus
  {
  
      [CmdletBinding(ConfirmImpact = 'low',DefaultParameterSetName="default")]
      param(
    
          [Parameter(Mandatory = $true,    ParameterSetName='default')]
          [string]$ipphone,
              
          [Parameter(Mandatory = $true,    ParameterSetName='default')]
          [Microsoft.PowerShell.Commands.WebRequestSession]$websession
      )
  
      process 
      { 
  
          $Parameters = @{ }
          $Parameters.ipphone = $ipphone
          $Parameters.action = "/voip_status.cgi"
          $parameters.webSession = $websession 
  
          $result = Invoke-ipphoneWebRequest @parameters -returnobject
          if ($result.statuscode -eq 200) {
            ([xml]$result.content).status | select-object -ExpandProperty line
          }
          
      }
  
    }
    function Get-ipphoneHookStatus
    {
    
        [CmdletBinding(ConfirmImpact = 'low',DefaultParameterSetName="default")]
        param(
      
            [Parameter(Mandatory = $true,    ParameterSetName='default')]
            [string]$ipphone,
                
            [Parameter(Mandatory = $true,    ParameterSetName='default')]
            [Microsoft.PowerShell.Commands.WebRequestSession]$websession
        )
    
        process 
        { 
    
            $Parameters = @{ }
            $Parameters.ipphone = $ipphone
            $Parameters.action = "/voip_status.cgi"
            $parameters.webSession = $websession
    
            $result = Invoke-ipphoneWebRequest @parameters -returnobject
            if ($result.statuscode -eq 200) {
               ([xml]$result.content).status | select-object AudioDevice, HookState

            }
            
        }
    
      }

function Test-ipphoneMacAddress
{

    [CmdletBinding(ConfirmImpact = 'low',DefaultParameterSetName="default")]
    param(
  
        [Parameter(Mandatory = $true,    ParameterSetName='default')]
        [string]$ipphone,

        [Parameter(Mandatory = $true,    ParameterSetName='default')]
        [ValidatePattern('([0-9A-F]{2}[:-]?){5}([0-9A-F]){2}')]
        [string]$macaddress,
            
        [Parameter(Mandatory = $true,    ParameterSetName='default')]
        [Microsoft.PowerShell.Commands.WebRequestSession]$websession
    )

    process 
    { 

        $Parameters = @{ }
        $Parameters.ipphone = $ipphone
        $Parameters.action = "/mainform.cgi/network_status.htm"

        $macaddress = $macaddress.replace('-','').replace(':','')
        $ippphonemacaddress = get-ipphonemacaddress -ipphone $ipphone -websession $websession

        if($macaddress -eq $ippphonemacaddress) {$true} else {$false}
        
    }

  }

function Invoke-ipphoneLoginUser
{

    [CmdletBinding(ConfirmImpact = 'low',DefaultParameterSetName="default")]
    param(
  
        [Parameter(Mandatory = $true,    ParameterSetName='default')]
        [Parameter(Mandatory = $true,    ParameterSetName='cloud')]
        [Parameter(Mandatory = $true,    ParameterSetName='logoff')]
        [string]$ipphone,
            
        [Parameter(Mandatory = $true,    ParameterSetName='default')]
        [string]$sipaddress,

        [Parameter(Mandatory = $true,    ParameterSetName='default')]
        [pscredential]$sipcredential,

        [Parameter(Mandatory = $true,    ParameterSetName='default')]
        [Parameter(Mandatory = $true,    ParameterSetName='cloud')]
        [Parameter(Mandatory = $true,    ParameterSetName='logoff')]
        [Microsoft.PowerShell.Commands.WebRequestSession]$websession,

        [Parameter(Mandatory = $false,    ParameterSetName='logoff')]
        [switch]$Logoffuser,

        [Parameter(Mandatory = $false,    ParameterSetName='cloud')]
        [switch]$cloud,

        [Parameter(Mandatory = $false,    ParameterSetName='default')]
        [Parameter(Mandatory = $false,    ParameterSetName='cloud')]
        [Parameter(Mandatory = $false,    ParameterSetName='logoff')]
        [switch]$returnobject

    )

    process 
    { 

        $Parameters = @{ }
        $Parameters.ipphone = $ipphone
        $Parameters.action = "/mainform.cgi/SfB_signin.htm"
        $Parameters.Method ="post"
        if ($PsCmdlet.ParameterSetName -eq 'default') 
        {
            $parameters.body = @{SIGNINMODE="1";LYNC_SIGNIN_ADDR="$($sipaddress)";LYNC_USER_NAME="$($sipcredential.username)";LYNC_PASSWORD="$($sipcredential.GetNetworkCredential().password)";}
        }
        elseif ($PsCmdlet.ParameterSetName -eq 'cloud') 
        {
            $parameters.body = @{ SIGNINMODE = "2";}
            write-warning "use get-ipphonestatus to retrieve the code" -WarningAction Continue
        }
        elseif ($PsCmdlet.ParameterSetName -eq 'logoff') 
        {
            $parameters.body = @{LYNC_SIGN_OUT="2";}
        }
        $parameters.contenttype = "application/x-www-form-urlencoded" 
        $parameters.webSession = $websession 

        $result = Invoke-ipphoneWebRequest @parameters -returnobject

        if($PSBoundParameters.returnobject) 
            {    
                $result 
            }
        
    }

  }


# SIG # Begin signature block
# MIINCgYJKoZIhvcNAQcCoIIM+zCCDPcCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUWF7AAU8v9V0QDpywZISjMcGG
# Fa6gggpMMIIFFDCCA/ygAwIBAgIQDq/cAHxKXBt+xmIx8FoOkTANBgkqhkiG9w0B
# AQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFz
# c3VyZWQgSUQgQ29kZSBTaWduaW5nIENBMB4XDTE4MDEwMzAwMDAwMFoXDTE5MDEw
# ODEyMDAwMFowUTELMAkGA1UEBhMCQVUxGDAWBgNVBAcTD1JvY2hlZGFsZSBTb3V0
# aDETMBEGA1UEChMKU2hhbmUgSG9leTETMBEGA1UEAxMKU2hhbmUgSG9leTCCASIw
# DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANAI9q03Pl+EpWcVZ7PQ3AOJ17k6
# OoS9SCIbZprs7NhyRIg7mKzxdcHMnjKwUe/7NDlt5mYzXT2yY/0MeUkyspiEs1+t
# eiHJ6IIs9llWgPGOkV4Ro5fZzlutqeeaomEW/ulH7mVjihVCR6mP/O09YSNo0Dv4
# AltYmVXqhXTB64NdwupL2G8fmTmVUJsww9abtGxy3mhL/l2W3VBcozZbCZVw363p
# 9mjeR9WUz5AxZji042xldKB/97cNHd/2YyWuJ8eMlYfRqz1nVgmmpuU+SuApRult
# hy6wNEngVmJBVhH/a8AH29dEZNL9pzhJGRwGBFi+m/vIr5SFhQVFZYJy79kCAwEA
# AaOCAcUwggHBMB8GA1UdIwQYMBaAFFrEuXsqCqOl6nEDwGD5LfZldQ5YMB0GA1Ud
# DgQWBBROEIC6bKfPIk2DtUTZh7HSa5ajqDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0l
# BAwwCgYIKwYBBQUHAwMwdwYDVR0fBHAwbjA1oDOgMYYvaHR0cDovL2NybDMuZGln
# aWNlcnQuY29tL3NoYTItYXNzdXJlZC1jcy1nMS5jcmwwNaAzoDGGL2h0dHA6Ly9j
# cmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtY3MtZzEuY3JsMEwGA1UdIARF
# MEMwNwYJYIZIAYb9bAMBMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2lj
# ZXJ0LmNvbS9DUFMwCAYGZ4EMAQQBMIGEBggrBgEFBQcBAQR4MHYwJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBOBggrBgEFBQcwAoZCaHR0cDov
# L2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0U0hBMkFzc3VyZWRJRENvZGVT
# aWduaW5nQ0EuY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggEBAIly
# KESC2V2sBAl6sIQiHRRgQ9oQdtQamES3fVBNHwmsXl76DdjDURDNi6ptwve3FALo
# ROZHkrjTU+5r6GaOIopKwE4IXkboVoPBP0wJ4jcVm7kcfKJqllSBGZfpnSUjlaRp
# EE5k1XdVAGEoz+m0GG+tmb9gGblHUiCAnGWLw9bmRoGbJ20a0IQ8jZsiEq+91Ft3
# 1vJSBO2RRBgqHTama5GD16OyE3Aps5ypaKYXuq0cnNZCaCasRtDJPolSP4KQ+NVg
# Z/W/rDiO8LNOTDwGcZ2bYScAT88A5KX42wiKnKldmyXnd4ffrwWk8fPngR5sVhus
# Arv6TbwR8dRMGwXwQqMwggUwMIIEGKADAgECAhAECRgbX9W7ZnVTQ7VvlVAIMA0G
# CSqGSIb3DQEBCwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJ
# bmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0
# IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0xMzEwMjIxMjAwMDBaFw0yODEwMjIxMjAw
# MDBaMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNV
# BAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNz
# dXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
# ggEKAoIBAQD407Mcfw4Rr2d3B9MLMUkZz9D7RZmxOttE9X/lqJ3bMtdx6nadBS63
# j/qSQ8Cl+YnUNxnXtqrwnIal2CWsDnkoOn7p0WfTxvspJ8fTeyOU5JEjlpB3gvmh
# hCNmElQzUHSxKCa7JGnCwlLyFGeKiUXULaGj6YgsIJWuHEqHCN8M9eJNYBi+qsSy
# rnAxZjNxPqxwoqvOf+l8y5Kh5TsxHM/q8grkV7tKtel05iv+bMt+dDk2DZDv5LVO
# pKnqagqrhPOsZ061xPeM0SAlI+sIZD5SlsHyDxL0xY4PwaLoLFH3c7y9hbFig3NB
# ggfkOItqcyDQD2RzPJ6fpjOp/RnfJZPRAgMBAAGjggHNMIIByTASBgNVHRMBAf8E
# CDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcDAzB5
# BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0
# LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0Rp
# Z2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHoweDA6oDigNoY0aHR0
# cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNy
# bDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJl
# ZElEUm9vdENBLmNybDBPBgNVHSAESDBGMDgGCmCGSAGG/WwAAgQwKjAoBggrBgEF
# BQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzAKBghghkgBhv1sAzAd
# BgNVHQ4EFgQUWsS5eyoKo6XqcQPAYPkt9mV1DlgwHwYDVR0jBBgwFoAUReuir/SS
# y4IxLVGLp6chnfNtyA8wDQYJKoZIhvcNAQELBQADggEBAD7sDVoks/Mi0RXILHwl
# KXaoHV0cLToaxO8wYdd+C2D9wz0PxK+L/e8q3yBVN7Dh9tGSdQ9RtG6ljlriXiSB
# ThCk7j9xjmMOE0ut119EefM2FAaK95xGTlz/kLEbBw6RFfu6r7VRwo0kriTGxycq
# oSkoGjpxKAI8LpGjwCUR4pwUR6F6aGivm6dcIFzZcbEMj7uo+MUSaJ/PQMtARKUT
# 8OZkDCUIQjKyNookAv4vcn4c10lFluhZHen6dGRrsutmQ9qzsIzV6Q3d9gEgzpkx
# Yz0IGhizgZtPxpMQBvwHgfqL2vmCSfdibqFT+hKUGIUukpHqaGxEMrJmoecYpJpk
# Ue8xggIoMIICJAIBATCBhjByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNl
# cnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdp
# Q2VydCBTSEEyIEFzc3VyZWQgSUQgQ29kZSBTaWduaW5nIENBAhAOr9wAfEpcG37G
# YjHwWg6RMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkG
# CSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEE
# AYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQhvxOHQpV2/563bgmqYMUk8nTJjzANBgkq
# hkiG9w0BAQEFAASCAQAvfCXJKbtRzlIXTQpXrbooD5BUHl6OA5bSXpWwMyMjJjCL
# iA83MWa6h47ZJsGFqoZbkl4nz2t0VeWfkaJ+lqYdQsK+yZKVsaz1PoOmYHN2W8FE
# 0Do0bk2GsnSO4xfO/U5qd0jEkpUAhHBbbU0aUm21LlvkgPSSRda3tEyaxwy+mIlh
# nZ7gLJRv27cljoHKPTw2xEK4Tq9UO6XASYEi1TBSeJtBSS8ADBOCKsoGWHIKZLEc
# dDGoaTtiyNOkXdKVNX0iOYTvivHABv/zZTTOjtS1HTE5toO5/HLqbo6lz0HzBQqr
# SAf4l9atbmG0I25DrYDlPk/FMGdLAhE0J32LnJyJ
# SIG # End signature block
