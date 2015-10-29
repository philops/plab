# Params file for pe_razor
#
# This class contains variables for use in the module that need to be conditionally determined, such as
# a path that is different across OS's
class pe_razor::params {

  # The current pe_razor module only supports RedHat/CentOS 6 & 7.
  $is_on_el = $::operatingsystem ? {
    'RedHat' => true,
    'CentOS' => true,
    default  => false
  }

  $is_valid_version = $::operatingsystemmajrelease ? {
    '6'       => true,
    '7'       => true,
    default   => false
  }

  # Determine the file extension. Pre-releases are .tar, releases are .tar.gz
  $file_extension = pe_build_version() ? {
    /^[^-]+-.+/ => "tar",
    default     => "tar.gz",
  }

  # We would like to run silent with regards to the deprecation warning around
  # the package type's allow_virtual parameter. However, the allow_virtual
  # parameter did not exist prior to Puppet 3.6.1. Therefore we have a few
  # places where we need to set package resource defaults dependent on what
  # version of Puppet the client is running (so long as we support clients
  # older than 3.6.1). Performing the calculation here as it is used in more
  # than one location elsewhere in the module.
  $supports_allow_virtual = versioncmp($::puppetversion,'3.6.1') >= 0
  $allow_virtual_default = $supports_allow_virtual ? {
    true  => true,
    false => undef,
  }


  $pe_razor_server_unified_layout_version = '1.0.1.0'
  # Determine razor paths based on version
  if $::pe_razor_server_version == undef or versioncmp($::pe_razor_server_version, $pe_razor_server_unified_layout_version) >= 0 {
    # AIO Paths

    # Core razor paths
    $data_dir  = '/opt/puppetlabs/server/data/razor-server'
    $repo_dir  = '/opt/puppetlabs/server/data/razor-server/repo'
    $razor_etc = '/etc/puppetlabs/razor-server'
    $config_defaults_path = '/opt/puppetlabs/server/apps/razor-server/config-defaults.yaml'

    # Postgres paths
    $pg_version  = '9.4'
    $pgsqldir    = '/opt/puppetlabs/server/data/postgresql'
    $pg_bin_dir  = '/opt/puppetlabs/server/bin'
    $pg_sql_path = '/opt/puppetlabs/server/bin/psql'

    # Java KS path
    $pe_java_ks_path = '/opt/puppetlabs/server/bin'

    # Torquebox Paths
    $torquebox_home       = '/opt/puppetlabs/server/apps/razor-server/share/torquebox'
    $razor_server         = '/opt/puppetlabs/server/apps/razor-server/share/razor-server'
    $razor_admin          = "${razor_server}/bin/razor-admin"
    $jboss_standalone_dir = "/opt/puppetlabs/server/apps/razor-server/share/torquebox/jboss/standalone"

    $upgrade_directory_ensure = absent
    $upgrade_script_ensure = absent
  }
  else {
    # Old Paths

    # Core razor paths
    $data_dir  = '/opt/puppet/razor'
    $repo_dir  = '/opt/puppet/var/razor/repo'
    $razor_etc = '/etc/puppetlabs/razor'
    $config_defaults_path = '/opt/puppet/razor/config-defaults.yaml'

    # Postgres paths
    $pg_version  = '9.2'
    $pgsqldir    = '/opt/puppet/var/lib/pgsql'
    $pg_bin_dir  = '/opt/puppet/bin'
    $pg_sql_path = '/opt/puppet/bin/psql'

    # Java KS path
    $pe_java_ks_path = '/opt/puppet/bin'

    # Torquebox Paths
    $torquebox_home       = '/opt/puppet/share/torquebox'
    $razor_server         = '/opt/puppet/share/razor-server'
    $razor_admin          = '/opt/puppet/share/razor-server/bin/razor-admin'
    $jboss_standalone_dir = '/opt/puppet/share/torquebox/jboss/standalone'

    $upgrade_directory_ensure = directory
    $upgrade_script_ensure = file

    notify { "You are using an old version of pe-razor-server. Current: \
${$::pe_razor_server_version}. See the upgrade documentation at \
http://docs.puppetlabs.com/pe/latest/razor_upgrade.html":
      loglevel => warning
    }
  }
}
