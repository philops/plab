# Profile for creating a MCollective server.
#
# For more information, see the [README.md](./README.md)
#
# @param activemq_brokers [Array] List of ActiveMQ brokers.
# @param allow_no_actionpolicy [Integer] Determine if Action Policies are required by default.
#         Valid values: 1 or 0. Value of 1 indicates no actionpolicies are required.
# @param collectives [Array] List of collectives that this client should talk to.
# @param create_user [String] Whether or not we should create and manage this users account on disk.
# @param main_collective [String] The collective this client should direct Registration messages to.
# @param mco_identity [String] The node's name or identity. This should be unique for each node, but
#         does not need to be.
# @param mco_registerinterval [Integer] How long (in seconds) to wait between registration messages.
#         Setting this to 0 disables registration.
# @param randomize_activemq [Boolean] Whether to randomize the order of the connection pool before connecting.
# @param stomp_passowrd [String] The stomp password.
# @param stomp_port [Integer] The port that the stomp service is listening on.
# @param stomp_user [String] The username for sending messages over the stomp protocol.
class puppet_enterprise::profile::mcollective::agent (
  $activemq_brokers       = $puppet_enterprise::mcollective_middleware_hosts,
  $allow_no_actionpolicy  = $puppet_enterprise::params::mco_require_actionpolicy,
  $collectives            = ['mcollective'],
  $main_collective        = 'mcollective',
  $manage_metadata_cron   = true,
  $mco_identity           = $puppet_enterprise::params::mco_identity,
  $mco_registerinterval   = $puppet_enterprise::params::mco_registerinterval,
  $randomize_activemq     = false,
  $stomp_password         = $puppet_enterprise::mcollective_middleware_password,
  $stomp_port             = $puppet_enterprise::mcollective_middleware_port,
  $stomp_user             = $puppet_enterprise::mcollective_middleware_user,
) inherits puppet_enterprise {

  pe_validate_array($activemq_brokers)
  pe_validate_array($collectives)
  pe_validate_re($allow_no_actionpolicy, '^[0-1]$')
  pe_validate_bool($randomize_activemq)

  # Don't accept the shared server public key as a client, or every server can
  # act as a client!
  file { "${puppet_enterprise::params::mco_clients_cert_dir}/${puppet_enterprise::params::mco_server_name}-public.pem":
    ensure => absent,
  }

  class { 'puppet_enterprise::mcollective::server':
    activemq_brokers      => $activemq_brokers,
    allow_no_actionpolicy => $allow_no_actionpolicy,
    collectives           => $collectives,
    main_collective       => $main_collective,
    manage_metadata_cron  => $manage_metadata_cron,
    mco_identity          => $mco_identity,
    mco_registerinterval  => $mco_registerinterval,
    randomize_activemq   => $randomize_activemq,
    stomp_password        => $stomp_password,
    stomp_port            => $stomp_port,
    stomp_user            => $stomp_user,
  }
}
