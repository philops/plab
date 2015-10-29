# Class for setting up the activemq service.
#
# Subsribes to any changes in puppet_enterprise::amq::config
class puppet_enterprise::amq::service {
  service { 'pe-activemq':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    subscribe  => Class['puppet_enterprise::amq::config'],
  }
}
