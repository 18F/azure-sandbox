#
# Cookbook Name:: motd
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require_relative '../../spec_helper'

describe 'motd::default' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    it 'should message for the day' do
      expect(chef_run).to render_file('c:/motd.txt')
    end
  end
end
