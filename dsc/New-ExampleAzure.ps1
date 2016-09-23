<#
.EXAMPLE
$password = "MySecure1234String--"
New-ExampleAzure -verbose $password
#>

[CmdletBinding()]


# this can be improved with Read-Host -AsSecureString
param(
  [Parameter(Mandatory=$True, Position=1)]
  [string]$pwd
)

$target = "18faz-sqls1"
$user = "18fazure"
$dscPath = ".\DSCConf1"

$ErrorActionPreference = "Stop"

Write-Verbose "Setting uri and credentials"
$uri = Get-AzureWinRMUri -ServiceName $target
$securePwd = "$pwd" | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($user, $securePwd)
Write-Verbose "uri: $($uri.host)"


$mycert = gci cert:\LocalMachine\Root -DnsName "$target*"
if($mycert.length -eq 0) {
  Write-Verbose "Starting SSL cert import"
  $certTempFile = [IO.Path]::GetTempFileName()
  Get-AzureCertificate -ServiceName $target |
    select -Expand Data |  Out-File $certTempFile
  Import-Certificate  $certTempFile -CertStoreLocation cert:\LocalMachine\Root
  rm $certTempFile
}


Write-Verbose "Setting up Session in CIM"
$sessionOption = New-CimSessionOption -SkipCNCheck -UseSSL -SkipRevocationCheck -SkipCACheck
$cs = New-CimSession -ComputerName $uri.host -Port $uri.port -Credential $credential -SessionOption $sessionOption

Write-Verbose "Starting DSC"
Start-DscConfiguration -Path $dscPath -Verbose -Force -CimSession $cs -Wait
