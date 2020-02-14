# Usage:
# ./dsc_configuration -sqlSysadmin 'domain/username'
configuration tfsSqlServer
{
  param(
    [string]$sqlSysadmin
  )
  Import-DSCResource -ModuleName "PSDesiredStateConfiguration"
  Import-DscResource -ModuleName "xSQLServer"
  Import-DscResource -ModuleName "xStorage"

  $imagePath = "c:\dsc\"

  Node localhost {
    # Debug Needed to prevent caching of resources, Implemented by
    # Set-DscLocalConfigurationManager -Path $Dsc -Verbose -Force -CimSession $cs
    LocalConfigurationManager
    {
        DebugMode = 'All'
        RebootNodeIfNeeded = $true
    }

    WindowsFeature "NET-Framework-Core"
    {
        Ensure = "Present"
        Name = "NET-Framework-Core"
    }

    File DataDir {
      DestinationPath = "F:\MSSQLDATADIR"
      Ensure = "Present"
      Type = "Directory"
    }

    xMountImage MSSQLIso {
      ImagePath = "C:\dsc\SQLServer2014SP2-FullSlipstream-x64-ENU.iso"
      DriveLetter = "S:"
      Ensure = "Present"
    }

    $Features = "SQLENGINE,FULLTEXT"
    $SQLInstanceName = "MSSQLSERVER"
    $SetupArgs = "/QUIET /ACTION=Install "
    $SetupArgs += "/FEATURES=$Features /INSTANCENAME=$SQLInstanceName "
    $SetupArgs += "/IACCEPTSQLSERVERLICENSETERMS /SqlSysadminAccounts=$sqlSysadmin "
    $SetupArgs += "/INSTALLSQLDATADIR=F:\MSSQLDATADIR"
    $SetupPath = "S:\setup.exe"
    $SetupCommand = $SetupPath + $SetupArgs

    Script SqlServerSetup {
      DependsOn = @("[WindowsFeature]NET-Framework-Core", "[xMountImage]MSSQLIso")
      TestScript = {
        if (Get-Service | Where Name -eq $using:SQLInstanceName) {
          return $true
        }
        return $false
      }
      GetScript = {
        Get-Service | Where Name -eq $using:SQLInstanceName
      }
      SetScript = {
        $FP = "$using:SetupPath"
        $AL = "$using:SetupArgs"
        # Cribbed from https://github.com/PowerShell/xSQLServer/pull/123/files
        $Process = Start-Process -FilePath $FP -ArgumentList $AL -PassThru -Wait -NoNewWindow
        Write-Information "setup exited with code $($Process.ExitCode)"
        Write-Verbose -Message "============== FINIS ========="
      }
    }

# Windows Firewall rules for SQLServer:
#    https://msdn.microsoft.com/en-us/library/cc646023.aspx

  }
}

$configuration_data = @{
  AllNodes = @(
    @{
      NodeName = "localhost"
      PSDscAllowPlainTextPassword = $True
    }
  )
}

$Dsc="tfsSqlServer"
tfsSqlServer -ConfigurationData $configuration_data

Set-DscLocalConfigurationManager -Path $Dsc -Verbose -Force
Start-DscConfiguration -Path $Dsc -Verbose -Force -Wait
