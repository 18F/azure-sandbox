# Prerequisites

# Technically, installing Chocolatey isn't required, but one
# can't do install-module (some-module) on hardened boxes
# unless it is, per https://github.com/OneGet/oneget/issues/183
# as Get-PackageProvider returns nothing.

function Go-CertYourself
{
   Import-Certificate -CertStoreLocation Cert:\LocalMachine\Root .\godaddy2.pem
   Import-Certificate -CertStoreLocation Cert:\LocalMachine\Root .\comodo_ecc.pem
}

$env:chocolateyUseWindowsCompression='false'

function Install-Choco
{
  iwr https://chocolatey.org/install.ps1 | iex
}

Go-CertYourself
Install-Choco
