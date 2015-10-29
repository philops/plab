require 'spec_helper'

describe 'ca_master', :type => :host do
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
    }
  end

  let(:facts) { @facter_facts }
  let(:pre_condition) {}

  it { should satisfy_all_relationships }

  context "when compiled" do
    it { should contain_pe_concat__fragment('puppetserver certificate-authority-service') }
    it { should contain_pe_hocon_setting('certificate-authority.certificate-status.client-whitelist').with_value(['pe-internal-dashboard']) }
    it { should_not contain_pe_hocon_setting('certificate-authority.proxiy-config') }
    it do
      should contain_pe_hocon_setting('certificate-authority.proxy-config.proxy-target-url')
        .with_ensure('absent')
    end
    it do
      should contain_pe_hocon_setting('certificate-authority.proxy-config.ssl-opts.ssl-cert')
        .with_ensure('absent')
    end
    it do
      should contain_pe_hocon_setting('certificate-authority.proxy-config.ssl-opts.ssl-key')
        .with_ensure('absent')
    end
    it do
      should contain_pe_hocon_setting('certificate-authority.proxy-config.ssl-opts.ssl-ca-cert')
        .with_ensure('absent')
    end
  end

end
