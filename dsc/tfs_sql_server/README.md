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

## Configs for next install

This install was two steps, first to install base server, then to add the FULLTEXT feature required for TFS.

The two generate configuration.ini files are in ./Logs-20161108 directory
