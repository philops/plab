# == Define: puppet_enterprise::certs::puppetdb_whitelist_entry
#
# A defined type for adding a certificate to the puppetdb certificate whitelist.
# If a file_line has already been defined with the same target and certname, it
# will not be defined again.
#
# A certificate whitelist is a basic text file with one certificate
# per line that an applciation will load and parse.
#
# === Parameters
#
# [*certname*]
#   String. The name of the certificate to add to this file.
#
# === Examples
#
#   puppet_enterprise::certs::puppetdb_whitelist_entry { "${certificate_whitelist_target}:#{certname}":
#     certname => 'example.local.vm'
#   }
#
define puppet_enterprise::certs::puppetdb_whitelist_entry(
  $certname = $title
) {
  include puppet_enterprise::params

  $cert_whitelist_path = '/etc/puppetlabs/puppetdb/certificate-whitelist'

  puppet_enterprise::certs::whitelist_entry { "puppetdb cert whitelist entry: ${certname}":
    certname => $certname,
    target   => $cert_whitelist_path,
    notify   => Service['pe-puppetdb'],
    require  => File[$cert_whitelist_path],
  }
}
