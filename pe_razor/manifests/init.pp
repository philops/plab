class pe_razor(
  $dbpassword          = 'razor',
  $pe_tarball_base_url = "https://pm.puppetlabs.com/puppet-enterprise",
  $microkernel_url     = undef,
  $server_http_port    = 8150,
  $server_https_port   = 8151
) {
  include pe_razor::params

  # Assert the platform being used is one validated for this version of Razor.
  if !($pe_razor::params::is_on_el and $pe_razor::params::is_valid_version) {
    fail("Sorry, this version of Razor is only available for Red Hat Enterprise Linux 6 and 7.")
  }

  File {
    ensure => file,
    owner  => 'pe-razor',
    group  => 'pe-razor',
    mode   => '0640'
  }

  # The microkernal url expects a x.y.z version number.
  # The pe_version fact no longer exists in shallow gravy, until the integration team can
  # create a new function to return just the x.y.z, strip the pe_build (x.y.z-rc0-gitsha)
  $pe_build = pe_compiling_server_version()

  $_microkernel_url = $microkernel_url ? {
    undef   => "https://pm.puppetlabs.com/puppet-enterprise-razor-microkernel-${pe_build}.tar",
    default => $microkernel_url,
  }


  class { 'pe_razor::server':
    dbpassword          => $dbpassword,
    pe_tarball_base_url => $pe_tarball_base_url,
    microkernel_url     => $_microkernel_url,
    server_http_port    => $server_http_port,
    server_https_port   => $server_https_port,
  }
}
