# Configure a domain controller.

Resources:
- https://foxdeploy.com/2015/04/03/part-iii-dsc-making-our-domain-controller/
- https://gallery.technet.microsoft.com/scriptcenter/xActiveDirectory-f2d573f3

# Converging the tests

# Running inspec manually:

inspec exec test/integration/TLABetaDomainController/create_test.rb \
  -t winrm://pburkholder@ec2-54-209-75-78.compute-1.amazonaws.com --password 'password'
