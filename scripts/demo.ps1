
#http://docs.shanehoey.com/ipphone
install-module -Name ipphone -Scope CurrentUser

Import-Module -name ipphone 

$ipphone = “172.16.18.135”
$ippcredential = get-credential -Message "Credential" -UserName "admin"

$sipaddress = “shane@shoey.xyz”
$sipcredential  = get-credential -Message "Credential" -UserName $sipaddress

Test-ipphoneTrustCertPolicy -ipphone $ipphone 
Set-ipphoneTrustAllCertPolicy

$websession  = new-ipphonewebsession -ipphone $ipphone 

connect-ipphone -ipphone $ipphone -credential $ippcredential -websession $websession 
Test-ipphoneConnection -ipphone $ipphone -websession $websession


Get-ipphoneMacAddress -ipphone $ipphone -websession $websession
Get-ipphoneStatus -ipphone $ipphone -websession $websession 
Get-ipphoneHookStatus -ipphone $ipphone -websession $websession

Invoke-ipphoneLoginUser -ipphone $ipphone -sipcredential $sipcredential -sipaddress $sipaddress -websession $websession

invoke-ipphonereset -ipphone 172.16.18.135 -websession $websession 

.\invoke-ipphoneScanLogin\invoke-ipphoneScanLogin.ps1 -subnet "172.16.18." -first 129 -last 136 -file .\PRIVATE-phones.json -ipppassword $ipppassword

.\invoke-ipphoneScanMaintenanceTask\invoke-ipphoneScanMaintenanceTask.ps1   -subnet "172.16.18." -first 129 -last 136 -LogoutOnly
.\invoke-ipphoneScanMaintenanceTask\invoke-ipphoneScanMaintenanceTask.ps1   -subnet "172.16.18." -first 129 -last 136 
.\invoke-ipphoneScanMaintenanceTask\invoke-ipphoneScanMaintenanceTask.ps1   -subnet "172.16.18." -first 129 -last 136 -FactoryDefault
