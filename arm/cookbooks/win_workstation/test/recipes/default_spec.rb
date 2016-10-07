require 'inspec'

describe package 'git' do
  it { should be_installed }
end

describe package 'atom' do
  it { should be_installed }
end

describe package 'chefdk' do
  it { should be_installed }
end
