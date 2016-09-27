Configuration xJenkins {
  param(
    [string[]]$ComputerName
    [string]$StorageAccountName
  )
  Import-DSCResource -ModuleName 'xPSDesiredStateConfiguration' # get xRemoteFile,

  $StorageKey = (Get-AzureStorageKey $StorageAccountName).Secondary

  node $ComputerName {
    # Debug Needed to prevent caching of resources, Implemented by
    # Set-DscLocalConfigurationManager -Path $Dsc -Verbose -Force -CimSession $cs
    LocalConfigurationManager
    {
        DebugMode = 'All'
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

    #xRemoteFile JenkinsZip {
    #  Uri = "http://mirror.xmission.com/jenkins/windows/jenkins-${JenkinsVersion}.zip"
    #  DestinationPath = Join-Path $Node.DSCScratchDirPath "jenkins-${JenkinsVersion}.zip"
    #}
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
