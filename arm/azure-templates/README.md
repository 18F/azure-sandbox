# Azure Automation Demo

The README documents the steps I took to get to a demo of:

- create a resource group
- deploy a single instance to that group
  - that instance uses the Azure Automation extension
  - to implement a single resource, e.g. IIS feature.

## Resources

https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-ps-template -- A simple template example

## 1: Create a functional VM from a template

### Follow the steps from microsoft:

1. Copy template json from https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-ps-template to azure-deploy.json
1. The file above expects `adminUsername` and `adminPassword` to be profived as parameters, which I've saved to `parameters.json`
  - Add `parameters.json` to your `.gitignore`
1. Connect to Azure USGov with `az login`
  - Make sure correct cloud is specified in `~/.azure/context_config/default`
1. Create the resource group with location `usgovvirginia`:
```
az group create --name myrg1 --location usgovvirginia
```
1. Implement the template
```
az group deployment create --verbose \
  --resource-group myrg1 \
  --template-file azure-automation-demo/azure-deploy.json \
  --name azautodemo \
  --parameters '@azure-automation-demo/parameters.json'
```
1. It fails with `The storage account named mystorage1 is already taken.`

### Update steps for unique storage account

Storage accounts share a global namespace, so we need to assure that storageaccount name is unique.
Make the following changes to change 'mystorage1' to a variable from `uniquestring`

```
diff --git a/arm/azure-templates/azure-automation-demo/azure-deploy.json b/arm/azure-templates/azure-automation-demo/azure-deploy.json
index f878202..2fe6d99 100644
@@ -8,2 +8,3 @@
  "variables": {
+   "storageAccountName": "[concat(uniquestring(resourceGroup().id), 'azautodemo')]",
    "vnetID":"[resourceId('Microsoft.Network/virtualNetworks','myvn1')]",
@@ -14,3 +15,3 @@
      "type": "Microsoft.Storage/storageAccounts",
-     "name": "mystorage1",
+     "name": "[variables('storageAccountName')]",
      "apiVersion": "2015-06-15",
@@ -71,3 +72,3 @@
        "Microsoft.Network/networkInterfaces/mync1",
-       "Microsoft.Storage/storageAccounts/mystorage1"
+       "[concat('Microsoft.Storage/storageAccounts/', variables('storageAccountName'))]"
      ],
@@ -90,3 +91,3 @@
            "vhd": {
-             "uri": "https://mystorage1.blob.core.windows.net/vhds/myosdisk1.vhd"
+             "uri": "[concat('http://',variables('storageAccountName'),'.blob.core.usgovcloudapi.net/vhds/','osdisk.vhd')]"
            },
```

Note also: the storage account now uses `blob.core.usgovcloudapi.net`

### Now, to get to the Azure Automation point, we'll need a WMF machine

From https://docs.microsoft.com/en-us/azure/automation/automation-dsc-overview:

> It could take up to an hour for the VM to show up.... due to the installation of Windows Management Framework 5.0

We need WMF5+, so we'll substitute in `2016` for `2012-R2`, delete the resource group, and try again. To better signal to my coworkers what I'm doing, we'll use a better resource group name:

```
RG="AzAutomationDemo-PeterB"
az group create --name $RG --location usgovvirginia
az group deployment create --verbose \
  --resource-group $RG \
  --template-file azure-automation-demo/azure-deploy.json \
  --name azautodemo \
  --parameters '@azure-automation-demo/parameters.json'
```

Since templates are convergent, re-running,

```
 az group deployment create   --resource-group AzAutomationDemo-PeterB \
   --template-file azure-automation-demo/azure-deploy.json   --name azautodemo   --parameters \
   '@azure-automation-demo/parameters.json'
```

is a no-op, and updates that deployment info at https://portal.azure.us/#resource/subscriptions/66e4e513-02ab-43e3-bd78-0c2f28a1cdb7/resourceGroups/AzAutomationDemo-PeterB/deployments

## Now add DSC stuff to that image.

From there, let's reference https://github.com/Azure/azure-quickstart-templates/tree/master/dsc-extension-azure-automation-pullserver

For your $RG (resource-group):
- Create an AzureAutomation acccount through the portal that is in your ResourceGroup
- Upload TestConfig.ps1:
```
 configuration TestConfig
 {
     Node WebServer
     {
         WindowsFeature IIS
         {
             Ensure               = 'Present'
             Name                 = 'Web-Server'
             IncludeAllSubFeature = $true

         }
     }

     Node NotWebServer
     {
         WindowsFeature IIS
         {
             Ensure               = 'Absent'
             Name                 = 'Web-Server'

         }
     }
     }
```
- Get the URL and Keys for the automation account from AutomationAccount -> AllSettings -> Keys (see below)

The purpose of the template is to add DSC to an existing VM, I'll copy the content of `azuredeploy.json` to `add-azure-auto.json` and parameters to `add-azure-auto.parameters.json`. In that file, change:

* vmName, myvm1
* registrationUrl, https://usge-agentservice-prod-1.azure-automation.us/accounts/1lasldfjljaslfdj-asldfjk-asdlfjalskdfj lk
* registrationKey, RZR;sldfkja;lsdfja;lsdfj;aljf;as;ldfjvS==
* nodeConfigurationName, "TestConfig.WebServer"

The above are all for the AzureAutomation Account created in the same ResourceGroup as my vm/deployment.

```
 az group deployment create   --resource-group AzAutomationDemo-PeterB --template-file \
   azure-automation-demo/add-azure-auto.json   --name azautodemo   --parameters \
   '@azure-automation-demo/add-azure-auto.parameters.json'
```

That failed, trying with new deploy name:

```
az group deployment create   --resource-group AzAutomationDemo-PeterB --template-file \
  azure-automation-demo/add-azure-auto.json   --name azautodemodsc   --parameters \
  '@azure-automation-demo/add-azure-auto.parameters.json'
```

Oops, had the `nodeConfigurationName` incorrect, trying again with `TestConfig.WebServer` instead of just `WebServer'`

THAT WORKED!
