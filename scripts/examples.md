
# Recommended Installation Method

### Install the IP Phone Module 
To install the IP Phone module with PowerShellGet 

```
Install-Module -Name ipphone -Scope CurrentUser
```

### Update the IP Phone Module 
To update the IP Phone module with PowerShellGet 

```
Install-Module -Name ipphone -Scope CurrentUser
```

### List Commands
List all commands in IP Phone Module

```
Get-Command -Module ipphone
```

# Checking SSL Trust 
By default your computer may not trust the SSL certifcate on the IP Phone, this command will check if your computer trusts the IP Phone SSL certificate

```
test-ipphoneTrustCertPolicy -ipphone 172.16.18.131
```

if the  IP Phone is not trusted modify the trust cert policy (powershell core you use -skipcertificatecheck instead). Any changes are only valid for the current shell, if you close powershell the TrustAllCertPolicy will be reverted

```
set-ipphoneTrustAllCertPolicy
```

# Example Usages

### Login Single IP Phone

The following example will log an AudioCodes IPP Phone on remotely. 

 * __ipphone__ Is the IP Address or FQDN of the IP Phone you want to log onto
 * __ippcredential__ Is the Credential(username/password) of the IP Phone (default is admin/1234)
 * __sipaddress__ Is the sip address of the user that you want to log the phone in as
 * __sipcredential__ Is the credential(username/password) of the user that you want to log the phone in as 

```
set-ipphoneTrustAllCertPolicy

$ipphone = “172.16.18.135”
$ippcredential = get-credential -Message "Credential" -UserName "admin"

$sipaddress = “shane@shoey.xyz”
$sipcredential  = get-credential -Message "Credential" -UserName $sipaddress

$websession  = new-ipphonewebsession -ipphone $ipphone
connect-ipphone -ipphone $ipphone -credential $ippcredential -websession $websession 
Invoke-ipphoneLoginUser -ipphone $ipphone -sipcredential $sipcredential -sipaddress $sipaddress -websession $websession
```

### Logon Single IP Phone (using Office 365 CLoud login)

The following example will log an AudioCodes IPP Phone on remotely. 

 * __ipphone__ Is the IP Address or FQDN of the IP Phone you want to log onto
 * __ippcredential__ Is the Credential(username/password) of the IP Phone (default is admin/1234)

```

set-ipphoneTrustAllCertPolicy

$ipphone = “172.16.18.135”
$ippcredential = get-credential -Message "Credential" -UserName "admin"

$websession  = new-ipphonewebsession -ipphone $ipphone
connect-ipphone -ipphone $ipphone -credential $ippcredential -websession $websession 
Invoke-ipphoneLoginUser -ipphone $ipphone -cloud -websession $websession

get-ipphonestatus -ipphone $ipphone -websession $websession 

```

### Logoff Single IP Phone

The following example will logoff the current logged in user of an AudioCodes IPP Phone. 

 * __ipphone__ Is the IP Address or FQDN of the IP Phone you want to log onto
 * __ippcredential__ Is the Credential(username/password) of the IP Phone (default is admin/1234)
 

```

$ipphone       =  “172.16.18.135”
$ippcredential = get-credential -Message "Credential" -UserName "admin"

$websession  = new-ipphonewebsession -ipphone $ipphone
connect-ipphone -ipphone $ipphone  -credential $ippcredential -websession $websession
Invoke-ipphoneLoginUser -ipphone $ipphone -logoff -websession $websession

```

### Logon - Multiple Phone (JSON)

The following example will log an AudioCodes IPP Phone based on a json file. It will scan the subnet given and only logon to the phone if the MAC address matches 


The following information is required in the json file 
 * __mac__ is the mac address of the IP Phone in format 00-00-00-00-00-00
 * __username__ is the username of the account you want to log the phone in as  (username@domain or domain\username)
 * __sipaddress__ is the sip address is the credentials of the user that you want to log the phone in as
 * __password__ to store password in JSON file ->  "mypassword" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString and copy the resulting string to a file. _IMPORTANT_  The password is only valid when logged in as the same user/same password as it was created with.

