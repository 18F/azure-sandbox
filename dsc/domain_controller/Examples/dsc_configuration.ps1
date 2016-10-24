  # Hard-coded parameters for initial tests
  $DomainName = "tlabeta.test"

#  $insecurePassword = ConvertTo-SecureString 'IveGot2$kills!' -AsPlainText -Force
#  $DomanAdminCreds =New-Object System.Management.Automation.PSCredential ('domainadmin', $insecurePassword)

#  $secpasswd = ConvertTo-SecureString 'IWouldLiketoRecoverPlease1!' -AsPlainText -Force
#  $SafeModeCreds = New-Object System.Management.Automation.PSCredential ('guest', $secpasswd)

configuration TLABetaDomainController
{
  param
  (
    [string[]]$NodeName = 'localhost'
  )

  #Import the required DSC Resources
  #Import-DscResource -Module xComputerManagement
  Import-DscResource -ModuleName xActiveDirectory

  Node $NodeName
  {
    WindowsFeature ADDSInstall
    {
      Ensure = 'Present'
      Name = 'AD-Domain-Services'
    }
  }

  xADDomain TLABetaDomain
  {
#     DomainAdministratorCredential= $DomanAdminCreds
     DomainName= $DomainName
#     SafemodeAdministratorPassword= $SafeModePW
     DomainNetbiosName = $DomainName.Split('.')[0]
     DependsOn = "[WindowsFeature]ADDSInstall"
  }
}

#$configData = @{
#  AllNodes = @(
#    @{
#      NodeName = 'localhost';
#      PSDscAllowPlainTextPassword = $true
#    }
#  )
#}

TLABetaDomainController -configurationData $configData
Start-DscConfiguration -ComputerName localhost -Wait -Force`
  -Verbose -path .\TLABetaDomainController -Debug
