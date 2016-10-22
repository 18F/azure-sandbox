require 'inspec'

describe file 'c:/' do
  it { should exist }
end

describe windows_feature('AD-Domain-Services') do
   it { should be_installed }
 end
