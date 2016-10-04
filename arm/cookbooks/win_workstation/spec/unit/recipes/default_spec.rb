#
# Cookbook Name:: win_workstation
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'win_workstation::default' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner= ChefSpec::SoloRunner.new(platform: 'windows', version: '2012R2')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to be
    end

#    it 'installs chocolatey' do
#      expect(chef_run).to run_powershell_script(/choco/)
#    end

#    it 'adds atom' do
#      expect(chef_run).to install_chocolatey_package('atom')
#    end

    it 'adds git' do
      expect(chef_run).to install_chocolatey_package('git')
    end
  end
end
