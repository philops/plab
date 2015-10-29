require 'spec_helper'

describe 'puppet_enterprise::profile::certificate_authority' do
  before :each do
    @facter_facts = {
      'osfamily'          => 'Debian',
      'operatingsystem'   => 'Debian',
      'lsbmajdistrelease' => '6',
      'puppetversion'     => '3.6.2 (Puppet Enterprise 3.3.0)',
      'is_pe'             => 'true',
      'fqdn'              => 'master.rspec',
      'clientcert'        => 'awesomecert',
      'pe_concat_basedir' => '/tmp/file',
      'processorcount'    => '1',
      'custom_auth_conf'  => 'true',
    }
    @params = {}
  end

  let(:facts)   { @facter_facts }
  let(:confdir) { "/etc/puppetlabs/puppetserver" }
  let(:params)  { @params }


  it { should satisfy_all_relationships }

  context 'client-whitelist certs' do
    context 'default list' do
      it { should contain_pe_hocon_setting('certificate-authority.certificate-status.client-whitelist').with_value(['pe-internal-dashboard']) }
    end

    context 'using custom certs' do
      before :each do
        @params['client_whitelist'] = ['foo', 'bar']
      end

      it { should contain_pe_hocon_setting('certificate-authority.certificate-status.client-whitelist').with_value(['pe-internal-dashboard', 'foo', 'bar']) }
    end
  end

  context 'fileserver.conf' do
    it do
      should contain_augeas('fileserver.conf pe_modules')
        .with_changes([
          "set /files/etc/puppetlabs/puppet/fileserver.conf/pe_modules/path /opt/puppetlabs/server/share/installer/modules",
          "set /files/etc/puppetlabs/puppet/fileserver.conf/pe_modules/allow *",
        ])
        .with_incl('/etc/puppetlabs/puppet/fileserver.conf')
        .with_load_path('/opt/puppetlabs/puppet/share/augeas/lenses/dist')
        .with_lens('PuppetFileserver.lns')
    end

    it do
      pending('rspec 2') do
        should contain_augeas('fileserver.conf pe_modules').that_comes_before('Pe_anchor[puppet_enterprise:barrier:ca]')
      end
    end
  end
end
