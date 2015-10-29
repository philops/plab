# This is the class for configuring a node as a database node with Postgresql
# for PuppetDB, RBAC, Console Services, and the activity services databases for
# Puppet Enterprise.
#
# For more information, see the [README.md](./README.md)
#
# @param certname [String] Name of a certificate Postgres will use for
#        encrypting network traffic
# @param database_listen_addresses [String] The hostname and port that Postgres
#        will be listening on
# @param manage_kernel_shmmax [Boolean] Allows Postgres to manage maximum size
#        of shared kernel memory
# @param puppetdb_database_name [String] The name of the puppetdb database
# @param puppetdb_database_user [String] The user connecting to the puppetdb
#        database
# @param puppetdb_database_password [String] The password for the user
#        connecting to the puppetdb database
# @param classifier_database_name [String] The name of the classifier database
# @param classifier_database_user [String] The user connecting to the
#        classifier database
# @param classifier_database_password [String] The password for the user
#        connecting to the classifier database
# @param rbac_database_name [String] The name of the rbac database
# @param rbac_database_user [String] The user connecting to the rbac database
# @param rbac_database_password [String] The password for the user connecting
#        to the rbac database
# @param activity_database_name [String] The name of the activity database
# @param activity_database_user [String] The user connecting to the activity
#        database
# @param activity_database_password [String] The password for the user
#        connecting to the activity database
# @param localcacert [String] The path to the local CA certificate. This will
#        be used instead of the CA that is in Puppet's ssl dir.
# @param maintenance_work_mem [String] The amount of memory Postgres can use
#        when performing maintenance operations
# @param wal_buffers [String] The amount of memory to be used for the
#        Write-Ahead Log (WAL) during a transaction
# @param work_mem [String] The amount of memory to be used by Postgres for
#        internal sorts and hashes before resorting to temporary disk files
# @param checkpoint_segments [String] The maximum number of log file segments
#        between automatic Write-Ahead Log (WAL) checkpoints
# @param log_min_duration_statement [String] The amount of time, in
#        milliseconds, a statement can run before creating an entry in the Postgres
#        log
# @param effective_cache_size [String] The amount of disk space that is
#        available to a single query
# @param shared_buffers [String] The amount of memory that Postgres may use for
#        shared buffers
# @param memorysize_in_bytes [Integer] The amount of memory available in bytes
#        for managing kernal_shmmax setting
# @param console_database_name [String] This setting is no longer used
# @param console_database_user [String] This setting is no longer used
# @param console_database_password [String] This setting is no longer used
class puppet_enterprise::profile::database(
  $certname                       = $::clientcert,
  $database_listen_addresses      = $puppet_enterprise::params::database_listen_addresses,
  $manage_kernel_shmmax           = $puppet_enterprise::params::manage_kernel_shmmax,
  $puppetdb_database_name         = $puppet_enterprise::puppetdb_database_name,
  $puppetdb_database_user         = $puppet_enterprise::puppetdb_database_user,
  $puppetdb_database_password     = $puppet_enterprise::puppetdb_database_password,
  $classifier_database_name       = $puppet_enterprise::classifier_database_name,
  $classifier_database_user       = $puppet_enterprise::classifier_database_user,
  $classifier_database_password   = $puppet_enterprise::classifier_database_password,
  $rbac_database_name             = $puppet_enterprise::rbac_database_name,
  $rbac_database_user             = $puppet_enterprise::rbac_database_user,
  $rbac_database_password         = $puppet_enterprise::rbac_database_password,
  $activity_database_name         = $puppet_enterprise::activity_database_name,
  $activity_database_user         = $puppet_enterprise::activity_database_user,
  $activity_database_password     = $puppet_enterprise::activity_database_password,
  $localcacert                    = $puppet_enterprise::params::localcacert,
  $maintenance_work_mem           = $puppet_enterprise::params::maintenance_work_mem,
  $wal_buffers                    = $puppet_enterprise::params::wal_buffers,
  $work_mem                       = $puppet_enterprise::params::work_mem,
  $checkpoint_segments            = $puppet_enterprise::params::checkpoint_segments,
  $log_min_duration_statement     = $puppet_enterprise::params::log_min_duration_statement,
  $log_line_prefix                = '%m [db:%d,sess:%c,pid:%p,vtid:%v,tid:%x] ',
  $effective_cache_size           = $puppet_enterprise::params::effective_cache_size,
  $shared_buffers                 = $puppet_enterprise::params::shared_buffers,
  $memorysize_in_bytes            = $puppet_enterprise::params::memorysize_in_bytes,
  $locale                         = 'en_US.UTF-8',
  $encoding                       = 'UTF8',
  $console_database_name          = undef,
  $console_database_user          = undef,
  $console_database_password      = undef,
) inherits puppet_enterprise {

  # We would like to run silent with regards to the deprecation warning around
  # the package type's allow_virtual parameter, and so must explicitly set a
  # default for it as long as we support clients older than 3.6.1. No packages
  # are declared here, but the postgresql class has package types. We will take
  # advantage of another feature that will be deprecated at some point (dynamic
  # scope for resource defaults) to accomplish the desired suppression of the
  # deprecation warning without modifying the postgresql module itself, by
  # setting the package resource defaults here.
  Package {
    allow_virtual => $puppet_enterprise::params::allow_virtual_default,
  }

  $pgsqldir = "${puppet_enterprise::server_data_dir}/postgresql"
  $version = $puppet_enterprise::params::postgres_version
  # set our parameters for the params for to inherit
  class { '::pe_postgresql::globals':
    user                 => 'pe-postgres',
    group                => 'pe-postgres',
    client_package_name  => 'pe-postgresql',
    server_package_name  => 'pe-postgresql-server',
    contrib_package_name => 'pe-postgresql-contrib',
    service_name         => 'pe-postgresql',
    default_database     => 'pe-postgres',
    version              => $version,
    bindir               => $puppet_enterprise::server_bin_dir,
    datadir              => "${pgsqldir}/${version}/data",
    confdir              => "${pgsqldir}/${version}/data",
    psql_path            => "${puppet_enterprise::server_bin_dir}/psql",
    needs_initdb         => true,
    locale               => $locale,
    encoding             => $encoding,
  }

  include pe_postgresql::server::contrib

  # manage the directories the pgsql server will use
  file {[$pgsqldir, "${pgsqldir}/${version}" ]:
    ensure  => directory,
    mode    => '0755',
    owner   => 'pe-postgres',
    group   => 'pe-postgres',
  }

  # This is a hack to workaround the fact that the postgresql module 3.4.0
  # hardcodes /etc/sysconfig/pgsql/postgresql, even though the path in PE is
  # /etc/sysconfig/pe-pgsql/pe-postgresql. We ensure
  # /etc/sysconfig/pgsql exists so the module can create and manage
  # pgsql/postgresql, and we symlink /etc/sysconfig/pe-pgsql/pe-postgresql to
  # it.
  if ($::osfamily == 'RedHat') and ($::operatingsystemrelease !~ /^7/) {
    file { ['/etc/sysconfig/pgsql', '/etc/sysconfig/pe-pgsql']:
      ensure => directory,
    }

    file { '/etc/sysconfig/pe-pgsql/pe-postgresql':
      ensure => link,
      target => '/etc/sysconfig/pgsql/postgresql',
    }
  }

  # get the pg server up and running
  class { '::pe_postgresql::server':
    listen_addresses        => $database_listen_addresses,
    ip_mask_allow_all_users => '0.0.0.0/0',
  }

  # we only want to manage this on installs
  # If we upgrade to the new Psql we won't need this
  if $manage_kernel_shmmax {
    # set kernel.shmmax to 50% of total RAM to be able to set shared_buffers to an appropriate value
    $shmmax = $memorysize_in_bytes / 2

    exec { 'set kernel.shmmax':
      command => "sysctl -w kernel.shmmax=${shmmax}",
      path    => '/sbin/:/bin/',
      unless  => "sysctl kernel.shmmax | grep \"kernel.shmmax\s*=\s*${shmmax}$\""
    }

    pe_ini_setting { 'kernel.shmmax':
      ensure  => present,
      section => '',
      path    => '/etc/sysctl.conf',
      setting => 'kernel.shmmax',
      value   => $shmmax,
    }
  }

  file { "${pgsqldir}/${version}/data/certs" :
    ensure => directory,
    mode   => '0600',
    owner  => 'pe-postgres',
    group  => 'pe-postgres',
    before => Puppet_enterprise::Certs['pe-postgres'],
  }
  # use existing certs/key from puppet master
  # and place them in pgsql dir
  puppet_enterprise::certs { 'pe-postgres':
    certname  => $certname,
    cert_dir  => "${pgsqldir}/${version}/data/certs",
  }

  # enable ssl in postgres using certs/key
  pe_postgresql::server::config_entry { 'ssl':
    value => on,
  }

  # tell postgresql host cert name
  pe_postgresql::server::config_entry { 'ssl_cert_file':
    value => "certs/${certname}.cert.pem",
  }

  # tell postgresql host private key name
  pe_postgresql::server::config_entry { 'ssl_key_file':
    value => "certs/${certname}.private_key.pem",
  }

  # tell postgresql CA cert name
  pe_postgresql::server::config_entry { 'ssl_ca_file':
    value => $localcacert,
  }

  # These values were originally in the pe_puppetdb
  # module but are now defaults managed here
  pe_postgresql::server::config_entry { 'effective_cache_size':
    value => $effective_cache_size,
  }

  pe_postgresql::server::config_entry { 'shared_buffers':
    value => $shared_buffers,
  }

  pe_postgresql::server::config_entry { 'maintenance_work_mem':
    value => $maintenance_work_mem,
  }

  pe_postgresql::server::config_entry { 'wal_buffers':
    value => $wal_buffers,
  }

  pe_postgresql::server::config_entry { 'work_mem':
    value => $work_mem,
  }

  pe_postgresql::server::config_entry { 'checkpoint_segments':
    value => $checkpoint_segments,
  }

  pe_postgresql::server::config_entry { 'log_line_prefix':
    value => $log_line_prefix,
  }

  pe_postgresql::server::config_entry { 'log_min_duration_statement':
    value => $log_min_duration_statement,
  }

  pe_postgresql::server::pg_hba_rule { 'allow access to all ipv6':
    description => 'none',
    type        => 'host',
    database    => 'all',
    user        => 'all',
    address     => '::/0',
    auth_method => 'md5',
  }

  unless pe_empty( $puppetdb_database_password ) {
    # create the puppetdb tablespace
    # create the puppetdb database
    pe_postgresql::server::tablespace{ 'pe-puppetdb':
      location => "${pgsqldir}/puppetdb",
      require  => Class['::pe_postgresql::server'],
    }

    pe_postgresql::server::db { $puppetdb_database_name:
      user       => $puppetdb_database_user,
      password   => $puppetdb_database_password,
      tablespace => 'pe-puppetdb',
      require    => Pe_postgresql::Server::Tablespace['pe-puppetdb'],
    }

    $pg_trgm_cmd = 'CREATE EXTENSION pg_trgm;'
    pe_postgresql_psql { $pg_trgm_cmd:
      db         => $puppetdb_database_name,
      port       => $pe_postgresql::params::port,
      psql_user  => $pe_postgresql::params::user,
      psql_group => $pe_postgresql::params::group,
      psql_path  => $pe_postgresql::params::psql_path,
      unless     => "select * from pg_extension where extname='pg_trgm'",
      require    => Pe_postgresql::Server::Db[$puppetdb_database_name],
    }
  }

  unless pe_empty( $classifier_database_password ) {
    # create the classifier tablespace
    # create the classifier database
    pe_postgresql::server::tablespace{ 'pe-classifier':
      location => "${pgsqldir}/classifier",
      require  => Class['::pe_postgresql::server'],
    }

    pe_postgresql::server::db { $classifier_database_name:
      user       => $classifier_database_user,
      password   => $classifier_database_password,
      tablespace => 'pe-classifier',
      require    => Pe_postgresql::Server::Tablespace['pe-classifier'],
    }
  }

  unless pe_empty( $rbac_database_password ) {
    # create the rbac tablespace
    # create the rbac database
    pe_postgresql::server::tablespace{ 'pe-rbac':
      location => "${pgsqldir}/rbac",
      require  => Class['::pe_postgresql::server'],
    }

    pe_postgresql::server::db { $rbac_database_name:
      user       => $rbac_database_user,
      password   => $rbac_database_password,
      tablespace => 'pe-rbac',
      require    => Pe_postgresql::Server::Tablespace['pe-rbac'],
    }

    $citext_cmd = 'CREATE EXTENSION citext;'
    pe_postgresql_psql { $citext_cmd:
      db         => $rbac_database_name,
      port       => $pe_postgresql::params::port,
      psql_user  => $pe_postgresql::params::user,
      psql_group => $pe_postgresql::params::group,
      psql_path  => $pe_postgresql::params::psql_path,
      unless     => "select * from pg_extension where extname='citext'",
      require    => Pe_postgresql::Server::Db[$rbac_database_name],
    }
  }

  unless pe_empty( $activity_database_password ) {
    # create the activity tablespace
    # create the activity database
    pe_postgresql::server::tablespace{ 'pe-activity':
      location => "${pgsqldir}/activity",
      require  => Class['::pe_postgresql::server'],
    }

    pe_postgresql::server::db { $activity_database_name:
      user       => $activity_database_user,
      password   => $activity_database_password,
      tablespace => 'pe-activity',
      require    => Pe_postgresql::Server::Tablespace['pe-activity'],
    }
  }
}
