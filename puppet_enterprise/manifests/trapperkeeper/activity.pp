define puppet_enterprise::trapperkeeper::activity (
  $container           = $title,
  $database_host       = 'localhost',
  $database_name       = $puppet_enterprise::params::activity_database_name,
  $database_password   = $puppet_enterprise::params::activity_database_password,
  $database_port       = $puppet_enterprise::params::database_port,
  $database_properties = '',
  $database_user       = $puppet_enterprise::params::activity_database_user,
  $group               = "pe-${title}",
  $rbac_host           = 'localhost',
  $rbac_port           = $puppet_enterprise::params::console_services_api_listen_port,
  $rbac_url_prefix     = $puppet_enterprise::params::rbac_url_prefix,
  $user                = "pe-${title}",
) {
  File {
    owner => $user,
    group => $group,
    mode  => '0640',
  }

  Pe_hocon_setting {
    ensure  => present,
    notify  => Service["pe-${container}"],
  }

  # Uses
  #   $rbac_host
  #   $rbac_port
  #   $rbac_url_prefix
  file { "/etc/puppetlabs/${container}/conf.d/activity.conf":
    ensure => present,
  }
  pe_hocon_setting { 'activity.rbac-base-url':
    path    => "/etc/puppetlabs/${container}/conf.d/activity.conf",
    setting => 'activity.rbac-base-url',
    value   => "http://${rbac_host}:${rbac_port}${rbac_url_prefix}/v1",
  }
  pe_hocon_setting { 'activity.cors-origin-pattern':
    path    => "/etc/puppetlabs/${container}/conf.d/activity.conf",
    setting => 'activity.cors-origin-pattern',
    value   => ".*"
  }

  unless pe_empty($database_password) {
    # Uses
    #   $database_host
    #   $database_port
    #   $database_name
    #   $database_user
    #   $database_password
    #   $database_properties
    file { "/etc/puppetlabs/${container}/conf.d/activity-database.conf":
      ensure => present,
    }
    pe_hocon_setting { 'activity.database.subprotocol':
      path    => "/etc/puppetlabs/${container}/conf.d/activity-database.conf",
      setting => 'activity.database.subprotocol',
      value   => 'postgresql',
    }
    pe_hocon_setting { 'activity.database.subname':
      path    => "/etc/puppetlabs/${container}/conf.d/activity-database.conf",
      setting => 'activity.database.subname',
      value   => "//${database_host}:${database_port}/${database_name}${database_properties}",
    }
    pe_hocon_setting { 'activity.database.user':
      path    => "/etc/puppetlabs/${container}/conf.d/activity-database.conf",
      setting => 'activity.database.user',
      value   => $database_user,
    }
    pe_hocon_setting { 'activity.database.password':
      path    => "/etc/puppetlabs/${container}/conf.d/activity-database.conf",
      setting => 'activity.database.password',
      value   => $database_password,
    }
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { "${container}:activity activity-service" :
    container => $container,
    namespace => 'puppetlabs.activity.services',
    service   => 'activity-service',
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { "${container}:activity jetty9-service" :
    container => $container,
    namespace => 'puppetlabs.trapperkeeper.services.webserver.jetty9-service',
    service   => 'jetty9-service',
  }
}
