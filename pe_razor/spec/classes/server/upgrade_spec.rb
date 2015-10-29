require 'spec_helper'

describe 'pe_razor::server::upgrade' do
  before :each do
    @facter_facts = {
        'operatingsystem'           => 'RedHat',
        'operatingsystemmajrelease' => '6',
        'pe_razor_server_version'   => '1.0.0.70',
    }
    @params = {
        'pe_tarball_base_url' => 'https://example.com/pe.tar.gz',
    }
  end

  let(:params) { @params }
  let(:facts) { @facter_facts }

  context 'with valid parameters' do
    context 'removing the upgrade.bash script' do
      it { should contain_file('/opt/puppet/razor/upgrade').with_ensure(:absent).with_force(:true) }
      it { should contain_file('/opt/puppet/razor/upgrade/upgrade.bash').with_ensure(:absent)}
      it { should contain_file('/opt/puppet/razor/upgrade/pe-code-migration.rb').with_ensure(:absent)}
    end
    context 'creating the upgrade.bash script' do
      before :each do
        @facter_facts['pe_razor_server_version'] = '1.0.0.0'
      end
      it { should contain_file('/opt/puppet/razor/upgrade').with_ensure(:directory).with_force(:true) }
      it { should contain_file('/opt/puppet/razor/upgrade/upgrade.bash').with_ensure(:file)}
      it { should contain_file('/opt/puppet/razor/upgrade/pe-code-migration.rb').with_ensure(:file)}
    end
  end
end

