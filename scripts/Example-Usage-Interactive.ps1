
#List out all the cmdlets in the module
Get-Command -Module ipphone

#Optional: Check that the endpoint is pingable  
test-ipphoneICMP -ipphone 172.16.18.131 
test-ipphoneICMP -ipphone 172.16.18.132
test-ipphoneICMP -ipphone 172.16.18.133
test-ipphoneICMP -ipphone 172.16.18.134
test-ipphoneICMP -ipphone 172.16.18.135

#Optional: Check that the endpoint is an IP Phone
test-ipphoneweb -ipphone 172.16.18.131 
test-ipphoneweb -ipphone 172.16.18.132
test-ipphoneweb -ipphone 172.16.18.133
test-ipphoneweb -ipphone 172.16.18.134
test-ipphoneweb -ipphone 172.16.18.135

#Check if your computer trusts the IP Phone SSL certificate
test-ipphoneTrustCertPolicy -ipphone 172.16.18.135

#if the  IP Phone is not trusted modify the trust cert policy (powershell core you use -skipcertificatecheck instead)
set-ipphoneTrustAllCertPolicy

#Create Websessions and store them in a variable for reuse
$ws1 = new-ipphonewebsession -ipphone 172.16.18.131 
$ws2 = new-ipphonewebsession -ipphone 172.16.18.132
$ws3 = new-ipphonewebsession -ipphone 172.16.18.133 
$ws4 = new-ipphonewebsession -ipphone 172.16.18.134 
$ws5 = new-ipphonewebsession -ipphone 172.16.18.135 

#Login to each IP Phone using username/password username/securestring or credential 
[securestring]$password = "000000000200009d4f9bc823503d24d189c6e37b0addda92fdee516705564a17fea4a4e78a7e7ce49705a56d5dc8964b3bfe7a2ae959ede95e6a29" | ConvertTo-SecureString
$ippcredential = New-Object System.Management.Automation.PSCredential ("admin", $password)
connect-ipphone -ipphone 172.16.18.131 -username "admin" -passwordtext "1234" -websession $ws1 
connect-ipphone -ipphone 172.16.18.132 -username "admin" -passwordtext "1234" -websession $ws2 
connect-ipphone -ipphone 172.16.18.133 -username "admin" -passwordtext "1234" -websession $ws3 
connect-ipphone -ipphone 172.16.18.134 -username "admin" -passwordtext "1234" -websession $ws4 
connect-ipphone -ipphone 172.16.18.135 -username "admin" -passwordtext "1234" -websession $ws5

#test each IP Phone is logged on
test-ipphoneConnection -ipphone 172.16.18.131 -websession $ws1 
test-ipphoneConnection -ipphone 172.16.18.132 -websession $ws2
test-ipphoneConnection -ipphone 172.16.18.133 -websession $ws3 
test-ipphoneConnection -ipphone 172.16.18.134 -websession $ws4 
test-ipphoneConnection -ipphone 172.16.18.135 -websession $ws5 

#Get the mac address of the IP Phone
get-ipphonemacaddress -ipphone 172.16.18.131 -websession $ws1
get-ipphonemacaddress -ipphone 172.16.18.132 -websession $ws2
get-ipphonemacaddress -ipphone 172.16.18.133 -websession $ws3
get-ipphonemacaddress -ipphone 172.16.18.134 -websession $ws4
get-ipphonemacaddress -ipphone 172.16.18.135 -websession $ws5

#Test the mac address of the IP Phone
test-ipphonemacaddress -ipphone 172.16.18.131 -macaddress "00-90-8F-99-FF-71" -websession $ws1
test-ipphonemacaddress -ipphone 172.16.18.132 -macaddress "00-90-8F-99-FF-70" -websession $ws2
test-ipphonemacaddress -ipphone 172.16.18.133 -macaddress "00:90:8F:99:FF:67" -websession $ws3
test-ipphonemacaddress -ipphone 172.16.18.134 -macaddress "00908F99FF39" -websession $ws4
test-ipphonemacaddress -ipphone 172.16.18.135 -macaddress "00908F99FF6E" -websession $ws5
test-ipphonemacaddress -ipphone 172.16.18.135 -macaddress "00-00-00-00-00-00" -websession $ws5

