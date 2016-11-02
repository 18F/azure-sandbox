# Prerequisites
# As of 2 Nov FIPS enablement wreaks havoc - see for resolution:
#  See: https://github.com/OneGet/oneget/issues/195

# Make sure we have the .iso available
$isoPath="C:\dsc\SQLServer2014SP2-FullSlipstream-x64-ENU.iso"

if ( -not (Get-Item $isoPath) )
{
  Write-Host "Need ISO at $isoPath"
  exit
}

# Don't install multipled times
$m = Get-Module -ListAvailable -FullyQualifiedName xSqlServer
if ($m -eq $null) { Install-Module xSQLServer }

$m = Get-Module -ListAvailable -FullyQualifiedName xStorage
if ($m -eq $null) { Install-Module xStorage }
