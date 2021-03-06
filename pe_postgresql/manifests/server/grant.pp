# Define for granting permissions to roles. See README.md for more details.
define pe_postgresql::server::grant (
  $role,
  $db,
  $privilege   = undef,
  $object_type = 'database',
  $object_name = $db,
  $psql_db     = $pe_postgresql::server::default_database,
  $psql_user   = $pe_postgresql::server::user,
  $port        = $pe_postgresql::server::port
) {
  $group     = $pe_postgresql::server::group
  $psql_path = $pe_postgresql::server::psql_path

  ## Munge the input values
  $_object_type = pe_upcase($object_type)
  $_privilege   = pe_upcase($privilege)

  ## Validate that the object type is known
  pe_validate_string($_object_type,
    #'COLUMN',
    'DATABASE',
    #'FOREIGN SERVER',
    #'FOREIGN DATA WRAPPER',
    #'FUNCTION',
    #'PROCEDURAL LANGUAGE',
    #'SCHEMA',
    #'SEQUENCE',
    'TABLE',
    #'TABLESPACE',
    #'VIEW',
  )

  ## Validate that the object type's privilege is acceptable
  # TODO: this is a terrible hack; if they pass "ALL" as the desired privilege,
  #  we need a way to test for it--and has_database_privilege does not
  #  recognize 'ALL' as a valid privilege name. So we probably need to
  #  hard-code a mapping between 'ALL' and the list of actual privileges that
  #  it entails, and loop over them to check them.  That sort of thing will
  #  probably need to wait until we port this over to ruby, so, for now, we're
  #  just going to assume that if they have "CREATE" privileges on a database,
  #  then they have "ALL".  (I told you that it was terrible!)
  case $_object_type {
    'DATABASE': {
      $unless_privilege = $_privilege ? {
        'ALL'   => 'CREATE',
        default => $_privilege,
      }
      pe_validate_string($unless_privilege,'CREATE','CONNECT','TEMPORARY','TEMP',
        'ALL','ALL PRIVILEGES')
      $unless_function = 'has_database_privilege'
      $on_db = $psql_db
    }
    'TABLE': {
      $unless_privilege = $_privilege ? {
        'ALL'   => 'INSERT',
        default => $_privilege,
      }
      pe_validate_string($unless_privilege,'SELECT','INSERT','UPDATE','DELETE',
        'TRUNCATE','REFERENCES','TRIGGER','ALL','ALL PRIVILEGES')
      $unless_function = 'has_table_privilege'
      $on_db = $db
    }
    default: {
      fail("Missing privilege validation for object type ${_object_type}")
    }
  }

  $grant_cmd = "GRANT ${_privilege} ON ${_object_type} \"${object_name}\" TO \"${role}\""
  pe_postgresql_psql { $grant_cmd:
    db         => $on_db,
    port       => $port,
    psql_user  => $psql_user,
    psql_group => $group,
    psql_path  => $psql_path,
    unless     => "SELECT 1 WHERE ${unless_function}('${role}', '${object_name}', '${unless_privilege}')",
    require    => Class['pe_postgresql::server']
  }

  if($role != undef and defined(Pe_postgresql::Server::Role[$role])) {
    Pe_postgresql::Server::Role[$role]->Pe_postgresql_psql[$grant_cmd]
  }

  if($db != undef and defined(Pe_postgresql::Server::Database[$db])) {
    Pe_postgresql::Server::Database[$db]->Pe_postgresql_psql[$grant_cmd]
  }
}
