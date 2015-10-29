# Internal class for Puppet Enterprise to manage all master-services.
#
# @param metrics_enabled [Boolean] Toggle whether the metrics service is running or not.
# @param metrics_server_id [Integer] What ID to tag the metrics with
# @param metrics_jmx_enabled [Boolean] Toggle whether to run with JMX (Java Management Extensions) enabled.
# @param metrics_graphite_enabled [Boolean] Toggle whether to write metrics to Graphite.
# @param metrics_graphite_host [String] Graphite server to write metrics to..
# @param metrics_graphite_port [Integer] Port on Graphite server to write metrics to.
# @param metrics_graphite_update_interval_seconds [Integer] How often, in seconds, to wait between writing metrics to the Graphity server.
# @param profiler_enabled [Boolean] Whether to run the Java profiler.
# @param certname [String] The cert name the Server will use.
# @param static_files [Hash] Paths to static files to serve up on the master. Keys are the URLs the files will be found at, values are the paths to the folders to be served.
# @param localcacert [String] The path to the local CA cert used for generating SSL certs.
# @param java_args [Hash] Key-value pairs describing the java arguments to be passed when starting the master
# @param environments_dir_mode [String] Permissions mode to set the Puppet environments directory to. User/group will be `pe-puppet`.
# @param enable_future_parser [Boolean] Toggle use of the "future" Puppet 4 parser.
# @param manage_symlinks [Boolean] Flag to enable creation of convenience links
class puppet_enterprise::master(
  $metrics_enabled,
  $metrics_server_id,
  $metrics_jmx_enabled,
  $metrics_graphite_enabled,
  $metrics_graphite_host,
  $metrics_graphite_port,
  $metrics_graphite_update_interval_seconds,
  $profiler_enabled,
  $certname                                  = $::client_cert,
  $static_files                              = {},
  $localcacert                               = $puppet_enterprise::params::localcacert,
  $java_args                                 = $puppet_enterprise::params::puppetserver_java_args,
  $environments_dir_mode                     = '0755',
  $enable_future_parser                      = undef,
  $manage_symlinks                           = true,
) inherits puppet_enterprise::params {

  include puppet_enterprise::packages
  Package <| tag == 'pe-master-packages' |>

  include puppet_enterprise::symlinks

  $user = 'pe-puppet'
  $group = 'pe-puppet'

  if $manage_symlinks {
    File <| tag == 'pe-master-symlinks' |>
  }

  class { 'puppet_enterprise::master::puppetserver':
    certname                                 => $certname,
    localcacert                              => $localcacert,
    static_files                             => $static_files,
    java_args                                => $java_args,
    metrics_enabled                          => $metrics_enabled,
    metrics_server_id                        => $metrics_server_id,
    metrics_jmx_enabled                      => $metrics_jmx_enabled,
    metrics_graphite_enabled                 => $metrics_graphite_enabled,
    metrics_graphite_host                    => $metrics_graphite_host,
    metrics_graphite_port                    => $metrics_graphite_port,
    metrics_graphite_update_interval_seconds => $metrics_graphite_update_interval_seconds,
    profiler_enabled                         => $profiler_enabled,
  }

  File {
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '0644',
  }

  file { '/etc/puppetlabs/code/environments':
    mode    => $environments_dir_mode,
  }

  if !pe_empty($java_args) {
    pe_validate_hash($java_args)
  }

  # FIXME PACKAGING Should the packages set the permissions correctly?
  file { '/var/log/puppetlabs/puppet' :
    mode    => '0640',
  }

  # This is intended to establish the pe_build file on new compile masters.
  # The installer lays down pe_build for the master of masters.
  file { '/opt/puppetlabs/server/pe_build':
    ensure  => file,
    content => pe_build_version(),
  }

  # Start
  # puppet.conf
  Pe_ini_setting {
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
  }

  pe_ini_setting { 'puppetserver puppetconf certname' :
    setting => 'certname',
    value   => $certname,
    section => 'master',
  }

  pe_ini_setting { 'puppetserver puppetconf always_cache_features' :
    setting => 'always_cache_features',
    value   => 'true',
    section => 'master',
  }

  pe_ini_setting { 'puppetserver puppetconf user':
    setting => 'user',
    value   => $user,
    section => 'main'
  }

  pe_ini_setting { 'puppetserver puppetconf group':
    setting => 'group',
    value   => $group,
    section => 'main'
  }
  # End puppet.conf
}
