[CmdletBinding()]
Configuration xBaseDSC {
  param(
    [string[]]$ComputerName,
    [string]$StorageAccountName
  )
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
        Write-Verbose "NetUse TestScript"
        Test-Path 'i:\psmodules'
      }
      SetScript = {
        Write-Verbose "NetUse SetScript"
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
  }
}

$cd = @{
  AllNodes = @(
    @{
      NodeName = "*"
      DSCScratchDirPath = "C:\DSCScratchDirPath"
    }
    @{
      NodeName = '18faz-sql1.cloudapp.net'
    }
    @{
      NodeName = '18faz-sql2.cloudapp.net'
    }
    @{
      NodeName = '18faz-jen1.cloudapp.net'
      DSCScratchDirPath = "C:\DSCScratchDirPath"
    }
  )
}

xBaseDSC -ComputerName 18faz-jen1.cloudapp.net,18faz-sql1.cloudapp.net,18faz-sql2.cloudapp.net -StorageAccountName 18fazsandbox2 -ConfigurationData $cd
Write-Host "./Run-AzureDSC -Target $computername -User 18fazure -Password $$assword -verbose -Dsc ./xBaseDSC"
