require 'spec_helper'

describe 'pe_postgresql::server::database', :type => :define do
  let :facts do
    {
      :osfamily => 'Debian',
      :operatingsystem => 'Debian',
      :operatingsystemrelease => '6.0',
      :kernel => 'Linux',
      :pe_concat_basedir => tmpfilename('contrib'),
      :id => 'root',
      :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    }
  end
  let :title do
    'test'
  end

  let :pre_condition do
    "class {'pe_postgresql::server':}"
  end

  it { should contain_pe_postgresql__server__database('test') }
  it { should contain_pe_postgresql_psql("Check for existence of db 'test'") }
end
