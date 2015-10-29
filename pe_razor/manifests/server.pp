# Main class for installing and setting up a pe-razor-server
#
#
class pe_razor::server(
  $dbpassword,
  $microkernel_url,
  $pe_tarball_base_url,
  $server_http_port,
  $server_https_port,
){
  include pe_razor::params

  # In order to install razor and its dependencies, we need to set up a package repo
  # containing the packages from a PE tarball.
  class { 'pe_razor::server::repo':
    target              => "${pe_razor::params::data_dir}/packages/razor-repo",
    pe_tarball_base_url => $pe_tarball_base_url,
  }

  # Because puppet doesn't do package dependency resolution, list all packages
  # that need to be updated.
  $packages = [
    'pe-razor-server',
    'pe-razor-libs',
    'pe-java',
  ]
  package { $packages:
    ensure  => latest,
    require => Class['pe_razor::server::repo'],
  }

  class { 'pe_razor::server::config':
    dbpassword => $dbpassword,
    require    => Package['pe-razor-server'],
  }


  class { 'pe_razor::server::upgrade':
    pe_tarball_base_url => $pe_tarball_base_url,
    require             => Class['pe_razor::server::config'],
  }

  class { '::pe_razor::server::database':
    dbpassword => $dbpassword,
    require    => Class['pe_razor::server::config'],

  }

  class { 'pe_razor::server::torquebox':
    server_http_port  => $server_http_port,
    server_https_port => $server_https_port,
    require           => Class['pe_razor::server::database'],
  }

  exec { "migrate the razor database":
    # Allow up to 60 minutes for this to run.  It should be super-fast, right
    # now, but if we get large installations and a migration that needs to do
    # substantial work and can't be lazy-evaluated, this will help.
    provider => shell,
    timeout  => 3600,
    command  => template('pe_razor/do-migrate.sh.erb'),
    unless   => template('pe_razor/do-check-migrate.sh.erb'),
    notify   => Exec["redeploy the razor application to torquebox"],
    require  => Class['pe_razor::server::database']
  }

  exec { "unpack the microkernel":
    provider => shell, timeout => 3600,
    command  => template('pe_razor/install-mk.sh.erb'),
    path     => "/usr/local/bin:/bin:/usr/bin",
    creates  => "${pe_razor::params::repo_dir}/microkernel/initrd0.img"
  }

  service { "pe-razor-server":
    ensure  => running,
    enable  => true,
  }
}
