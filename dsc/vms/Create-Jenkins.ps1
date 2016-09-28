param (
  $pwd = 'supersecret'
)
#
$subscription = "Free Trial"
Select-AzureSubscription $subscription
# New-AzureStorageAccount -Location "South Central US" 18fazsandbox2
Set-AzureSubscription -SubscriptionName $subscription -CurrentStorageAccount 18fazsandbox2

$image = "Win2012r2WPSAtom"
$user = "18fazure"
#           123456789012345  -- max 15 chars for svc name
# $vms = @("18faz-sql1", "18faz-sql2")
$vms =   @("18faz-jen1")
foreach ($VMName in $vms ) {
  $location = "South Central US"

  $secPassword = ConvertTo-SecureString $pwd -AsPlainText -Force
  $credential = New-Object System.Management.Automation.PSCredential($user, $secPassword)

  New-AzureVMConfig -Name $VMName -InstanceSize "Standard_DS2" -ImageName $image |
                  Add-AzureProvisioningConfig -Windows -AdminUsername $user -Password $pwd |
                  New-AzureVM -ServiceName $VMName -Location $location
}
