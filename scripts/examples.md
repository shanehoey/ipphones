
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
    "password": "01000000d0854243985694038694540549320658490236894319004039216947864654765379859643068950437634318694368054318690841390864239665423654265243654378687689"
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

 * __ippcredential__ Credential of IP Phone, example blow users defaut usernamepassword of admin/1234
 * __defaultpassword__ Password to log sip address account on if it is not in the file 
 * __subnet__  subnet to scan ( exclude the last octlet ie 192.168.1.0 should be entered as 192.168.1.)
 * __startip__ IP address to start scan at 
 * __endip__  IP address to end scan at

```
#imports the phones from the json file 
[Collections.Generic.List[Object]]$phones = get-content -path .\phones.json | convertfrom-json

#store the credential of the IPP 
$ippcredential = New-Object System.Management.Automation.PSCredential ("admin", (ConvertTo-SecureString "1234" -AsPlainText -Force))

#password to use if not password in the file 
$defaultpassword = read-host -prompt "Password to use if password not in file ?" -AsSecureString 

#subnet to scan 
$subnet = "192.168.10."  #this is correct it does not include last digits
$startip = "1"
$endip =  "254"

for ($i = 99; $i -lt 110; $i++)
{
    $ip = "$subnet$i"
    Write-Verbose "Checking $IP" -verbose
    if (test-Connection -ComputerName  $ip -count 1 -Quiet) 
    {
      $index = $phones.find( {$args[0].mac -eq ((Get-NetNeighbor -IPAddress $ip -ErrorAction SilentlyContinue).LinkLayerAddress) } ) 
      if($index) 
      {
        if ($index.password -eq $null) { $index.password = $defaultpassword } else  { $index.password = $index.password | ConvertTo-SecureString  }
        $sipaddress = New-Object System.Management.Automation.PSCredential ($index.username,$index.password )
        Write-Verbose "Login $($index.username) onto $ip" -verbose
        .\set-ipploginuser.ps1 -ipp $ip -ippcredential $ippcredential -sipaddress $sipaddress -username $index.username
      }
      Remove-Variable -name index
    }
}
```
