# The define resource extracts compressed file to a staging location.
define pe_staging::deploy (
  $source,               #: the source file location, supports local files, puppet://, http://, https://, ftp://
  $target,               #: the target extraction directory
  $staging_path = undef, #: the staging location for compressed file. defaults to ${pe_staging::path}/${caller_module_name}
  $username     = undef, #: https or ftp username
  $certificate  = undef, #: https certifcate file
  $password     = undef, #: https or ftp user password or https certificate password
  $environment  = undef, #: environment variable for settings such as http_proxy
  $strip        = undef, #: extract file with the --strip=X option. Only works with GNU tar.
  $timeout      = undef, #: the time to wait for the file transfer to complete
  $user         = undef, #: extract file as this user
  $group        = undef, #: extract file as this group
  $mode         = undef, #: extract file with this mode
  $creates      = undef, #: the file/folder created after extraction. if unspecified defaults to ${target}/${name}
  $unless       = undef, #: alternative way to conditionally extract file
  $onlyif       = undef  #: alternative way to conditionally extract file
) {

  pe_staging::file { $name:
    source      => $source,
    target      => $staging_path,
    username    => $username,
    certificate => $certificate,
    password    => $password,
    environment => $environment,
    subdir      => $caller_module_name,
    timeout     => $timeout,
    unless      => "[ -e '${creates}' ]"
  }

  pe_staging::extract { $name:
    target      => $target,
    source      => $staging_path,
    user        => $user,
    group       => $group,
    mode        => $mode,
    environment => $environment,
    subdir      => $caller_module_name,
    strip       => $strip,
    creates     => $creates,
    unless      => $unless,
    onlyif      => $onlyif,
    require     => Pe_staging::File[$name],
  }

}
