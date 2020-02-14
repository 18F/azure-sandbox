$env:path += ";c:\users\peter.burkholder\appdata\local\chefdk\gem\ruby\2.3.0\bin"

$me = "peter.burkholder"

function Sync-From-Home
{
  Robocopy.exe \\TSCLIENT\Projects\18f\azure-sandbox\dsc C:\Users\$me\dsc /e
}

Function Sync-To-Remote
{
  Robocopy.exe \\TSCLIENT\Projects\18f\azure-sandbox\dsc "\\$($remote)\c`$\Users\$($me)\dsc" /e
}
