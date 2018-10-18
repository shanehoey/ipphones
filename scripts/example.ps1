
set-location $env:USERPROFILE\onedrive\github\ipphones
Remove-Module ipphone -ErrorAction SilentlyContinue
Import-Module .\ipphone\ipphone.psd1

#List out all the cmdlets in the module
Get-Command -Module ipphone

#test if the phone's SSL is trusted 
test-ipphoneTrustCertPolicy -ipphone 172.16.18.135

#if the phone is not trusted modify the trust cert policy (powershell core you use -skipcertificatecheck instead)
set-ipphoneTrustAllCertPolicy

#test that the ipphone is pingable  
test-ipphoneICMP -ipphone 172.16.18.131 
test-ipphoneICMP -ipphone 172.16.18.132
test-ipphoneICMP -ipphone 172.16.18.133
test-ipphoneICMP -ipphone 172.16.18.134
test-ipphoneICMP -ipphone 172.16.18.135

#test if the endpoint is an IPPhone
test-ipphoneweb -ipphone 172.16.18.131 
test-ipphoneweb -ipphone 172.16.18.132
test-ipphoneweb -ipphone 172.16.18.133
test-ipphoneweb -ipphone 172.16.18.134
test-ipphoneweb -ipphone 172.16.18.135

#Create Websessions and store them in a variable for reuse
$ws1 = new-ipphonewebsession -ipphone 172.16.18.131 
$ws2 = new-ipphonewebsession -ipphone 172.16.18.132
$ws3 = new-ipphonewebsession -ipphone 172.16.18.133 
$ws4 = new-ipphonewebsession -ipphone 172.16.18.134 
$ws5 = new-ipphonewebsession -ipphone 172.16.18.135 

#Login to each phone using username/password username/securestring or credential 
[securestring]$password = "01000000d08c9ddf0115d1118c7a00c04fc297eb01000000d9c9d5b34fd2354c9dc43ed0f5b6eb0a000000000200000000001066000000010000200000000d8af1bb6449fc0a9d4f9bc823503d24d18b5eabb390bf526b684db4eb28f453000000000e8000000002000020000000dee194657d6f8e7f4b453c0d0ef35675b10ba033f6a61702e7e7e17e11c1b831100000004f09db2e6f33b610569ed9c6e37c85a64000000089f1a04de6dae2db0addda92fdee5167055646d7f19939a0ea4a4f3c3fe3ccf42618e81a17fea4a4e78a7e7ce49705a56d5dc8964b3bfe7a2ae959ede95e6a29" | ConvertTo-SecureString
$ippcredential          = New-Object System.Management.Automation.PSCredential ("admin", $password)
connect-ipphone -ipphone 172.16.18.131 -username "admin" -passwordtext "1234" -websession $ws1 
connect-ipphone -ipphone 172.16.18.132 -username "admin" -password $password  -websession $ws2 
connect-ipphone -ipphone 172.16.18.133 -credential $ippcredential -websession $ws3 
connect-ipphone -ipphone 172.16.18.134 -username "admin" -passwordtext "1234" -websession $ws4 
connect-ipphone -ipphone 172.16.18.135 -username "admin" -passwordtext "1234" -websession $ws5

#test each phone is logged on
test-ipphoneConnection -ipphone 172.16.18.131 -websession $ws1 
test-ipphoneConnection -ipphone 172.16.18.132 -websession $ws2
test-ipphoneConnection -ipphone 172.16.18.133 -websession $ws3 
test-ipphoneConnection -ipphone 172.16.18.134 -websession $ws4 
test-ipphoneConnection -ipphone 172.16.18.135 -websession $ws5 

#Get the mac address of the phone 
get-ipphonemacaddress -ipphone 172.16.18.131 -websession $ws1
get-ipphonemacaddress -ipphone 172.16.18.132 -websession $ws2
get-ipphonemacaddress -ipphone 172.16.18.133 -websession $ws3
get-ipphonemacaddress -ipphone 172.16.18.134 -websession $ws4
get-ipphonemacaddress -ipphone 172.16.18.135 -websession $ws5

