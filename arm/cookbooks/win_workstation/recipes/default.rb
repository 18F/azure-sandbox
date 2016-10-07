#
# Cookbook Name:: win_workstation
# Recipe:: default
#

include_recipe 'chocolatey'

chocolatey_package 'git' do
  options '--params "/GitAndUnixToolsOnPath /NoAutoCrlf"'
end

%w(7zip atom chefdk).each do |package|
  chocolatey_package package
end

include_recipe 'win_workstation::posh'
