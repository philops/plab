require 'spec_helper'

describe 'default' do
  it 'should work' do
    is_expected.to contain_pe_java_ks('puppetca:truststore')
  end
end
