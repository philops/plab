require 'spec_helper'

describe 'pe_postgresql::server::plperl', :type => :class do
  let :facts do
    {
      :osfamily => 'Debian',
      :operatingsystem => 'Debian',
      :operatingsystemrelease => '6.0',
      :kernel => 'Linux',
      :pe_concat_basedir => tmpfilename('plperl'),
      :id => 'root',
      :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    }
  end

  let :pre_condition do
    "class { 'pe_postgresql::server': }"
  end

  describe 'with no parameters' do
    it { should contain_class("pe_postgresql::server::plperl") }
    it 'should create package' do
      should contain_package('postgresql-plperl').with({
        :ensure => 'present',
        :tag => 'postgresql',
      })
    end
  end

  describe 'with parameters' do
    let :params do
      {
        :package_ensure => 'absent',
        :package_name => 'mypackage',
      }
    end

    it { should contain_class("pe_postgresql::server::plperl") }
    it 'should create package with correct params' do
      should contain_package('postgresql-plperl').with({
        :ensure => 'absent',
        :name => 'mypackage',
        :tag => 'postgresql',
      })
    end
  end
end