#Test the mac address of the phone 
test-ipphonemacaddress -ipphone 172.16.18.131 -macaddress "00-90-8F-97-FD-71" -websession $ws1
test-ipphonemacaddress -ipphone 172.16.18.132 -macaddress "00-90-8F-97-FD-70" -websession $ws2
test-ipphonemacaddress -ipphone 172.16.18.133 -macaddress "00:90:8F:61:30:67" -websession $ws3
test-ipphonemacaddress -ipphone 172.16.18.134 -macaddress "00908F760439" -websession $ws4
test-ipphonemacaddress -ipphone 172.16.18.135 -macaddress "00908F98486E" -websession $ws5
test-ipphonemacaddress -ipphone 172.16.18.135 -macaddress "00-00-00-00-00-00" -websession $ws5

#Get the status of the phone 
Get-ipphoneStatus -ipphone 172.16.18.131 -websession $ws1
Get-ipphoneStatus -ipphone 172.16.18.132 -websession $ws2
Get-ipphoneStatus -ipphone 172.16.18.133 -websession $ws3
Get-ipphoneStatus -ipphone 172.16.18.134 -websession $ws4
Get-ipphoneStatus -ipphone 172.16.18.135 -websession $ws5

Get-ipphoneHookStatus -ipphone 172.16.18.131 -websession $ws1
Get-ipphoneHookStatus -ipphone 172.16.18.132 -websession $ws2
Get-ipphoneHookStatus -ipphone 172.16.18.133 -websession $ws3
Get-ipphoneHookStatus -ipphone 172.16.18.134 -websession $ws4
Get-ipphoneHookStatus -ipphone 172.16.18.135 -websession $ws5

#Reboot each phone 
invoke-ipphonereboot -ipphone 172.16.18.131 -websession $ws1 
invoke-ipphonereboot -ipphone 172.16.18.132 -websession $ws2 
invoke-ipphonereboot -ipphone 172.16.18.133 -websession $ws3 
invoke-ipphonereboot -ipphone 172.16.18.134 -websession $ws4
invoke-ipphonereboot -ipphone 172.16.18.135 -websession $ws5 

#Factory Default each phone 
invoke-ipphonereset -ipphone 172.16.18.131 -websession $ws1 
invoke-ipphonereset -ipphone 172.16.18.132 -websession $ws2 
invoke-ipphonereset -ipphone 172.16.18.133 -websession $ws3 
invoke-ipphonereset -ipphone 172.16.18.134 -websession $ws4
invoke-ipphonereset -ipphone 172.16.18.135 -websession $ws5 

#Set Login User 
$sipcredential = Get-Credential -UserName adelev@shoey.xyz -Message "adelev@shoey.xyz"
invoke-ipphoneLoginUser -ipphone 172.16.18.131 -websession $ws1 -sipaddress "adelev@shoey.xyz" -sipcredential $sipcredential
invoke-ipphoneLoginUser -ipphone 172.16.18.132 -websession $ws2 -sipaddress "adelev@shoey.xyz" -sipcredential $sipcredential
invoke-ipphoneLoginUser -ipphone 172.16.18.133 -websession $ws3 -sipaddress "adelev@shoey.xyz" -sipcredential $sipcredential
invoke-ipphoneLoginUser -ipphone 172.16.18.134 -websession $ws4 -sipaddress "adelev@shoey.xyz" -sipcredential $sipcredential
invoke-ipphoneLoginUser -ipphone 172.16.18.135 -websession $ws5 -sipaddress "adelev@shoey.xyz" -sipcredential $sipcredential


#Do A CLOUD LOGIN 
invoke-ipphoneLoginUser -ipphone 172.16.18.135 -websession $ws5 -cloud
Get-ipphoneStatus -ipphone 172.16.18.135 -websession $ws5
#

#Logoff each Phone
invoke-ipphoneLoginUser -ipphone 172.16.18.131 -websession $ws1 -Logoff
invoke-ipphoneLoginUser -ipphone 172.16.18.132 -websession $ws2 -Logoff
invoke-ipphoneLoginUser -ipphone 172.16.18.133 -websession $ws3 -Logoff
invoke-ipphoneLoginUser -ipphone 172.16.18.134 -websession $ws4 -Logoff
invoke-ipphoneLoginUser -ipphone 172.16.18.135 -websession $ws5 -Logoff

