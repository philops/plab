require 'spec_helper'

describe 'pe_nginx' do
  it 'compiles' do
    subject
  end

  it { should contain_package('pe-nginx') }
  it { should contain_service('pe-nginx') }
end
