# Azure Templates
Cribbed from https://github.com/Azure/azure-quickstart-templates

## Usage





## Using with KeyVault

```
$ azure group create KVexample eastus
$ azure provider list | grep KeyVault
data:    Microsoft.KeyVault                      NotRegistered

$ azure keyvault create --vault-name KV01 --resource-group KVexample --location eastus
info:    Executing command keyvault create
+ Checking pre-condition
+ Creating vault KV01
info:    Created vault KV01
data:    id "/subscriptions/34faf229-f395-4c97-9657-af92de86c679/resourceGroups/KVexample/providers/Microsoft.KeyVault/vaults/KV01"
data:    name "KV01"
data:    type "Microsoft.KeyVault/vaults"
data:    location "eastus"
data:    properties sku family "A"
data:    properties sku name "Standard"
data:    properties tenantId "6f3119cc-09f0-41a8-a773-93b32b63f9da"
data:    properties accessPolicies 0 tenantId "6f3119cc-09f0-41a8-a773-93b32b63f9da"
data:    properties accessPolicies 0 objectId "65b3a2d2-ce96-4e35-b087-f3a71418605e (upn=peter.burkholder_gsa.gov#EXT#@peterburkholdergsa.onmicrosoft.com)"
data:    properties accessPolicies 0 permissions keys 0 "get"
data:    properties accessPolicies 0 permissions keys 1 "create"
data:    properties accessPolicies 0 permissions keys 2 "delete"
data:    properties accessPolicies 0 permissions keys 3 "list"
data:    properties accessPolicies 0 permissions keys 4 "update"
data:    properties accessPolicies 0 permissions keys 5 "import"
data:    properties accessPolicies 0 permissions keys 6 "backup"
data:    properties accessPolicies 0 permissions keys 7 "restore"
data:    properties accessPolicies 0 permissions secrets 0 "all"
data:    properties enabledForDeployment false
data:    properties vaultUri "https://KV01.vault.azure.net"
warn:    This vault does not support HSM-protected keys. Please refer to http://go.microsoft.com/fwlink/?linkid=512521 for the vault service tiers.
warn:    When creating a vault, specify the --sku parameter to select a service tier that supports HSM-protected keys.
info:    keyvault create command OK
```

KeyVault is like a bucket, having a global namespace. See https://KV01.vault.azure.net

```
$ azure keyvault secret set --vault-name 'KV01' --secret-name 'azjen0AdminPassword' --value 'MWoGM9dJN4Refc'
info:    Executing command keyvault secret set
+ Creating secret https://KV01.vault.azure.net/secrets/azjen0AdminPassword
info:    keyvault secret set command OK
```

That was easy. Now, from https://azure.microsoft.com/en-us/documentation/articles/resource-manager-keyvault-parameter/
> To create key vault that can be referenced from other Resource Manager templates, you must set the enabledForTemplateDeployment property to true, and you must grant access to the user or service principal that will execute the deployment which references the secret.

List ActiveDirectory users and service principals with `azure ad user list` and `azure ad sp list`.
The service principal I created earlier, `exampleapp` was used https://github.com/Azure-Samples/resource-manager-ruby-template-deployment and only for the Ruby-enabled deployment. The ARM stuff has been done as myself.

In the future we'll probably want to delegate ARM builds to service principal. However, since I'm executing the ARM template, and I can read the secret, presumably my template can read it too.

At this point, ` azure keyvault show KV01` shows that the vault is NOT enabledForDeployment or enabledForTemplateDeployment. So, per https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-key-vault-setup

```
azure keyvault set-policy KV01  --enabled-for-template-deployment true
```

Now, replace this in `chef-json-parameters-linux-vm/azuredeploy.parameters.json`:

```
"adminPassword": {
  "value": "MWoGM9dJN4Refc"
},
```

With

```
"adminPassword": {
  "reference": {
    "keyVault": {
      "id": "/subscriptions/34faf229-f395-4c97-9657-af92de86c679/resourceGroups/KVexample/providers/Microsoft.KeyVault/vaults/KV01"
    },
    "secretName": "azjen0AdminPassword"
  }
```

Similarly for validation-key:

```
cat ~/.ssh/pburkholder_gsa | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g' > t
azure keyvault secret set --vault-name 'KV01' --secret-name 'validation-key' --file t
```

Now, let's make it so:

```
azure group delete chef-json-parameters-linux-vm
./azure-group-deploy.sh -a chef-json-parameters -l eastus
```
