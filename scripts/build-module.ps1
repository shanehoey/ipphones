exit

set-location $env:USERPROFILE\onedrive\github\ipphones

$NuGetApiKey = $NuGetApiKey
$NuGetApiKey

$cert = Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert
$cert | format-table subject,issuer
$cert

$version = "0.0.2"

Update-ModuleManifest -Path ".\ipphone\ipphone.psd1" -ModuleVersion $version 

Set-AuthenticodeSignature -filepath ".\ipphone\ipphone.psd1" -Certificate $cert 
(Get-AuthenticodeSignature -FilePath ".\ipphone\ipphone.psd1").Status

Set-AuthenticodeSignature -filepath ".\ipphone\ipphone.psm1" -Certificate $cert
(Get-AuthenticodeSignature -FilePath ".\ipphone\ipphone.psm1").Status

(Test-ModuleManifest -path ".\ipphone\ipphone.psd1")

Remove-Module ipphone -ErrorAction SilentlyContinue
Import-Module .\ipphone\ipphone.psd1

get-command -Module ipphone | Select-Object name,version


### MANUAL GitHUB Commit to master

### IMPORTANT ONLY RUN AFTER ALL ABOVE IS COMPLETED
pause
Publish-Module -path .\ipphone -NuGetApiKey $NuGetApiKey