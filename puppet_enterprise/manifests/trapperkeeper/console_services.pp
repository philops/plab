define puppet_enterprise::trapperkeeper::console_services(
  $activity_host,
  $puppetdb_host,
  $master_host,
  $classifier_host,
  $rbac_host,
  $status_proxy_enabled,
  $activity_port         = $puppet_enterprise::params::console_services_api_listen_port,
  $activity_url_prefix   = $puppet_enterprise::params::activity_url_prefix,
  $classifier_port       = $puppet_enterprise::params::console_services_api_listen_port,
  $classifier_url_prefix = $puppet_enterprise::params::classifier_url_prefix,
  $client_certname       = $puppet_enterprise::params::console_client_certname,
  $container             = $title,
  $dashboard_port        = $puppet_enterprise::params::dashboard_listen_port,
  $group                 = "pe-${title}",
  $localcacert           = $puppet_enterprise::params::localcacert,
  $proxy_idle_timeout    = 60,
  $puppetdb_port         = $puppet_enterprise::params::puppetdb_ssl_listen_port,
  $rbac_port             = $puppet_enterprise::params::console_services_api_listen_port,
  $rbac_url_prefix       = $puppet_enterprise::params::rbac_url_prefix,
  $user                  = "pe-${title}",
) {

  $cert_dir = "${puppet_enterprise::server_data_dir}/${container}/certs"
  $ssl_key = "${cert_dir}/${client_certname}.private_key.pem"
  $ssl_cert =  "${cert_dir}/${client_certname}.cert.pem"

  $license_key_path = $puppet_enterprise::license_key_path

  Pe_hocon_setting {
    ensure  => present,
    notify  => Service["pe-${container}"],
  }

  # Uses
  #   $ssl_key
  #   $ssl_cert
  #   $license_key_path
  #   $localcacert
  #   $puppetdb
  #   $puppetdb_port
  #   $master_host
  #   $rbac
  #   $rbac_port
  #   $rbac_url_prefix
  #   $classifier
  #   $classifier_port
  #   $dashboard_port
  #   $classifier_url_prefix
  #   $activity
  #   $activity_port
  #   $activity_url_prefix
  #   $proxy_idle_timeout
  file { "/etc/puppetlabs/${container}/conf.d/console.conf":
    ensure => present,
    owner  => $user,
    group  => $group,
    mode   => '0640',
  }

  pe_hocon_setting { "${container}.console.assets-dir":
    path    => "/etc/puppetlabs/${container}/conf.d/console.conf",
    setting => 'console.assets-dir',
    value   => 'dist',
  }
  pe_hocon_setting { "${container}.console.puppet-master":
    path    => "/etc/puppetlabs/${container}/conf.d/console.conf",
    setting => 'console.puppet-master',
    value   => "https://${master_host}:8140",
  }
  pe_hocon_setting { "${container}.console.rbac-server":
    path    => "/etc/puppetlabs/${container}/conf.d/console.conf",
    setting => 'console.rbac-server',
    value   => "http://${rbac_host}:${rbac_port}${rbac_url_prefix}",
  }
  pe_hocon_setting { "${container}.console.classifier-server":
    path    => "/etc/puppetlabs/${container}/conf.d/console.conf",
    setting => 'console.classifier-server',
    value   => "http://${classifier_host}:${classifier_port}${classifier_url_prefix}",
  }
  pe_hocon_setting { "${container}.console.activity-server":
    path    => "/etc/puppetlabs/${container}/conf.d/console.conf",
    setting => 'console.activity-server',
    value   => "http://${activity_host}:${activity_port}${activity_url_prefix}",
  }

  # For PuppetDB HA, a user may pass in an Array to specify their PuppetDBs
  $first_puppetdb_host = pe_any2array($puppetdb_host)[0]
  $first_puppetdb_port = pe_any2array($puppetdb_port)[0]
  pe_hocon_setting { "${container}.console.puppetdb-server":
    path    => "/etc/puppetlabs/${container}/conf.d/console.conf",
    setting => 'console.puppetdb-server',
    value   => "https://${first_puppetdb_host}:${first_puppetdb_port}",
  }
  pe_hocon_setting { "${container}.console.certs.ssl-key":
    path    => "/etc/puppetlabs/${container}/conf.d/console.conf",
    setting => 'console.certs.ssl-key',
    value   => $ssl_key,
  }
  pe_hocon_setting { "${container}.console.certs.ssl-cert":
    path    => "/etc/puppetlabs/${container}/conf.d/console.conf",
    setting => 'console.certs.ssl-cert',
    value   => $ssl_cert,
  }
  pe_hocon_setting { "${container}.console.certs.ssl-ca-cert":
    path    => "/etc/puppetlabs/${container}/conf.d/console.conf",
    setting => 'console.certs.ssl-ca-cert',
    value   => $localcacert,
  }
  pe_hocon_setting { "${container}.console.dashboard-server":
    path    => "/etc/puppetlabs/${container}/conf.d/console.conf",
    setting => 'console.dashboard-server',
    value   => "http://127.0.0.1:${dashboard_port}",
  }

  if $proxy_idle_timeout and $proxy_idle_timeout != '' {
    pe_validate_single_integer($proxy_idle_timeout)
    $proxy_idle_timeout_ensure = present
  } else {
    $proxy_idle_timeout_ensure = absent
  }

  pe_hocon_setting { "${container}.console.proxy-idle-timeout":
    ensure  => $proxy_idle_timeout_ensure,
    path    => "/etc/puppetlabs/${container}/conf.d/console.conf",
    setting => 'console.proxy-idle-timeout',
    value   => $proxy_idle_timeout,
  }

  pe_hocon_setting { "${container}.console.license-key":
    path    => "/etc/puppetlabs/${container}/conf.d/console.conf",
    setting => 'console.license-key',
    value   => $license_key_path,
  }


  $cookie_secret_key = cookie_secret_key()
  # Uses
  #   $cookie_secret_key
  file { "/etc/puppetlabs/${container}/conf.d/console_secret_key.conf":
    ensure  => present,
    owner   => $user,
    group   => $group,
    replace => false,
    mode    => '0640',
    content => "console: { cookie-secret-key: ${cookie_secret_key} }",
  }

  # pe_hocon_setting doesn't have a no replace mode
  # pe_hocon_setting { "${container}.console.cookie-secret-key":
  #   path    => "/etc/puppetlabs/${container}/conf.d/console_secret_key.conf",
  #   setting => 'console.cookie-secret-key',
  #   value   => cookie_secret_key(),
  # }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { "${container}:console webrouting-service" :
    container => $container,
    namespace => 'puppetlabs.trapperkeeper.services.webrouting.webrouting-service',
    service   => 'webrouting-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { "${container}:console rbac-service" :
    container => $container,
    namespace => 'puppetlabs.rbac.services.rbac',
    service   => 'rbac-service',
  }
  puppet_enterprise::trapperkeeper::bootstrap_cfg { "${container}:console rbac-authn-middleware" :
    container => $container,
    namespace => 'puppetlabs.rbac.services.http.middleware',
    service   => 'rbac-authn-middleware',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { "${container}:console rbac-status-service" :
    container => $container,
    namespace => 'puppetlabs.rbac.services.status',
    service   => 'rbac-status-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { "${container}:console rbac-storage-service" :
    container => $container,
    namespace => 'puppetlabs.rbac.services.storage.permissioned',
    service   => 'rbac-storage-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { "${container}:console rbac-authn-service" :
    container => $container,
    namespace => 'puppetlabs.rbac.services.authn',
    service   => 'rbac-authn-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { "${container}:console rbac-authz-service" :
    container => $container,
    namespace => 'puppetlabs.rbac.services.authz',
    service   => 'rbac-authz-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { "${container}:console pe-console-ui-service" :
    container => $container,
    namespace => 'puppetlabs.pe-console-ui.service',
    service   => 'pe-console-ui-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { "${container}:console pe-console-auth-ui-service" :
    container => $container,
    namespace => 'puppetlabs.pe-console-auth-ui.service',
    service   => 'pe-console-auth-ui-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { "${container}:console jetty9-service" :
    container => $container,
    namespace => 'puppetlabs.trapperkeeper.services.webserver.jetty9-service',
    service   => 'jetty9-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { "${container}:console status-service" :
    container => $container,
    namespace => 'puppetlabs.trapperkeeper.services.status.status-service',
    service   => 'status-service',
  }

  if $status_proxy_enabled {
    puppet_enterprise::trapperkeeper::bootstrap_cfg { "${container}:console status-proxy-service" :
      container => $container,
      namespace => 'puppetlabs.trapperkeeper.services.status.status-proxy-service',
      service   => 'status-proxy-service',
    }
  }
}