#Get the status of the IP Phone
Get-ipphoneStatus -ipphone 172.16.18.131 -websession $ws1
Get-ipphoneStatus -ipphone 172.16.18.132 -websession $ws2
Get-ipphoneStatus -ipphone 172.16.18.133 -websession $ws3
Get-ipphoneStatus -ipphone 172.16.18.134 -websession $ws4
Get-ipphoneStatus -ipphone 172.16.18.135 -websession $ws5

#Get the hook status of the IP Phone
Get-ipphoneHookStatus -ipphone 172.16.18.131 -websession $ws1
Get-ipphoneHookStatus -ipphone 172.16.18.132 -websession $ws2
Get-ipphoneHookStatus -ipphone 172.16.18.133 -websession $ws3
Get-ipphoneHookStatus -ipphone 172.16.18.134 -websession $ws4
Get-ipphoneHookStatus -ipphone 172.16.18.135 -websession $ws5

#Reboot the IP Phone
invoke-ipphonereboot -ipphone 172.16.18.131 -websession $ws1 
invoke-ipphonereboot -ipphone 172.16.18.132 -websession $ws2 
invoke-ipphonereboot -ipphone 172.16.18.133 -websession $ws3 
invoke-ipphonereboot -ipphone 172.16.18.134 -websession $ws4
invoke-ipphonereboot -ipphone 172.16.18.135 -websession $ws5 

#Factory Default the IP Phone
invoke-ipphonereset -ipphone 172.16.18.131 -websession $ws1 
invoke-ipphonereset -ipphone 172.16.18.132 -websession $ws2 
invoke-ipphonereset -ipphone 172.16.18.133 -websession $ws3 
invoke-ipphonereset -ipphone 172.16.18.134 -websession $ws4
invoke-ipphonereset -ipphone 172.16.18.135 -websession $ws5 

#Login the IP Phone
$sipcredential = Get-Credential -UserName adelev@shoey.xyz -Message "shane@shoey.example"
invoke-ipphoneLoginUser -ipphone 172.16.18.131 -websession $ws1 -sipaddress "shane@shoey.example" -sipcredential $sipcredential
invoke-ipphoneLoginUser -ipphone 172.16.18.132 -websession $ws2 -sipaddress "shane@shoey.example" -sipcredential $sipcredential
invoke-ipphoneLoginUser -ipphone 172.16.18.133 -websession $ws3 -sipaddress "shane@shoey.example" -sipcredential $sipcredential
invoke-ipphoneLoginUser -ipphone 172.16.18.134 -websession $ws4 -sipaddress "shane@shoey.example" -sipcredential $sipcredential
invoke-ipphoneLoginUser -ipphone 172.16.18.135 -websession $ws5 -sipaddress "shane@shoey.example" -sipcredential $sipcredential

#Login the IP Phone (Cloud Login)
invoke-ipphoneLoginUser -ipphone 172.16.18.135 -websession $ws5 -cloud
Get-ipphoneStatus -ipphone 172.16.18.135 -websession $ws5

#Logoff each IP Phone
invoke-ipphoneLoginUser -ipphone 172.16.18.131 -websession $ws1 -Logoff
invoke-ipphoneLoginUser -ipphone 172.16.18.132 -websession $ws2 -Logoff
invoke-ipphoneLoginUser -ipphone 172.16.18.133 -websession $ws3 -Logoff
invoke-ipphoneLoginUser -ipphone 172.16.18.134 -websession $ws4 -Logoff
invoke-ipphoneLoginUser -ipphone 172.16.18.135 -websession $ws5 -Logoff


#Example 
set-ipphoneTrustAllCertPolicy
$ipphone = “172.16.18.135”
$ippcredential = get-credential -Message "Credential" -UserName "admin"
$sipaddress = “shane@shoey.xyz”
$sipcredential  = get-credential -Message "Credential" -UserName $sipaddress
$websession  = new-ipphonewebsession -ipphone $ipphone
connect-ipphone -ipphone $ipphone -credential $ippcredential -websession $websession 
Invoke-ipphoneLoginUser -ipphone $ipphone -sipcredential $sipcredential -sipaddress $sipaddress -websession $websession
