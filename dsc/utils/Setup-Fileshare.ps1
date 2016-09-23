# to install sqlserver remotely, we'll need to fileshare with
# the install media stored on it.
# what I’m trying to do now is to figure out AzureFileStorage so I can take the sqlserver.iso,
# mount it at f:, then copy f:/* to //18fazurestorage/installers/sqlserver, and then
# mount that on the target machine (along with //18fazurestorage/modules/…)

# Already downloaded SQLServer2014SP2-FullSlipstream-x64-ENU.iso from
#  https://www.microsoft.com/en-us/evalcenter/evaluate-sql-server-2014-sp2

# Reference https://azure.microsoft.com/en-us/documentation/articles/storage-dotnet-how-to-use-files/

# if we followed the steps in vms/init.ps, we already did:

# New-AzureStorageAccount -Location "South Central US" 18fazsandbox2
# Set-AzureSubscription -SubscriptionName $subscription -CurrentStorageAccount 18fazsandbox2
# So we can see:

# Get-AzureStorageAccount -StorageAccountName 18fazsandbox2

$StorageAccountName="18fazsandbox2"
$StorageKey = (Get-AzureStorageKey $StorageAccountName).Primary
$ctx = New-AzureStorageContext $StorageAccountName $StorageKey

# Create a share:
if ((Get-AzureStorageShare install -Context $ctx).length -eq 0) {
   Write-Warning "Creating install share and mounting it"
  $s = New-AzureStorageShare install -Context $ctx
  cmdkey /add:$StorageAccountName.file.core.windows.net /user:$StorageAccountName /pass:$StorageKey
  net use i: \\$StorageAccountName.file.core.windows.net\install
} else {
  Write-Warning "Install share should be present"
}
