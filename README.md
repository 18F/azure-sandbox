# azure-jenkins2-2016

Temporary home for deploying Jenkins 2 into Azure: reliably, repeatably, compliantly


## Local Setup

### Azure Account
Get a Microsoft account at [login.live.com](https://login.live.com).  Next sign into [portal.azure.com](https://portal.azure.com) and create a [Free Trial Subscription](https://portal.azure.com/#blade/Microsoft_Azure_Billing/SubscriptionsBlade).

You'll need your own credit card to set up the trial account.

### Chef Server Account
Create a new account at [api.chef.io](api.chef.io). Visit the Administration tab and download the Starter Kit.

### Local Tools
For OSX:
```
brew install azure-cli
brew cask install chefdk
```

### Launch an Azure VM and provision with Chef
Launch an Azure VM using a canned quick-start template and our own parameters.

0. Authenticate the Azure CLI `azure login`
0. Upload our local cookbooks to your server `knife upload azure-jenkins2-2016/cookbooks`
0. Get templates `git clone git@github.com:Azure/azure-quickstart-templates.git`
0. Copy and customize `azuredeploy.parameters.json.example` from this repo to `azure-quickstart-templates/chef-json-parameters-linux-vm/azuredeploy.parameters.json`. Take care when specifying the `validation_key` to replace newline characters with `\n`.
0. Run the template `./azure-quickstart-templates/azure-group-deploy.sh -a multi-vm-chef-template-ubuntu-vm -l eastus`
0. Connect to your node `ssh <username>@<subdomain>.eastus.cloudapp.azure.com`

### Destroy launched infra
Turn things off at EOD to avoid charges
`azure group delete chef-json-parameters-linux-vm`
