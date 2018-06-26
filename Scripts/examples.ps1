
#Logon - Single Phone
$sipaddress = get-credential -message "Enter the Sip Address Credentials"
$ippcredential = get-credential -message "Enter the IPPhone Credentials"
.\set-ipploginuser.ps1 -ipp 192.168.10.103 -sipaddress $sipaddress -ippcredential $ippcredential
.\set-ipploginuser.ps1 -ipp 192.168.10.103 -sipaddress $sipaddress

#Logon - Multiple Phone (JSON)
#to store password in file ->  "mypassword" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString and copy to file
#password only valid on nachine it was created with user that created it
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

#Logon - Multiple Phone (CSV)
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

#Factory Default - Single phone
$ippcredential = get-credential -message "Enter the IPPhone Credentials"admin
.\set-ippfactoryDefault.ps1 -ipp 192.168.10.10 -ippcredential $ippcredential

#Factory Default - Multiple Phones
$ippcredential = New-Object System.Management.Automation.PSCredential ("admin", (ConvertTo-SecureString "1234" -AsPlainText -Force))
for ($i = 100; $i -lt 110; $i++)
{
    .\set-ippfactoryDefault.ps1 -ipp 192.168.10.$i -ippcredential $ippcredential
}

#Factory Default - Multiple Phones
$ippcredential = New-Object System.Management.Automation.PSCredential ("admin", (ConvertTo-SecureString "1234" -AsPlainText -Force))
$ipp = "192.168.10.12","192.168.10.13","192.168.10.14","192.168.10.15","192.168.10.16"
foreach($i in $ipp)
{
    .\set-ippfactoryDefault.ps1 -ipp $i -ippcredential $ippcredential
}


#Factory Default - Multiple Phone (JSON)
#will scan IP address's and Factory default only phones in the json file.
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


#Reboot - Single phone
$ippcredential = get-credential -message "Enter the IPPhone Credentials"
.\set-ippreboot.ps1 -ipp 192.168.10.10 -ippcredential $ippcredential

#Reboot - Multiple Phones
$ippcredential = New-Object System.Management.Automation.PSCredential ("admin", (ConvertTo-SecureString "1234" -AsPlainText -Force))
$ipp = "192.168.10.12","192.168.10.13","192.168.10.14","192.168.10.15","192.168.10.16"
foreach($i in $ipp)
{
    .\set-ippfactoryDefault.ps1 -ipp $i -ippcredential $ippcredential
}

#Reboot - Multiple Phones
$ippcredential = New-Object System.Management.Automation.PSCredential ("admin", (ConvertTo-SecureString "1234" -AsPlainText -Force))
for ($i = 1; $i -lt 255; $i++)
{
    .\set-ippreboot.ps1 -ipp 192.168.10.$i -ippcredential $ippcredential
}

#Reboot - Multiple Phone (JSON)
#will scan IP address's and reboot only phones in the json file.
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




