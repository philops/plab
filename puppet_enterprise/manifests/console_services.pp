class puppet_enterprise::console_services(
  $proxy_idle_timeout    = 60,
  $client_certname       = $puppet_enterprise::params::console_client_certname,
  $dashboard_port        = $puppet_enterprise::params::dashboard_listen_port,
  $master_host           = $master_host,
  $classifier_host       = 'localhost',
  $classifier_port       = $puppet_enterprise::params::console_services_api_listen_port,
  $classifier_url_prefix = $puppet_enterprise::params::classifier_url_prefix,
  $rbac_host             = 'localhost',
  $rbac_port             = $puppet_enterprise::params::console_services_api_listen_port,
  $activity_host         = 'localhost',
  $activity_port         = $puppet_enterprise::params::console_services_api_listen_port,
  $activity_url_prefix   = $puppet_enterprise::params::activity_url_prefix,
  $puppetdb_host         = 'localhost',
  $puppetdb_port         = $puppet_enterprise::params::puppetdb_ssl_listen_port,
  $localcacert           = $puppet_enterprise::params::localcacert,
  $java_args             = $puppet_enterprise::params::console_services_java_args,
  $status_proxy_enabled  = false,
  $service_stop_retries  = 60,
  $start_timeout         = 120,
) inherits puppet_enterprise::params {

  pe_validate_single_integer($service_stop_retries)
  pe_validate_single_integer($start_timeout)

  $container = 'pe-console-services'

  $confdir = '/etc/puppetlabs/console-services'

  puppet_enterprise::trapperkeeper::console_services { 'console-services':
    client_certname       => $client_certname,
    proxy_idle_timeout    => $proxy_idle_timeout,
    master_host           => $master_host,
    dashboard_port        => $dashboard_port,
    classifier_host       => $classifier_host,
    classifier_port       => $classifier_port,
    classifier_url_prefix => $classifier_url_prefix,
    puppetdb_host         => $puppetdb_host,
    puppetdb_port         => $puppetdb_port,
    rbac_host             => $rbac_host,
    rbac_port             => $rbac_port,
    activity_host         => $activity_host,
    activity_port         => $activity_port,
    activity_url_prefix   => $activity_url_prefix,
    localcacert           => $localcacert,
    status_proxy_enabled  => $status_proxy_enabled,
    notify                => Service[ 'pe-console-services' ],
  }

  $console_initconf = "${puppet_enterprise::params::defaults_dir}/pe-console-services"
  if !pe_empty($java_args) {
    pe_validate_hash($java_args)

    create_resources(
      'pe_ini_subsetting',
      create_java_args_subsettings_hash(
        'pe-console-services',
        $java_args,
        { path => $console_initconf,
          require => Package['pe-console-services'],
          notify => Service['pe-console-services'],
        })
    )
  }

  Pe_ini_setting {
    ensure => present,
    path => $console_initconf,
    key_val_separator => '=',
    section => '',
  }

  pe_ini_setting { "${container} initconf java_bin":
    setting => 'JAVA_BIN',
    value   => '"/opt/puppetlabs/server/bin/java"',
  }

  pe_ini_setting { "${container} initconf user":
    setting => 'USER',
    value   => 'pe-console-services',
  }

  pe_ini_setting { "${container} initconf group":
    setting => 'GROUP',
    value   => 'pe-console-services',
  }

  pe_ini_setting { "${container} initconf install_dir":
    setting => 'INSTALL_DIR',
    value   => '"/opt/puppetlabs/server/apps/console-services"',
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

  service { 'pe-console-services':
    ensure => running,
    enable => true,
  }
}
