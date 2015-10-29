# Creates a cron job (or scheduled task) to refresh mcollective's fact data.
#
# Fact plugins are used during discovery whenever you run the agent with queries like -W country=de.
#
# For more information, @see https://docs.puppetlabs.com/mcollective/reference/plugins/facts.html
class puppet_enterprise::mcollective::server::facter(
  $manage_metadata_cron = true,
  ) {
  include puppet_enterprise::params

  $puppet_bin_dir = '/opt/puppetlabs/puppet/bin'

  # Service['mcollective'] is referenced in ordering of resources below, so we ensure to include it here.
  include puppet_enterprise::mcollective::service

  $mco_etc = $puppet_enterprise::params::mco_etc

  File {
    owner   => $puppet_enterprise::params::root_user,
    group   => $puppet_enterprise::params::root_group,
    mode    => '0775',
  }

  # Manage facter metadata updates for MCollective in PE.
  if $::osfamily == 'windows' {
    file { 'refresh-mcollective-metadata.bat':
      path    => "${mco_etc}/refresh-mcollective-metadata.bat",
      content => template('puppet_enterprise/mcollective/refresh-mcollective-metadata.bat.erb'),
      before  => [ Exec['bootstrap mcollective metadata'], Scheduled_task['pe-mcollective-metadata'] ],
    }

    file { 'refresh-mcollective-metadata.rb':
      path    => "${mco_etc}/refresh-mcollective-metadata.rb",
      content => template('puppet_enterprise/mcollective/refresh-mcollective-metadata.erb'),
      before  => [ Exec['bootstrap mcollective metadata'], Scheduled_task['pe-mcollective-metadata'] ],
    }

    exec { 'bootstrap mcollective metadata':
      command => "\"${mco_etc}/refresh-mcollective-metadata.bat\"",
      creates => "${mco_etc}/facts.yaml",
      before  => Service['mcollective'],
    }

    scheduled_task { 'pe-mcollective-metadata':
      ensure  => 'present',
      command => "${mco_etc}/refresh-mcollective-metadata.bat",
      enabled => true,
      trigger => {
        'every'      => '1',
        'schedule'   => 'daily',
        'start_time' => '13:00'
      },
    }
  }
  else {
    $metadata_file_before = $manage_metadata_cron ? {
      true    => [Cron['pe-mcollective-metadata'], Exec['bootstrap mcollective metadata']],
      false   => [Exec['bootstrap mcollective metadata']],
      default => [Exec['bootstrap mcollective metadata']],
    }

    file { "${puppet_bin_dir}/refresh-mcollective-metadata":
      content => template('puppet_enterprise/mcollective/refresh-mcollective-metadata.erb'),
      before  => $metadata_file_before,
    }

    exec { 'bootstrap mcollective metadata':
      command => "${puppet_bin_dir}/refresh-mcollective-metadata 2>&1 >>${puppet_enterprise::params::mco_logdir}/mcollective-metadata-cron.log",
      creates => "${mco_etc}/facts.yaml",
      require => File["${puppet_bin_dir}/refresh-mcollective-metadata"],
      before  => Service['mcollective'],
    }

    if ($manage_metadata_cron) {
      cron { 'pe-mcollective-metadata':
        command => "${puppet_bin_dir}/refresh-mcollective-metadata 2>&1 >>${puppet_enterprise::params::mco_logdir}/mcollective-metadata-cron.log",
        user    => $puppet_enterprise::params::root_user,
        minute  => [ '0', '15', '30', '45' ],
        require => File["${puppet_bin_dir}/refresh-mcollective-metadata"],
      }
    }
  }
}
