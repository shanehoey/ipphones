
#requires that the phone has a parameter set to enable weblogin 
##TODO Confirm parameter, I think it is lync/sign_in/web/enabled=1

$ipp = "172.18.10.103"
$username = "USERNAME@FQDN"
$sipaddress = "USERNAME@FQDN"
$password = "PASSWORD"

$loginURL = "https://$ipp/web_login.cgi"
$sfbFields = @{LYNC_SIGNIN_ADDR="$sipaddress";LYNC_USER_NAME="$username";LYNC_PASSWORD="$password";}
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$result = Invoke-WebRequest -Uri $loginurl -Method Post -Body $sfbFields -ContentType "application/x-www-form-urlencoded" -skipcertificatecheck
$result.content
