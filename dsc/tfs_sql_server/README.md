# Don't do any of this...

... without verifying the hardcoded values in all the scripts and commands


## Set up workstation

- Clone this repo to, say, ~/Projects/dsc
- Get RDP access to remote jumpbox
- Connect to jumpbox while redirecting the ~/Projects directory

## Set up Jumpbox

Copy the redirected files to jumpbox (otherwise you'll get remote exec errors)
with this function:

```
$me=fname.lastname
function Sync-From-Home
{
  Robocopy.exe \\TSCLIENT\Projects\dsc C:\Users\$me\dsc /e
}
```

Then source the files to set up the rest of the useful functions:

```
source jumpbox/particulars.ps1 (This file is NOT in version control)
source Jumpbox/remote.ps1
sync-from-home
$remote=name-of-tfs-sql-box
sync-to-remote
```

## Missing stepS

- Get the install media and copy to remote


## Connect to tfs-sql-box

*Fix the FIPS issues*

See https://github.com/OneGet/oneget/issues/195.  Solving involves the
steps at the end of that issue (or maybe resolved by now)

The script `strong.ps1` sets the necessary registry settings per that issue.


Install the Prerequisites:

```
./prereqs.ps1
```

Do the install w/ DSC:

```
./dsc_configuration.ps1
```

The above is a bunch of Posh and DSC around:

```
MSSQL2014.exe `
/Quiet="True" /IAcceptSQLServerLicenseTerms="True" /Action="Install" `
/AGTSVCSTARTUPTYPE=Automatic /InstanceName="TFSSQLSERVER" /Features="SQLENGINE" `
/SqlSysAdminAccounts="domain\peter.burkholder"
```

# (Random notes, possibly not useful)

Automation steps

## 1 Use DSC to bootstrap to chef

```
Start-DSCConfguration... target system
```

- install cert for Chocolatey install
- install cert for Chocolatey packages
- install microsoft cert
- install cert for Github
- install chef-client from chocolatey

Why do it this way? Typically we would bootstrap to Chef directly over WinRM,
but it would fail w/o the cert for the Chef downloads installed. Since the
only thing we need the Chef cert is for the Chef itself, just skip it and
use Chocolatey, which we'll need extensivly later on anyhow.

Also, this is fully portable to any later installation regime, since we
know LCM will always be there.


## 2 Set up base system with Chef

Not sure yet what goes here


## 3 Install SQLServer for TFS

https://download.microsoft.com/download/6/D/9/6D90C751-6FA3-4A78-A78E-D11E1C254700/SQLServer2014SP2-KB3171021-x64-ENU.exe


Install media and which server version to use:
- There's a Chocolatey package for MSSQl server express: https://chocolatey.org/packages/MsSqlServer2014Express, but it
doesn't have the funtionality we need.
- https://msdn.microsoft.com/en-us/library/dd631889(v=vs.120).aspx has the SQL
  Server requirements for VS. As far as the support matrix for
  TFS/OS/SQLServer, that's at: https://www.visualstudio.com/en-us/docs/setup-admin/requirements
- The DOD STIGs don't have any specific to SQLServer, the general guide can be
  viewed at [STIGViewer Database Security Requirements Guide](https://www.stigviewer.com/stig/database_security_requirements_guide/)

We'll use MSSQL 2014 for best forward compatibility and for some hope of being
old enough for partner agencies

### 3.1 Fetch and attach install media

- Use chef `remote_file` to fetch (we'll need the appropriate cert)
- Mount at I:
  - Moot, as there are only ephemeral URLs for download. We'll have to save
    to //share someplace and copy around
- Install from CLI -- see earlier DSC work on this. The xSQLServerSetup
  resource gets things wrong

```
SQLServer2014SP2\Source\setup.exe
/Quiet="True" /IAcceptSQLServerLicenseTerms="True" /Action="Install"
/AGTSVCSTARTUPTYPE=Automatic /InstanceName="TFSSQLSERVER" /Features="SQLENGINE"
/SqlSysAdminAccounts="domain\peter.burkholder"
```

### 3.2 Set up a TFS User

- Use `xSQLServerLogin` to create user

### 3.3. Set up the required databases TFS_...

- Per https://msdn.microsoft.com/en-us/library/ee248709(v=vs.120).aspx, create
      Tfs_BETADEV/Warehouse and Tfs_BETADEV/Application
  - Although this might be at odds with https://msdn.microsoft.com/en-us/library/ms400720(v=vs.120).aspx


-- Associate
