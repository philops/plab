# This class sets up the agent. For more information, see the [README.md](./README.md)
#
# @param manage_symlinks [Boolean] Flag to enable creation of convenience links
class puppet_enterprise::profile::agent(
  $manage_symlinks = $puppet_enterprise::manage_symlinks,
) inherits puppet_enterprise {
  pe_validate_bool($manage_symlinks)

  include puppet_enterprise::symlinks

  if $manage_symlinks {
    File <| tag == 'pe-agent-symlinks' |>
  }

}
