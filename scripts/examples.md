
# Recommended Installation Method

## Install the IP Phone Module 
To install the IP Phone module with PowerShellGet 
`
Install-Module -Name ipphone -Scope CurrentUser
`

## Update the IP Phone Module 
To update the IP Phone module with PowerShellGet 

`
Install-Module -Name ipphone -Scope CurrentUser
`

## List Commands
List all commands in IP Phone Module

`
Get-Command -Module ipphone
`

## Avalible Commands

Check that the endpoint is pingable  
```
$ipphone = "192.168.10.131"
test-ipphoneICMP -ipphone $ipphone
test-ipphoneWeb -ipphone $ipphone
```
##Module Usage 

#Check SSL Trust 
By default your computer may not trust the SSL certifcate on the IP PHone, this command will sheck if your computer trusts the IP Phone SSL certificate

```
test-ipphoneTrustCertPolicy -ipphone 172.16.18.131
```

if the  IP Phone is not trusted modify the trust cert policy (powershell core you use -skipcertificatecheck instead)

```
set-ipphoneTrustAllCertPolicy
```

# Logon - Single Phone

The following example will log an AudioCodes IPP Phone on remotely. 

 * __ippcredential__ Is the Credential(username/password) of the IP Phone (default is admin/1234)
 * __ipp__ Is the IP Address or FQDN of the IP Phone you want to log onto
 * __sipaddress__ Is the sip address of the user that you want to log the phone in as
 * __sipcredential__ Is the credential(username/password) of the user that you want to log the phone in as 


```
$ipphone       = "192.168.10.131"
$ippcredential =  get-credential 

$sipcredential = get-credential 
$sipaddress    = "shane@shoey.example"

$websession  = new-ipphonewebsession -ipphone $ipphone
connect-ipphone -ipphone $ipphone  -ippcredential $ippcredential -websession $websession
Invoke-ipphoneLoginUser -ipphone $ipphone -sipaddress $sipaddress -sipcredential $sipcredential -websession $websession
```

# Logon (Office 365 CLoud)- Single Phone

The following example will log an AudioCodes IPP Phone on remotely. 

 * __ippcredential__ Is the Credential(username/password) of the IP Phone (default is admin/1234)
 * __ipp__ Is the IP Address or FQDN of the IP Phone you want to log onto


```
$ipphone       = "192.168.10.131"
$ippcredential =  get-credential 

$websession  = new-ipphonewebsession -ipphone $ipphone
connect-ipphone -ipphone $ipphone  -ippcredential $ippcredential -websession $websession
Invoke-ipphoneLoginUser -ipphone $ipphone -cloud -websession $websession
```


# Logoff - Single Phone

The following example will logoff the current logged in user of an AudioCodes IPP Phone. 

 * __ippcredential__ Is the Credential(username/password) of the IP Phone (default is admin/1234)
 * __ipp__ Is the IP Address or FQDN of the IP Phone you want to log onto


```
$ipphone       = "192.168.10.131"
$ippcredential =  get-credential 

$websession  = new-ipphonewebsession -ipphone $ipphone
connect-ipphone -ipphone $ipphone  -ippcredential $ippcredential -websession $websession
Invoke-ipphoneLoginUser -ipphone $ipphone -logoff -websession $websession
```



# Logon - Multiple Phone (JSON)

The following example will log an AudioCodes IPP Phone based on a json file. It will scan the subnet given and only logon to the phone if the MAC address matches 

### JSON File Format 

The following information is required in the json file 
 * __mac__ is the mac address of the IP Phone in format 00-00-00-00-00-00
 * __username__ is the username of the account you want to log the phone in as  (username@domain or domain\username)
 * __sipaddress__ is the sip address is the credentials of the user that you want to log the phone in as
 * __password__ to store password in JSON file ->  "mypassword" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString and copy the resulting string to a file. _IMPORTANT_  The password is only valid when logged in as the same user/same password as it was created with.

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
````

## Script 
To run this script you must edit the Following at a minimum 

```


[Collections.Generic.List[Object]]$phones = get-content -path .\phones.json | convertfrom-json
$ippcredential = New-Object System.Management.Automation.PSCredential ("admin", (ConvertTo-SecureString "1234" -AsPlainText -Force))
$defaultpassword = read-host -prompt "Password to use if password not in file ?" -AsSecureString 
for ($i = 130; $i -le 136; $i++)
{
    $ip = "172.16.18.$i"
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


# Reset all Phones in subnet  (Factory Default)

```
$ippcredential = New-Object System.Management.Automation.PSCredential ("admin", (ConvertTo-SecureString "1234" -AsPlainText -Force))
for ($i = 130; $i -le 136; $i++)
{
    $ip = "172.16.18.$i"
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

## Reboot all Phones in subnet 

```
$ippcredential = New-Object System.Management.Automation.PSCredential ("admin", (ConvertTo-SecureString "1234" -AsPlainText -Force))
for ($i = 130; $i -le 136; $i++)
{
    $ip = "172.16.18.$i"
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