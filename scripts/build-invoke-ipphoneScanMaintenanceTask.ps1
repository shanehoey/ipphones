
set-location .\ipphones\Scripts

$NuGetApiKey

$cert = Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert
$cert | format-table subject,issuer

$version = "0.0.1"

update-ScriptFileInfo -Path .\invoke-ipphoneScanMaintenanceTask\invoke-ipphoneScanMaintenanceTask.ps1 -Version $version -Author "Shane Hoey" -Copyright "2018 Shane Hoey" `
                        -RequiredModules ipphone  -ProjectUri https://docs.shanehoey.com/ipphone/ -ReleaseNotes https://docs.shanehoey.com/ipphone/ `
                        -LicenseUri https://docs.shanehoey.com/license/ -Tags "ipphone" -Description "Scan a subnet and reboot/logoff/factory IP Phones"
Set-AuthenticodeSignature -filepath .\invoke-ipphoneScanMaintenanceTask\invoke-ipphoneScanMaintenanceTask.ps1 -Certificate $cert
Get-AuthenticodeSignature -FilePath .\invoke-ipphoneScanMaintenanceTask\invoke-ipphoneScanMaintenanceTask.ps1


### IMPORTANT ONLY RUN AFTER ALL ABOVE IS COMPLETED
pause
Publish-Script -path .\invoke-ipphoneScanMaintenanceTask\invoke-ipphoneScanMaintenanceTask.ps1 -NuGetApiKey $NuGetApiKey