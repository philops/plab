class pe_repo::platform::ubuntu_1204_i386(
  $agent_version = $::aio_agent_version,
){
  include pe_repo

  pe_repo::debian { 'ubuntu-12.04-i386':
    agent_version => $agent_version,
    codename   => 'precise',
    pe_version => $pe_repo::default_pe_build,
  }
}
