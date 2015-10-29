class pe_repo::platform::sles_10_x86_64(
  $agent_version = $::aio_agent_version,
){
  include pe_repo

  pe_repo::rpm { 'sles-10-x86_64':
    agent_version => $agent_version,
    pe_version => $pe_repo::default_pe_build,
  }
}
