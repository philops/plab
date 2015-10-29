# Define for creating a database. See README.md for more details.
define pe_postgresql::server::database(
  $dbname     = $title,
  $owner      = $pe_postgresql::server::user,
  $tablespace = undef,
  $template   = 'template0',
  $encoding   = $pe_postgresql::server::encoding,
  $locale     = $pe_postgresql::server::locale,
  $istemplate = false
) {
  $createdb_path = $pe_postgresql::server::createdb_path
  $user          = $pe_postgresql::server::user
  $group         = $pe_postgresql::server::group
  $psql_path     = $pe_postgresql::server::psql_path
  $port          = $pe_postgresql::server::port
  $version       = $pe_postgresql::server::version
  $default_db    = $pe_postgresql::server::default_database

  # Set the defaults for the postgresql_psql resource
  Pe_postgresql_psql {
    psql_user  => $user,
    psql_group => $group,
    psql_path  => $psql_path,
    port       => $port,
  }

  # Optionally set the locale switch. Older versions of createdb may not accept
  # --locale, so if the parameter is undefined its safer not to pass it.
  if ($version != '8.1') {
    $locale_option = $locale ? {
      undef   => '',
      default => "--locale=${locale} ",
    }
    $public_revoke_privilege = 'CONNECT'
  } else {
    $locale_option = ''
    $public_revoke_privilege = 'ALL'
  }

  $encoding_option = $encoding ? {
    undef   => '',
    default => "--encoding '${encoding}' ",
  }

  $tablespace_option = $tablespace ? {
    undef   => '',
    default => "--tablespace='${tablespace}' ",
  }

  $createdb_command = "${createdb_path} --port='${port}' --owner='${owner}' --template=${template} ${encoding_option}${locale_option}${tablespace_option} '${dbname}'"

  pe_postgresql_psql { "Check for existence of db '${dbname}'":
    command => 'SELECT 1',
    unless  => "SELECT datname FROM pg_database WHERE datname='${dbname}'",
    db      => $default_db,
    port    => $port,
    require => Class['pe_postgresql::server::service']
  }~>
  exec { $createdb_command :
    refreshonly => true,
    user        => $user,
    logoutput   => on_failure,
  }~>

  # This will prevent users from connecting to the database unless they've been
  #  granted privileges.
  pe_postgresql_psql {"REVOKE ${public_revoke_privilege} ON DATABASE \"${dbname}\" FROM public":
    db          => $default_db,
    port        => $port,
    refreshonly => true,
  }

  Exec[ $createdb_command ]->
  pe_postgresql_psql {"UPDATE pg_database SET datistemplate = ${istemplate} WHERE datname = '${dbname}'":
    unless => "SELECT datname FROM pg_database WHERE datname = '${dbname}' AND datistemplate = ${istemplate}",
    db     => $default_db,
  }

  # Build up dependencies on tablespace
  if($tablespace != undef and defined(Pe_postgresql::Server::Tablespace[$tablespace])) {
    Pe_postgresql::Server::Tablespace[$tablespace]->Exec[$createdb_command]
  }
}
