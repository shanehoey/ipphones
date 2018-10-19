
set-location .\ipphones\scripts

$NuGetApiKey

$cert = Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert
$cert | format-table subject,issuer

$version = "0.0.1"

update-ScriptFileInfo -Path .\invoke-ipphoneScanlogin\invoke-ipphoneScanlogin.ps1 -Version $version -Author "Shane Hoey" -Copyright "2018 Shane Hoey" `
                        -RequiredModules ipphone  -ProjectUri https://docs.shanehoey.com/ipphone/ -ReleaseNotes https://docs.shanehoey.com/ipphone/ `
                        -LicenseUri https://docs.shanehoey.com/license/ -Tags "ipphone" -Description "Scan a subnet and logon IP Phones based on JSON file"

Set-AuthenticodeSignature -filepath .\invoke-ipphoneScanlogin\invoke-ipphoneScanlogin.ps1 -Certificate $cert
(Get-AuthenticodeSignature -FilePath .\invoke-ipphoneScanlogin\invoke-ipphoneScanlogin.ps1).Status


### IMPORTANT ONLY RUN AFTER ALL ABOVE IS COMPLETED
pause
Publish-Script -path .\invoke-ipphoneScanlogin\invoke-ipphoneScanlogin.ps1 -NuGetApiKey $NuGetApiKey