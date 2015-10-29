class pe_repo::platform::el_4_i386(
  $agent_version = $::aio_agent_version,
){
  include pe_repo

  pe_repo::rpm { 'el-4-i386':
    agent_version => $agent_version,
    pe_version => $pe_repo::default_pe_build,
  }
}
