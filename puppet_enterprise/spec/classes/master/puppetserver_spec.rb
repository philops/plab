require 'spec_helper'

describe 'puppet_enterprise::master::puppetserver' do
  before :all do
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

    @params = {
      'certname'                                 => 'master.rspec',
      'metrics_enabled'                          => true,
      'metrics_server_id'                        => 'localhost',
      'metrics_jmx_enabled'                      => true,
      'metrics_graphite_enabled'                 => false,
      'metrics_graphite_host'                    => 'graphite',
      'metrics_graphite_port'                    => 2003,
      'metrics_graphite_update_interval_seconds' => 30,
      'profiler_enabled'                         => true,
    }
  end

  let(:facts)   { @facter_facts }
  let(:params)  { @params }
  let(:confdir) { "/etc/puppetlabs/puppetserver" }

  context 'puppet-admin certs' do
    context 'default list' do
      it { should contain_pe_hocon_setting('puppet-admin.client-whitelist').with_value(['pe-internal-classifier']) }
    end

    context 'using custom certs' do
      before :each do
        @params['puppet_admin_certs'] = ['foo', 'bar']
      end

      it { should contain_pe_hocon_setting('puppet-admin.client-whitelist').with_value(['pe-internal-classifier', 'foo', 'bar' ]) }
    end
  end

  context "managing files" do
    it { should contain_pe_concat("#{confdir}/bootstrap.cfg").with_mode('0640') }
    it { should contain_file("#{confdir}/conf.d/webserver.conf").with_mode('0640') }
    it { should contain_pe_hocon_setting('webserver.static-content').with_ensure('absent') }
    it { should contain_pe_hocon_setting('jruby-puppet.borrow-timeout').with_ensure('absent') }
    it { should contain_pe_hocon_setting('jruby-puppet.max-active-instances').with_ensure('absent') }
    it { should contain_pe_hocon_setting('jruby-puppet.max-requests-per-instance').with_ensure('absent') }
    it { should contain_pe_hocon_setting('jruby-puppet.ruby-load-path').with_value(['/opt/puppetlabs/puppet/lib/ruby/vendor_ruby', '/opt/puppetlabs/puppet/cache/lib']) }

    it { should contain_pe_hocon_setting('os-settings.remove').with_ensure('absent') }

    it { should contain_pe_hocon_setting('http-client.ssl-protocols').with_ensure('absent') }
    it { should contain_pe_hocon_setting('http-client.cipher-suites').with_ensure('absent') }
    it { should contain_pe_hocon_setting('http-client.idle-timeout-milliseconds').with_ensure('absent') }
    it { should contain_pe_hocon_setting('http-client.connect-timeout-milliseconds').with_ensure('absent') }
    it { should contain_pe_hocon_setting('webserver.max-threads').with_ensure('absent') }
    it { should contain_pe_hocon_setting('webserver.ssl-ca-cert').with_value('/etc/puppetlabs/puppet/ssl/certs/ca.pem') }
    it { should contain_pe_hocon_setting('webserver.ssl-crl-path').with_value('/etc/puppetlabs/puppet/ssl/crl.pem') }
    it { should contain_pe_hocon_setting('webserver.access-log-config').with_value('/etc/puppetlabs/puppetserver/request-logging.xml') }

    it { should contain_pe_hocon_setting('web-router-service/pe-master-service').with_value('/puppet') }
    it do
      should contain_pe_hocon_setting('web-router-service/pe-master-service')
        .with_setting('web-router-service."puppetlabs.enterprise.services.master.master-service/pe-master-service"')
    end
    it { should contain_pe_hocon_setting('web-router-service/legacy-routes-service').with_value('') }
    it do
      should contain_pe_hocon_setting('web-router-service/legacy-routes-service')
        .with_setting('web-router-service."puppetlabs.services.legacy-routes.legacy-routes-service/legacy-routes-service"')
    end
    it { should contain_pe_hocon_setting('web-router-service/certificate-authority-service').with_value('/puppet-ca') }
    it do
      should contain_pe_hocon_setting('web-router-service/certificate-authority-service')
        .with_setting('web-router-service."puppetlabs.services.ca.certificate-authority-service/certificate-authority-service"')
    end
    it { should contain_pe_hocon_setting('web-router-service/reverse-proxy-ca-service').with_value('') }
    it do
      should contain_pe_hocon_setting('web-router-service/reverse-proxy-ca-service')
        .with_setting('web-router-service."puppetlabs.enterprise.services.reverse-proxy.reverse-proxy-ca-service/reverse-proxy-ca-service"')
    end
    it { should contain_pe_hocon_setting('web-router-service/puppet-admin-service').with_value('/puppet-admin-api') }
    it do
      should contain_pe_hocon_setting('web-router-service/puppet-admin-service')
        .with_setting('web-router-service."puppetlabs.services.puppet-admin.puppet-admin-service/puppet-admin-service"')
    end
    it { should contain_pe_hocon_setting('web-router-service/remove-master-service').with_ensure('absent') }

    it { should contain_file("#{confdir}/conf.d/global.conf").with_mode('0640') }
    it { should contain_file("#{confdir}/conf.d/pe-puppet-server.conf").with_mode('0640') }
    it { should contain_file("#{confdir}/conf.d/metrics.conf").with_mode('0640') }
    it { should_not contain_file("#{confdir}/conf.d/webserver.conf").with_content(%r[max-threads:\s*\d*]) }
  end

  context "managing service defaults" do
    it { should contain_pe_ini_setting('puppetserver initconf java_bin')
         .with_setting('JAVA_BIN')
         .with_value('"/opt/puppetlabs/server/bin/java"')
         .with_path('/etc/default/pe-puppetserver') }
    it { should contain_pe_ini_setting('puppetserver initconf user')
         .with_setting('USER')
         .with_value('pe-puppet') }
    it { should contain_pe_ini_setting('puppetserver initconf group')
         .with_setting('GROUP')
         .with_value('pe-puppet') }
    it { should contain_pe_ini_setting('puppetserver initconf install_dir')
         .with_setting('INSTALL_DIR')
         .with_value('"/opt/puppetlabs/server/apps/puppetserver"') }
    it { should contain_pe_ini_setting('puppetserver initconf config')
         .with_setting('CONFIG')
         .with_value('"/etc/puppetlabs/puppetserver/conf.d"') }
    it { should contain_pe_ini_setting('puppetserver initconf bootstrap_config')
         .with_setting('BOOTSTRAP_CONFIG')
         .with_value('"/etc/puppetlabs/puppetserver/bootstrap.cfg"') }
    it { should contain_pe_ini_setting('puppetserver initconf service_stop_retries')
         .with_setting('SERVICE_STOP_RETRIES')
         .with_value('60') }
    it { should contain_pe_ini_setting('puppetserver initconf start_timeout')
         .with_setting('START_TIMEOUT')
         .with_value('120') }

    context "with overrides" do
      before(:each) do
        @params['service_stop_retries'] = 12345
        @params['start_timeout'] = 67890
      end

      it { should contain_pe_ini_setting('puppetserver initconf service_stop_retries')
           .with_setting('SERVICE_STOP_RETRIES')
           .with_value('12345') }
      it { should contain_pe_ini_setting('puppetserver initconf start_timeout')
           .with_setting('START_TIMEOUT')
           .with_value('67890') }
    end
  end

  context "managing jetty cipher-suites" do
    before :each do
      @params['cipher_suites'] = [
        'TLS_RSA_WITH_AES_256_CBC_SHA256',
	      'TLS_RSA_WITH_AES_256_CBC_SHA',
        'TLS_RSA_WITH_AES_128_CBC_SHA256',
        'TLS_RSA_WITH_AES_128_CBC_SHA'
      ]
    end
    it { should contain_pe_hocon_setting('http-client.cipher-suites').with_value(['TLS_RSA_WITH_AES_256_CBC_SHA256', 'TLS_RSA_WITH_AES_256_CBC_SHA', 'TLS_RSA_WITH_AES_128_CBC_SHA256', 'TLS_RSA_WITH_AES_128_CBC_SHA']) }
  end

  context "managing jetty ssl-protocols" do
    before :each do
      @params['ssl_protocols'] = [
        'TLSv1',
        'TLSv1.1',
        'TLSv1.2'
      ]
    end
    it { should contain_pe_hocon_setting('http-client.ssl-protocols').with_value(['TLSv1', 'TLSv1.1', 'TLSv1.2']) }
  end

  context "managing jetty idle-timeout-milliseconds" do
    before :each do
      @params['idle_timeout_milliseconds'] = '12000000'
    end
    it { should contain_pe_hocon_setting('http-client.idle-timeout-milliseconds').with_value('12000000') }
  end

  context "managing jetty max-requests-per-instance" do
    before :each do
      @params['jruby_max_requests_per_instance'] = '42'
    end
    it { should contain_pe_hocon_setting('jruby-puppet.max-requests-per-instance').with_value('42') }
  end

  context "managing jetty connect-timeout-milliseconds" do
    before :each do
      @params['connect_timeout_milliseconds'] = '1200000'
    end
    it { should contain_pe_hocon_setting('http-client.connect-timeout-milliseconds').with_value('1200000') }
  end

  context "managing jetty max-threads" do
    before :each do
      @params['tk_jetty_max_threads'] = '10'
    end

    it { should contain_pe_hocon_setting('webserver.max-threads').with_value('10') }
  end

  context "managing jruby borrow_timeout" do
    before :each do
      @params['jruby_borrow_timeout'] = '1000'
    end

    it { should contain_pe_hocon_setting('jruby-puppet.borrow-timeout').with_value('1000') }
  end

  context "managing the number of jruby instances" do
    before :each do
      @params['jruby_max_active_instances'] = '5'
    end

    it { should contain_pe_hocon_setting('jruby-puppet.max-active-instances').with_value('5') }
  end

  context "serving static files" do
    before :each do
      @params['static_files'] = {
        "/baz-files" => "/foo/bar/baz",
        "/others" => "/foo/bar/others"
      }
    end
    it { should contain_pe_hocon_setting('webserver.static-content').with_value(%r[.*resource.*/foo/bar/baz.*path.*/baz-files.*follow-links.*true])}
    it { should contain_pe_hocon_setting('webserver.static-content').with_value(%r[.*resource.*/foo/bar/others.*path.*/others.*follow-links.*true])}
  end

  context "managing services" do
    it { should contain_service('pe-puppetserver').with_ensure('running') }
  end
end
