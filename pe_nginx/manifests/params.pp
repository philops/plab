class pe_nginx::params {

  # Becuase the default for OracleLinux is up2date...
  if $::operatingsystem == 'OracleLinux' {
    $package_provider = 'yum'
  } elsif $::operatingsystem == 'SLES' {
    $package_provider = 'zypper'
  }


}
