# Don Jones. The DSC Book (Kindle Locations 532-546). leanpub.com.

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

  node $ComputerName {
    Script AzureModule {
      GetScript = { write @{} }
      TestScript = {
        (Get-Module -Name Azure.Storage).length -ge 1
      }
      SetScript = {
        Write-Warning "Next Install-PackageProvider line may need to be uncommented"
        #Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
        Install-Module azure
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

RemoteFileshareInstall -ComputerName 18faz-sqls1.cloudapp.net -StorageAccountName 18fazsandbox2
