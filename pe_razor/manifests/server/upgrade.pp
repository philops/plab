class pe_razor::server::upgrade(
  $pe_tarball_base_url,
){
  include pe_razor::params

  $upgrade_dir = '/opt/puppet/razor/upgrade'

  file { $upgrade_dir:
    ensure => $::pe_razor::params::upgrade_directory_ensure,
    force  => true,
  }

  # Get the pe version of the master
  # Template uses:
  #   - new_pe_version
  #   - pe_tarball_base_url
  $new_pe_version = pe_build_version()
  file { "${upgrade_dir}/upgrade.bash":
    ensure  => $::pe_razor::params::upgrade_script_ensure,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => template('pe_razor/upgrade.bash.erb'),
  }

  file { "${upgrade_dir}/pe-code-migration.rb":
    ensure => $::pe_razor::params::upgrade_script_ensure,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/pe_razor/pe-code-migration.rb',
  }

}
