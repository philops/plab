define pe_repo::el(
  $agent_version   = $::aio_agent_version,
  $installer_build = $title,
  $pe_version      = $pe_repo::default_pe_build,
) {
  include pe_repo

  File {
    ensure => file,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
  }

  # These variables are needed by the templates
  $prefix = $pe_repo::prefix
  $master = $pe_repo::master
  $port = $settings::masterport

  file { "${pe_repo::public_dir}/${pe_version}/${installer_build}.repo":
    content => template('pe_repo/el.repo.erb'),
  }

  file { "${pe_repo::public_dir}/${pe_version}/${installer_build}.bash":
    content => template('pe_repo/el.bash.erb'),
  }

  pe_repo::repo { "${installer_build} ${pe_version}":
    agent_version   => $agent_version,
    installer_build => $installer_build,
    pe_version      => $pe_version,
    tarball_creates => "${pe_version}/${installer_build}/repodata",
    tarball_strip   => '5',
  }
}
