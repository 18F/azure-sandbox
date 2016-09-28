#############
# Only do these two lines once!
# Import-Module azure
# Add-AzureAccount # open IE and login

# Usage: ./init.ps1 mypassword

param (
  $pwd = 'supersecret'
)
#
$subscription = "Free Trial"
Select-AzureSubscription $subscription
# New-AzureStorageAccount -Location "South Central US" 18fazsandbox2
Set-AzureSubscription -SubscriptionName $subscription -CurrentStorageAccount 18fazsandbox2

# From
# https://www.opsgility.com/blog/windows-azure-powershell-reference-guide/introduction-remote-powershell-with-windows-azure/

#### Different ways of getting an image
## 1
# $family="Windows Server 2012 R2 Datacenter"
# $image = Get-AzureVMImage | where { $_.ImageFamily -eq $family } | sort PublishedDate -Descending | select -First 1 ImageName
## 2
# $image = "a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-Datacenter-201305.01-en.us-127GB.vhd"
$image = "Win2012r2WPSAtom"
## 3
####

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
