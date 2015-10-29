# == Class: puppet_enterprise::packages
#
# This class contains virtual resources for all packages managed by PE.
# This is necessary as a single node may contain multiple profiles
# where each profile could want to install the same package, e.g.
# pe-java, causing a compilation error.
#
# === Examples
#
# include puppet_enterprise::packages
#
# Package <| tag == 'master' |>
#
class puppet_enterprise::packages{
  include puppet_enterprise::params

  # Note on allow_virtual:
  # We would like to run silent with regards to the deprecation warning around
  # the package type's allow_virtual parameter, and so must explicitly set a
  # default for it. This may be removed after we deprecate support for clients
  # older than 3.6.1.
  Package {
    ensure        => latest,
    provider      => $puppet_enterprise::params::package_provider,
    allow_virtual => $puppet_enterprise::params::allow_virtual_default,
  }


  @package { 'pe-java':
    tag => [ 'pe-master-packages', 'pe-puppetdb-packages'],
  }

  @package { 'pe-puppetdb':
    tag => 'pe-puppetdb-packages',
  }

  @package { 'pe-console-services':
    tag => 'pe-console-packages',
  }

  @package { [
    'pe-puppet-license-cli',
    'pe-puppetdb-termini',
    'pe-console-services-termini',
    'pe-puppetserver',
  ]:
    tag => 'pe-master-packages',
  }

  @package { 'pe-activemq':
    tag => 'pe-activemq-packages',
  }

}
