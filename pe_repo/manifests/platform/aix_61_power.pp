class pe_repo::platform::aix_61_power(
  $agent_version = $::aio_agent_version,
){
  include pe_repo

  pe_repo::aix { 'aix-6.1-power':
    agent_version => $agent_version,
    pe_version => $pe_repo::default_pe_build,
  }
}
