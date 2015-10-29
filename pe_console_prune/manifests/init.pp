# == Class: pe_console_prune
#
# The pe_console_prune class optionally installs a cron job to prune
# reports from the console database.  By default, it installs the
# cron job to run at 1AM everyday.
#
# === Parameters
#
# Document parameters here.
#
# [*ensure_prune_cron*]
#   Whether or not the cron job will be installed.
# [*prune_upto*]
#   The number of units of reports that will be deleted from the console database
# [*prune_unit*]
#   Unit examples are day or mon.
# [*prune_cron_user*]
#   The user to run the prune rake task as
# [*prune_cron_target*]
#   The user who owns the cron job
# [*prune_cron_hour*]
#   http://docs.puppetlabs.com/references/latest/type.html#cron-attribute-hour
# [*prune_cron_minute*]
#   http://docs.puppetlabs.com/references/latest/type.html#cron-attribute-minute
# [*prune_cron_weekday*]
#   http://docs.puppetlabs.com/references/latest/type.html#cron-attribute-weekday
# [*prune_cron_month*]
#   http://docs.puppetlabs.com/references/latest/type.html#cron-attribute-month
# [*prune_cron_monthday*]
#   http://docs.puppetlabs.com/references/latest/type.html#cron-attribute-monthday
# === Variables
#
# === Examples
#
#  class { pe_console_prune: }
#
# === Authors
#
# Author Name <nick.walker@puppetlabs.com>
#
# === Copyright
#
# Copyright 2013 Nick Walker, unless otherwise noted.
#
class pe_console_prune (
  $ensure_prune_cron   = 'absent',
  $prune_upto          = 30,
  $prune_unit          = 'day',
  $prune_cron_user     = 'root',
  $prune_cron_target   = 'root',
  $prune_cron_hour     = 1,
  $prune_cron_minute   = 0,
  $prune_cron_weekday  = 'absent',
  $prune_cron_month    = 'absent',
  $prune_cron_monthday = 'absent'
)
{
  warning('The pe_console_prune class is deprecated. Please remove it from all of your node groups.')
  cron { 'pe-puppet-console-prune-task':
    ensure   => 'absent',
    command  => "/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production reports:prune reports:prune:failed upto=${prune_upto} unit=${prune_unit} > /dev/null",
    user     => $prune_cron_user,
    target   => $prune_cron_target,
    hour     => $prune_cron_hour,
    minute   => $prune_cron_minute,
    weekday  => $prune_cron_weekday,
    month    => $prune_cron_month,
    monthday => $prune_cron_monthday,
  }
}
