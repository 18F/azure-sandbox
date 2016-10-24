require 'inspec'

describe file 'c:/' do
  it { should exist }
end

describe windows_feature('AD-Domain-Services') do
   it { should be_installed }
end

# demo of a port range test
describe port.where { protocol =~ /tcp/ && port > 22 && port < 80 } do
  it { should_not be_listening }
end
