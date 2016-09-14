# Jenkins on Azure with tests

Follow the steps here to
- Launch and configure Jenkins locally and run tests
- Launch and configure Jenkins in Azure

## Local Tools

- Install the Azure CLI: `brew install azure-cli`
- Download and install the latest [Chef DevelopmentKit](https://downloads.chef.io/chef-dk/)
- Virtualbox: `brew cask install virtualbox`
- Download and install the latest [Docker Toolbox](https://www.docker.com/products/docker-toolbox)
- Install Vagrant: `brew cask install vagrant`
- Install Virtualbox: `brew cask install virtualbox`

For some reason the Homebrew(`brew`) versions of `chefdk` and `docker` didn't work for me.

## Local Jenkins on Docker for testing.

Launch and configure Jenkins locally, into Docker and run [Kitchen](https://docs.chef.io/kitchen.html) tests

0. Start `Kitematic` app that comes with the Docker Toolbox. After Kitematic starts the Docker VM you can quit the app.
0. put docker in your ENV `eval $(docker-machine env default)`
0. I needed a couple gems, so `bundle install`
0. Tell kitchen about our configs`export KITCHEN_LOCAL_YAML=.kitchen.dokken.yml`
0. `cd cookbooks/tla_jenkins`
0. `kitchen list`
0. `kitchen create`, `kitchen destroy` if you wish
0. `kitchen list` again to prove it's running
0. `knife cookbook list`
0. `berks upload` to upload cookbook dependencies with [Berkshelf](http://berkshelf.com/)
0. `knife cookbook list` again to prove uploads
0. `kitchen verify`
0. `kitchen converge`
0. `kitchen test`

## Launch Jenkins in Azure
0. `berks upload` to upload to chef server
0. Add our recipe to the Azure example `chef-json-parameters-linux-vm/azuredeploy.parameters.json`.  Like this: `recipe[motd],recipe[tla_jenkins]`
0. Run the example template `cd azure-quickstart-templates && ./azure-group-deploy.sh -a chef-json-parameters-linux-vm -l eastus`
0. Jenkins should be running on port 8080

### Destroy launched infra
Turn things off at EOD to avoid charges
`azure group delete chef-json-parameters-linux-vm`
