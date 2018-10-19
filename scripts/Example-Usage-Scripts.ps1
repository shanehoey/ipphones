$defaultpassword = read-host  -AsSecureString
$ippuser = "admin"
$ipppassword = read-host -AsSecureString 

#reboot ALL Phones in subnet 
.\Example-Reboot.ps1 -subnet "172.16.18." -first 130 -last 135  
.\Example-Reboot.ps1 -subnet "172.16.18." -first 130 -last 135 -noping
.\Example-Reboot.ps1 -subnet "172.16.18." -first 130 -last 135 -ippadmin $ippuser -ipppassword $ipppassword

#factory Default ALL Phones in subnet
.\Example-Reboot.ps1 -subnet "172.16.18." -first 130 -last 135 -FactoryDefault
.\Example-Reboot.ps1 -subnet "172.16.18." -first 130 -last 135 -FactoryDefault -ippadmin $ippuser -ipppassword $ipppassword
.\Example-Reboot.ps1 -subnet "172.16.18." -first 130 -last 135 -FactoryDefault -noping

#Log Off Phones ALL Phones in subnet
.\Example-Reboot.ps1 -subnet "172.16.18." -first 130 -last 135 -logoff
.\Example-Reboot.ps1 -subnet "172.16.18." -first 130 -last 135 -logoff -ippadmin $ippuser -ipppassword $ipppassword
.\Example-Reboot.ps1 -subnet "172.16.18." -first 130 -last 135 -logoff -noping

#Login with JSON
.\Example-Login-csv-cleartext.ps1 -subnet "172.16.18." -first 130 -last 135 -file .\PRIVATE-phones.json 
.\Example-Login-csv-cleartext.ps1 -subnet "172.16.18." -first 130 -last 135 -file .\PRIVATE-phones.json -ippadmin $ippuser -ipppassword $ipppassword -defaultpassword $defaultpassword
.\Example-Login-csv-cleartext.ps1 -subnet "172.16.18." -first 130 -last 135 -file .\PRIVATE-phones.json -noping 

#Login with CSV & Clear Text Password
.\Example-Login-csv-cleartext.ps1 -subnet "172.16.18." -first 130 -last 135 -file .\PRIVATE-phones.csv
.\Example-Login-csv-cleartext.ps1 -subnet "172.16.18." -first 130 -last 135 -file .\PRIVATE-phones.csv -ippadmin $ippuser -ipppassword $ipppassword -defaultpassword $defaultpassword
.\Example-Login-csv-cleartext.ps1 -subnet "172.16.18." -first 130 -last 135 -file .\PRIVATE-phones.csv -noping
