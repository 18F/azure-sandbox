#
# Cookbook Name:: tla_jenkins
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'tla_jenkins::default' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to be
    end

    it 'installs jenkins::master from package' do
      expect(chef_run).to include_recipe('jenkins::master')
    end
  end
end
