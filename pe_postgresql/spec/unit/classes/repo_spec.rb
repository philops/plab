require 'spec_helper'

describe 'pe_postgresql::repo', :type => :class do
  let :facts do
    {
      :osfamily               => 'Debian',
      :operatingsystem        => 'Debian',
      :operatingsystemrelease => '6.0',
      :lsbdistid              => 'Debian',
      :lsbdistcodename        => 'squeeze',
    }
  end

end
