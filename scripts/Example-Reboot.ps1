#Requires -Version 5.0
#Requires -Modules ipphone

[CmdletBinding(ConfirmImpact = 'low',DefaultParameterSetName="default")]

param(
    [Parameter(Mandatory = $false,ParameterSetName="default")]
    [Parameter(Mandatory = $false,ParameterSetName="factory")]
    [Parameter(Mandatory = $false,ParameterSetName="logoff")]
    $subnet = "192.168.10.",

    [Parameter(Mandatory = $false,ParameterSetName="default")]
    [Parameter(Mandatory = $false,ParameterSetName="factory")]
    [Parameter(Mandatory = $false,ParameterSetName="logoff")]
    [int]$first = 1,

    [Parameter(Mandatory = $false,ParameterSetName="default")]
    [Parameter(Mandatory = $false,ParameterSetName="factory")]
    [Parameter(Mandatory = $false,ParameterSetName="logoff")]
    [int]$last = 254,

    [Parameter(Mandatory = $false,ParameterSetName="default")]
    [Parameter(Mandatory = $false,ParameterSetName="factory")]
    [Parameter(Mandatory = $false,ParameterSetName="logoff")]
    [String]$ippadmin = "admin",

    [Parameter(Mandatory = $true,ParameterSetName="default")]
    [Parameter(Mandatory = $true,ParameterSetName="factory")]
    [Parameter(Mandatory = $true,ParameterSetName="logoff")]
    [securestring]$ipppassword,

    [Parameter(Mandatory = $false,ParameterSetName="factory")]
    [switch]$FactoryDefault,

    [Parameter(Mandatory = $false,ParameterSetName="logoff")]
    [switch]$LogoutOnly,

    [Parameter(Mandatory = $false,ParameterSetName="default")]
    [Parameter(Mandatory = $false,ParameterSetName="factory")]
    [Parameter(Mandatory = $false,ParameterSetName="logoff")]
    [switch]$noping
)

set-ipphoneTrustAllCertPolicy
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
            if($FactoryDefault)
            {
                Invoke-ipphoneReset -ipphone $ip -websession $websession
                Write-verbose -Message "Factory Default ->  $ip" -verbose
            }
            elseif($LogoutOnly) {
                Invoke-ipphoneLoginUser -ipphone $ip -Logoffuser -websession $websession
                Write-verbose -Message "logoff ->  $ip" -verbose 
            }
            else {
                Invoke-ipphoneReboot -ipphone $ip -websession $websession
                Write-verbose -Message "Reboot ->  $ip" -verbose 
            }
            
        }
    }                                       
}