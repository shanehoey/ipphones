
<#PSScriptInfo

.VERSION 0.0.1

.GUID 34feea0f-d3fe-4107-ada3-60edbbbfb817

.AUTHOR Shane Hoey

.COMPANYNAME 

.COPYRIGHT 2018 Shane Hoey

.TAGS ipphone

.LICENSEURI https://docs.shanehoey.com/license/

.PROJECTURI https://docs.shanehoey.com/ipphone/

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
https://docs.shanehoey.com/ipphone/

.PRIVATEDATA 

#> 

#Requires -Module ipphone



#Requires -Version 5.0

<# 

.DESCRIPTION 
Scan a subnet and logon IP Phones based on JSON file

#> 

[CmdletBinding(ConfirmImpact = 'low',DefaultParameterSetName="default")]

param(
    [Parameter(Mandatory = $false,ParameterSetName="default")]
    $file = ".\phones.json",

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
    [switch]$noping,

    [Parameter(Mandatory = $false,ParameterSetName="default")]
    [switch]$cleartext
    
)

    if ($noping) 
    {   
        Write-warning "When using -noping this script will take a long time to complete" -warningaction Continue 
    }

    if ($cleartext) 
    {   
        Write-warning "******* Storing Passwords as Clear Text in the files is Not Recommended and a Security Risk *******" -warningaction Continue
    }

    set-ipphoneTrustAllCertPolicy

    try 
    {
        [Collections.Generic.List[Object]]$phones = get-content -path $file | convertfrom-json
        Write-Verbose ($phones | Out-String)
    }
    catch 
    {
        throw "Unable to Import file "
    }

    $ippcredential = New-Object System.Management.Automation.PSCredential ($ippadmin, $ipppassword )
    Write-Verbose ($ippcredential | Out-String)

    $count = 0
    for ($i = $first; $i -le $last; $i++)
    {
        $count++
        $ip = "$($subnet)$($i)"
        Write-Progress -Activity "Scanning subnet" -Status "IP Address -> $ip" -PercentComplete ((($count/($last-$first+1)))*100)
        if ($noping) 
        { 
            $ping = $true 
        }
        else 
        { 
            $ping = test-ipphoneicmp -ipphone $ip 
        }
        if ($ping)      
        {   
            try 
            {            
                if ( test-ipphoneweb -ipphone $ip )
                {
                    $websession  = new-ipphonewebsession -ipphone $ip
                    connect-ipphone -ipphone $ip -credential $ippcredential -websession $websession 
                    $macaddress = get-ipphonemacaddress -ipphone $ip -websession $websession 
                    $index = $phones.find( { $args[0].mac -eq $macaddress } ) 
                    if($index) 
                    {
                        if ($index.password -ne $null) 
                        { 
                            if($cleartext) 
                            {
                                Write-warning "******* ($$index.username) password was stored in cleartext this is not recommended and a security risk *******" -warningaction Continue
                                $sipcredential = New-Object System.Management.Automation.PSCredential ($index.username, (ConvertTo-SecureString -String $index.password -AsPlainText -Force) )
                                write-verbose -Message "$($index.username) -> Password Found"
                            }
                            else 
                            {
                                $sipcredential = New-Object System.Management.Automation.PSCredential ($index.username, (ConvertTo-SecureString -String $index.password) )
                                write-verbose -Message "$($index.username) -> Password Found"
                            }
                        } 
                        else  
                        { 
                            $sipcredential = New-Object System.Management.Automation.PSCredential ($index.username, $defaultpassword) 
                            write-verbose -Message "$($index.username) -> Using Default Password"  
                        }     
                        Invoke-ipphoneLoginUser -ipphone $ip -sipaddress $index.sipaddress -sipcredential $sipcredential -websession $websession
                        Write-verbose  "Logging in $($index.username) to $($index.mac) $IP" -verbose
                        Write-verbose  "`n`n" 
                    }
                }
            }
            catch 
            {
                Write-Warning -Message "Error with $($subnet)$($i) - $psitem.exception"
                
            }
        }
    }                                           


