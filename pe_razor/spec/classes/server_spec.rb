require 'spec_helper'

describe 'pe_razor::server' do
  before :each do
    @facter_facts = {
        'operatingsystem'           => 'RedHat',
        'operatingsystemmajrelease' => '6',
        'pe_razor_server_version'   => '1.0.0.70',
    }
    @params = {
        'dbpassword'          => 'strongPassword1234',
        'microkernel_url'     => 'https://example.com/microkernel.tar.gz',
        'pe_tarball_base_url' => 'https://example.com/pe.tar.gz',
        'server_http_port'    => 8150,
        'server_https_port'   => 8151,
    }
  end

  let(:params) { @params }
  let(:facts) { @facter_facts }

  context 'with valid parameters' do
    it { should contain_class('pe_razor::server::config').that_requires('Package[pe-razor-server]') }
  end
end
