Some sample scripts for getting started with DSC in Azure.

**See the Github project WIKI for lots more info on DSC**

To make these as generally applicable as possible, they are developed in Classic aka Azure Service Manager (ASM) mode. For Azure cli, get started with:

```
azure config mode asm
azure account download # D/L something like Free\ Trial-date-credentials.publishsettings
azure account import ~/Downloads/Free\ Trial-date-credentials.publishsettings
rm ~/Downloads/Free\ Trial-date-credentials.publishsettings
azure account list
azure vm list
```

For collaboration purposes, the relevant files are being developed
in the wiki, and demonstrate how to set up a Win2012R2 box as a PS/DSC workstation
and connect/manage nodes in Azure.

* https://github.com/18F/azure-sandbox/wiki/Azure-Desktop-with-Chocolatey
* https://github.com/18F/azure-sandbox/wiki/ssh-and-git-in-Windows
* https://github.com/18F/azure-sandbox/wiki/Azure-and-PSRemote
* https://github.com/18F/azure-sandbox/wiki/remote-dsc-in-azure


About some of these files:
- Get-DSCResourceKit.ps1: Install DSC resources
- New-ExampleAzure.ps1: Shows how to connect to a fresh VM and configure it
  with DSC over a CIM session
- SCDPM-SeperateSQL.ps1: WIP to configure a SQLServer for use with SCCM,
  copied from xSCDPM/Examples
- SCDPM-SingleServer.ps1: Ditto - only it seems that this script may be
  innately unworkable.
- vms/init.ps1: Stand up a VM with Powershell
- washere.ps1: An inanely simple DSC Demo.


Notes about using DSC w/ Azure
- One gotcha is that the target node is going to need to get remote resources.
- So one way of doing that is mount some Azure FileStore as a UNC share on the workstation computer, and copying all of "C:\Program Files\WindowsPowerShell\modules" to I:\psmodules (and thence to the target machines)
  - Likewise for the install media
- It turns out that the target node does not need any Azure Powershell modules installed, it just needs to run:
```
net use i: \\18fazsandbox2.file.core.windows.net\install  $using:StorageKey /user:18fazsandbox2 /persistent:yes
```
- Logging in via `Enter-PSSession` will not see the net install, but it's there for DSC use
- The use of `cmdkey` to persist credentials for net use did not work for me, the output of `net use /list` on the target machine was always empty.
-
