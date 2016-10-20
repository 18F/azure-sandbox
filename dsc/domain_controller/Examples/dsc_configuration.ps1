configuration create_DomainController
{
  param
  (
    [string[]]$NodeName = 'localhost'
  )

  #Import the required DSC Resources
  #Import-DscResource -Module xComputerManagement
  #Import-DscResource -Module xActiveDirectory

  Node $NodeName
  {
    WindowsFeature ADDSInstall
      {
        Ensure = 'Present'
        Name = 'AD-Domain-Services'
      }
  }

}

create_DomainController

Start-DscConfiguration -ComputerName localhost -Wait -Force`
 -Verbose -path .\create_DomainController -Debug
