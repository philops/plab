require 'spec_helper'

describe 'pe_console_prune', :type => :class do

  it {
    should contain_cron('pe-puppet-console-prune-task').with({
      :ensure   => 'absent',
      :command  => '/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production reports:prune reports:prune:failed upto=30 unit=day > /dev/null',
      :user     => 'root',
      :target   => 'root',
      :hour     => 1,
      :minute   => 0,
      :weekday  => 'absent',
      :month    => 'absent',
      :monthday => 'absent',
    })
  }

end
