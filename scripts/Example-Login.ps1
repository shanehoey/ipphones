#Requires -Version 5.0
#Requires -Modules ipphone

[CmdletBinding(ConfirmImpact = 'low',DefaultParameterSetName="default")]

param(
    [Parameter(Mandatory = $false,ParameterSetName="default")]
    $file = ".\phone.csv",

    [Parameter(Mandatory = $false,ParameterSetName="default")]
    $subnet = "192.168.10.",

    [Parameter(Mandatory = $false,ParameterSetName="default")]
    [int]$first = 1,

    [Parameter(Mandatory = $false,ParameterSetName="default")]
    [int]$last = 254,

    [Parameter(Mandatory = $true,ParameterSetName="default")]
    [securestring]$defaultpassword,

    [Parameter(Mandatory = $false,ParameterSetName="default")]
    [String]$ippadmin = "admin",

    [Parameter(Mandatory = $true,ParameterSetName="default")]
    [securestring]$ipppassword,

    [Parameter(Mandatory = $false,ParameterSetName="default")]
    [switch]$noping
)

if ($noping) {Write-warning "When using -noping this script will take a long time to complete" -warningaction Continue }

set-ipphoneTrustAllCertPolicy

[Collections.Generic.List[Object]]$phones = get-content -path $file | convertfrom-json

$ippcredential = New-Object System.Management.Automation.PSCredential ($ippadmin, $ipppassword )

for ($i = $first; $i -le $last; $i++)
{
    $count++
    $ip = "$($subnet)$($i)"
    Write-Progress -Activity "Scanning subnet" -Status "IP Address -> $ip" -PercentComplete ((($count/($last-$first+1)))*100)
    if ($noping) {$ping = $true}
    else { $ping = test-ipphoneicmp -ipphone $ip }
    if ($ping)      
    {                                       
        if (test-ipphoneweb -ipphone $ip )
        {
            $websession  = new-ipphonewebsession -ipphone $ip
            connect-ipphone -ipphone $ip -credential $ippcredential -websession $websession 
            $macaddress = get-ipphonemacaddress -ipphone $ip -websession $websession 
            $index = $phones.find( {$args[0].mac -eq $macaddress } ) 
            if($index) 
            {
              if ($index.password -eq $null) { $sipcredential = New-Object System.Management.Automation.PSCredential ($index.username, $defaultpassword ) } else  { $sipcredential = New-Object System.Management.Automation.PSCredential ($index.username, (ConvertTo-SecureString -String $index.password) )  }     
              Invoke-ipphoneLoginUser -ipphone $ip -sipcredential $sipcredential -sipaddress $index.sipaddress -websession $websession
              Write-verbose  "Logging in $($index.username) to  $IP" -verbose
            }
        }
    }                                       
}