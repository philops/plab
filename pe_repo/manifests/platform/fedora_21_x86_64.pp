class pe_repo::platform::fedora_21_x86_64(
  $agent_version = $::aio_agent_version,
){
  include pe_repo

  pe_repo::el { 'fedora-21-x86_64':
    agent_version => $agent_version,
    pe_version    => $pe_repo::default_pe_build,
  }
}
