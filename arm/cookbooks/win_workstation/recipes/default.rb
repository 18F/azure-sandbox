#
# Cookbook Name:: win_workstation
# Recipe:: default
#

include_recipe 'chocolatey'

chocolatey_package '7zip'

chocolatey_package 'git' do
  options '--params "/GitAndUnixToolsOnPath /NoAutoCrlf"'
end

chocolatey_package 'atom'
