class pe_repo::platform::osx_1010_x86_64(
  $agent_version = $::aio_agent_build,
){
  include pe_repo

  pe_repo::osx { 'osx-10.10-x86_64':
    agent_version => $agent_version,
    pe_version    => $pe_repo::default_pe_build,
    codename      => 'yosemite',
  }
}
