require 'spec_helper'

describe 'pe_razor::server::config' do
  before :each do
    @facter_facts = {
      'operatingsystem'           => 'RedHat',
      'operatingsystemmajrelease' => '6',
      'pe_razor_server_version'   => '1.0.0.66',
    }
    @params = {
      'dbpassword' => 'strongPassword1234',
    }
  end

  let(:params) { @params }
  let(:facts) { @facter_facts }

  context 'with valid parameters' do
    it { should contain_file('/opt/puppetlabs/server/data/razor-server').with(
      :ensure => 'directory',
      :owner  => 'root'
    ) }
    it { should contain_file('/etc/puppetlabs/razor-server').with(
      :ensure => 'directory',
      :owner  => 'pe-razor',
      :mode   => '0640',
    ) }
    it { should contain_file('/opt/puppetlabs/server/data/razor-server/repo').with(
      :ensure => 'directory',
      :owner  => 'pe-razor',
      :mode   => '0755',
    ) }
    it { should contain_file('/etc/puppetlabs/razor-server/config.yaml').with_content(/database_url.*password=strongPassword1234'/) }
    it { should contain_file('/opt/puppetlabs/server/apps/razor-server/config-defaults.yaml').with_content(/database_url.*password=strongPassword1234'/) }
    it { should contain_file('/etc/puppetlabs/razor-server/shiro.ini') }
  end
end
