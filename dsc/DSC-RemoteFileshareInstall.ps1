# Usage
# ./script # generates mof for ComputerName
# $password = "My secret password"
# ./Run-AzureDSC -Target $computername -User 18fazure -Dsc path\to\MyDSC -Password $password -verbose

# Remote nodes need
# SharedInstallMount
#   //$storageaccount.file.core.windows.net/install mounted at i:
# PowershellModuleCopy
#   Everything from i:\psmodules copied over

configuration RemoteFileshareInstall {
  param(
    [string[]]$ComputerName,
    [string]$StorageAccountName
  )

  $user = "peter.burkholder@gsa.gov"
  $password = "XXXXXXXX"
  $secPassword = ConvertTo-SecureString $password -AsPlainText -Force
  $credential = New-Object System.Management.Automation.PSCredential($user,$secPassword)
  $publishsettings = Get-Content $HOME\Projects\freetrial.publishsettings

  Import-DSCResource -ModuleName "PSDesiredStateConfiguration"

  node $ComputerName {
    File PubSettings {
      DestinationPath = "c:/tmp.publishsettings"
      Contents = [string]$publishsettings
      Ensure = "Present"
    }
    Script AzureModule {
      GetScript = { write @{} }
      TestScript = {
        (Get-Module -Name Azure.Storage).length -ge 1
      }
      SetScript = {
        Write-Warning "Next Install-PackageProvider call won't work in locked-down Azure"
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
        Install-Module azure
      }
    }

    Script AzureSubscription {
      GetScript = { Write @{} }
      TestScript = {
        (Get-AzureSubscription).length -ge 1
      }
      SetScript = {
        Import-AzurePublishSettingsFile "c:/tmp.publishsettings"
      }
    }

    Script ShareInstallMount {
#      DependsOn = [Script]"AzureModule"
      GetScript = { write @{} }
      TestScript = {
        Test-Path 'i:\psmodules'
      }
      SetScript = {
        # get the full storage key, but use just the primary, which
        # is just a long secret like an AWS secret key
        $StorageKey = (Get-AzureStorageKey $StorageAccountName).Primary

        # cmdkey will "persist the account crentials" on the node
        cmdkey /add:$StorageAccountName.file.core.windows.net /user:$StorageAccountName /pass:$StorageKey

        # net use mounts the share
        net use i: \\$StorageAccountName.file.core.windows.net\install
      }
    }
  }
}

RemoteFileshareInstall -ComputerName 18faz-sql1.cloudapp.net -StorageAccountName 18fazsandbox2


<#
Turn off IE enhance security
Server Manager -> Local Server -> Internet Explorer Enhanced security

Get the publishsettings with Get-AzurePublishSettingsFile and
  login on IE

Save as
  $publishsettings = Get-Content path/to/settings

Then wrote publishsettings to remote System
and there, run Import-publishesettings file


######## NOtE #########

Add-AzureAccount just doesn't work! -Creds are not what we expect --

#>
