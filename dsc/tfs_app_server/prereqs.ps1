# Prerequisites
# As of 2 Nov FIPS enablement wreaks havoc - see for resolution:
#  See: https://github.com/OneGet/oneget/issues/195

# Make sure we have the .iso available
$isoPath="C:\dsc\tfs.iso"

if ( -not (Get-Item $isoPath) )
{
  Write-Host "Need ISO at $isoPath"
  exit
}

$m = Get-Module -ListAvailable -FullyQualifiedName xStorage
if ($m -eq $null) { Install-Module xStorage }
