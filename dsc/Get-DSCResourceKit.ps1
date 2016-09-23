
# Install stuff from the DSC Resource Kit:

Write-Warning -Message "Don't run this script twice, or you'll get version specification errors"
$resources = @('xDismFeature', 'xSqlServer', 'xSCDPM')

#$sc_resources  = Find-Module -Tag DSCResourceKit | Select -Expand Name | select-string "xSC"

Foreach($r in $resources) {
  Write-Host $r
  Install-Module $r -Force
}


#+     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Multiple versions of the module 'xSqlServer' were found. You can run 'Get-Module -ListAvailable -FullyQualifiedName
#xSqlServer' to see available versions on the system, and then use the fully qualified name '@{ModuleName="xSqlServer";
#RequiredVersion="Version"}'.
