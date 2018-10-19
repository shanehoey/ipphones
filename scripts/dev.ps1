
set-location $env:USERPROFILE\onedrive\github\ipphones
Remove-Module ipphone -ErrorAction SilentlyContinue
Import-Module .\ipphone\ipphone.psm1

Get-Command -Module ipphone

$ipphone = "172.16.18.132"
$ippcredential = New-Object System.Management.Automation.PSCredential ("admin", (ConvertTo-SecureString "1234" -AsPlainText -Force)) 
$sipaddress = "adelev@shoey.xyz"
$sipcredential = Get-Credential -UserName "adelev@shoey.xyz" -Message "adelev@shoey.xyz"
$contenttype = "application/x-www-form-urlencoded"
Invoke-WebRequest -uri "https://$ipphone/" -SessionVariable websession
$websession

(Invoke-WebRequest -uri "https://$ipphone/" -websession $websession).content
(Invoke-WebRequest -uri "https://$ipphone/mainform.cgi?go=mainframe.htm" -websession $websession).content
(Invoke-WebRequest -uri "https://$ipphone/mainform.cgi/login_redirect.htm" -websession $websession).content
(Invoke-WebRequest -uri "https://$ipphone/login.cgi" -websession $websession).content

#working -> /login.cgi
$body = @{user="$($ippcredential.username)";psw="$([Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($ippcredential.GetNetworkCredential().password)))" }
(Invoke-WebRequest -uri "https://$ipphone/login.cgi" -method Post -body $body  -ContentType $contenttype -websession $websession ).content

#testing -> /mainform.cgi/network_status.htm
(Invoke-WebRequest -uri "https://$ipphone/mainform.cgi/network_status.htm" -websession $websession).content

$result = (Invoke-WebRequest -uri "https://$ipphone/mainform.cgi/network_status.htm" -websession $websession).content
$macaddress = [Regex]::new('([0-9A-F]{2}[:-]){5}([0-9A-F]{2})')
$matches = $macaddress.Matches($result)
$mac = ($matches.Value).replace("-","").replace(":","")

#testing -> /mainform.cgi/info.htm
(Invoke-WebRequest -uri "https://$ipphone/mainform.cgi/info.htm" -websession $websession).content

#configuration files 

$file = "450HD_$mac.log"
$file = "450HD_$mac.cfg" 
$file = "provisioning.cfg" 
$file = "provision_url"
$file = "dhcpip"
$file = "network_ready.cfg"
$file = "call_info"
$file = "http_passwd"
$file = "pl_reboot_flag"
$file = "450HD_$mac_dump.tgz"
$file = "core"
$file = "ifname.conf"
$file = "BootUpTime"
$file = "coredump_collector_lst.txt"
$file = "initializing_ip"
$file = "Eth0IP.conf"
$file = "dhcp.info"
$file = "last_request.url"
$file = "system.log"
$file = "MY_TIMERS_SRV_VOIP_TASK"
$file = "dhcp_inform_pipe"
$file = "lighttpd_access.conf"
$file = "tmp4coredump"
$file = "SipServers"
$file = "log"
$file = "user_agent.txt"
$file = "TZ"
$file = "dialed.txt"
$file = "missed.txt"
$file = "voip_status"
$file = "answered.txt"
$file = "exp.log"
$file = "mtd3_utilization.txt"
$file = "wget_provivion_log_file"
$file = "archive_of_cores"
$file = "expected_bytes.txt"
$file = "bluetooth_status" 
$file = "hidraw1"
$file = "passwd"

(Invoke-WebRequest -uri "https://$ipphone/configuration/$file" -ContentType $contenttype -websession $websession )
[System.Text.Encoding]::UTF8.GetString((Invoke-ipphoneWebRequest -ipphone $ipphone -http https -action "/configuration/$file" -method get  -ContentType $contenttype -websession $websession -returnobject).content)

#testing -> /mainform.cgi/SfB_signin.htm
$body = @{SIGNINMODE="1";LYNC_SIGNIN_ADDR="$($sipaddress)";LYNC_USER_NAME="$($sipcredential.username)";LYNC_PASSWORD="$($sipcredential.GetNetworkCredential().password)";}
$body = @{SIGNINMODE="2";}

$a = Invoke-WebRequest -uri "https://$ipphone/mainform.cgi/SfB_signin.htm" -method post -body $body -contenttype $contenttype -websession $websession 
$b = (Invoke-WebRequest -uri "https://$ipphone/mainform.cgi/SfB_signin.htm" -websession $websession).content

[xml](Invoke-WebRequest -uri "https://$ipphone/voip_status.cgi" -websession $websession).content

$Parameters = @{ }
$Parameters.ipphone = $ipphone
$Parameters.action = "/mainform.cgi/voip_status.cgi"
$parameters.webSession = $websession 

$result = Invoke-ipphoneWebRequest @parameters -returnobject
if ($result.statuscode -eq 200) {
   ([xml]$result.content).status.line
}


#working -> /mainform.cgi/reboot.htm
$body = @{ REBOOT = 2 }
Invoke-WebRequest -uri "https://$ipphone//mainform.cgi/reboot.htm" -method post -body $body -ContentType $contenttype -websession $websession -returnobject)