# SIG # Begin signature block
# MIINCgYJKoZIhvcNAQcCoIIM+zCCDPcCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUfE4FATBhJo/PZNln4h8eCNCI
# F2OgggpMMIIFFDCCA/ygAwIBAgIQDq/cAHxKXBt+xmIx8FoOkTANBgkqhkiG9w0B
# AQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFz
# c3VyZWQgSUQgQ29kZSBTaWduaW5nIENBMB4XDTE4MDEwMzAwMDAwMFoXDTE5MDEw
# ODEyMDAwMFowUTELMAkGA1UEBhMCQVUxGDAWBgNVBAcTD1JvY2hlZGFsZSBTb3V0
# aDETMBEGA1UEChMKU2hhbmUgSG9leTETMBEGA1UEAxMKU2hhbmUgSG9leTCCASIw
# DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANAI9q03Pl+EpWcVZ7PQ3AOJ17k6
# OoS9SCIbZprs7NhyRIg7mKzxdcHMnjKwUe/7NDlt5mYzXT2yY/0MeUkyspiEs1+t
# eiHJ6IIs9llWgPGOkV4Ro5fZzlutqeeaomEW/ulH7mVjihVCR6mP/O09YSNo0Dv4
# AltYmVXqhXTB64NdwupL2G8fmTmVUJsww9abtGxy3mhL/l2W3VBcozZbCZVw363p
# 9mjeR9WUz5AxZji042xldKB/97cNHd/2YyWuJ8eMlYfRqz1nVgmmpuU+SuApRult
# hy6wNEngVmJBVhH/a8AH29dEZNL9pzhJGRwGBFi+m/vIr5SFhQVFZYJy79kCAwEA
# AaOCAcUwggHBMB8GA1UdIwQYMBaAFFrEuXsqCqOl6nEDwGD5LfZldQ5YMB0GA1Ud
# DgQWBBROEIC6bKfPIk2DtUTZh7HSa5ajqDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0l
# BAwwCgYIKwYBBQUHAwMwdwYDVR0fBHAwbjA1oDOgMYYvaHR0cDovL2NybDMuZGln
# aWNlcnQuY29tL3NoYTItYXNzdXJlZC1jcy1nMS5jcmwwNaAzoDGGL2h0dHA6Ly9j
# cmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtY3MtZzEuY3JsMEwGA1UdIARF
# MEMwNwYJYIZIAYb9bAMBMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2lj
# ZXJ0LmNvbS9DUFMwCAYGZ4EMAQQBMIGEBggrBgEFBQcBAQR4MHYwJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBOBggrBgEFBQcwAoZCaHR0cDov
# L2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0U0hBMkFzc3VyZWRJRENvZGVT
# aWduaW5nQ0EuY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggEBAIly
# KESC2V2sBAl6sIQiHRRgQ9oQdtQamES3fVBNHwmsXl76DdjDURDNi6ptwve3FALo
# ROZHkrjTU+5r6GaOIopKwE4IXkboVoPBP0wJ4jcVm7kcfKJqllSBGZfpnSUjlaRp
# EE5k1XdVAGEoz+m0GG+tmb9gGblHUiCAnGWLw9bmRoGbJ20a0IQ8jZsiEq+91Ft3
# 1vJSBO2RRBgqHTama5GD16OyE3Aps5ypaKYXuq0cnNZCaCasRtDJPolSP4KQ+NVg
# Z/W/rDiO8LNOTDwGcZ2bYScAT88A5KX42wiKnKldmyXnd4ffrwWk8fPngR5sVhus
# Arv6TbwR8dRMGwXwQqMwggUwMIIEGKADAgECAhAECRgbX9W7ZnVTQ7VvlVAIMA0G
# CSqGSIb3DQEBCwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJ
# bmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0
# IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0xMzEwMjIxMjAwMDBaFw0yODEwMjIxMjAw
# MDBaMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNV
# BAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNz
# dXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
# ggEKAoIBAQD407Mcfw4Rr2d3B9MLMUkZz9D7RZmxOttE9X/lqJ3bMtdx6nadBS63
# j/qSQ8Cl+YnUNxnXtqrwnIal2CWsDnkoOn7p0WfTxvspJ8fTeyOU5JEjlpB3gvmh
# hCNmElQzUHSxKCa7JGnCwlLyFGeKiUXULaGj6YgsIJWuHEqHCN8M9eJNYBi+qsSy
# rnAxZjNxPqxwoqvOf+l8y5Kh5TsxHM/q8grkV7tKtel05iv+bMt+dDk2DZDv5LVO
# pKnqagqrhPOsZ061xPeM0SAlI+sIZD5SlsHyDxL0xY4PwaLoLFH3c7y9hbFig3NB
# ggfkOItqcyDQD2RzPJ6fpjOp/RnfJZPRAgMBAAGjggHNMIIByTASBgNVHRMBAf8E
# CDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcDAzB5
# BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0
# LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0Rp
# Z2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHoweDA6oDigNoY0aHR0
# cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNy
# bDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJl
# ZElEUm9vdENBLmNybDBPBgNVHSAESDBGMDgGCmCGSAGG/WwAAgQwKjAoBggrBgEF
# BQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzAKBghghkgBhv1sAzAd
# BgNVHQ4EFgQUWsS5eyoKo6XqcQPAYPkt9mV1DlgwHwYDVR0jBBgwFoAUReuir/SS
# y4IxLVGLp6chnfNtyA8wDQYJKoZIhvcNAQELBQADggEBAD7sDVoks/Mi0RXILHwl
# KXaoHV0cLToaxO8wYdd+C2D9wz0PxK+L/e8q3yBVN7Dh9tGSdQ9RtG6ljlriXiSB
# ThCk7j9xjmMOE0ut119EefM2FAaK95xGTlz/kLEbBw6RFfu6r7VRwo0kriTGxycq
# oSkoGjpxKAI8LpGjwCUR4pwUR6F6aGivm6dcIFzZcbEMj7uo+MUSaJ/PQMtARKUT
# 8OZkDCUIQjKyNookAv4vcn4c10lFluhZHen6dGRrsutmQ9qzsIzV6Q3d9gEgzpkx
# Yz0IGhizgZtPxpMQBvwHgfqL2vmCSfdibqFT+hKUGIUukpHqaGxEMrJmoecYpJpk
# Ue8xggIoMIICJAIBATCBhjByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNl
# cnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdp
# Q2VydCBTSEEyIEFzc3VyZWQgSUQgQ29kZSBTaWduaW5nIENBAhAOr9wAfEpcG37G
# YjHwWg6RMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkG
# CSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEE
# AYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRQo0iay7y4kfTvw3f//widR5gJITANBgkq
# hkiG9w0BAQEFAASCAQDORXyqIZeOHnGv3lvKekTTVJ0Jws+IRanXL1kMrVOGEQeL
# A4NbCgDxnfIgUnlHkjmyJFq++LRT//f7HJN7sKErlHAhc8D+eBO3lud3MxrS24jC
# 9ykihDa+UjE4oJmvQahx+xznu/+r3UgbjzcWQnfTbpcf+lrl9iWFGyrqEJeqxJzI
# kH/fDMoY/L5OfiEhel8SpSY5hprGVBDTV+ucKMQ5e8Kgy+PdHgINr29mgJu+uCdk
# t4zObjR7aOTi3aeU2HtpKdw50e0eg6x3CvbP5lP+PHCAJtDBVBdunwXmiqkM2eUW
# Qqx4KVy7Qbz6lc/AzdH7dMDaW96KQKRvcp09gW1d
# SIG # End signature block
