
# Source the particulars

. .\particulars.ps1

function Sync-From-Home
{
  Robocopy.exe \\TSCLIENT\Projects\18f\azure-sandbox\dsc C:\Users\$me\dsc /mir
}

Function Sync-To-Remote
{
  Robocopy.exe \\TSCLIENT\Projects\18f\azure-sandbox\dsc $share /mir
}

Function Connect-To-Remote
{
  Enter-PSSession -Credential $credential -ConnectionURI $uri
}

# http://serverfault.com/questions/11879/gaining-administrator-privileges-in-powershell
# Haven't found a way to run these over a PSSession w/o going to an RDP console
function Run-Elevated ($scriptblock) # this doesn't work!!!
{
  # TODO: make -NoExit a parameter
  # TODO: just open PS (no -Command parameter) if $scriptblock -eq ''
  $sh = new-object -com 'Shell.Application'
  $sh.ShellExecute('powershell', "-NoExit -Command $scriptblock", '', 'runas')
}

function Go-CertYourself
{
   Import-Certificate -CertStoreLocation Cert:\LocalMachine\Root .\godaddy2.pem
   Import-Certificate -CertStoreLocation Cert:\LocalMachine\Root .\comodo_ecc.pem
}

$env:chocolateyUseWindowsCompression='false'

function Install-Choco
{
  iwr https://chocolatey.org/install.ps1 | iex
}

function Disable-Firewall
{
  Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
}

function Enable-Firewall
{
  Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
}

function See-Jenkins
{
  irw http://localhost:8080/login   # or in IE: http://hostname:8080/login
}
