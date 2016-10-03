#
# Cookbook Name:: motd
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
#

file 'c:/motd.txt' do
  content "Welcome to Azure\n"
end
