
0. Tear down current jenkins:
```
(Get-AzureVM).Where({ $PSItem.ServiceName -match '18f*'}) | Remove-AzureVM
(Get-AzureService).Where({ $PSItem.ServiceName -match '18f*'})  | Remove-AzureService
Get-ChildItem Cert:/LocalMachine/Root | Where {$_.Subject -eq "CN=18faz-jen1.cloudapp.net"}  | Remove-item
```

1. Create new Vm and cloud service for Jenkins:
```
$computername="18faz-jen1"
$password="correct horse battery staple q@"
.\vms\Create-Jenkins.ps1 $password
```

2. Sync all our DSC PSmodules from C: to network mount I:
If we need more modules, first edit, then run:
```
utils\Get-DSCResourceKit.ps1
```
Check we have I: mounted:
```
Get-WMIObject -query "Select DeviceID,ProviderName From Win32_MappedLogicalDisk" | select DeviceId,ProviderName
```
Do the sync:
```
.\utils\Sync-Modules.ps1
```

3. Run Base DSC to set up necessary modules, scratch space:
This is needed because other DSC will have things like:
`Import-DscResource -ModuleName @{ModuleName="xSqlServer"; ModuleVersion="2.0.0.0"}`
and that module, xSqlServer, needs to be in place for the run to WORK
```
.\xBaseDSC.ps1
.\Run-AzureDSC -Target $computername -User 18fazure -Password $password -verbose -Dsc ./xBaseDSC
```

4. Now run the Jenkins DSC
```
.\xJenkins.ps1
.\Run-AzureDSC -Target $computername -User 18fazure -Password $password -verbose -Dsc ./xJenkins
```

5. Set endpoint
```
.\utils\Add-JenkinsAzureEndpoint.ps1
```

6. View
http://18faz-jen1.cloudapp.net
