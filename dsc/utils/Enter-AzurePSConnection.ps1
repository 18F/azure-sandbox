<#
.SYNOPSIS
Sets up inter-system communication for running DSC in Azure, then
invokes the DSC

.EXAMPLE
$password = "MySecure1234String--"

Run-AzureDSC -Target 18faz-sqls1 -User 18fazure -Dsc path\to\MyDSC -Password $password -verbose
#>

[CmdletBinding()]


# this can be improved with Read-Host -AsSecureString
param(
  [Parameter(Mandatory=$True)]
  [string]$Password,

  [string]$User="18fazure",
  [string]$Target = "18faz-sql1"

)

$ErrorActionPreference = "Stop"

Write-Verbose "Setting uri and credentials"
$uri = Get-AzureWinRMUri -ServiceName $Target
$securePwd = "$Password" | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($User, $securePwd)
Write-Verbose "uri: $($uri.host) port: $($uri.port)"

$mycert = gci cert:\LocalMachine\Root -DnsName "$Target*"
if($mycert.length -eq 0) {
  Write-Verbose "Starting SSL cert import"
  $certTempFile = [IO.Path]::GetTempFileName()
  Get-AzureCertificate -ServiceName $Target |
    select -Expand Data |  Out-File $certTempFile
  Import-Certificate  $certTempFile -CertStoreLocation cert:\LocalMachine\Root
  rm $certTempFile
}

Write-Verbose "Starting PSsession"
Enter-PSSession -ConnectionURI $uri -Credential $credential
