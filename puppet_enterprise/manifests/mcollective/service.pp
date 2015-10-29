# Ensures that the mcollective service is running
class puppet_enterprise::mcollective::service {
  service { 'mcollective':
    ensure     => running,
    enable     => true,
    hasrestart => true,
  }
}