_JSON FILE_
```
[
  {
    "mac": "00-90-8F-00-00-00",
    "username": "shane@shoey.example",
    "sipaddress": "shane@shoey.example",
    "password": null
  },
  {
    "mac": "00-90-8F-00-00-00",
    "username": "debra@shoey.example",
    "sipaddress": "debrab@shoey.example",
    "password": null
  }
]
```
_Script_
```

set-ipphoneTrustAllCertPolicy
[Collections.Generic.List[Object]]$phones = get-content -path .\phones.json | convertfrom-json
$ippcredential = New-Object System.Management.Automation.PSCredential ("admin", (ConvertTo-SecureString "1234" -AsPlainText -Force))
$defaultpassword = read-host -prompt "Password to use if password not in file ?" -AsSecureString 
for ($i = 1; $i -le 254; $i++)
{
    $ip = "172.16.18.$i"
    Write-Progress -Activity "Scanning subnet" -Status "IP Address -> $ip" -PercentComplete (($I/254)*100)
    if (test-ipphoneicmp -ipphone $ip )       
    {                                       
        if (test-ipphoneweb -ipphone $ip )
        {
            $websession  = new-ipphonewebsession -ipphone $ip
            connect-ipphone -ipphone $ip -credential $ippcredential -websession $websession 
            $macaddress = get-ipphonemacaddress -ipphone $ip -websession $websession 
            $index = $phones.find( {$args[0].mac -eq $macaddress } ) 
            if($index) 
            {
              if ($index.password -eq $null) { $sipcredential = New-Object System.Management.Automation.PSCredential ($index.username, $defaultpassword ) } else  { $sipcredential = New-Object System.Management.Automation.PSCredential ($index.username, ($index.password | ConvertTo-SecureString) )  }     
              Invoke-ipphoneLoginUser -ipphone $ip -sipcredential $sipcredential -sipaddress $index.sipaddress -websession $websession
              Write-verbose  "Logging in $($index.username) to  $IP" -verbose
            }
        }
    }                                       
}

```

### Scan Subnet and reboot all IP Phones

The following example will scan a subnet and reboot all IP Phones it discovers automatically

The following information is required:
 * __ippcredential__ Is the Credential(username/password) of the IP Phone (default is admin/1234)
 
```

set-ipphoneTrustAllCertPolicy
$ippcredential = New-Object System.Management.Automation.PSCredential ("admin", (ConvertTo-SecureString "1234" -AsPlainText -Force))
for ($i = 1; $i -le 254; $i++)
{
    $ip = "172.16.18.$i"
    Write-Progress -Activity "Scanning subnet" -Status "IP Address -> $ip" -PercentComplete (($I/254)*100)
    if (test-ipphoneicmp -ipphone $ip )       
    {                                       
        if (test-ipphoneweb -ipphone $ip )
        {
            $websession  = new-ipphonewebsession -ipphone $ip
            connect-ipphone -ipphone $ip -credential $ippcredential -websession $websession 
            Invoke-ipphoneReboot -ipphone $ip -websession $websession
            Write-verbose -Message "Reset ->  $ip" -verbose
        }
    }                                       
}

```

### Scan Subnet and Factory Default all IP Phones

The following example will scan a subnet and Factory Default (reset) all IP Phones it discovers automatically

The following information is required:
 * __ippcredential__ Is the Credential(username/password) of the IP Phone (default is admin/1234)
 
```

set-ipphoneTrustAllCertPolicy
$ippcredential = New-Object System.Management.Automation.PSCredential ("admin", (ConvertTo-SecureString "1234" -AsPlainText -Force))
for ($i = 1; $i -le 254; $i++)
{
    $ip = "172.16.18.$i"
    Write-Progress -Activity "Scanning subnet" -Status "IP Address -> $ip" -PercentComplete (($I/254)*100)
    if (test-ipphoneicmp -ipphone $ip )       
    {                                       
        if (test-ipphoneweb -ipphone $ip )
        {
            $websession  = new-ipphonewebsession -ipphone $ip
            connect-ipphone -ipphone $ip -credential $ippcredential -websession $websession 
            Invoke-ipphoneReset -ipphone $ip -websession $websession
            Write-verbose -Message "Factory Default ->  $ip" -verbose
        }
    }                                       
}

```
