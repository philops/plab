require 'spec_helper'

describe 'pe_postgresql::lib::devel', :type => :class do
  let :facts do
    {
      :osfamily => 'Debian',
      :operatingsystem => 'Debian',
      :operatingsystemrelease => '6.0',
    }
  end
  it { should contain_class("pe_postgresql::lib::devel") }
end
