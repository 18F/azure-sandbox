# Usage:
# ./dsc_configuration -sqlSysadmin 'domain/username'
configuration tfsAppServer
{
#  param(
#    [string]$sqlSysadmin
#  )

#  Import-DSCResource -ModuleName "PSDesiredStateConfiguration"
#  Import-DscResource -ModuleName "xSQLServer"
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

    xMountImage MSSQLIso {
      ImagePath = "C:\dsc\tfs.iso"
      DriveLetter = "S:"
      Ensure = "Present"
    }

    Registry FipsDisabled
    {
      Ensure      = "Present"  # You can also set Ensure to "Absent"
      Key         = "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy"
      ValueType   = "Dword"
      ValueName   = "Enabled"
      ValueData   = 0
    }

    $TFSinstaller = "S:\TfsServer2015.3.exe"
    # Cribbed from https://github.com/haxu/ps/blob/master/TFS/Env-TFS-Installation.ps1
    Script FullTFS  # This script does nothing when TFS has been manually installed....
    {
      TestScript = {
        if (Test-Path -Path "$env:ProgramFiles\Microsoft Team Foundation Server 14.0\Tools\TfsConfig.exe") {
          return $true
        }
        return $false
      }
      GetScript = {
        Get-Item "$env:ProgramFiles\Microsoft Team Foundation Server 14.0\Tools\TfsConfig.exe"
      }
      SetScript = {
        $Process = Start-Process -FilePath $TFSinstaller -ArgumentList '/Full /Quiet' -PassThru -Wait -NoNewWindow
        Write-Information "setup exited with code $($Process.ExitCode)"
        Write-Verbose -Message "============== FINIS ========="
      }


    } #script
  } #node
} #configuration

$configuration_data = @{
  AllNodes = @(
    @{
      NodeName = "localhost"
      PSDscAllowPlainTextPassword = $True
    }
  )
}

$Dsc="tfsAppServer"
tfsAppServer -ConfigurationData $configuration_data

Set-DscLocalConfigurationManager -Path $Dsc -Verbose -Force
Start-DscConfiguration -Path $Dsc -Verbose -Force -Wait
