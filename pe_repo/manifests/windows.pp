# Defined type for downloading the windows MSI.
# This is needed to support agent upgrades, there is currently no support for it in
# install.bash
#
# This defined type only handles creating the folder structure and the downloading
# of the MSI for serving over the network along with the other packages.
define pe_repo::windows(
  $arch,
  $agent_version   = $::aio_agent_version,
  $installer_build = $title,
  $pe_version      = $pe_repo::default_pe_build,
){
  include pe_repo

  File {
    ensure => file,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
  }

  $msi_target = "${pe_repo::public_dir}/${pe_version}/${installer_build}"
  $msi_name = "puppet-agent-${arch}.msi"

  if ! defined(File[$msi_target]) {
    file { $msi_target:
      ensure => directory,
      mode   => '755',
      owner  => root,
      group  => root,
    }
  }

  # Since the msi is not tarred up, we just want pe_staing::file, not deploy
  pe_staging::file { $msi_name:
    source  => "${pe_repo::base_path}/${pe_version}/${agent_version}/repos/windows/${msi_name}",
    target  => "${msi_target}/${msi_name}",
    require => File[$pe_repo::public_dir, $msi_target],
  }
}
