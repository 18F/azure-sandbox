# Usage
# ./script # generates mof for ComputerName
# $password = "My secret password"
# ./Run-AzureDSC -Target $computername -User 18fazure -Dsc path\to\MyDSC -Password $password -verbose


######
# Configure one machine as the SQL Server for SCOM
######

# Remote nodes need
# SharedInstallMount
#   //$storageaccount.file.core.windows.net/install mounted at i:
# PowershellModuleCopy
#   Everything from i:\psmodules copied over

configuration xSCOMSqlServer {
  param(
    [string[]]$ComputerName,
    [string]$StorageAccountName
  )

  $AzureUser = '18fazure'
  $StorageAccountName = 'azsandbox2'
  $StorageKey = (Get-AzureStorageKey 18fazsandbox2).Secondary

  Import-DSCResource -ModuleName "PSDesiredStateConfiguration"

  node $ComputerName {

    LocalConfigurationManager
    {
        DebugMode = $true
        RebootNodeIfNeeded = $true
    }

    Script NetUse {
      GetScript = { write @{} }
      TestScript = {
        Test-Path 'i:\psmodules'
      }
      SetScript = {
        net use i: \\$using:StorageAccountName.file.core.windows.net\install `
          $using:StorageKey /user:$using:AzureUser /persistent:yes
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

    WindowsFeature "NET-Framework-Core"
    {
        Ensure = "Present"
        Name = "NET-Framework-Core"
    }

    <#

            $Features = "SQLENGINE,RS"
            xSqlServerSetup ($Node.NodeName + $SQLInstanceName)
            {
                DependsOn = "[WindowsFeature]NET-Framework-Core"
                SourcePath = $Node.SourcePath
                SetupCredential = $Node.InstallerServiceAccount
                InstanceName = $SQLInstanceName
                Features = $Features
                SQLSysAdminAccounts = $Node.AdminAccount
                SQLSvcAccount = $Node.LocalSystemAccount
                AgtSvcAccount = $Node.LocalSystemAccount
                RSSvcAccount = $Node.LocalSystemAccount
            }

            xSqlServerFirewall ($Node.NodeName + $SQLInstanceName)
            {
                DependsOn = ("[xSqlServerSetup]" + $Node.NodeName + $SQLInstanceName)
                SourcePath = $Node.SourcePath
                InstanceName = $SQLInstanceName
                Features = $Features
            }

            # Set SSRS secure connection level on database node
            xSQLServerRSSecureConnectionLevel ($Node.NodeName + $SQLInstanceName)
            {
                DependsOn = ("[xSqlServerSetup]" + $Node.NodeName + $SQLInstanceName)
                InstanceName = $SystemCenter2012R2DataProtectionManagerDatabaseInstance
                SecureConnectionLevel = 0
                SQLAdminCredential = $Node.InstallerServiceAccount
            }
        }
    }

    # Install SQL Management Tools
    if(
        ($SystemCenter2012R2DataProtectionManagerServers | Where-Object {$_ -eq $Node.NodeName}) -or
        ($SQLServer2012ManagementTools | Where-Object {$_ -eq $Node.NodeName})
    )
    {
        xSqlServerSetup "SQLMT"
        {
            DependsOn = "[WindowsFeature]NET-Framework-Core"
            SourcePath = $Node.SourcePath
            SetupCredential = $Node.InstallerServiceAccount
            InstanceName = "NULL"
            Features = "SSMS,ADV_SSMS"
        }
    }
#>

  } # end node $computername
}

xSCOMSqlServer -ComputerName 18faz-sql1.cloudapp.net -StorageAccountName 18fazsandbox2
