#
# Cookbook Name:: win_workstation
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

#powershell_script 'install_choco' do
#  code 'iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex'
#  not_if 'test-path'
#end

chocolatey_package '7zip'

chocolatey_package 'git' do
  options '--params /GitAndUnixToolsOnPath'
end

# chocolatey_package 'atom'
