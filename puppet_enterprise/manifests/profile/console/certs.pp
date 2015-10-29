# Profile for configuring dashboard ssl certs.
#
#
# @param certname [String] The certname the console will use to encrypt network traffic.
# @param localcacert [String] The path to the local CA certificate. This will be used instead of the
#        CA that is in Puppet's ssl dir.
# @param hostcrl [String] Path to certificate revocation list file.
class puppet_enterprise::profile::console::certs(
  $certname    = $::clientcert,
  $localcacert = $puppet_enterprise::params::localcacert,
  $hostcrl     = $puppet_enterprise::params::hostcrl,
) inherits puppet_enterprise::params {
  $classifier_client_certname = $puppet_enterprise::params::classifier_client_certname
  $console_client_certname = $puppet_enterprise::params::console_client_certname
  $console_server_certname = $certname

  $services_cert_dir = "${puppet_enterprise::server_data_dir}/console-services/certs"

  file { $services_cert_dir :
    ensure => directory,
    mode   => '0600',
    owner  => 'pe-console-services',
    group  => 'pe-console-services',
    before => Puppet_enterprise::Certs[ 'pe-console-services::server_cert',
                                        'pe-console-services::client_cert',
                                        'pe-console-services::classifier::client_cert'],
  }
  puppet_enterprise::certs { 'pe-console-services::server_cert' :
    certname  => $console_server_certname,
    owner     => 'pe-console-services',
    group     => 'pe-console-services',
    cert_dir  => $services_cert_dir,
    append_ca => true,
    before    => File[ '/etc/puppetlabs/console-services/conf.d/webserver.conf' ],
  }
  puppet_enterprise::certs { 'pe-console-services::client_cert' :
    certname => $console_client_certname,
    owner    => 'pe-console-services',
    group    => 'pe-console-services',
    cert_dir => $services_cert_dir,
    before   => Puppet_enterprise::Trapperkeeper::Console_services[ 'console-services' ]
  }
  puppet_enterprise::certs { 'pe-console-services::classifier::client_cert' :
    certname => $classifier_client_certname,
    owner    => 'pe-console-services',
    group    => 'pe-console-services',
    cert_dir => $services_cert_dir,
    before   => Puppet_enterprise::Trapperkeeper::Classifier[ 'console-services' ]
  }
}
