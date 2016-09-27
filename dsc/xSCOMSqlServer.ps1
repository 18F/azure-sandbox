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


# [18faz-sql1.cloudapp.net]: PS C:\Users\18fazure\Documents> net use j: \\18fazsandbox2.file.core.windows.net\install 2/UFgCylwA== /persistent:no /user:18fazsandbox2

configuration xSCOMSqlServer {
  param(
    [string[]]$ComputerName,
    [string]$StorageAccountName
  )

  $StorageAccountName = '18fazsandbox2'
  $StorageKey = (Get-AzureStorageKey $StorageAccountName).Secondary

  $AzureUser = '18fazure'
  $SecurePassword = ConvertTo-SecureString -String "Pass@word1" -AsPlainText -Force
  $InstallerServiceAccount = New-Object System.Management.Automation.PSCredential ($AzureUser, $SecurePassword)

  Import-DSCResource -ModuleName "PSDesiredStateConfiguration"
  Import-DscResource -ModuleName @{ModuleName="xSqlServer"; ModuleVersion="2.0.0.0"}

  node $ComputerName {
    # Debug Needed to prevent caching of resources, Implemented by
    # Set-DscLocalConfigurationManager -Path $Dsc -Verbose -Force -CimSession $cs
    LocalConfigurationManager
    {
        DebugMode = 'All'
        RebootNodeIfNeeded = $true
    }

    # Script CmdKey - probably a better way to persist credentials, but didn't seem to
    # be available for `net use`

    # Note use if `$using` here, which fetches variables available at compliation time.
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

    WindowsFeature "NET-Framework-Core"
    {
        Ensure = "Present"
        Name = "NET-Framework-Core"
    }

    $Features = "SQLENGINE,RS"
    $SQLInstanceName = "SCOMSqlServer"

<#   THIS STUFF OUGHT TO WORK - SEEMS BUSTED AT RUNNING SETUP.EXE
 #   NEED TO REMVOE THE /QUIET SWITCH AND PUSH TO SHARED MODULE REPO
    # Didja know -- SQLServer2014 is SQLVersion #12.  SqlSwerver2016 is #13.
    xSqlServerSetup $SQLInstanceName
    {
        DependsOn = "[WindowsFeature]NET-Framework-Core"
        SourcePath = "i:\SQLServer2014SP2"
        SetupCredential = $InstallerServiceAccount
        InstanceName = $SQLInstanceName
        Features = $Features
#        SQLSysAdminAccounts = $Node.AdminAccount
#        SQLSvcAccount = $Node.LocalSystemAccount
#        AgtSvcAccount = $Node.LocalSystemAccount
#        RSSvcAccount = $Node.LocalSystemAccount
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

# Install SQL Management Tools
    xSqlServerSetup "SQLMT"
    {
        DependsOn = "[WindowsFeature]NET-Framework-Core"
        SourcePath = $Node.SourcePath
        SetupCredential = $Node.InstallerServiceAccount
        InstanceName = "NULL"
        Features = "SSMS,ADV_SSMS"
    }
#>

  } # end node $computername
}


# PSDscAllowPlainTextPassword is needed to avoid
# security errors on plain test credientials in
# MOF from the use of StorageKey or Crediential above.

# https://blogs.technet.microsoft.com/ashleymcglone/2015/12/18/using-credentials-with-psdscallowplaintextpassword-and-psdscallowdomainuser-in-powershell-dsc-configuration-data/

$cd = @{
    AllNodes = @(
        @{
            NodeName = "18faz-sql1.cloudapp.net"
            PSDscAllowPlainTextPassword = $True
        }
    )
}

xSCOMSqlServer -ComputerName 18faz-sql1.cloudapp.net -StorageAccountName 18fazsandbox2 -ConfigurationData $cd
