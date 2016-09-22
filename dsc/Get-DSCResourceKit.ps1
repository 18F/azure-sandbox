$resources = @('xDismFeature', 'xSqlServer', 'xSCDPM')

#$sc_resources  = Find-Module -Tag DSCResourceKit | Select -Expand Name | select-string "xSC"

Foreach($r in $resources) {
  Write-Host $r
  Remove-Module $r -Force
}


#+     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Multiple versions of the module 'xSqlServer' were found. You can run 'Get-Module -ListAvailable -FullyQualifiedName
#xSqlServer' to see available versions on the system, and then use the fully qualified name '@{ModuleName="xSqlServer";
#RequiredVersion="Version"}'.
