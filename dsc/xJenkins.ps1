[CmdletBinding()]
Configuration xJenkins {
  param(
    [string[]]$ComputerName,
    [string]$StorageAccountName
  )

  Import-DscResource -ModuleName @{ModuleName="xPSDesiredStateConfiguration"; ModuleVersion="4.0.0.0"}
  $StorageKey = (Get-AzureStorageKey $StorageAccountName).Secondary

  node $ComputerName {
    # Debug Needed to prevent caching of resources, Implemented by
    # Set-DscLocalConfigurationManager -Path $Dsc -Verbose -Force -CimSession $cs
    LocalConfigurationManager
    {
        DebugMode = 'ForceModuleImport'
        RebootNodeIfNeeded = $true
    }

    Script NetUse {
      GetScript = { write @{} }
      TestScript = {
        Test-Path 'i:\psmodules'
      }
      SetScript = {
        net use i: \\$using:StorageAccountName.file.core.windows.net\install `
          $using:StorageKey /user:$using:StorageAccountName /persistent:yes
      }
    }

    # Copy all modules over to the PSModule directory
    Get-ChildItem i:\psmodules\x* | foreach {
      $xModule = $_.name
      File $xModule {
        DependsOn = "[Script]NetUse"
        DestinationPath = "C:\Program Files\WindowsPowerShell\Modules\$xModule"
        SourcePath = "I:\psmodules\$xModule"
        Type = "Directory"
        Recurse = $True
      }
    }


    File ScratchDir {
      DestinationPath = $Node.DSCScratchDirPath
      Ensure = "Present"
      Type = "Directory"
    }

    Write-Verbose "Setting up xRemoteFile"
    $JenkinsFile = "jenkins-" + $Node.JenkinsVersion + ".zip"
    #$JenkinsMirror = "https://ftp-nyc.osuosl.org"
    $JenkinsURI = "http://mirror.xmission.com/jenkins/windows/" + $JenkinsFile
    $JenkinsZip = Join-Path $Node.DSCScratchDirPath $JenkinsFile
    xRemoteFile JenkinsZip {
      Uri = $JenkinsURI
      DestinationPath = $JenkinsZip
      DependsOn = "[File]ScratchDir"
      MatchSource = $False
    }

    Write-Verbose "Setting up Archive"
    $JenkinsMSI = Join-Path $Node.DSCScratchDirPath "jenkins.msi"
    Archive JenkinsMSI {
      Path = $JenkinsZip
      #Destination = $JenkinsMSI
      Destination = $Node.DSCScratchDirPath
      DependsOn = "[xRemoteFile]JenkinsZip"
    }

    Write-Verbose "Setting up Package"
    # Use ./Get-ProductId
    Package JenkinsPackage {
      ProductID = "DB0F32AA-628E-4C21-AAD4-9924E24EDF75"
      Name = "Jenkins 2.23"
      Path = $JenkinsMSI
      DependsOn = "[Archive]JenkinsMSI"
    }
  }
}

$cd = @{
  AllNodes = @(
    @{
      NodeName = '18faz-sql2.cloudapp.net'
      PSDscAllowPlainTextPassword = $true
      DSCScratchDirPath = "C:\DSCScratchDirPath"
      JenkinsVersion = "2.23"
    }
  )
}

xJenkins -ComputerName 18faz-sql2.cloudapp.net -StorageAccountName 18fazsandbox2 -ConfigurationData $cd
