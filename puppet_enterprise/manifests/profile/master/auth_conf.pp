# This class manages a master's node's auth.conf file, which controls which
# routes are authenticated on the master.
#
# This class is called internally by the Master profile, and should not be called
# directly.
#
# @param console_client_certname [String] The name on the certificate used by the console.
# @param classifier_clint_certname [String] The name on the certificate used by the classifier.
class puppet_enterprise::profile::master::auth_conf(
  $console_client_certname,
  $classifier_client_certname,
) {

  # Uses
  #  $console_client_certname
  #  $classifier_client_certname
  file { '/etc/puppetlabs/puppet/auth.conf' :
    ensure  => present,
    owner   => $puppet_enterprise::params::root_user,
    group   => $puppet_enterprise::params::root_group,
    content => template('puppet_enterprise/profile/master/auth.conf.erb'),
  }

}
