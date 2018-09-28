
# Logon - Single Phone

The following example will log an AudioCodes IPP Phone on remotely. The following information is required

 * __sipaddress__ Is the sip address is the credentials of the user that you want to log the phone in as
 * __ippcredential__ Is the ipp Credential is the the username/password use to remotely log onto the IPP (default is admin/1234)
 * __ipp__ Is the IP Address or FQDN of the IP Phone you want to log onto

```
$sipaddress = get-credential -message "Enter the Sip Address Credentials"
$ippcredential = get-credential -message "Enter the IPPhone Credentials"
.\set-ipploginuser.ps1 -ipp 192.168.10.103 -sipaddress $sipaddress -ippcredential $ippcredential
.\set-ipploginuser.ps1 -ipp 192.168.10.103 -sipaddress $sipaddress
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
    "username": "adelev@sipaddress.example.com",
    "sipaddress": "adelev@sipaddress.example.com",
    "password": "01000000d0854243985694038694540549320658490236894319004039216947864654765379859643068950437634318694368054318690841390864239665423654265243654378687689"
  },
  {
    "mac": "00-90-8F-00-00-00",
    "username": "debrab@sipaddress.example.com",
    "sipaddress": "debrab@sipaddress.example.com",
    "password": null
  },
  {
    "mac": "00-90-8F-00-00-00",
    "username": "pattif@sipaddress.example.com",
    "sipaddress": "pattif@sipaddress.example.com",
    "password": null
  },
  {
    "mac": "00-90-8F-00-00-00",
    "username": "pattif@sipaddress.example.com",
    "sipaddress": "pattif@sipaddress.example.com",
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

# Logon - Multiple Phone (CSV)

```
[Collections.Generic.List[Object]]$phones = get-content -path .\phones.csv | convertfrom-csv
$ippcredential = New-Object System.Management.Automation.PSCredential ("admin", (ConvertTo-SecureString "1234" -AsPlainText -Force))
$defaultpassword = read-host -prompt "Password to use if password not in file ?" -AsSecureString 
for ($i = 99; $i -lt 110; $i++)
{
    $ip = "192.168.10.$i"
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

# Factory Default - Single phone

*** Under Development *** Dont use script at the moment

```
$ippcredential = get-credential -message "Enter the IPPhone Credentials"admin
.\set-ippfactoryDefault.ps1 -ipp 192.168.10.10 -ippcredential $ippcredential
```

# Factory Default - Multiple Phones

*** Under Development *** Dont use script at the moment

```
$ippcredential = New-Object System.Management.Automation.PSCredential ("admin", (ConvertTo-SecureString "1234" -AsPlainText -Force))
for ($i = 100; $i -lt 110; $i++)
{
    .\set-ippfactoryDefault.ps1 -ipp 192.168.10.$i -ippcredential $ippcredential
}
```

# Factory Default - Multiple Phones

*** Under Development *** Dont use script at the moment

```
$ippcredential = New-Object System.Management.Automation.PSCredential ("admin", (ConvertTo-SecureString "1234" -AsPlainText -Force))
$ipp = "192.168.10.12","192.168.10.13","192.168.10.14","192.168.10.15","192.168.10.16"
foreach($i in $ipp)
{
    .\set-ippfactoryDefault.ps1 -ipp $i -ippcredential $ippcredential
}
```

# Factory Default - Multiple Phone (JSON)


*** Under Development *** Dont use script at the moment

will scan IP address's and Factory default only phones in the json file.
```
[Collections.Generic.List[Object]]$phones = get-content -path .\phones.json | convertfrom-json
$ippcredential = New-Object System.Management.Automation.PSCredential ("admin", (ConvertTo-SecureString "1234" -AsPlainText -Force))
for ($i = 99; $i -lt 110; $i++)
{
    $ip = "192.168.10.$i"
    Write-Verbose "Checking $IP" -verbose
    if (test-Connection -ComputerName  $ip -count 1 -Quiet) 
    {
      $index = $phones.find( {$args[0].mac -eq ((Get-NetNeighbor -IPAddress $ip).LinkLayerAddress) } )
      if($index) 
      {
        Write-Verbose "Factory Default  $ip" -verbose
        .\set-ippfactoryDefault.ps1 -ipp $ip -ippcredential $ippcredential
      }
      Remove-Variable -name index
    }
}
```

# Reboot - Single phone

*** Under Development *** Dont use script at the moment

```
$ippcredential = get-credential -message "Enter the IPPhone Credentials"
.\set-ippreboot.ps1 -ipp 192.168.10.10 -ippcredential $ippcredential
```

# Reboot - Multiple Phones

*** Under Development *** Dont use script at the moment

```
$ippcredential = New-Object System.Management.Automation.PSCredential ("admin", (ConvertTo-SecureString "1234" -AsPlainText -Force))
$ipp = "192.168.10.12","192.168.10.13","192.168.10.14","192.168.10.15","192.168.10.16"
foreach($i in $ipp)
{
    .\set-ippfactoryDefault.ps1 -ipp $i -ippcredential $ippcredential
}
```

# Reboot - Multiple Phones


*** Under Development *** Dont use script at the moment

```
$ippcredential = New-Object System.Management.Automation.PSCredential ("admin", (ConvertTo-SecureString "1234" -AsPlainText -Force))
for ($i = 1; $i -lt 255; $i++)
{
    .\set-ippreboot.ps1 -ipp 192.168.10.$i -ippcredential $ippcredential
}
```

# Reboot - Multiple Phone (JSON)


*** Under Development *** Dont use script at the moment

will scan IP address's and reboot only phones in the json file.

```
[Collections.Generic.List[Object]]$phones = get-content -path .\phones.json | convertfrom-json
$ippcredential = New-Object System.Management.Automation.PSCredential ("admin", (ConvertTo-SecureString "1234" -AsPlainText -Force))
for ($i = 99; $i -lt 110; $i++)
{
    $ip = "192.168.10.$i"
    Write-Verbose "Checking $IP" -verbose
    if (test-Connection -ComputerName  $ip -count 1 -Quiet) 
    {
      $index = $phones.find( {$args[0].mac -eq ((Get-NetNeighbor -IPAddress $ip).LinkLayerAddress) } )
      if($index) 
      {
        Write-Verbose "Reboot  $ip" -verbose
        .\set-ippreboot.ps1 -ipp $ip -ippcredential $ippcredential
      }
      Remove-Variable -name index
    }
}
```