#working -> /mainform.cgi/reset.htm 
$body = @{ CONFIG = 2 }
Invoke-WebRequest -uri "https://$ipphone/mainform.cgi/reset.htm" -method post -body $body -ContentType $contenttype -websession $websession -returnobject)

#attempting -> /mainform.cgi/info.htm
(Invoke-ipphoneWebRequest -ipphone $ipphone -http $http -action "/mainform.cgi/info.htm" -method Get  -websession $websession -returnobject).content

#attempting ->  /mainform.cgi/quick_setup.htm
$body = @{ PROXYPORT = 6000 }
(Invoke-ipphoneWebRequest -ipphone $ipphone -http https -action "/mainform.cgi/quick_setup.htm" -method GET -ContentType $contenttype -websession $websession -returnobject).rawcontent

#attempting ->  /mainform.cgi/quick_setup.htm
$body = @{ show_modified_cfg_params = $false }
$result = (Invoke-ipphoneWebRequest -ipphone $ipphone -http https -action "/mainform.cgi/manu_config.htm" -method Post -ContentType $contenttype -websession $websession -returnobject) 
$result.InputFields


#attempting -> /mainform.cgi/network_status.htm
(Invoke-ipphoneWebRequest -ipphone $ipphone -http https -action "/mainform.cgi/network_status.htm" -method Get -websession $ws5 -returnobject).content

#Working -> /voip_status.cgi
(invoke-webrequest "https://172.16.18.135/mainform.cgi/voip_status.htm" -method GET -websession $websession
$a = [xml]Invoke-WebRequest -uri "https://$ipphone//voip_status.cgi" -method GET -body $login   -ContentType $contenttype -websession $websession -returnobject).content
$a.Status.AudioDevice
$a.Status.line
$a.Status.hookstate

#Found CGI Scripts
Invoke-WebRequest -uri "https://$ipphone/action_gen_csr.cgi" -method GET   -ContentType $contenttype -websession $websession -returnobject).content
Invoke-WebRequest -uri "https://$ipphone/command.cgi"    -method GET   -ContentType $contenttype -websession $websession -returnobject).content
Invoke-WebRequest -uri "https://$ipphone/line_keys.cgi" -method GET    -ContentType $contenttype -websession $websession -returnobject).content
Invoke-WebRequest -uri "https://$ipphone/login.cgi" -method GET    -ContentType $contenttype -websession $websession -returnobject).content
Invoke-WebRequest -uri "https://$ipphone/mainform.cgi" -method GET     -ContentType $contenttype -websession $websession -returnobject).content
Invoke-WebRequest -uri "https://$ipphone/phone_lock.cgi" -method Get    -ContentType $contenttype -websession $websession -returnobject).content
Invoke-WebRequest -uri "https://$ipphone/upload.cgi" -method GET    -ContentType $contenttype -websession $websession -returnobject).content
Invoke-WebRequest -uri "https://$ipphone/voip_status.cgi" -method GET   -ContentType $contenttype -websession $websession -returnobject).content
Invoke-WebRequest -uri "https://$ipphone/web_login.cgi" -method GET   -ContentType $contenttype -websession $websession -returnobject).content
Invoke-WebRequest -uri "https://$ipphone/contact.cfg" -method GET   -ContentType $contenttype -websession $websession -returnobject).rawcontent
Invoke-WebRequest -uri "https://$ipphone/corporate.cfg" -method GET   -ContentType $contenttype -websession $websession -returnobject).content
Invoke-WebRequest -uri "https://$ipphone/configuration" -method GET   -ContentType $contenttype -websession $websession -returnobject).content









$Parameters = @{ }
$Parameters.http = "https"
$Parameters.ipphone = "172.16.18.132"
$Parameters.action = "/login.cgi"
$Parameters.Method ="get"
$parameters.body = @{user="$($credential.username)";psw="$([Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($credential.GetNetworkCredential().password)))" } 

$t = (Invoke-ipphoneWebRequest @parameters -returnobject -SkipCertificateCheck).content -like "*Login failed*"

Invoke-ipphoneWebRequest @parameters -SkipCertificateCheck

get-ipphoneWebSession

(Invoke-ipphoneWebRequest   -http "http" `
                            -ipphone "172.16.18.132" `
                            -action "/mainform.cgi/network_status.htm" `
                            -method "get" `
                            -websession $ws2 `
                            -returnobject `
                            -verbose).content

( Invoke-WebRequest http://172.16.18.131/login.cgi ).rawcontent
( Invoke-WebRequest https://172.16.18.131 ).rawcontent
( Invoke-WebRequest http://172.16.18.133 ).headers
( Invoke-WebRequest http://172.16.18.134 ).parsedhtml
( Invoke-WebRequest http://172.16.18.135 )



try { invoke-webrequest https://172.16.18.131/ }
catch { 
    $PSItem.InvocationInfo
    $psitem.exception 
    $psitem.exception.message -eq "The underlying connection was closed: An unexpected error occurred on a send."
}



function test-ipphonemac
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
