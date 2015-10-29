require 'spec_helper'

describe 'pe_razor::server::repo' do
  before :each do
    @platform_tag = 'el-7-x86_64'
    @file_name = "puppet-enterprise-4.0.0-el-7-x86_64"

    @params = {
      'target'               => '/opt/puppetlabs/server/data/razor-server',
      'pe_tarball_base_url'  => "pm.pl.com/puppet-enterprise",
    }

  end

  let(:params) { @params }

  context 'with valid parameters' do
    it { should contain_exec('unpack the razor repo').with_timeout(3600) }
    it { should contain_yumrepo('pe-razor').with(
      :baseurl  => 'file:///opt/puppetlabs/server/data/razor-server',
      :enabled  => 1,
      :gpgcheck => 0,
    )}
  end
end
