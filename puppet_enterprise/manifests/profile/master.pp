# This class sets up the master. For more information, see the [README.md](./README.md)
#
# @param ca_host [String] The hostname of the node acting as a certificate authority.
# @param ca_port [Integer] The port the CA service is listening on.
# @param console_host [String] The hostname of the node acting as the PE Console.
# @param enable_ca_proxy [Boolean] Enable the internal PE CA proxy that will forward agent CA requests to the @ca_host
# @param dashboard_port [Integer] The port the PE console is listening on.
# @param puppetdb_host [String] The hostname of the PuppetDB host.
# @param puppetdb_port [Integer] The port the PuppetDB host is listening on.
# @param console_server_certname [String] The name of the console's SSL certificate.
# @param certname [String] The name of the the master SSL certificate.
# @param classifier_host [String] The hostname of the PE Classifier.
# @param classifier_port [Integer] The port the PE Classifter is listening on.
# @param classifier_url_prefix [String] What to prefix to URLs used with the classifier.
# @param console_client_certname [String]  The name of the certificate to use when connecting to the PE Console.
# @param classifier_client_certname [String] The name of the certificate to use when connecting to the PE Classifier.
# @param dns_alt_names [String] *Deprecated* Alternate DNS names for the master to accept/use.
# @param localcacert [String] Certificate of the CA to use when verifying certificates.
# @param java_args [Hash] Key-value pairs describing the java arguments to be passed when starting the master.
# @param metrics_enabled [Boolean] Flag to enable the master metrics logging system.
# @param metrics_server_id [String] Unique identifier for this server in the metrics backend.
# @param metrics_jmx_enabled [Boolean] Flag to enable JMX on metrics.
# @param metrics_graphite_enabled [Boolean] Flag to enable logging metrics to Graphite.
# @param metrics_graphite_host [String] The name of the Graphite server to log metrics to.
# @param metrics_graphite_port [Integer] the port the Graphite server is listening on.
# @param metrics_graphite_update_interval_seconds [Integer] How often to write metrics to the Graphite server.
# @param profiler_enabled [Boolean] Flag to enable the profiler.
# @param manage_symlinks [Boolean] Flag to enable creation of convenience links
# @param r10k_remote [String] The git url for the pe_r10k configuration
# @param r10k_private_key [String] The rugged private key path for pe_r10k configuration
# @param facts_terminus [String] The terminus to use when agents submit facts
# @param environmentpath [String] Set environmentpath in puppet.conf
class puppet_enterprise::profile::master(
  $ca_host                                  = $puppet_enterprise::certificate_authority_host,
  $ca_port                                  = $puppet_enterprise::certificate_authority_port,
  $certname                                 = $::clientcert,
  $classifier_client_certname               = $puppet_enterprise::params::classifier_client_certname,
  $classifier_host                          = $puppet_enterprise::console_host,
  $classifier_port                          = $puppet_enterprise::api_port,
  $classifier_url_prefix                    = $puppet_enterprise::classifier_url_prefix,
  $console_client_certname                  = $puppet_enterprise::params::console_client_certname,
  $console_host                             = $puppet_enterprise::console_host,
  $console_server_certname                  = $puppet_enterprise::console_host,
  $dashboard_port                           = $puppet_enterprise::params::dashboard_ssl_listen_port,
  $dns_alt_names                            = undef,
  $enable_ca_proxy                          = true,
  $enable_future_parser                     = undef,
  $facts_terminus                           = 'puppetdb',
  $java_args                                = $puppet_enterprise::params::puppetserver_java_args,
  $localcacert                              = $puppet_enterprise::params::localcacert,
  $manage_symlinks                          = $puppet_enterprise::manage_symlinks,
  $metrics_enabled                          = true,
  $metrics_graphite_enabled                 = false,
  $metrics_graphite_host                    = 'graphite',
  $metrics_graphite_port                    = 2003,
  $metrics_graphite_update_interval_seconds = 5,
  $metrics_jmx_enabled                      = true,
  $metrics_server_id                        = $::hostname,
  $profiler_enabled                         = true,
  $puppetdb_host                            = $puppet_enterprise::puppetdb_host,
  $puppetdb_port                            = $puppet_enterprise::puppetdb_port,
  $r10k_remote                              = undef,
  $r10k_private_key                         = undef,
  $r10k_proxy                               = undef,
  $environmentpath                          = $::settings::environmentpath,
) inherits puppet_enterprise {
  pe_validate_bool($manage_symlinks)

  if ($dns_alt_names != undef) {
    warning('Setting $puppet_enterprise::profile::master::dns_alt_names is no longer necessary; please remove any dns_alt_names from the node classifier.')
  }

  pe_validate_bool($enable_ca_proxy)

  $compile_master = $servername and $servername != $::fqdn
  $current_server_version = pe_pick($::pe_server_version, $::pe_version, 'NOT-INSTALLED')
  $compiling_server_version = pe_compiling_server_version()
  $compiling_server_aio_build = pe_compiling_server_aio_build()
  if $compile_master and ($compiling_server_aio_build != $::aio_agent_build) {
    fail("This compile master has a PE version of '${current_server_version}' and an aio puppet-agent version of '${::aio_agent_build}', while the master of masters has version '${compiling_server_version}' and an aio puppet-agent version of '${compiling_server_aio_build}'. Please ensure that the PE versions are consistent across all Puppet masters by following the LEI upgrade documentation.")
  }

  $confdir = '/etc/puppetlabs/puppet'

  Pe_ini_setting {
    ensure  => present,
    path    => "${confdir}/puppet.conf",
    section => 'master',
    notify  => Service['pe-puppetserver'],
  }

  @@puppet_enterprise::certs::rbac_whitelist_entry { "export: ${certname}-for-rbac":
    certname => $certname,
  }

  if $enable_ca_proxy {
    # A reverse proxy between the master and the ca will be configured,
    # allowing agents to have their ca traffic silently forwarded
    $ca_namespace   = 'puppetlabs.enterprise.services.reverse-proxy.reverse-proxy-ca-service'
    $ca_service     = 'reverse-proxy-ca-service'
    $ca_conf_ensure = file
    $ca_setting_ensure = present
  }
  else {
    # We disable the certificate-authority-service on masters.
    # Relevant resources are collected and overridden in the ca profile
    $ca_namespace   = 'puppetlabs.services.ca.certificate-authority-disabled-service'
    $ca_service     = 'certificate-authority-disabled-service'
    $ca_conf_ensure = absent
    $ca_setting_ensure = absent
  }

  puppet_enterprise::trapperkeeper::bootstrap_cfg { 'certificate-authority-service' :
    container => 'puppetserver',
    namespace => $ca_namespace,
    service   => $ca_service,
    require   => Package['pe-puppetserver'],
    notify    => Service['pe-puppetserver'],
  }

  # Uses
  #   $ca_host
  #   $ca_port
  #   $certname
  #   $localcacert
  file { '/etc/puppetlabs/puppetserver/conf.d/ca.conf':
    ensure  => $ca_conf_ensure,
    require => Package['pe-puppetserver'],
  }

  Pe_hocon_setting {
    ensure  => present,
    notify  => Service['pe-puppetserver'],
  }

  pe_hocon_setting{ 'certificate-authority.proxy-config.proxy-target-url':
    ensure  => $ca_setting_ensure,
    path    => '/etc/puppetlabs/puppetserver/conf.d/ca.conf',
    setting => 'certificate-authority.proxy-config.proxy-target-url',
    value   => "https://${ca_host}:${ca_port}",
    require => Package['pe-puppetserver'],
  }
  pe_hocon_setting{ 'certificate-authority.proxy-config.ssl-opts.ssl-cert':
    ensure  => $ca_setting_ensure,
    path    => '/etc/puppetlabs/puppetserver/conf.d/ca.conf',
    setting => 'certificate-authority.proxy-config.ssl-opts.ssl-cert',
    value   => "/etc/puppetlabs/puppet/ssl/certs/${certname}.pem",
    require => Package['pe-puppetserver'],
  }
  pe_hocon_setting{ 'certificate-authority.proxy-config.ssl-opts.ssl-key':
    ensure  => $ca_setting_ensure,
    path    => '/etc/puppetlabs/puppetserver/conf.d/ca.conf',
    setting => 'certificate-authority.proxy-config.ssl-opts.ssl-key',
    value   => "/etc/puppetlabs/puppet/ssl/private_keys/${certname}.pem",
    require => Package['pe-puppetserver'],
  }
  pe_hocon_setting{ 'certificate-authority.proxy-config.ssl-opts.ssl-ca-cert':
    ensure  => $ca_setting_ensure,
    path    => '/etc/puppetlabs/puppetserver/conf.d/ca.conf',
    setting => 'certificate-authority.proxy-config.ssl-opts.ssl-ca-cert',
    value   => $localcacert,
    require => Package['pe-puppetserver'],
  }

  # 'Updating puppet.conf node terminus'
  if ! pe_empty($classifier_host) {
    class { 'puppet_enterprise::profile::master::classifier' :
      classifier_host       => $classifier_host,
      classifier_port       => $classifier_port,
      classifier_url_prefix => $classifier_url_prefix,
      notify                => Service['pe-puppetserver'],
      require               => Package['pe-puppetserver'],
    }
  }

  # Copy the crl from the ca is we're a secondary master
  # and if we're the ca just move it to the hostcrl as the canonical location
  file { $puppet_enterprise::params::hostcrl:
    ensure  => file,
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
    mode    => '0644',
    content => file($::settings::cacrl, $::settings::hostcrl, '/dev/null'),
    require => Package['pe-puppetserver'],
  }

  file { "${puppet_enterprise::params::ssl_dir}/private_keys":
    ensure  => directory,
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
    require => Package['pe-puppetserver'],
  }

  file { "${puppet_enterprise::params::ssl_dir}/private_keys/${::clientcert}.pem":
    ensure  => file,
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
    require => Package['pe-puppetserver'],
    before  => Service['pe-puppetserver'],
  }

  # PMT access to pe_only content
  pe_ini_setting { 'module_groups' :
    section => 'main',
    setting => 'module_groups',
    value   => 'base+pe_only',
  }

  pe_ini_setting { 'environmentpath_setting':
    setting => 'environmentpath',
    value   => $environmentpath,
    section => 'main',
  }

  unless $::custom_auth_conf == 'true' {
    class { 'puppet_enterprise::profile::master::auth_conf' :
      console_client_certname    => $console_client_certname,
      classifier_client_certname => $classifier_client_certname,
      require                    => Package['pe-puppetserver'],
      notify                     => Service['pe-puppetserver'],
    }
  }

  class { 'puppet_enterprise::profile::master::puppetdb' :
    puppetdb_host      => $puppetdb_host,
    puppetdb_port      => $puppetdb_port,
    soft_write_failure => false,
    facts_terminus     => $facts_terminus,
    notify             => Service['pe-puppetserver'],
    require            => Package['pe-puppetserver'],
  }

  if !pe_empty($java_args) {
    pe_validate_hash($java_args)
  }

  class { 'puppet_enterprise::master' :
    certname                                 => $certname,
    static_files                             => {'/packages' => "${puppet_enterprise::packages_dir}/public"},
    localcacert                              => $localcacert,
    java_args                                => $java_args,
    metrics_enabled                          => $metrics_enabled,
    metrics_server_id                        => $metrics_server_id,
    metrics_jmx_enabled                      => $metrics_jmx_enabled,
    metrics_graphite_enabled                 => $metrics_graphite_enabled,
    metrics_graphite_host                    => $metrics_graphite_host,
    metrics_graphite_port                    => $metrics_graphite_port,
    metrics_graphite_update_interval_seconds => $metrics_graphite_update_interval_seconds,
    profiler_enabled                         => $profiler_enabled,
    enable_future_parser                     => $enable_future_parser,
    manage_symlinks                          => $manage_symlinks,
  }

  # PE MODULE DEPLOYMENT
  # Puppet Enterprise supported deployments need to have a base set of modules
  # installed. These modules are not packaged using rpm or deb, but come from
  # tarball sources. Ensure that each required module is retrieved and
  # deployed.

  $sharedir = $::osfamily ? {
    'windows' => "${::common_appdata}/PuppetLabs/puppet/share",
    default   => "${puppet_enterprise::server_share_dir}/puppet_enterprise",
  }
  $tarball_staging = "${sharedir}/pe_modules"

  file { $sharedir:
    ensure => directory,
    owner  => $puppet_enterprise::params::root_user,
    group  => $puppet_enterprise::params::root_group,
    mode   => '0755',
  }
  file { $tarball_staging:
    ensure  => directory,
    purge   => true,
    recurse => true,
    force   => true,
    source  => [
      $puppet_enterprise::module_tarballsrc,
      "puppet:///${puppet_enterprise::module_mountpoint}/",
    ],
    require => Pe_anchor['puppet_enterprise:barrier:ca'],
  }

  # Template uses:
  #   - $puppet_enterprise::system_module_dir
  #   - $puppet_enterprise::puppetlabs_bin_dir
  #   - $tarball_staging
  file { "${tarball_staging}/install.sh":
    ensure  => file,
    mode    => '0755',
    content => template("${module_name}/master/install_module_tarballs.sh.erb"),
  }

  exec { 'Extract PE Modules':
    command     => "${tarball_staging}/install.sh",
    subscribe   => File[$tarball_staging],
    refreshonly => true,
  }

  $public_packages_dir = "${puppet_enterprise::packages_dir}/public"

  # This directory is managed by pe_repo.  However, if this directory does not
  # exist and pe_repo is not part of the classification (during initial installation
  # puppet apply) then an error will be thrown by Puppet's fileserver mount code.
  exec { "Ensure public dir ${public_packages_dir}":
      command => "mkdir -p ${public_packages_dir}",
      path    => '/sbin/:/bin/',
      unless  => "ls ${public_packages_dir}",
      require => Package['pe-puppetserver'],
  }

  # FILESERVER
  # Allow Puppet to serve puppet-agent packages from the public fileserver set up
  # by pe_repo.
  puppet_enterprise::fileserver_conf { "${puppet_enterprise::packages_mountpoint}":
    mountpoint => $puppet_enterprise::packages_mountpoint,
    path       => $public_packages_dir,
    require    => Exec["Ensure public dir ${public_packages_dir}"],
  }

  if !pe_empty($r10k_remote) {

    # If users declare r10k via the installer we automatically enable
    # rugged support if they specify a private_key so we have no
    # external dependencies on the os providing git. This also
    # allows us to hardcode a path to the key without knowing what
    # user account they will run r10k as in the future.

    if !pe_empty($r10k_private_key) {
      pe_validate_absolute_path($r10k_private_key)

      $git_settings = {
        'provider'    => 'rugged',
        'private_key' => $r10k_private_key,
      }
    }
    else {
      $git_settings = undef
    }

    if !pe_empty($r10k_proxy) {

      $forge_settings = {
        'proxy' => $r10k_proxy,
      }
    }
    else {
      $forge_settings = undef
    }

    class {'pe_r10k':
      remote         => $r10k_remote,
      git_settings   => $git_settings,
      forge_settings => $forge_settings,
      r10k_basedir   => $environmentpath,
    }
  }
  else {
    # If the user did not specify a remote, then only include
    # the package and not the configuration. We don't want to
    # include the main class here as that prevents the user
    # from using a class resource to declare their configuration
    include pe_r10k::package
  }

}
