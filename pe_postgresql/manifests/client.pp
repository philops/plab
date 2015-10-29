# Install client cli tool. See README.md for more details.
class pe_postgresql::client (
  $package_name   = $pe_postgresql::params::client_package_name,
  $package_ensure = 'present'
) inherits pe_postgresql::params {
  pe_validate_string($package_name)

  package { 'postgresql-client':
    ensure  => $package_ensure,
    name    => $package_name,
    tag     => 'postgresql',
  }

  $file_ensure = $package_ensure ? {
    'present' => 'file',
    true      => 'file',
    'absent'  => 'absent',
    false     => 'absent',
    default   => 'file',
  }
  file { "${pe_postgresql::params::bindir}/validate_postgresql_connection.sh":
    ensure => $file_ensure,
    source => "puppet:///modules/pe_postgresql/validate_postgresql_connection.sh",
    owner  => 0,
    group  => 0,
    mode   => '0755',
  }

}
