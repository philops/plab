class pe_razor::server::database(
  $dbpassword,
  $db_listen_address = '*'
) {
  include pe_razor::params

  # Without this, the default owner is 'pe-razor', which gets created
  # by the package (which hasn't happened yet).
  File {
    ensure => file,
    owner  => 'pe-postgres',
    group  => 'pe-postgres',
  }


  $pgsqldir = $pe_razor::params::pgsqldir
  $version = $pe_razor::params::pg_version
  # set our parameters for the params for to inherit
  class { '::pe_postgresql::globals':
    user                => 'pe-postgres',
    group               => 'pe-postgres',
    client_package_name => 'pe-postgresql',
    server_package_name => 'pe-postgresql-server',
    service_name        => 'pe-postgresql',
    default_database    => 'pe-postgres',
    version             => $version,
    bindir              => $pe_razor::params::pg_bin_dir,
    datadir             => "${pgsqldir}/${version}/data",
    confdir             => "${pgsqldir}/${version}/data",
    psql_path           => $pe_razor::params::pg_sql_path,
    needs_initdb        => true,
  }

  # manage the directories the pgsql server will use
  file {[$pgsqldir, "${pgsqldir}/${version}" ]:
    ensure  => directory,
    mode    => '0755',
    owner   => 'pe-postgres',
    group   => 'pe-postgres',
    require => Class['pe_postgresql::server::install'],
    before  => Class['pe_postgresql::server::initdb'],
  } ->

  # Ensure /etc/sysconfig/pgsql exists so the module can create and manage
  # pgsql/postgresql
  file { '/etc/sysconfig/pgsql':
    ensure => directory,
  }

  # get the pg server up and running
  class { '::pe_postgresql::server':
    listen_addresses        => $db_listen_address,
    ip_mask_allow_all_users => '0.0.0.0/0',
    package_ensure          => 'latest',
  }

  # create the razor tablespace
  # create the razor database
  pe_postgresql::server::tablespace { 'razor':
    location => "${pgsqldir}/${version}/razor",
    require  => Class['::pe_postgresql::server'],
  }
  # create our database
  pe_postgresql::server::db { 'razor':
    user       => 'razor',
    password   => $dbpassword,
    tablespace => 'razor',
    require    => Pe_postgresql::Server::Tablespace['razor'],
  }

}
