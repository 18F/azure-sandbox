# Configures a simple stand-alone DomainController
# and adds a few users

# References:
# - https://gallery.technet.microsoft.com/scriptcenter/xActiveDirectory-f2d573f3
# - https://foxdeploy.com/2015/03/20/part-i-building-an-ad-domain-testlab-with-dsc/
# - https://foxdeploy.com/2015/04/03/part-iii-dsc-making-our-domain-controller/

# Steps
# - Need a windows workstation (win_workstation cookbook) from which to run kitchen-dsk (maybe)
#   -
# - Create a base image with WMF5 installed
#   - Instantiate Win2012r2 image and login
#   - Start Admin powershell
#   - `iwr https://chocolatey.org/install.ps1 | iex`
#   - Start new admin powershell
#   - `choco install powershell`
#   - Restart
#   - Create AMI from EC2 console.....
