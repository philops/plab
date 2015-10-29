# This class configures the master node to be able to communicate with PuppetDB.
# The configuration that needs to be done is telling the master where to find
# the PuppetDB node and how to submit data.
#
# This class is called internally by the Master profile, and should not be called
# directly.
#
# @param puppetdb_host [String] The hostname of the puppetdb node.
# @param puppetdB_port [Integer] The post that puppetdb listens on.
# @param soft_write_failure [Boolean] Toggles the puppetdb.conf soft_write_failure setting.
# @param facts_terminus [String] The terminus to use to submit facts
# @param report_processor_ensure [String] Toggles presence of the puppetdb report processor in puppet.conf
class puppet_enterprise::profile::master::puppetdb(
  $puppetdb_host,
  $puppetdb_port,
  $soft_write_failure       = false,
  $facts_terminus           = 'puppetdb',
  $report_processor_ensure  = 'present',
) inherits puppet_enterprise::params {

  pe_validate_re($report_processor_ensure, [ '^(absent|present)$' ])

  @@puppet_enterprise::certs::puppetdb_whitelist_entry { "export: ${::clientcert}-for-puppetdb-whitelist":
    certname => $::clientcert,
  }

  $confdir = '/etc/puppetlabs/puppet'

  Pe_ini_setting {
    ensure  => present,
    section => 'main'
  }

  # Start
  # puppetdb.conf
  file { "${confdir}/puppetdb.conf":
    mode    => '0644',
  }

  # For PuppetDB HA, a user may pass in an Array to specify their PuppetDBs
  $puppetdb_hosts = pe_any2array($puppetdb_host)
  $puppetdb_ports = pe_any2array($puppetdb_port)
  $puppetdb_servers = pe_zip($puppetdb_hosts, $puppetdb_ports)

  each($puppetdb_servers) |$pdb_server| {
    $pdb_host = $pdb_server[0]
    $pdb_port = $pdb_server[1]
    pe_ini_subsetting { "puppetdb.conf_server_urls_${pdb_host}":
      ensure               => present,
      path                 => "${confdir}/puppetdb.conf",
      section              => 'main',
      setting              => 'server_urls',
      subsetting           => "https://${pdb_host}:${pdb_port}",
      subsetting_separator => ',',
    }
  }

  pe_ini_setting { 'puppetdb.conf_soft_write_failure':
    path    => "${confdir}/puppetdb.conf",
    setting => 'soft_write_failure',
    value   => $soft_write_failure,
  }
  # End

  # Start
  # puppet.conf
  pe_ini_setting { 'storeconfigs' :
    path    => "${confdir}/puppet.conf",
    section => 'master',
    setting => 'storeconfigs',
    value   => true,
  }

  pe_ini_setting { 'storeconfigs_backend' :
    path    => "${confdir}/puppet.conf",
    section => 'master',
    setting => 'storeconfigs_backend',
    value   => 'puppetdb',
  }

  pe_ini_subsetting { 'reports_puppetdb' :
    ensure               => $report_processor_ensure,
    path                 => "${confdir}/puppet.conf",
    section              => 'master',
    setting              => 'reports',
    subsetting           => 'puppetdb',
    subsetting_separator => ',',
  }
  # End

  file { "${confdir}/routes.yaml":
    ensure  => present,
    content => template('puppet_enterprise/master/routes.yaml.erb'),
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
    mode    => '0444',
  }
}
