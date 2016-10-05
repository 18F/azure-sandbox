# motd-windows

# 0. Creates file c:/motd.txt, doesn't currently actually set the MOTD -

That's done with `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\legalnoticecaption`

## Unit testing

`rspec`

## Integration testing

### With vagrant and kitchen-vagrant

Install vagrant
Download the mwrock/Windows2012R2 box with (in a temp directory),

```
vagrant init mwrock/Windows2012R2; vagrant up --provider virtualbox
# make sure it comes up
vagrant destroy
```

Then run a full test:

```
export KITCHEN_LOCAL_YAML=$(pwd)/.kitchen.vagrant.yml
kitchen test
```

This takes: 6m53s

## Set up with kitchen-ec2

Confirm it's installed with `gem list kitchen*`. It should be distributed with the ChefDK

Also, install  AWS tools: `brew install awscli`

Login in AWS, https://18f-sandbox.signin.aws.amazon.com/console

Get you access keys: https://console.aws.amazon.com/iam/home#users/firstname.lastname

Then run `aws configure`

Now create and save an aws SSH key

```
AWSUSER="peter.burkholder.aws"
aws ec2 create-key-pair --key-name $AWSUSER |
   ruby -e "require 'json'; puts JSON.parse(STDIN.read)['KeyMaterial']" > ~/.ssh/$AWSUSER
```

Run the kitchen initialization `kitchen init -D ec2`

Create a security group that allows WinRM and RDP (5985, 3389) from your IP address. I've used Terraform with ../../tools/create_windows_sg (see that README). As a handy aside, to find your default VPC, run:

```
aws ec2 describe-account-attributes
```

Update the local `.kitchen.local.yaml` with your values for:

```
driver:
  aws_ssh_key_id: your_key_id
  instance_type: t2.medium
  security_group_ids: ["sg-d84319a2"]
  subnet_id: subnet-0655c75e

transport:
  username: username
  password: a_password
```

Then run a full test:

```
kitchen test
```

This takes:
  t2.medium: 6m02s, 5m50s
  m3.large: 5m37s, 5m53s


## Set up with kitchen-azurerm

https://github.com/pendrica/kitchen-azurerm

Assumes you have already set up an Azure account.

0. Install gem(s) `/azure-sandbox$ bundle`
0. Install and configure cli `brew install azure-cli && azure login`
0. Follow along here to create a service principal with Contributor permissions: https://github.com/pendrica/kitchen-azurerm#configuration.  For me it looked like:
```
azure ad app create -n kitchen --home-page http://www.contoso.org --identifier-uris https://www.contoso.org/example -p <password>
azure ad sp create -a <AppId from last output>
azure role assignment create --objectId <Object Id from last output> -o Contributor  -c /subscriptions/<subscription_id>/
```
0. Configure Kitchen/azurerm. Easiest is to export some ENV vars. Another option is to use a `~/.azure/config` file, more info see kitchen-azurerm docs.
```
export AZURE_CLIENT_ID="<AppId from above>"
export AZURE_CLIENT_SECRET="<Password from above>"
export AZURE_TENANT_ID="<from `azure account show`>"
export SUBSCRIPTION_ID="<from `azure account list`>"
export KITCHEN_LOCAL_YAML=$(pwd)/.kitchen.local.azure.example.yml
```

0. `kitchen test`.  If this fails trying to delete non-existing resources, `rm -rf .kitchen` and try again.

Benchmarks:

| VM | Cores | Memory | t1 | t2 | t3 |
| -- | -- | -- | -- | -- | -- |
| Standard_D1 | 1 | 3.5G | 9:00 | 9:15 | 7:35 |
| Standard_D2 | 2 | 7G | 8:01 | 9:53 | 8:04 |
