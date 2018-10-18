<#
.SYNOPSIS
    Remotely reboot a AudioCodes IP Phone
.DESCRIPTION
    Remotely reboot a AudioCodes IP Phone
.PARAMETER ipp
    The IPP address or FQDN of the IP Phone
.PARAMETER ippcredential 
    The Credential to log onto the IPPhone 
.EXAMPLE
    C:\PS> 
    $ippcredential = get-credential
    set-ippreboot.ps1 -ipp 192.168.10.100 -ippcredential $ippcredential
.LINK
    github.com/shanehoey/ipphones
.NOTES
MIT License

Copyright (c) 2017 Shane Hoey
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

[CmdletBinding(DefaultParameterSetName="Default")]  

Param(
  [Parameter(Mandatory=$true,ParameterSetName = "Default",HelpMessage="IP or FQDN of IP Phone")]
  [string]$ipp,

  [Parameter(Mandatory=$true,ParameterSetName = "Default",HelpMessage="Credential of IP Phone")]
  [PSCredential]$ippcredential
  )

Write-verbose  "set-ippreboot $ipp" -Verbose

if (Test-Connection -computername $ipp  -count 1 -Quiet) 
{
    write-verbose "ping $ipp successful" -verbose

    $loginURL = "http://$ipp/login.cgi"
    $reseturl = "http://$ipp/mainform.cgi/reboot.htm"
    $LoginFields = @{user="$($ippcredential.username)";psw="$([Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($ippcredential.GetNetworkCredential().password)))";}
    $ResetFields = @{CONFIG="2";}

    Switch ($PSEdition)
    {
        "Desktop"
        {
            write-verbose "Login $ipp" -verbose
            [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
            $result = Invoke-WebRequest -Uri $loginurl -Method Post -Body $LoginFields -ContentType "application/x-www-form-urlencoded" -SessionVariable ws
            write-verbose "reboot $ipp" -verbose
            $result = Invoke-WebRequest -Uri $reseturl -Method Post -body $resetfields -ContentType "application/x-www-form-urlencoded" -WebSession $ws
        }
        "Core"
        {
            write-verbose "Login $ipp" -verbose
            $result = Invoke-WebRequest -Uri $loginurl -Method Post -Body $LoginFields -ContentType "application/x-www-form-urlencoded" -SessionVariable ws -skipcertificatecheck
            write-verbose "reboot $ipp" -verbose
            $result = Invoke-WebRequest -Uri $reseturl -Method Post -body $resetfields -ContentType "application/x-www-form-urlencoded" -WebSession $ws -skipcertificatecheck
        }
    }
    
    return $result.ParsedHtml.title
    Remove-Variable -name loginurl 
    Remove-Variable -name SFBFields 
    Remove-Variable -name result 
}
else 
{
    write-verbose "ping $ipp failed... exiting" -verbose    
}

