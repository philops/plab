define puppet_enterprise::trapperkeeper::rbac (
  $certname,
  $container                 = $title,
  $database_host             = 'localhost',
  $database_name             = $puppet_enterprise::params::rbac_database_name,
  $database_password         = $puppet_enterprise::params::rbac_database_password,
  $database_port             = $puppet_enterprise::params::database_port,
  $database_properties       = '',
  $database_user             = $puppet_enterprise::params::rbac_database_user,
  $ds_trust_chain            = undef,
  $failed_attempts_lockout   = undef,
  $group                     = "pe-${title}",
  $password_reset_expiration = undef,
  $session_timeout           = undef,
  $user                      = "pe-${title}",
) {

  $cert_dir = "${puppet_enterprise::server_data_dir}/${container}/certs"
  $ssl_key = "${cert_dir}/${certname}.private_key.pem"
  $ssl_cert =  "${cert_dir}/${certname}.cert.pem"

  File {
    owner => $user,
    group => $group,
    mode  => '0640',
  }

  Pe_hocon_setting {
    ensure  => present,
    notify  => Service["pe-${container}"],
  }

  $cert_whitelist_path = "/etc/puppetlabs/${container}/rbac-certificate-whitelist"
  # Uses
  #   $ssl_key
  #   $ssl_cert
  #   $cert_whitelist_path
  file { "/etc/puppetlabs/${container}/conf.d/rbac.conf":
    ensure => present,
  }
  pe_hocon_setting { "${container}.rbac.certificate-whitelist":
    path    => "/etc/puppetlabs/${container}/conf.d/rbac.conf",
    setting => 'rbac.certificate-whitelist',
    value   => $cert_whitelist_path,
  }
  pe_hocon_setting { "${container}.rbac.token-private-key":
    path    => "/etc/puppetlabs/${container}/conf.d/rbac.conf",
    setting => 'rbac.token-private-key',
    value   => $ssl_key,
  }
  pe_hocon_setting { "${container}.rbac.token-public-key":
    path    => "/etc/puppetlabs/${container}/conf.d/rbac.conf",
    setting => 'rbac.token-public-key',
    value   => $ssl_cert,
  }

  if $password_reset_expiration {
    pe_validate_single_integer($password_reset_expiration)
    $password_reset_expiration_ensure = present
  } else {
    $password_reset_expiration_ensure = absent
  }

  pe_hocon_setting { "${container}.rbac.password-reset-expiration":
    ensure  => $password_reset_expiration_ensure,
    path    => "/etc/puppetlabs/${container}/conf.d/rbac.conf",
    setting => 'rbac.password-reset-expiration',
    value   => $password_reset_expiration,
  }

  if $session_timeout {
    pe_validate_single_integer($session_timeout)
    $session_timeout_ensure = present
  } else {
    $session_timeout_ensure = absent
  }

  pe_hocon_setting { "${container}.rbac.session-timeout":
    ensure  => $session_timeout_ensure,
    path    => "/etc/puppetlabs/${container}/conf.d/rbac.conf",
    setting => 'rbac.session-timeout',
    value   => $session_timeout,
  }

  if $ds_trust_chain and !pe_empty($ds_trust_chain) {
    $ds_trust_chain_ensure = present
  } else {
    $ds_trust_chain_ensure = absent
  }

  pe_hocon_setting { "${container}.rbac.ds-trust-chain":
    ensure  => $ds_trust_chain_ensure,
    path    => "/etc/puppetlabs/${container}/conf.d/rbac.conf",
    setting => 'rbac.ds-trust-chain',
    value   => $ds_trust_chain,
  }

  if $failed_attempts_lockout {
    pe_validate_single_integer($failed_attempts_lockout)
    $failed_attempts_lockout_ensure = present
  } else {
    $failed_attempts_lockout_ensure = absent
  }

  pe_hocon_setting { "${container}.rbac.failed-attempts-lockout":
    ensure  => $failed_attempts_lockout_ensure,
    path    => "/etc/puppetlabs/${container}/conf.d/rbac.conf",
    setting => 'rbac.failed-attempts-lockout',
    value   => $failed_attempts_lockout,
  }

  unless pe_empty($database_password) {
    # Uses
    #   $database_host
    #   $database_port
    #   $database_name
    #   $database_user
    #   $database_password
    #   $database_properties
    file { "/etc/puppetlabs/${container}/conf.d/rbac-database.conf":
      ensure => present,
    }
    pe_hocon_setting { "${container}.rbac.database.subprotocol":
      path    => "/etc/puppetlabs/${container}/conf.d/rbac-database.conf",
      setting => 'rbac.database.subprotocol',
      value   => 'postgresql',
    }
    pe_hocon_setting { "${container}.rbac.database.subname":
      path    => "/etc/puppetlabs/${container}/conf.d/rbac-database.conf",
      setting => 'rbac.database.subname',
      value   => "//${database_host}:${database_port}/${database_name}${database_properties}",
    }
    pe_hocon_setting { "${container}.rbac.database.user":
      path    => "/etc/puppetlabs/${container}/conf.d/rbac-database.conf",
      setting => 'rbac.database.user',
      value   => $database_user,
    }
    pe_hocon_setting { "${container}.rbac.database.password":
      path    => "/etc/puppetlabs/${container}/conf.d/rbac-database.conf",
      setting => 'rbac.database.password',
      value   => $database_password,
    }
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { "${container}:rbac rbac-service" :
    container => $container,
    namespace => 'puppetlabs.rbac.services.rbac',
    service   => 'rbac-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { "${container}:rbac rbac-storage-service" :
    container => $container,
    namespace => 'puppetlabs.rbac.services.storage.permissioned',
    service   => 'rbac-storage-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { "${container}:rbac rbac-http-api-service" :
    container => $container,
    namespace => 'puppetlabs.rbac.services.http.api',
    service   => 'rbac-http-api-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { "${container}:rbac rbac-authn-middleware" :
    container => $container,
    namespace => 'puppetlabs.rbac.services.http.middleware',
    service   => 'rbac-authn-middleware',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { "${container}:rbac activity-reporting-service" :
    container => $container,
    namespace => 'puppetlabs.activity.services',
    service   => 'activity-reporting-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { "${container}:rbac jetty9-service" :
    container => $container,
    namespace => 'puppetlabs.trapperkeeper.services.webserver.jetty9-service',
    service   => 'jetty9-service',
  }
}
