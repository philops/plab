require 'spec_helper'

describe 'pe_postgresql::server::initdb', :type => :class do
  let (:pre_condition) do
    "include pe_postgresql::server"
  end
  describe 'on RedHat' do
    let :facts do
      {
        :osfamily => 'RedHat',
        :operatingsystem => 'CentOS',
        :operatingsystemrelease => '6.0',
        :pe_concat_basedir => tmpfilename('server'),
        :kernel => 'Linux',
        :id => 'root',
        :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      }
    end
    it { should contain_file('/var/lib/pgsql/data').with_ensure('directory') }
  end
  describe 'on Amazon' do
    let :facts do
      {
        :osfamily => 'RedHat',
        :operatingsystem => 'Amazon',
        :operatingsystemrelease => '1.0',
        :pe_concat_basedir => tmpfilename('server'),
        :kernel => 'Linux',
        :id => 'root',
        :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      }
    end
    it { should contain_file('/var/lib/pgsql9/data').with_ensure('directory') }
  end
end

