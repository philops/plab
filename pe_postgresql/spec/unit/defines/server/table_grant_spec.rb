require 'spec_helper'

describe 'pe_postgresql::server::table_grant', :type => :define do
  let :facts do
    {
      :osfamily => 'Debian',
      :operatingsystem => 'Debian',
      :operatingsystemrelease => '6.0',
      :kernel => 'Linux',
      :pe_concat_basedir => tmpfilename('table_grant'),
      :id => 'root',
      :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    }
  end

  let :title do
    'test'
  end

  let :params do
    {
      :privilege => 'ALL',
      :db => 'test',
      :role => 'test',
      :table => 'foo',
    }
  end

  let :pre_condition do
    "class {'pe_postgresql::server':}"
  end

  it { should contain_pe_postgresql__server__table_grant('test') }
  it { should contain_pe_postgresql__server__grant('table:test') }
end
