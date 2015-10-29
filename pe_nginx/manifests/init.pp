# Base class for pe_nginx.
#
# This module is expected to be used by several different services (update service, console) that could
# live on the same node.
#
# Due to that possibility, params should be avoided being added to this base class so that it can be
# consumed by end users with an `include pe_nginx`, thereby avoiding duplicate resource conflicts.
#
# In the event that params are required, consumers of this module should still use the `include
# pe_nginx` syntax over creating a class resource, and provide any overrides to this classes params via
# hiera.
class pe_nginx(
){
  include pe_nginx::params


  package { 'pe-nginx':
    ensure        => latest,
    provider      => $pe_nginx::params::package_provider,
  }

  service { 'pe-nginx':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => Package['pe-nginx'],
  }
}
