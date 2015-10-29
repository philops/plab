# == Define: puppet_enterprise::certs::rbac_whitelist_entry
#
# A defined type for adding a certificate to the rbac certificate whitelist.
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
#   puppet_enterprise::certs::rbac_whitelist_entry { "${certificate_whitelist_target}:#{certname}":
#     certname => 'example.local.vm'
#   }
#
define puppet_enterprise::certs::rbac_whitelist_entry(
  $certname = $title
) {

  puppet_enterprise::certs::whitelist_entry { "rbac cert whitelist entry: ${certname}":
    certname => $certname,
    target   => '/etc/puppetlabs/console-services/rbac-certificate-whitelist',
    notify   => Service['pe-console-services'],
    require  => File['/etc/puppetlabs/console-services/rbac-certificate-whitelist'],
  }
}
