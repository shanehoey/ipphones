
## IMPORTANT 
# Script will log onto the phone first, then log into Skype for Business via sipaddress/username/password

#NOTE : if you get Exception 417 the reboot the phone!

#IPP Details
$ipp         = "10.1.10.22"
$ippuser     = "admin"
$ipppassword = "Password as encode string" 

#SFB Details
$username    = "sipaddress@shanehoey.net"
$sipaddress  = "sipaddress@shanehoey.net"
$password    = "password"

#URL
$loginURL = "https://$ipp/login.cgi"
$sfburl = "https://$ipp/mainform.cgi/SfB_signin.htm"

#Fields
$LoginFields = @{user="$ippuser";psw="$ipppassword";}
$SFBFields = @{SIGNINMODE="1";LYNC_SIGNIN_ADDR="$sipaddress";LYNC_USER_NAME="$username";LYNC_PASSWORD="$password";}

#webrequest
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$result = Invoke-WebRequest -Uri $loginurl -Method Post -Body $LoginFields -ContentType "application/x-www-form-urlencoded" -SessionVariable ws 
$result = Invoke-WebRequest -Uri $sfburl -Method Post -Body $SFBFields -ContentType "application/x-www-form-urlencoded" -WebSession $ws 
$result.content


