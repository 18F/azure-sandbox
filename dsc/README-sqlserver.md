
How I tried to run it, got error that .NeT 3.5 not installed

```
J:\SQLServer2014SP2\Source\setup.exe /QUIET /ACTION=Install /FEATURES=SQLEngine /INSTANCENAME=MSSQLSERVER /IACCEPTSQLSERVERLICENSETERMS
/SqlSyadminAccounts="18fazure"

```

What I got from:

```
$Features = "SQLEngine"
$SQLInstanceName = "SCOMSqlServer"

xSqlServerSetup $SQLInstanceName
{
    DependsOn = "[WindowsFeature]NET-Framework-Core"
    SourcePath = "i:\SQLServer2014SP2"
    SetupCredential = $InstallerServiceAccount  #18fazure . password
    InstanceName = $SQLInstanceName
    Features = $Features
}
```
Leads to:
```
[[xSQLServerSetup]SCOMSqlServer] Path: i:\SQLServer2014SP2\Source\setup.exe
[[xSQLServerSetup]SCOMSqlServer] Arguments: /Quiet="True" /IAcceptSQLServerLicenseTerms="True" /Action="Install"
/AGTSVCSTARTUPTYPE=Automatic /InstanceName="SCOMSQLSERVER" /Features="SQLENGINE" /SQLSysAdminAccounts="18fazure"
```

And then hangs. I think the sticker is the /AGTSVCSTARTUPTYPE --


From the CLI, tried again with:

```
J:\SQLServer2014SP2\Source\setup.exe /QUIET /ACTION=Install /FEATURES=SQLEngine /INSTANCENAME=MSSQLSERVER /IACCEPTSQLSERVERLICENSETERMS /SqlSyadminAccounts="18fazure"
```

and it worked since DSC installed .NET 3.5. Completion didn't show a service running:

```
Stopped  SQLBrowser         SQL Server Browser
Stopped  SQLSERVERAGENT     SQL Server Agent (MSSQLSERVER)
```

But RunDiscovery came out OK,  `...Setup.exe /q /action=RunDiscovery` completed with
```
PS C:\Program Files\Microsoft SQL Server\120\Setup Bootstrap\Log> more .\Summary.txt
Overall summary:
  Final result:                  Passed
  Exit code (Decimal):           0
  Start time:                    2016-09-29 01:32:51
  End time:                      2016-09-29 01:33:00
  Requested action:              RunDiscovery

Machine Properties:
  Machine name:                  18FAZ-SQL1
  Machine processor count:       2
  OS version:                    Windows Server 2012
  OS service pack:
  OS region:                     United States
  OS language:                   English (United States)
  OS architecture:               x64
  Process architecture:          64 Bit
  OS clustered:                  No

Product features discovered:
  Product              Instance             Instance ID                    Feature
uage             Edition              Version         Clustered  Configured
  SQL Server 2014      MSSQLSERVER          MSSQL12.MSSQLSERVER            Database Engine Services
                 Enterprise Evaluation Edition 12.2.5000.0     No         Yes

Package properties:
  Description:                   Microsoft SQL Server 2014
  ProductName:                   SQL Server 2014
  Type:                          RTM
  Version:                       12
  SPLevel:                       0
  Installation location:         J:\SQLServer2014SP2\Source\x64\setup\
  Installation edition:

User Input Settings:
  ACTION:                        RunDiscovery
  CONFIGURATIONFILE:
  ENU:                           true
  HELP:                          false
  IACCEPTSQLSERVERLICENSETERMS:  false
  INDICATEPROGRESS:              false
  QUIET:                         true
  QUIETSIMPLE:                   false
  UIMODE:                        Normal
  X86:                           false

  Configuration file:            C:\Program Files\Microsoft SQL Server\120\Setup Bootstrap\Log\20160929_013251\Confi tionFile.ini
  ```

Note the invocations of `setup.exe` generates `configurationFile.ini` which could
be used to make further installs.
