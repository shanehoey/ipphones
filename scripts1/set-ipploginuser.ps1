<#
.SYNOPSIS
    Remotely Sign an AudioCodes IP Phone onto Skype for Business & Skype for Business Online
.DESCRIPTION
    Remotely Sign an AudioCodes IP Phone onto Skype for Business & Skype for Business Online
.PARAMETER ipp
    The IPP address or FQDN of the IP Phone
.PARAMETER ippcredential 
    The Credentiial to log onto the IPPhone 
.EXAMPLE
    C:\PS> 
    login-ippuser.ps1 -ipp 192.168.10.100
.EXAMPLE
    C:\PS> 
    $sipaddress = get-credential
    $ippcredential = get-credential
    login-ippuser.ps1 -ipp 192.168.10.100  -ippcredential $ippcredential -sipaddress $sipaddress
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
  [Parameter(Mandatory=$true,ParameterSetName = "IPPAdmin",HelpMessage="IP or FQDN of IP Phone")]
  [Parameter(Mandatory=$true,ParameterSetName = "Default",HelpMessage="IP or FQDN of IP Phone")]
  [string]$ipp,

  [Parameter(Mandatory=$true,ParameterSetName = "IPPAdmin",HelpMessage="Credential of IP Phone")]
  [PSCredential]$ippcredential,

  [Parameter(Mandatory=$true,ParameterSetName = "IPPAdmin",HelpMessage="Credential of SIP Address")]
  [Parameter(Mandatory=$true,ParameterSetName = "Default",HelpMessage="Credential of SIP Address")]
  [PSCredential]$sipaddress,

  [Parameter(Mandatory=$false,ParameterSetName = "IPPAdmin",HelpMessage="Username override")]
  [Parameter(Mandatory=$false,ParameterSetName = "Default",HelpMessage="Username override")]
  [string]$username
  )

Write-verbose  "set-ipploginuser $($sipaddress.username) on $ipp" -Verbose
if (Test-Connection -computername $ipp  -count 1 -Quiet) {
    write-verbose "ping $ipp successful" -verbose
    if ($PSCmdlet.ParameterSetName -eq "IPPAdmin") 
    { 
        if (!($PSBoundParameters.ContainsKey('username'))) { $username = $sipaddress.UserName }
        $loginURL = "https://$ipp/login.cgi"
        $LoginFields = @{user="$($ippcredential.username)";psw="$([Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($ippcredential.GetNetworkCredential().password)))";}
        $SFBurl = "https://$ipp/mainform.cgi/SfB_signin.htm"
        $SFBFields = @{SIGNINMODE="1";LYNC_SIGNIN_ADDR="$($sipaddress.username)";LYNC_USER_NAME="$username";LYNC_PASSWORD="$($sipaddress.GetNetworkCredential().password)";}
        Switch ($PSEdition)
        {
            "Desktop"
            {
                [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
                write-verbose "logon to $ipp" -verbose
                $result = Invoke-WebRequest -Uri $loginurl -Method Post -Body $LoginFields -ContentType "application/x-www-form-urlencoded" -SessionVariable ws 
                write-verbose "logon $($sipaddress.username)" -verbose
                $result = Invoke-WebRequest -Uri $sfburl -Method Post -Body $SFBFields -ContentType "application/x-www-form-urlencoded" -WebSession $ws 
            }
            "Core"
            {
                write-verbose "Configuring $ipp - $sipaddress" -verbose
                write-verbose "logon to $ipp" -verbose
                $result = Invoke-WebRequest -Uri $loginurl -Method Post -Body $LoginFields -ContentType "application/x-www-form-urlencoded" -SessionVariable ws -skipcertificatecheck
                write-verbose "logon $($sipaddress.username)" -verbose
                $result = Invoke-WebRequest -Uri $sfburl -Method Post -Body $SFBFields -ContentType "application/x-www-form-urlencoded" -WebSession $ws -skipcertificatecheck
            }
        }
        return $result.ParsedHtml.title
        Remove-Variable -name ws
        Remove-Variable -name loginurl 
        Remove-Variable -name loginFields 
        Remove-Variable -name SFBurl
        Remove-Variable -name SFBFields 
        Remove-Variable -name result 
    }
    else 
    {
        if (!($PSBoundParameters.ContainsKey('username'))) { $username = $sipaddress.UserName }

        $loginURL = "https://$ipp/web_login.cgi"
        $SFBFields = @{LYNC_SIGNIN_ADDR="$($sipaddress.username)";LYNC_USER_NAME="$username";LYNC_PASSWORD="$($sipaddress.GetNetworkCredential().password)";}
 
        Switch ($PSEdition)
        {
        "Desktop"
            {
                write-verbose "Login $($sipaddress.username) to $ipp" -verbose
                [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
                $result = Invoke-WebRequest -Uri $loginurl -Method Post -Body $sfbFields -ContentType "application/x-www-form-urlencoded"
            }
        "Core"
        {
            write-verbose "Login $($sipaddress.username) to $ipp" -verbose
            $result = Invoke-WebRequest -Uri $loginurl -Method Post -Body $sfbFields -ContentType "application/x-www-form-urlencoded" -skipcertificatecheck
            }
        }
        return $result.ParsedHtml.title
        Remove-Variable -name loginurl 
        Remove-Variable -name SFBFields 
        Remove-Variable -name result 
    }
}
else 
{
    write-verbose "ping $ipp failed... exiting" -verbose    
}

