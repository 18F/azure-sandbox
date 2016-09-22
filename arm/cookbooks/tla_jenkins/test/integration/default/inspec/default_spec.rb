require 'inspec'

describe file('/') do
  it { should exist }
end
