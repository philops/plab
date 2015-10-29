class pe_repo (
  $base_path = "https://pm.puppetlabs.com/puppet-agent",
  $repo_dir  = '/opt/puppetlabs/server/data/packages',
  $prefix    = '/packages',
  $master    = $settings::server,
) {

  # The Puppet Collections version, will need to be manually bumped every time
  # Hopefully a rare occurence.
  $pc_version = "PC1"

  $root_staging_dir = '/opt/puppetlabs/server/data/staging'

  File {
    ensure => file,
    mode   => '644',
    owner  => 'root',
    group  => 'root',
  }

  if $::pe_build {
    # Then pe_build file has been laid down on node and we can use the fact
    $default_pe_build = $::pe_build
  } else {
    # We fall back to the compiling master's build version.  If and when
    # we improve puppet enterprise to allow the MoM to spin up compile masters
    # of arbitrary versions, then this will need to be revisted.
    $default_pe_build = pe_build_version()
  }

  # We provide this variable as part of the "public API" of this module; any
  # files added to this directory will be served over http, so it's a good
  # place to put custom install scripts.
  $public_dir = "${repo_dir}/public"

  # Due to the new file structure, pe_repo may be called before pe_puppetserver
  # is installed, or it may be installed on a non server platform.
  # To work around this, do an exec mkdir -p to create the repo_dir.
  # We don't want to managage it because we don't care about permissions
  # or want to prevent people from managing it. We just care about the
  # packages/public/ directory.
  exec { 'create repo_dir':
    command => "mkdir -p ${repo_dir}",
    creates => $repo_dir,
    path    => '/sbin/:/bin/',
  }

  #build file structure
  file { [$repo_dir, $public_dir]:
    ensure  => directory,
    require => Exec['create repo_dir'],
  }

  # Add a latest symlink
  file { "${public_dir}/current":
    ensure => 'link',
    target => "${public_dir}/${default_pe_build}",
  }

  # puppet labs gpg key
  file { "${public_dir}/GPG-KEY-puppetlabs":
    source => 'puppet:///modules/pe_repo/GPG-KEY-puppetlabs',
  }
}
