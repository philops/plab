require 'spec_helper'

describe 'puppet_enterprise::puppetdb' do
  before :all do
    @facter_facts = {
      'osfamily'          => 'Debian',
      'operatingsystem'   => 'Debian',
      'fqdn'              => 'puppetdb.local.domain',
    }

    @params = {
      'certname'            => 'puppetdb.local.domain',
      'database_host'       => 'database.local.domain',
      'database_password'   => 'password',
      'cert_whitelist_path' => '/etc/puppetlabs/puppetdb/certificate-whitelist',
    }
  end

  let(:facts) { @facter_facts }
  let(:params) { @params }
  let(:sharedir) { '/opt/puppet/share/puppet-dashboard' }
  let(:ssldir) { '/etc/puppetlabs/puppet/ssl' }

  context "when managing packages" do
    it { should contain_package('pe-java') }
    it { should contain_package('pe-puppetdb') }
  end

  context "when managing default java_args" do
    it { should contain_pe_ini_subsetting("pe-puppetdb_'Xmx'").with_value( '256m' ) }
    it { should contain_pe_ini_subsetting("pe-puppetdb_'Xms'").with_value( '256m' ) }
  end

  context "wth custom java_args" do
    before(:all) { @params['java_args'] = { 'Xmx' => '128m' } }
    it { should contain_pe_ini_subsetting("pe-puppetdb_'Xmx'").with(
     'value'   => '128m',
     'require' => 'Package[pe-puppetdb]',
    ) }
  end

  context "managing service defaults" do
    it { should contain_pe_ini_setting('pe-puppetdb initconf java_bin')
         .with_setting('JAVA_BIN')
         .with_value('"/opt/puppetlabs/server/bin/java"')
         .with_path('/etc/default/pe-puppetdb') }
    it { should contain_pe_ini_setting('pe-puppetdb initconf user')
         .with_setting('USER')
         .with_value('pe-puppetdb') }
    it { should contain_pe_ini_setting('pe-puppetdb initconf group')
         .with_setting('GROUP')
         .with_value('pe-puppetdb') }
    it { should contain_pe_ini_setting('pe-puppetdb initconf install_dir')
         .with_setting('INSTALL_DIR')
         .with_value('"/opt/puppetlabs/server/apps/puppetdb"') }
    it { should contain_pe_ini_setting('pe-puppetdb initconf config')
         .with_setting('CONFIG')
         .with_value('"/etc/puppetlabs/puppetdb/conf.d"') }
    it { should contain_pe_ini_setting('pe-puppetdb initconf bootstrap_config')
         .with_setting('BOOTSTRAP_CONFIG')
         .with_value('"/etc/puppetlabs/puppetdb/bootstrap.cfg"') }
    it { should contain_pe_ini_setting('pe-puppetdb initconf service_stop_retries')
         .with_setting('SERVICE_STOP_RETRIES')
         .with_value('60') }
    it { should contain_pe_ini_setting('pe-puppetdb initconf start_timeout')
         .with_setting('START_TIMEOUT')
         .with_value('120') }

    context "with overrides" do
      before(:each) do
        @params['service_stop_retries'] = 12345
        @params['start_timeout'] = 67890
      end

      it { should contain_pe_ini_setting('pe-puppetdb initconf service_stop_retries')
           .with_setting('SERVICE_STOP_RETRIES')
           .with_value('12345') }
      it { should contain_pe_ini_setting('pe-puppetdb initconf start_timeout')
           .with_setting('START_TIMEOUT')
           .with_value('67890') }
    end
  end

  it { should contain_class('puppet_enterprise::puppetdb::database_ini') }
  it { should contain_class('puppet_enterprise::puppetdb::jetty_ini') }
  it { should contain_class('puppet_enterprise::puppetdb::service') }
  it { should contain_file('/var/log/puppetlabs/puppetdb/').with(
    'ensure' => 'directory',
    'owner'  => 'pe-puppetdb',
    'group'  => 'pe-puppetdb',
    'mode'   => '0640'
  )}
  it { should contain_file('/var/log/puppetlabs/puppetdb/puppetdb.log').with(
    'ensure'  => 'present',
    'owner'   => 'pe-puppetdb',
    'group'   => 'pe-puppetdb',
    'mode'    => '0640',
  )}
end
