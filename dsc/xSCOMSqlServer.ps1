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

  #$SecurePassword = ConvertTo-SecureString -String "Pass@word1" -AsPlainText -Force
  $AzureUser = '18fazure'
  $SecurePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
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
    WindowsFeature "NET-Framework-Core"
    {
        Ensure = "Present"
        Name = "NET-Framework-Core"
    }
    #$Features = "SQLENGINE,RS"
    $Features = "SQLENGINE"
    $SQLInstanceName = "MSSQLSERVER"
    $SetupArgs = " /QUIET /ACTION=Install /FEATURES=$Features /INSTANCENAME=$SQLInstanceName /IACCEPTSQLSERVERLICENSETERMS /SqlSyadminAccounts=$AzureUser"
    $SetupPath = "I:\SQLServer2014SP2\Source\setup.exe"
    $SetupCommand = $SetupPath + $SetupArgs

    Script SqlServerSetup {
      DependsOn = "[WindowsFeature]NET-Framework-Core"
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
        $E = "c:\sqlerr"
        $O = "c:\sqlout"
        $FP = "$using:SetupPath"
        $AL = "$using:SetupArgs"
        Start-Process -FilePath $FP -ArgumentList $AL -NoNewWindow -Wait -RedirectStandardError $E -RedirectStandardOutput $O
        Write-Verbose $?
        Write-Verbose -Message "============== OUTPUT ========="
        Get-Content $O | Write-Verbose 
        Write-Verbose -Message "============== ERROR ========="
        Get-Content $E | Write-Verbose
        Write-Verbose -Message "============== FINIS ========="
      }
    }

   <#
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
    <#

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

# https://blogs.technet.microsoft.com/ashleymcglone/2015/12/18/using-cjredentials-with-psdscallowplaintextpassword-and-psdscallowdomainuser-in-powershell-dsc-configuration-data/

$cd = @{
  AllNodes = @(
    @{
      NodeName = "18faz-sql1.cloudapp.net"
      PSDscAllowPlainTextPassword = $True
      LocalSystemAccount = $User
    }
    @{
      NodeName = "18faz-sql2.cloudapp.net"
      PSDscAllowPlainTextPassword = $True
      LocalSystemAccount = $User
    }
  )
}

xSCOMSqlServer -ComputerName 18faz-sql1.cloudapp.net,18faz-sql2.cloudapp.net -StorageAccountName 18fazsandbox2 -ConfigurationData $cd
