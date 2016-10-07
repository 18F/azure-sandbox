#include_recipe 'powershell::powershell5'
windows_package("Windows Management Framework Core 5.0") do
         provider Chef::Provider::Package::Windows
         action [:install]
         retries 0
         retry_delay 2
         source "https://download.microsoft.com/download/2/C/6/2C6E1B4A-EBE5-48A6-B225-2D2058A9CEFB/Win8.1AndW2K12R2-KB3134758-x64.msu"
         checksum "bb6af4547545b5d10d8ef239f47d59de76daff06f05d0ed08c73eff30b213bf2"
         installer_type :custom
         options "/quiet /norestart"
         timeout 600
         success_codes [0, 42, 127, 3010, 2359302]
         package_name "Windows Management Framework Core 5.0"
end


powershell_module 'PSReadline'
