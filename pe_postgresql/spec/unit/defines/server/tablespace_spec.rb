require 'spec_helper'

describe 'pe_postgresql::server::tablespace', :type => :define do
  let :facts do
    {
      :osfamily => 'Debian',
      :operatingsystem => 'Debian',
      :operatingsystemrelease => '6.0',
      :kernel => 'Linux',
      :pe_concat_basedir => tmpfilename('tablespace'),
      :id => 'root',
      :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    }
  end

  let :title do
    'test'
  end

  let :params do
    {
      :location => '/srv/data/foo',
    }
  end

  let :pre_condition do
    "class {'pe_postgresql::server':}"
  end

  it { should contain_pe_postgresql__server__tablespace('test') }
end
