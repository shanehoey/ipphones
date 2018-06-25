
## IMPORTANT REQURIES POWERSHELL 6

$ipp = "172.18.10.103"
$ippuser = "admin"
$ipppassword = "Password as encode string" 
$username = "USERNAME@FQDN"
$sipaddress = "USERNAME@FQDN"
$password = "PASSWORD"

#Option1 - Will log into the phone first, then log into Skype logs onto the phone 
$loginURL = "https://$ipp/login.cgi"
$sfburl = "https://$ipp/mainform.cgi/SfB_signin.htm"
$LoginFields = @{user="$ippuser";psw="$ipppassword";}
$sfbFields = @{SIGNINMODE="1";LYNC_SIGNIN_ADDR="$sipaddress";LYNC_USER_NAME="$username";LYNC_PASSWORD="$password";}
$result = Invoke-WebRequest -Uri $loginurl -Method Post -Body $LoginFields -ContentType "application/x-www-form-urlencoded" -SessionVariable ws -skipcertificatecheck
$result = Invoke-WebRequest -Uri $sfburl -Method Post -Body $sfbFields -ContentType "application/x-www-form-urlencoded" -wEBSESSION  $ws -skipcertificatecheck
$result.content
