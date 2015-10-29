require 'spec_helper'

describe 'puppet_enterprise::trapperkeeper::console_services' do
  before :all do
    @facter_facts = {
      'osfamily'          => 'Debian',
      'operatingsystem'   => 'Debian',
      'lsbmajdistrelease' => '6',
      'puppetversion'     => '3.6.2 (Puppet Enterprise 3.3.0)',
      'is_pe'             => 'true',
      'fqdn'              => 'classifier_ui.rspec',
      'clientcert'        => 'awesomecert',
      'pe_concat_basedir' => '/tmp/file',
    }

    @params = {
      'proxy_idle_timeout'    => 60,
      'puppetdb_host'         => 'puppetdb.rspec',
      'master_host' => 'master.rspec',
      'puppetdb_port'         => 54321,
      'dashboard_port'        => 443,
      'classifier_host'       => 'classifier.rspec',
      'classifier_port'       => '4242',
      'classifier_url_prefix' => '/classifier-api',
      'rbac_host'             => 'rbac.rspec',
      'rbac_port'             => '4244',
      'rbac_url_prefix'       => '/rbac-api',
      'activity_host'         => 'activity.rspec',
      'activity_port'         => '4243',
      'activity_url_prefix'   => '/activity-api',
      'client_certname'       => 'classifier_ui.rspec',
      'status_proxy_enabled'  => false,
    }
  end

  let(:facts) { @facter_facts }
  let(:params) { @params }
  let(:title) { 'console-services' }

  context "when the parameters are valid" do
    it { should contain_file("/etc/puppetlabs/console-services/conf.d/console.conf").with(:owner => "pe-console-services",
                                                                                             :group => "pe-console-services",
                                                                                             :mode => "0640") }
    it { should contain_pe_hocon_setting("#{title}.console.assets-dir").with_value('dist') }
    it { should contain_pe_hocon_setting("#{title}.console.rbac-server").with_value('http://rbac.rspec:4244/rbac-api') }
    it { should contain_pe_hocon_setting("#{title}.console.classifier-server").with_value('http://classifier.rspec:4242/classifier-api') }
    it { should contain_pe_hocon_setting("#{title}.console.activity-server").with_value('http://activity.rspec:4243/activity-api') }
    it { should contain_pe_hocon_setting("#{title}.console.puppetdb-server").with_value('https://puppetdb.rspec:54321') }
    it { should contain_pe_hocon_setting("#{title}.console.certs.ssl-key").with_value('/opt/puppetlabs/server/data/console-services/certs/classifier_ui.rspec.private_key.pem') }
    it { should contain_pe_hocon_setting("#{title}.console.certs.ssl-cert").with_value('/opt/puppetlabs/server/data/console-services/certs/classifier_ui.rspec.cert.pem') }
    it { should contain_pe_hocon_setting("#{title}.console.certs.ssl-ca-cert").with_value('/etc/puppetlabs/puppet/ssl/certs/ca.pem') }
    it { should contain_pe_hocon_setting("#{title}.console.dashboard-server").with_value('http://127.0.0.1:443') }
    it { should contain_pe_hocon_setting("#{title}.console.proxy-idle-timeout").with_value('60') }
    #it { should contain_pe_hocon_setting("#{title}.console.cookie-secret-key").with_value(%r[(.){16}]) }

    it { should contain_file("/etc/puppetlabs/console-services/conf.d/console_secret_key.conf").with(:owner => "pe-console-services",
                                                                                                      :group => "pe-console-services",
                                                                                                      :mode => "0640",
                                                                                                      :replace => false,
                                                                                                      :content => %r[(.){16}]) }

    it { should contain_pe_concat__fragment('console-services pe-console-ui-service') }
    it { should contain_pe_concat__fragment('console-services pe-console-auth-ui-service') }
    it { should contain_pe_concat__fragment('console-services jetty9-service') }
    it { should contain_pe_concat__fragment('console-services rbac-authn-service') }
    it { should contain_pe_concat__fragment('console-services rbac-authn-middleware') }
    it { should contain_pe_concat__fragment('console-services rbac-service') }
    it { should contain_pe_concat__fragment('console-services rbac-status-service') }
    it { should contain_pe_concat__fragment('console-services rbac-storage-service') }
    it { should contain_pe_concat__fragment('console-services rbac-authz-service') }
    it { should contain_pe_concat__fragment('console-services rbac-authn-service') }
    it { should contain_pe_concat__fragment('console-services webrouting-service') }
    it { should contain_pe_concat__fragment('console-services status-service') }
    it { should_not contain_pe_concat__fragment('console-services status-proxy-service') }
    context "when status proxy is enabled" do
      before(:each) do
        params['status_proxy_enabled'] = true
      end
      it { should contain_pe_concat__fragment('console-services status-proxy-service') }
    end
  end

  context "when params are undef" do
    before(:each) do
      params['proxy_idle_timeout'] = ''
    end

    it { should contain_pe_hocon_setting("#{title}.console.proxy-idle-timeout").with_ensure('absent') }
  end

  context "when PuppetDB HA is configured" do
    before(:each) do
      params['puppetdb_host'] = ['puppetdb.rspec', 'replica.vm']
      params['puppetdb_port'] = ['54321', '8081']
    end

    # We only grab the first PuppetDB from the list of PuppetDB's for the
    # Console when HA is configured
    it { should contain_pe_hocon_setting("#{title}.console.puppetdb-server").with_value('https://puppetdb.rspec:54321') }
  end
end
