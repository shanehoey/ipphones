
$defaultpassword = read-host  -AsSecureString -Prompt "Default password of user accounts"
$ipppassword = read-host -AsSecureString -Prompt "Password of IP Phone"

# Reboot ALL Phones in subnet 
.\invoke-ipphoneScanMaintenanceTask\invoke-ipphoneScanMaintenanceTask.ps1 -subnet "172.16.18." -first 131 -last 132
.\invoke-ipphoneScanMaintenanceTask\invoke-ipphoneScanMaintenanceTask.ps1 -subnet "172.16.18." -first 133 -last 134 -noping
.\invoke-ipphoneScanMaintenanceTask\invoke-ipphoneScanMaintenanceTask.ps1 -subnet "172.16.18." -first 135 -last 136 -ippadmin "admin" -ipppassword $ipppassword

#factory Default ALL Phones in subnet 
.\invoke-ipphoneScanMaintenanceTask\invoke-ipphoneScanMaintenanceTask.ps1 -subnet "172.16.18." -first 131 -last 132 -FactoryDefault
.\invoke-ipphoneScanMaintenanceTask\invoke-ipphoneScanMaintenanceTask.ps1 -subnet "172.16.18." -first 133 -last 134 -FactoryDefault -ippadmin "admin" -ipppassword $ipppassword
.\invoke-ipphoneScanMaintenanceTask\invoke-ipphoneScanMaintenanceTask.ps1 -subnet "172.16.18." -first 135 -last 136 -FactoryDefault -ipppassword $ipppassword -noping

#Log Off Phones ALL Phones in subnet
.\invoke-ipphoneScanMaintenanceTask\invoke-ipphoneScanMaintenanceTask.ps1 -subnet "172.16.18." -first 131 -last 132 -LogoutOnly
.\invoke-ipphoneScanMaintenanceTask\invoke-ipphoneScanMaintenanceTask.ps1 -subnet "172.16.18." -first 133 -last 134 -LogoutOnly -ippadmin "admin" -ipppassword $ipppassword
.\invoke-ipphoneScanMaintenanceTask\invoke-ipphoneScanMaintenanceTask.ps1 -subnet "172.16.18." -first 135 -last 136 -LogoutOnly -noping

#Login with JSON
.\invoke-ipphoneScanLogin\invoke-ipphoneScanLogin.ps1 -subnet "172.16.18." -first 131 -last 132 -file .\PRIVATE-phones.json -ipppassword $ipppassword -defaultpassword $defaultpassword
.\invoke-ipphoneScanLogin\invoke-ipphoneScanLogin.ps1 -subnet "172.16.18." -first 133 -last 134 -file .\PRIVATE-phones.json -ipppassword $ipppassword -defaultpassword $defaultpassword
.\invoke-ipphoneScanLogin\invoke-ipphoneScanLogin.ps1 -subnet "172.16.18." -first 135 -last 136 -file .\PRIVATE-phones.json -ipppassword $ipppassword -defaultpassword $defaultpassword

#Login with JSON (ClearText) - *** NOT RECOMMENDED
.\invoke-ipphoneScanLogin\invoke-ipphoneScanLogin.ps1 -subnet "172.16.18." -first 131 -last 132 -file .\PRIVATE-phones-clear.json -cleartext
.\invoke-ipphoneScanLogin\invoke-ipphoneScanLogin.ps1 -subnet "172.16.18." -first 133 -last 134 -file .\PRIVATE-phones-clear.json -ippadmin "admin" -ipppassword $ipppassword -defaultpassword $defaultpassword -cleartext
.\invoke-ipphoneScanLogin\invoke-ipphoneScanLogin.ps1 -subnet "172.16.18." -first 135 -last 136 -file .\PRIVATE-phones-clear.json -noping -cleartext



#for quicktesting
$defaultpassword = read-host  -AsSecureString -Prompt "Default password of user accounts"
$ipppassword = read-host -AsSecureString -Prompt "Password of IP Phone"

#factory
.\invoke-ipphoneScanMaintenanceTask\invoke-ipphoneScanMaintenanceTask.ps1 -subnet "172.16.18." -first 130 -last 136 -FactoryDefault -ipppassword $ipppassword 
#logoff
.\invoke-ipphoneScanMaintenanceTask\invoke-ipphoneScanMaintenanceTask.ps1 -subnet "172.16.18." -first 130 -last 136 -LogoutOnly  -ipppassword $ipppassword 
#logon
.\invoke-ipphoneScanLogin\invoke-ipphoneScanLogin.ps1 -subnet "172.16.18." -first 130 -last 136 -file .\PRIVATE-phones.json -ipppassword $ipppassword -defaultpassword $defaultpassword
.\invoke-ipphoneScanLogin\invoke-ipphoneScanLogin.ps1 -subnet "172.16.18." -first 130 -last 136 -file .\PRIVATE-phones-clear.json -cleartext -ipppassword $ipppassword -defaultpassword $defaultpassword
