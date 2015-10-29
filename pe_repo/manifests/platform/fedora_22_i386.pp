class pe_repo::platform::fedora_22_i386(
  $agent_version = $::aio_agent_version,
){
  include pe_repo

  pe_repo::el { 'fedora-22-i386':
    agent_version => $agent_version,
    pe_version    => $pe_repo::default_pe_build,
  }
}
