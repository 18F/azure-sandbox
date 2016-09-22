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
