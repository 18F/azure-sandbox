# azure-jenkins2-2016

Temporary home for deploying Jenkins 2 into Azure: reliably, repeatably, compliantly


## Local Setup

We are currently signing up for Azure and ChefServer services individually.
### Azure Account
Get a Microsoft account at [login.live.com](https://login.live.com).  Next sign into [portal.azure.com](https://portal.azure.com) and create a [Free Trial Subscription](https://portal.azure.com/#blade/Microsoft_Azure_Billing/SubscriptionsBlade).

You'll need your own credit card to set up the trial account.

Install the Azure CLI and log in
```
brew install azure-cli
azure login
```

If you have problems with `azure` commands, first try to update the azure-cli (`brew upgrade azure-cli`).  It can be buggy and seems to be changing fast.

### Chef Server Account
Create a new account at [api.chef.io](api.chef.io). Visit the Administration tab and download the Starter Kit.

Download and install the [latest Chef DevelopmentKit](https://downloads.chef.io/chef-dk/)

### Other tools to install
0. Download and install the latest [Docker Toolbox](https://www.docker.com/products/docker-toolbox)
0. Start `Kitematic` app that comes with the Docker Toolbox. After Kitematic starts the Docker VM you can quit the app.
0. Install Vagrant: `brew cask install vagrant`
0. Install Virtualbox: `brew cask install virtualbox`

## Usage

### Chef Server

Make sure that our cookbooks are uploaded to your ChefServer. One-by-one for now.
```
cd cookbooks/motd && berks upload
cd ../..
cd cookbooks/tla_jenkins && berks upload
```

### Testing Cookbooks

Launch, configure, and run [Kitchen](https://docs.chef.io/kitchen.html) tests locally in Docker.

```
bundle install                                  # Install necessary gems
eval $(docker-machine env default)              # Put Docker in your ENV
export KITCHEN_LOCAL_YAML=.kitchen.dokken.yml   # Tell Kitchen about our configs
knife cookbook list                             # To verify cookbooks are uploaded
cd cookbooks/tla_jenkins
kitchen create
kitchen list
kitchen verify
kitchen converge
kitchen test
```

### Launch Jenkins in Azure

**Cribbed from https://github.com/Azure/azure-quickstart-templates**

#### Configure
Copy `azuredeploy.parameters.json.example` to `azuredeploy.parameters.json` and customize.  Take care when specifying the `validation_key` to replace newline characters with `\n`.

#### Run
```
cd azure-templates
./azure-group-deploy.sh -a chef-json-parameters-linux -l eastus
```

SSH to the node with values from your deploy parameters
`ssh <username>@<subdomain>.eastus.cloudapp.azure.com`

Jenkins should be running at `subdomain.eastus.cloudapp.azure.com:8080`

#### Destroy
Turn things off at EOD to avoid charges
`azure group delete chef-json-parameters-linux-vm`

### MS KeyVault Notes
KeyVault is like a bucket, having a global namespace. We can keep secrets there.

#### Create a vault
```
azure provider register Microsoft.KeyVault
azure group create KVexample eastus

VAULT=<some_globally_unique_name>
azure keyvault create --vault-name $VAULT --resource-group KVexample --location eastus
```

#### Set a secret
```
KEY=fake-password
VALUE=pa$$w0rd
azure keyvault secret set --vault-name $VAULT --secret-name '$KEY' --value '$VALUE'
```

#### Use a secret
Make the secret available to templates with `azure keyvault set-policy $VAULT --enabled-for-template-deployment true`.
We aren't injecting variables into templates yet, so a manual description for template editing:

In `chef-json-parameters-linux-vm/azuredeploy.parameters.json` replace

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
      "id": "/subscriptions/34faf229-f395-4c97-9657-af92de86c679/resourceGroups/KVexample/providers/Microsoft.KeyVault/vaults/$VAULT"
    },
    "secretName": "$KEY"
  }
```

Similarly for validation-key:
```
cat ~/.ssh/pburkholder_gsa | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g' > t
azure keyvault secret set --vault-name '$VAULT' --secret-name 'validation-key' --file t
```

#### Destroy
When you're done delete with `azure group delete KVexample`
