# Internal class for Puppet Enterprise to configure the Puppet Server
#
# @param metrics_enabled [Boolean] Toggle whether the metrics service is running or not.
# @param metrics_server_id [Integer] What ID to tag the metrics with
# @param metrics_jmx_enabled [Boolean] Toggle whether to run with JMX (Java Management Extensions) enabled.
# @param metrics_graphite_enabled [Boolean] Toggle whether to write metrics to Graphite.
# @param metrics_graphite_host [String] Graphite server to write metrics to..
# @param metrics_graphite_port [Integer] Port on Graphite server to write metrics to.
# @param metrics_graphite_update_interval_seconds [Integer] How often, in seconds, to wait between writing metrics to the Graphity server.
# @param profiler_enabled [Boolean] Whether to run the Java profiler.
# @param jruby_max_active_instances [Integer] The maximum number of jruby instances that the Puppet Server will spawn to server Agent traffic.
# @param jruby_max_requests_per_instance [Integer] The maximum number of requests a single JRuby instance will handle before it is flushed from memory and refreshed.
# @param jruby_borrow_timeout [Integer] Set the timeout when attempting to borrow an instance from the JRuby pool in milliseconds. Defaults is 1200000.
# @param certname [String] The cert name the Server will use.
# @param localcacert [String] The path to the local CA cert used for generating SSL certs.
# @param puppet_admin_certs [Array] Certificates to add to the whitelist on the master.
# @param static_files [Hash] Paths to static files to serve up on the master. Keys are the URLs the files will be found at, values are the paths to the folders to be served.
# @param java_args [Hash] Key-value pairs describing the java arguments to be passed when starting the master
# @param tk_jetty_max_threads [Integer] Maxiumum number of Jerry threads that should be started
# @param ssl_protocols [Array] List of acceptable protocols for making HTTP requests
# @param cipher_suites [Array] A list of acceptable cipher suites for making HTTP requests
# @param idle_timeout_milliseconds [Integer] The amount of time an outbound HTTP connection will wait for data to be available before closing the socket
# @param connect_timeout_milliseconds [Integer] The amount of time an outbound HTTP connection will wait to connect before giving up
class puppet_enterprise::master::puppetserver(
  $metrics_enabled,
  $metrics_graphite_enabled,
  $metrics_graphite_host,
  $metrics_graphite_port,
  $metrics_graphite_update_interval_seconds,
  $metrics_jmx_enabled,
  $metrics_server_id,
  $profiler_enabled,
  $certname                                               = $::clientcert,
  Optional[Array[String]] $cipher_suites                  = undef,
  $connect_timeout_milliseconds                           = undef,
  $idle_timeout_milliseconds                              = undef,
  $java_args                                              = $puppet_enterprise::params::puppetserver_java_args,
  $jruby_borrow_timeout                                   = undef,
  $jruby_max_active_instances                             = undef,
  $jruby_max_requests_per_instance                        = undef,
  $localcacert                                            = $puppet_enterprise::params::localcacert,
  Array[String] $puppet_admin_certs                       = [],
  Optional[Array[String]] $ssl_protocols                  = undef,
  $static_files                                           = {},
  $tk_jetty_max_threads                                   = undef,
  $puppetserver_webserver_ssl_host                        = '0.0.0.0',
  $puppetserver_webserver_ssl_port                        = '8140',
  $puppetserver_jruby_puppet_gem_home                     = '/opt/puppetlabs/server/data/puppetserver/jruby-gems',
  $puppetserver_jruby_puppet_master_conf_dir              = '/etc/puppetlabs/puppet',
  $puppetserver_jruby_puppet_master_code_dir              = '/etc/puppetlabs/code',
  $puppetserver_jruby_puppet_master_var_dir               = '/opt/puppetlabs/server/data/puppetserver',
  $puppetserver_jruby_puppet_master_run_dir               = '/var/run/puppetlabs/puppetserver',
  $puppetserver_jruby_puppet_master_log_dir               = '/var/log/puppetlabs/puppetserver',
  Array[String] $puppetserver_jruby_puppet_ruby_load_path = ['/opt/puppetlabs/puppet/lib/ruby/vendor_ruby', '/opt/puppetlabs/puppet/cache/lib'],
  $service_stop_retries                                   = 60,
  $start_timeout                                          = 120,
) inherits puppet_enterprise::params {

  pe_validate_single_integer($service_stop_retries)
  pe_validate_single_integer($start_timeout)

  $classifier_client_certname = $puppet_enterprise::params::classifier_client_certname
  $container = 'puppetserver'
  $_puppet_admin_certs = [$classifier_client_certname] + $puppet_admin_certs

  File {
    ensure => present,
    owner  => 'pe-puppet',
    group  => 'pe-puppet',
    mode   => '0640',
  }

  Pe_concat {
    owner  => 'pe-puppet',
    group  => 'pe-puppet',
    mode   => '0640',
  }

  Pe_hocon_setting {
    ensure => present,
    notify => Service["pe-${container}"],
  }

  Puppet_enterprise::Trapperkeeper::Bootstrap_cfg {
    container => $container,
  }

  $confdir = "/etc/puppetlabs/${container}"

  puppet_enterprise::trapperkeeper::bootstrap_cfg { "${container}:master jetty9-service" :
    namespace => 'puppetlabs.trapperkeeper.services.webserver.jetty9-service',
    service   => 'jetty9-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { 'pe-master-service' :
    namespace => 'puppetlabs.enterprise.services.master.master-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { 'request-handler-service' :
    namespace => 'puppetlabs.services.request-handler.request-handler-service',
  }
  puppet_enterprise::trapperkeeper::bootstrap_cfg { 'jruby-puppet-pooled-service' :
    namespace => 'puppetlabs.services.jruby.jruby-puppet-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { 'metrics-puppet-profiler-service' :
    namespace => 'puppetlabs.enterprise.services.puppet-profiler.puppet-profiler-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { 'pe-metrics-service' :
    namespace => 'puppetlabs.enterprise.services.metrics.pe-metrics-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { 'puppet-server-config-service' :
    namespace => 'puppetlabs.services.config.puppet-server-config-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { 'puppet-admin-service' :
    namespace => 'puppetlabs.services.puppet-admin.puppet-admin-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { 'webrouting-service' :
    namespace => 'puppetlabs.trapperkeeper.services.webrouting.webrouting-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { 'legacy-routes-service' :
    namespace => 'puppetlabs.services.legacy-routes.legacy-routes-service',
  }

  # Uses
  #   $certname
  #   $localcacert
  #   $static_files
  #   $tk_jetty_max_threads
  file { "${confdir}/conf.d/webserver.conf" :
    ensure => present,
  }

  pe_hocon_setting{ 'webserver.client-auth':
    path    => "${confdir}/conf.d/webserver.conf",
    setting => 'webserver.client-auth',
    value   => 'want',
  }
  pe_hocon_setting{ 'webserver.ssl-host':
    path    => "${confdir}/conf.d/webserver.conf",
    setting => 'webserver.ssl-host',
    value   => $puppetserver_webserver_ssl_host,
  }
  pe_hocon_setting{ 'webserver.ssl-port':
    path    => "${confdir}/conf.d/webserver.conf",
    setting => 'webserver.ssl-port',
    value   => $puppetserver_webserver_ssl_port,
  }
  pe_hocon_setting{ 'webserver.ssl-cert':
    path    => "${confdir}/conf.d/webserver.conf",
    setting => 'webserver.ssl-cert',
    value   => "/etc/puppetlabs/puppet/ssl/certs/${certname}.pem",
  }
  pe_hocon_setting{ 'webserver.ssl-key':
    path    => "${confdir}/conf.d/webserver.conf",
    setting => 'webserver.ssl-key',
    value   => "/etc/puppetlabs/puppet/ssl/private_keys/${certname}.pem",
  }
  pe_hocon_setting{ 'webserver.ssl-ca-cert':
    path    => "${confdir}/conf.d/webserver.conf",
    setting => 'webserver.ssl-ca-cert',
    value   => $localcacert,
  }
  pe_hocon_setting{ 'webserver.ssl-crl-path':
    path    => "${confdir}/conf.d/webserver.conf",
    setting => 'webserver.ssl-crl-path',
    value   => $hostcrl,
  }
  pe_hocon_setting{ 'webserver.access-log-config':
    path    => "${confdir}/conf.d/webserver.conf",
    setting => 'webserver.access-log-config',
    value   => "${confdir}/request-logging.xml",
  }

  if $tk_jetty_max_threads {
    $tk_jetty_max_threads_ensure = present
  } else {
    $tk_jetty_max_threads_ensure = absent
  }

  pe_hocon_setting{ 'webserver.max-threads':
    ensure  => $tk_jetty_max_threads_ensure,
    path    => "${confdir}/conf.d/webserver.conf",
    setting => 'webserver.max-threads',
    value   => $tk_jetty_max_threads,
  }

  if $static_files and !pe_empty($static_files) {
    $static_files_ensure = present
  } else {
    $static_files_ensure = absent
  }

  pe_hocon_setting{ 'webserver.static-content':
    ensure  => $static_files_ensure,
    path    => "${confdir}/conf.d/webserver.conf",
    setting => 'webserver.static-content',
    type    => 'array',
    value   => pe_puppetserver_static_content_list($static_files),
  }

  file { "${confdir}/conf.d/web-routes.conf" :
    ensure => present,
  }

  pe_hocon_setting { 'web-router-service/pe-master-service':
    path    => "${confdir}/conf.d/web-routes.conf",
    setting => 'web-router-service."puppetlabs.enterprise.services.master.master-service/pe-master-service"',
    value   => '/puppet',
  }
  pe_hocon_setting { 'web-router-service/legacy-routes-service':
    path    => "${confdir}/conf.d/web-routes.conf",
    setting => 'web-router-service."puppetlabs.services.legacy-routes.legacy-routes-service/legacy-routes-service"',
    value   => '',
  }
  pe_hocon_setting { 'web-router-service/certificate-authority-service':
    path    => "${confdir}/conf.d/web-routes.conf",
    setting => 'web-router-service."puppetlabs.services.ca.certificate-authority-service/certificate-authority-service"',
    value   => '/puppet-ca',
  }
  pe_hocon_setting { 'web-router-service/reverse-proxy-ca-service':
    path    => "${confdir}/conf.d/web-routes.conf",
    setting => 'web-router-service."puppetlabs.enterprise.services.reverse-proxy.reverse-proxy-ca-service/reverse-proxy-ca-service"',
    value   => '',
  }
  pe_hocon_setting { 'web-router-service/puppet-admin-service':
    path    => "${confdir}/conf.d/web-routes.conf",
    setting => 'web-router-service."puppetlabs.services.puppet-admin.puppet-admin-service/puppet-admin-service"',
    value   => '/puppet-admin-api',
  }
  # Puppetserver 2.x does not use this route in PE
  pe_hocon_setting { 'web-router-service/remove-master-service':
    ensure  => absent,
    path    => "${confdir}/conf.d/web-routes.conf",
    setting => 'web-router-service."puppetlabs.services.master.master-service/master-service"',
  }

  file { "${confdir}/conf.d/pe-puppet-server.conf" :
    ensure => present,
  }
  pe_hocon_setting { 'jruby-puppet.ruby-load-path':
    path    => "${confdir}/conf.d/pe-puppet-server.conf",
    setting => 'jruby-puppet.ruby-load-path',
    type    => 'array',
    value   => $puppetserver_jruby_puppet_ruby_load_path,
  }
  # Puppetserver 2.x moved ruby-load-path to the jruby-puppet section, and
  # os-settings had no other settings.
  pe_hocon_setting { 'os-settings.remove':
    ensure => absent,
    path     => "${confdir}/conf.d/pe-puppet-server.conf",
    setting  => 'os-settings',
  }
  pe_hocon_setting { 'jruby-puppet.gem-home':
    path    => "${confdir}/conf.d/pe-puppet-server.conf",
    setting => 'jruby-puppet.gem-home',
    value   => $puppetserver_jruby_puppet_gem_home,
  }
  pe_hocon_setting { 'jruby-puppet.master-conf-dir':
    path    => "${confdir}/conf.d/pe-puppet-server.conf",
    setting => 'jruby-puppet.master-conf-dir',
    value   => $puppetserver_jruby_puppet_master_conf_dir,
  }
  pe_hocon_setting { 'jruby-puppet.master-code-dir':
    path    => "${confdir}/conf.d/pe-puppet-server.conf",
    setting => 'jruby-puppet.master-code-dir',
    value   => $puppetserver_jruby_puppet_master_code_dir,
  }
  pe_hocon_setting { 'jruby-puppet.master-var-dir':
    path    => "${confdir}/conf.d/pe-puppet-server.conf",
    setting => 'jruby-puppet.master-var-dir',
    value   => $puppetserver_jruby_puppet_master_var_dir,
  }
  pe_hocon_setting { 'jruby-puppet.master-run-dir':
    path    => "${confdir}/conf.d/pe-puppet-server.conf",
    setting => 'jruby-puppet.master-run-dir',
    value   => $puppetserver_jruby_puppet_master_run_dir,
  }
  pe_hocon_setting { 'jruby-puppet.master-log-dir':
    path    => "${confdir}/conf.d/pe-puppet-server.conf",
    setting => 'jruby-puppet.master-log-dir',
    value   => $puppetserver_jruby_puppet_master_log_dir,
  }

  if $jruby_borrow_timeout {
    pe_validate_single_integer($jruby_borrow_timeout)
    $jruby_borrow_timeout_ensure = present
  } else {
    $jruby_borrow_timeout_ensure = absent
  }

  pe_hocon_setting { 'jruby-puppet.borrow-timeout':
    ensure  => $jruby_borrow_timeout_ensure,
    path    => "${confdir}/conf.d/pe-puppet-server.conf",
    setting => 'jruby-puppet.borrow-timeout',
    value   => $jruby_borrow_timeout,
  }

  if $jruby_max_active_instances {
    pe_validate_single_integer($jruby_max_active_instances)
    $jruby_max_active_instances_ensure = present
  } else {
    $jruby_max_active_instances_ensure = absent
  }

  pe_hocon_setting { 'jruby-puppet.max-active-instances':
    ensure  => $jruby_max_active_instances_ensure,
    path    => "${confdir}/conf.d/pe-puppet-server.conf",
    setting => 'jruby-puppet.max-active-instances',
    value   => $jruby_max_active_instances,
  }

  if $jruby_max_requests_per_instance {
    pe_validate_single_integer($jruby_max_requests_per_instance)
    $jruby_max_requests_per_instance_ensure = present
  } else {
    $jruby_max_requests_per_instance_ensure = absent
  }

  pe_hocon_setting { 'jruby-puppet.max-requests-per-instance':
    ensure  => $jruby_max_requests_per_instance_ensure,
    path    => "${confdir}/conf.d/pe-puppet-server.conf",
    setting => 'jruby-puppet.max-requests-per-instance',
    value   => $jruby_max_requests_per_instance,
  }

  pe_hocon_setting { 'profiler.enabled':
    path    => "${confdir}/conf.d/pe-puppet-server.conf",
    setting => 'profiler.enabled',
    value   => $profiler_enabled,
  }

  pe_hocon_setting { 'puppet-admin.client-whitelist':
    path    => "${confdir}/conf.d/pe-puppet-server.conf",
    setting => 'puppet-admin.client-whitelist',
    type    => 'array',
    value   => $_puppet_admin_certs,
  }

  if $ssl_protocols and !pe_empty($ssl_protocols) {
    $ssl_protocols_ensure = present
  } else {
    $ssl_protocols_ensure = absent
  }

  pe_hocon_setting { 'http-client.ssl-protocols':
    ensure  => $ssl_protocols_ensure,
    path    => "${confdir}/conf.d/pe-puppet-server.conf",
    setting => 'http-client.ssl-protocols',
    type    => 'array',
    value   => $ssl_protocols,
  }

  if $cipher_suites and !pe_empty($cipher_suites) {
    $cipher_suites_ensure = present
  } else {
    $cipher_suites_ensure = absent
  }

  pe_hocon_setting { 'http-client.cipher-suites':
    ensure  => $cipher_suites_ensure,
    path    => "${confdir}/conf.d/pe-puppet-server.conf",
    setting => 'http-client.cipher-suites',
    type    => 'array',
    value   => $cipher_suites,
  }

  if $idle_timeout_milliseconds {
    pe_validate_single_integer($idle_timeout_milliseconds)
    $idle_timeout_milliseconds_ensure = present
  } else {
    $idle_timeout_milliseconds_ensure = absent
  }

  pe_hocon_setting { 'http-client.idle-timeout-milliseconds':
    ensure  => $idle_timeout_milliseconds_ensure,
    path    => "${confdir}/conf.d/pe-puppet-server.conf",
    setting => 'http-client.idle-timeout-milliseconds',
    value   => $idle_timeout_milliseconds,
  }

  if $connect_timeout_milliseconds {
    pe_validate_single_integer($connect_timeout_milliseconds)
    $connect_timeout_milliseconds_ensure = present
  } else {
    $connect_timeout_milliseconds_ensure = absent
  }

  pe_hocon_setting { 'http-client.connect-timeout-milliseconds':
    ensure  => $connect_timeout_milliseconds_ensure,
    path    => "${confdir}/conf.d/pe-puppet-server.conf",
    setting => 'http-client.connect-timeout-milliseconds',
    value   => $connect_timeout_milliseconds,
  }

  # Uses
  #   $confdir
  #   $certname
  file { "${confdir}/conf.d/global.conf" :
    ensure => present,
  }
  pe_hocon_setting { "${confdir}/conf.d/global.conf#global.logging-config":
    path    => "${confdir}/conf.d/global.conf",
    setting => 'global.logging-config',
    value   => "${confdir}/logback.xml",
  }
  pe_hocon_setting { "${confdir}/conf.d/global.conf#global.hostname":
    path    => "${confdir}/conf.d/global.conf",
    setting => 'global.hostname',
    value   => $certname,
  }

  # Uses
  #   $metrics_enabled
  #   $metrics_server_id
  #   $metrics_jmx_enabled
  #   $metrics_graphite_enabled
  #   $metrics_graphite_host
  #   $metrics_graphite_port
  #   $metrics_graphite_update_interval_seconds
  file { "${confdir}/conf.d/metrics.conf" :
    ensure => present,
  }
  pe_hocon_setting { 'metrics.enabled':
    path    => "${confdir}/conf.d/metrics.conf",
    setting => 'metrics.enabled',
    value   => $metrics_enabled,
  }
  pe_hocon_setting { 'metrics.server-id':
    path    => "${confdir}/conf.d/metrics.conf",
    setting => 'metrics.server-id',
    value   => $metrics_server_id,
  }
  # Enable or disable jmx metrics reporter
  pe_hocon_setting { 'metrics.reporters.jmx.enabled':
    path    => "${confdir}/conf.d/metrics.conf",
    setting => 'metrics.reporters.jmx.enabled',
    value   => $metrics_jmx_enabled,
  }
  # Enable or disable Graphite metrics reporter
  pe_hocon_setting { 'metrics.reporters.graphite.enabled':
    path    => "${confdir}/conf.d/metrics.conf",
    setting => 'metrics.reporters.graphite.enabled',
    value   => $metrics_graphite_enabled,
  }
  # Graphite host
  pe_hocon_setting { 'metrics.reporters.graphite.host':
    path    => "${confdir}/conf.d/metrics.conf",
    setting => 'metrics.reporters.graphite.host',
    value   => $metrics_graphite_host,
  }
  # Graphite metrics port
  pe_hocon_setting { 'metrics.reporters.graphite.port':
    path    => "${confdir}/conf.d/metrics.conf",
    setting => 'metrics.reporters.graphite.port',
    value   => $metrics_graphite_port,
  }
  # How often to send metrics
  pe_hocon_setting { 'metrics.reporters.graphite.update-interval-seconds':
    path    => "${confdir}/conf.d/metrics.conf",
    setting => 'metrics.reporters.graphite.update-interval-seconds',
    value   => $metrics_graphite_update_interval_seconds,
  }

  $puppetserver_initconf = "${puppet_enterprise::params::defaults_dir}/pe-puppetserver"

  if !pe_empty($java_args) {
    pe_validate_hash($java_args)
    create_resources(
      'pe_ini_subsetting',
      create_java_args_subsettings_hash(
        'pe-puppetserver',
        $java_args,
        { path => $puppetserver_initconf,
          require => Package['pe-puppetserver'],
          notify => Service["pe-${container}"],
        })
    )
  }

  Pe_ini_setting {
    ensure            => present,
    path              => $puppetserver_initconf,
    key_val_separator => '=',
    section           => '',
  }

  pe_ini_setting { "${container} initconf java_bin":
    setting => 'JAVA_BIN',
    value   => '"/opt/puppetlabs/server/bin/java"',
  }

  pe_ini_setting { "${container} initconf user":
    setting => 'USER',
    value   => 'pe-puppet',
  }

  pe_ini_setting { "${container} initconf group":
    setting => 'GROUP',
    value   => 'pe-puppet',
  }

  pe_ini_setting { "${container} initconf install_dir":
    setting => 'INSTALL_DIR',
    value   => '"/opt/puppetlabs/server/apps/puppetserver"',
  }

  pe_ini_setting { "${container} initconf config":
    setting => 'CONFIG',
    value   => "\"${confdir}/conf.d\"",
  }

  pe_ini_setting { "${container} initconf bootstrap_config":
    setting => 'BOOTSTRAP_CONFIG',
    value   => "\"${confdir}/bootstrap.cfg\"",
  }

  pe_ini_setting { "${container} initconf service_stop_retries":
    setting => 'SERVICE_STOP_RETRIES',
    value   => $service_stop_retries,
  }

  pe_ini_setting { "${container} initconf start_timeout":
    setting => 'START_TIMEOUT',
    value   => $start_timeout,
  }

  # PE-10520 - invalid [files] section causes puppet run failure
  if ! $::puppet_files_dir_present {
    augeas { "fileserver.conf remove [files]":
      changes   => [
        "remove files",
      ],
      onlyif    => "match files size > 0",
      incl      => '/etc/puppetlabs/puppet/fileserver.conf',
      load_path => "${puppet_enterprise::puppet_share_dir}/augeas/lenses/dist",
      lens      => 'PuppetFileserver.lns',
      notify    => Service["pe-${container}"],
    }
  }

  service { "pe-${container}":
    ensure  => running,
    enable  => true,
    require => Package["pe-${container}"],
  }
}
