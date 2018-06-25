
## IMPORTANT 

## Requires that the phone has a parameter set to enable weblogin 
#      TODO: Confirm parameter, I think it is lync/sign_in/web/enabled=1

#NOTE : if you get Exception 417 the reboot the phone!

#IPP Details
$ipp         = "10.1.10.22"

#SfB Details
$username    = "sipaddress@shanehoey.net"
$sipaddress  = "sipaddress@shanehoey.net"
$password    = "password"

#URL
$loginURL = "https://$ipp/web_login.cgi"

#Fields
$SFBFields = @{LYNC_SIGNIN_ADDR="$sipaddress";LYNC_USER_NAME="$username";LYNC_PASSWORD="$password";}

#web request
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$result = Invoke-WebRequest -Uri $loginurl -Method Post -Body $sfbFields -ContentType "application/x-www-form-urlencoded"
$result.content
