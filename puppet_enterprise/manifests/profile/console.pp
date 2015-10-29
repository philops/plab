# Profile for configuring the puppet enterprise console.
#
#
# @param ca_host [String] The certificate authority host name.
# @param certname [String] The certname the console will use to encrypt network traffic.
# @param database_host [String] The hostname running PostgreSQL.
# @param database_port [Integer] The port that PostgreSQL is listening on.
# @param database_properties [String] A url encoded string of JDBC options.
# @param master_host [String] The hostname of the Puppet Master.
# @param master_certname [String] The master certificate name.
# @param puppetdb_host [String] The hostname running puppetdb.
# @param puppetdb_port [Integer] The port that puppetdb is listening on.
# @param secret_token [String] Used to validate cookies.  Note that changing this will invalidate
#        current sessions.
# @param listen_address [String] The network interface used by the console.
# @param ssl_listen_address [String] The network interface used by the console for ssl connections.
# @param dashboard_listen_port [Integer] The port that the dashboard is listening on.
# @param dashboard_ssl_listen_port [Integer] The port that the dashboard is listening on for ssl
#        connections.
# @param dashboard_database_name [String] The name of the dashboard database.
# @param dashboard_database_user [String] The user account for the dashboard DB.
# @param dashboard_database_password [String] The password for the user set by
#        dashboard_database_user.
# @param console_ssl_listen_port [Integer] The port that the console is listening on for ssl
#        connections.
# @param console_services_listen_port [Integer] The port that console services is listening on.
#        The default is 4430.
# @param console_services_ssl_listen_port [Integer] The port that console services is listening
#        on for ssl connections. The default is 4431.
# @param console_services_api_listen_port [Integer] The port that the console services api is
#        listening on. The default is 4432.
# @param console_services_api_ssl_listen_port [Integer] The port that the console services api
#        is listening on for ssl connections. The default is 4433.
# @param console_services_plaintext_status_enabled [Boolean] This parameter will enable the
#        plain HTTP version of the console services status endpoint. The default value is false.
# @param console_services_plaintext_status_port [Boolean] The port that the plain HTTP status endpoint
#        listens on. The default is 8123.
#        plain HTTP version of the console services status endpoint. The default value is false.
# @param activity_database_name [String] The activity database name.
# @param activity_database_user [String] The username for login to the activity DB.
# @param activity_database_password [String] The password for user defined by activity_database_user.
# @param activity_url_prefix [String] The url prefix for the activity api.
# @param classifier_database_name [String] The name for classifier's database.
# @param classifier_database_user [String] The username that can login to the classifier DB.
# @param classifier_database_password [String] The password for the user defined by
#        classifier_database_user.
# @param classifier_url_prefix [String] The url prefix for the classifier api.
# @param classifier_synchronization_period [Integer] How often to synchronize classification data between the master and classifier.
# @param classifier_prune_threshold [Integer] How many days of node check-ins to keep in the classifier database.
# @param rbac_database_name [String] The name for the rbac service's database.
# @param rbac_database_user [String] The username that can login to the rbac DB.
# @param rbac_database_password [String] The password for the user defined by rbac_database_user.
# @param rbac_url_prefix [String] The url prefix for the rbac api.
# @param rbac_password_reset_expiration [Integer] When a user doesn't remember their current password,
#        an administrator can generate a token for them to change their password. The duration, in
#        hours, that this generated token is valid can be changed with this config parameter. The
#        default value is 24.
# @param rbac_session_timeout [Integer] Positive integer that specifies how long a user's session
#        should last in minutes. The default value is 60.
# @param rbac_failed_attempts_lockout [Integer] This parameter is a positive integer that specifies
#        how many failed login attempts are allowed on an account before that account is revoked.
#        The default value is 10.
# @param rbac_ds_trust_chain [String] This parameter is file path string that indicates the location
#        of a certificate to use when contacting the directory service configured for use with RBAC
#        over LDAPS.
# @param localcacert [String] The path to the local CA certificate. This will be used instead of the
#        CA that is in Puppet's ssl dir.
# @param hostcrl [String] Path to certificate revocation list file.
# @param delayed_job_workers [Integer] Number of delayed job workers.
# @param disable_live_management [Boolean] This parameter will disable live management when set to
#        true. The default is false.
# @param migrate_db [Boolean] This parameter will allow automatic migration of the database.
# @param whitelisted_certnames [Array] An array of certificates allowed to communicate directly with
#        the console. This list is added to the base PE certificate list.
# @param java_args [String] Command line options for the Java binary, most notably
#        the -Xmx (max heap size) flag.
# @param browser_ssl_cert [String] Sets the path to the server certificate PEM file used by the
#        console for HTTPS.
# @param browser_ssl_private_key [String] For use with a custom CA, the path to a private key for
#        your public console ca certificate.
# @param browser_ssl_cert_chain [String] For use with a custom CA, the path to the ca certificate
#        for use with your public console.
# @param browser_ssl_ca_cert [String] For use with a custom CA, the path to the console's certificate.
class puppet_enterprise::profile::console (
  $ca_host                                   = $puppet_enterprise::certificate_authority_host,
  $certname                                  = $::clientcert,
  $database_host                             = $puppet_enterprise::database_host,
  $database_port                             = $puppet_enterprise::database_port,
  $database_properties                       = $puppet_enterprise::database_properties,
  $master_host                               = $puppet_enterprise::puppet_master_host,
  $master_certname                           = $puppet_enterprise::puppet_master_host,
  $puppetdb_host                             = $puppet_enterprise::puppetdb_host,
  $puppetdb_port                             = $puppet_enterprise::puppetdb_port,
  $secret_token                              = '',
  $listen_address                            = $puppet_enterprise::params::plaintext_address,
  $ssl_listen_address                        = $puppet_enterprise::params::ssl_address,
  $dashboard_listen_port                     = $puppet_enterprise::params::dashboard_listen_port,
  $dashboard_ssl_listen_port                 = $puppet_enterprise::params::dashboard_ssl_listen_port,
  $dashboard_database_name                   = $puppet_enterprise::dashboard_database_name,
  $dashboard_database_user                   = $puppet_enterprise::dashboard_database_user,
  $dashboard_database_password               = $puppet_enterprise::dashboard_database_password,
  $console_ssl_listen_port                   = $puppet_enterprise::console_port,
  $console_services_listen_port              = $puppet_enterprise::params::console_services_listen_port,
  $console_services_ssl_listen_port          = $puppet_enterprise::params::console_services_ssl_listen_port,
  $console_services_api_listen_port          = $puppet_enterprise::params::console_services_api_listen_port,
  $console_services_api_ssl_listen_port      = $puppet_enterprise::api_port,
  $console_services_plaintext_status_enabled = false,
  $console_services_plaintext_status_port    = 8123,
  $activity_url_prefix                       = $puppet_enterprise::params::activity_url_prefix,
  $activity_database_name                    = $puppet_enterprise::activity_database_name,
  $activity_database_user                    = $puppet_enterprise::activity_database_username,
  $activity_database_password                = $puppet_enterprise::activity_database_password,
  $classifier_database_name                  = $puppet_enterprise::classifier_database_name,
  $classifier_database_user                  = $puppet_enterprise::classifier_database_user,
  $classifier_database_password              = $puppet_enterprise::classifier_database_password,
  $classifier_url_prefix                     = $puppet_enterprise::params::classifier_url_prefix,
  $classifier_synchronization_period         = $puppet_enterprise::params::classifier_synchronization_period,
  $classifier_prune_threshold                = $puppet_enterprise::params::classifier_prune_threshold,
  $rbac_database_name                        = $puppet_enterprise::rbac_database_name,
  $rbac_database_user                        = $puppet_enterprise::rbac_database_username,
  $rbac_database_password                    = $puppet_enterprise::rbac_database_password,
  $rbac_url_prefix                           = $puppet_enterprise::params::rbac_url_prefix,
  $rbac_password_reset_expiration            = undef,
  $rbac_session_timeout                      = undef,
  $rbac_failed_attempts_lockout              = undef,
  $rbac_ds_trust_chain                       = undef,
  $localcacert                               = $puppet_enterprise::params::localcacert,
  $hostcrl                                   = $puppet_enterprise::params::hostcrl,
  $delayed_job_workers                       = 2,
  $disable_live_management                   = true,
  $migrate_db                                = false,
  $whitelisted_certnames                     = [],
  $java_args                                 = $puppet_enterprise::params::console_services_java_args,
  $browser_ssl_cert                          = undef,
  $browser_ssl_private_key                   = undef,
  $browser_ssl_cert_chain                    = undef,
  $browser_ssl_ca_cert                       = undef,
  $proxy_read_timeout                        = 120,
) inherits puppet_enterprise {

  $classifier_client_certname = $puppet_enterprise::params::classifier_client_certname
  $console_client_certname    = $puppet_enterprise::params::console_client_certname
  $console_server_certname    = $certname

  class { 'puppet_enterprise::profile::console::certs':
    certname    => $certname,
    localcacert => $localcacert,
    hostcrl     => $hostcrl,
  }

  include puppet_enterprise::packages
  Package <| tag == 'pe-console-packages' |> {
    before => Class['puppet_enterprise::profile::console::console_services_config'],
  }

  if ($browser_ssl_cert_chain != undef) {
    warning('Please use the node classifier to remove the parameter browser_ssl_cert_chain from the puppet_enterprise::profile::console::proxy class.')
  }

  if ($browser_ssl_ca_cert != undef) {
    warning('Please use the node classifier to remove the parameter browser_ssl_ca_cert from the puppet_enterprise::profile::console::proxy class.')
  }

  # Unfortunately because we have no HOCON module
  # we have to keep the webserver config at the profile level.
  # When a HOCON module exists this class will consist of entries in
  # console-services' webserver/global confs for the apis (nc, rbac, activity).
  class { 'puppet_enterprise::profile::console::console_services_config':
    certname              => $certname,
    listen_address        => $listen_address,
    listen_port           => $console_services_listen_port,
    ssl_listen_address    => $ssl_listen_address,
    ssl_listen_port       => $console_services_ssl_listen_port,
    api_listen_port       => $console_services_api_listen_port,
    api_ssl_listen_port   => $console_services_api_ssl_listen_port,
    localcacert           => $localcacert,
    classifier_url_prefix => $classifier_url_prefix,
    activity_url_prefix   => $activity_url_prefix,
    rbac_url_prefix       => $rbac_url_prefix,
    status_proxy_enabled  => $console_services_plaintext_status_enabled,
    status_proxy_port     => $console_services_plaintext_status_port,
    notify                => Service[ 'pe-console-services' ],
  }

  puppet_enterprise::trapperkeeper::activity { 'console-services' :
    database_host       => $database_host,
    database_port       => $database_port,
    database_name       => $activity_database_name,
    database_user       => $activity_database_user,
    database_password   => $activity_database_password,
    database_properties => $database_properties,
    rbac_host           => '127.0.0.1',
    rbac_port           => $console_services_api_listen_port,
    rbac_url_prefix     => $rbac_url_prefix,
    notify              => Service['pe-console-services'],
  }

  puppet_enterprise::trapperkeeper::rbac { 'console-services' :
    certname                  => $certname,
    database_host             => $database_host,
    database_port             => $database_port,
    database_name             => $rbac_database_name,
    database_user             => $rbac_database_user,
    database_password         => $rbac_database_password,
    database_properties       => $database_properties,
    password_reset_expiration => $rbac_password_reset_expiration,
    session_timeout           => $rbac_session_timeout,
    failed_attempts_lockout   => $rbac_failed_attempts_lockout,
    ds_trust_chain            => $rbac_ds_trust_chain,
    notify                    => Service['pe-console-services'],
  }

  file { '/etc/puppetlabs/console-services/rbac-certificate-whitelist':
    ensure => file,
    group  => 'pe-console-services',
    owner  => 'pe-console-services',
    mode   => '0640',
  }

  $certs = pe_union([$master_certname, $certname], $whitelisted_certnames)
  puppet_enterprise::certs::rbac_whitelist_entry { $certs: }
  Puppet_enterprise::Certs::Rbac_whitelist_entry <<| certname != $master_certname and certname != $certname |>>

  puppet_enterprise::trapperkeeper::classifier { 'console-services' :
    master_host            => $master_host,
    database_host          => $database_host,
    database_port          => $database_port,
    database_name          => $classifier_database_name,
    database_user          => $classifier_database_user,
    database_password      => $classifier_database_password,
    database_properties    => $database_properties,
    client_certname        => $classifier_client_certname,
    localcacert            => $localcacert,
    synchronization_period => $classifier_synchronization_period,
    prune_days_threshold   => $classifier_prune_threshold,
    notify                 => Service['pe-console-services'],
  }

  if !pe_empty($java_args) {
    pe_validate_hash($java_args)
  }

  class { 'puppet_enterprise::console_services':
    client_certname       => $console_client_certname,
    master_host           => $master_host,
    dashboard_port        => $dashboard_listen_port,
    classifier_host       => '127.0.0.1',
    classifier_port       => $console_services_api_listen_port,
    classifier_url_prefix => $classifier_url_prefix,
    puppetdb_host         => $puppetdb_host,
    puppetdb_port         => $puppetdb_port,
    rbac_host             => '127.0.0.1',
    rbac_port             => $console_services_api_listen_port,
    activity_host         => '127.0.0.1',
    activity_port         => $console_services_api_listen_port,
    activity_url_prefix   => $activity_url_prefix,
    localcacert           => $localcacert,
    java_args             => $java_args,
    status_proxy_enabled  => $console_services_plaintext_status_enabled,
  }


  class { 'puppet_enterprise::profile::console::proxy' :
    certname                           => $certname,
    trapperkeeper_proxy_listen_address => $listen_address,
    trapperkeeper_proxy_listen_port    => $console_services_listen_port,
    proxy_read_timeout                 => $proxy_read_timeout,
    ssl_listen_address                 => $ssl_listen_address,
    ssl_listen_port                    => $console_ssl_listen_port,
    browser_ssl_cert                   => $browser_ssl_cert,
    browser_ssl_private_key            => $browser_ssl_private_key,
    browser_ssl_cert_chain             => $browser_ssl_cert_chain,
    browser_ssl_ca_cert                => $browser_ssl_ca_cert,
    require                            => Class['puppet_enterprise::profile::console::certs'],
  }
}
