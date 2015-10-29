class pe_repo::platform::aix_53_power(
  $agent_version = $::aio_agent_version,
){
  include pe_repo

  pe_repo::aix { 'aix-5.3-power':
    agent_version => $agent_version,
    pe_version => $pe_repo::default_pe_build,
  }
}
