
# Logon - Single Phone

The following example will log an AudioCodes IPP Phone on remotely. The following information is required

 * *sipaddress* - is the sip address is the credentials of the user that you want to log the phone in as
 * _ippcredential_ - is the ipp Credential is the the username/password use to remotely log onto the IPP (default is admin/1234)
 * _ipp_ = is the IP Address or FQDN of the IP Phone you want to log onto

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
 * _mac_ - is the mac address of the IP Phone in format 00-00-00-00-00-00
 * _username_ - is the username of the account you want to log the phone in as  (username@domain or domain\username)
 * _sipaddress_ - is the sip address is the credentials of the user that you want to log the phone in as
 * _password_ to store password in JSON file ->  "mypassword" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString and copy the resulting string to a file. _IMPORTANT_  The password is only valid when logged in as the same user/same password as it was created with.

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
Run this script but make sure you edit the for loop and $ip address 
this will require the following inputs
 * _ippcrdential_ 
 * _defaultpassword_

```
[Collections.Generic.List[Object]]$phones = get-content -path .\phones.json | convertfrom-json
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
