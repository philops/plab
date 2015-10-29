# This class is for setting up the PuppetDB configuration file
#
# @param database_host [String] The hostname of the database that PuppetDB will
#        be running on
# @param confdir [String] The path to PuppetDB's confdir
# @param database_name [String] The name of the PuppetDB Database
# @param database_password [String] The password of the user
# @param database_port [Integer] The port that the database is running on
# @param database_properties [String] A url encoded string of JDBC options. This will replace the
#        default database property string which enables SSL connections.
# @param database_user [String] The user logging into the database
# @param gc_interval [String] The interval, in minutes, at which garbage collection should occur
# @param node_purge_ttl [String] The amount of time that must elapse before a
#        deactivated node is purged from PuppetDB
# @param node_ttl [String] The amount of time that must elapse before a node is
#        deactivated from PuppetDB
# @param report_ttl [String] The amount of time that must elapse before a report is deleted
class puppet_enterprise::puppetdb::database_ini(
  $database_host,
  $confdir                    = $puppet_enterprise::params::puppetdb_confdir,
  $database_name              = $puppet_enterprise::params::puppetdb_database_name,
  $database_password          = undef,
  $database_port              = $puppet_enterprise::params::database_port,
  $database_properties        = '',
  $database_user              = $puppet_enterprise::params::puppetdb_database_user,
  $gc_interval                = $puppet_enterprise::params::puppetdb_gc_interval,
  $node_purge_ttl             = $puppet_enterprise::params::puppetdb_node_purge_ttl,
  $node_ttl                   = $puppet_enterprise::params::puppetdb_node_ttl,
  $report_ttl                 = $puppet_enterprise::params::puppetdb_report_ttl,
) inherits puppet_enterprise::params {

  file { "${confdir}/database.ini":
    ensure => present,
    owner  => 'pe-puppetdb',
    group  => 'pe-puppetdb',
    mode   => '0640',
  }

  #Set the defaults
  Pe_ini_setting {
    path    => "${confdir}/database.ini",
    ensure  => present,
    section => 'database',
  }

  pe_ini_setting {'puppetdb_psdatabase_username':
    setting => 'username',
    value   => $database_user,
  }

  if $database_password != undef {
    pe_ini_setting {'puppetdb_psdatabase_password':
      setting => 'password',
      value   => $database_password,
    }
  }

  pe_ini_setting {'puppetdb_classname':
    setting => 'classname',
    value   => 'org.postgresql.Driver',
  }

  pe_ini_setting {'puppetdb_subprotocol':
    setting => 'subprotocol',
    value   => 'postgresql',
  }

  pe_ini_setting {'puppetdb_subname':
    setting => 'subname',
    value   => "//${database_host}:${database_port}/${database_name}${database_properties}",
  }

  pe_ini_setting {'puppetdb_gc_interval':
    setting => 'gc-interval',
    value   => $gc_interval,
  }

  pe_ini_setting {'puppetdb_node_ttl':
    setting => 'node-ttl',
    value   => $node_ttl,
  }

  pe_ini_setting {'puppetdb_node_purge_ttl':
    setting => 'node-purge-ttl',
    value   => $node_purge_ttl,
  }

  pe_ini_setting {'puppetdb_report_ttl':
    setting => 'report-ttl',
    value   => $report_ttl,
  }
}
