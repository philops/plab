class pe_repo::platform::debian_6_amd64(
  $agent_version = $::aio_agent_version,
){
  include pe_repo

  pe_repo::debian { 'debian-6-amd64':
    agent_version => $agent_version,
    codename   => 'squeeze',
    pe_version => $pe_repo::default_pe_build,
  }
}
