# Basic configuration of the razor server
#
# @param dbpassword [String] The password to the razor database.
class pe_razor::server::config(
  $dbpassword,
) {
  include pe_razor::params

  # The following directories need to be managed by root
  file { $pe_razor::params::data_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }

  file { $pe_razor::params::razor_etc:
    ensure => directory,
    owner  => 'pe-razor',
    group  => 'pe-razor',
    mode   => '0640'
  }

  file { $pe_razor::params::repo_dir:
    ensure => directory,
    owner  => 'pe-razor',
    group  => 'pe-razor',
    mode   => '0755'
  }

  # Configuration
  # This defaults file is fully managed by puppet.
  # Template uses:
  #   - $dbpassword
  file { $pe_razor::params::config_defaults_path:
    ensure  => file,
    owner   => 'root',
    mode    => '0444',
    content => template('pe_razor/config-defaults.yaml.erb')
  }

  # Only put this here if it does not exist already. The user adds
  # overrides here.
  file { "${pe_razor::params::razor_etc}/config.yaml":
    ensure  => file,
    owner   => 'root',
    content => template('pe_razor/config-defaults.yaml.erb'),
    replace => false
  }

  file { "${pe_razor::params::razor_etc}/shiro.ini":
    ensure  => file,
    owner   => 'root',
    content => template('pe_razor/shiro.ini.erb'),
    require => File[$pe_razor::params::razor_etc]
  }
}
