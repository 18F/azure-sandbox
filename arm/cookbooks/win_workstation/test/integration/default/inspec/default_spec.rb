require 'inspec'

describe file('c:/motd.txt') do
  it { should exist }
end
