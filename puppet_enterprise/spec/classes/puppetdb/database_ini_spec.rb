require 'spec_helper'

describe 'puppet_enterprise::puppetdb::database_ini', :type => :class do
  context 'on a supported platform' do
    let(:facts) do
      {
        :osfamily => 'RedHat',
        :fqdn     => 'test.domain.local',
      }
    end

    let(:database_host) { 'test.domain.local' }
    let(:database_password) { 'pa$$w0rd' }
    let(:params) do
      {
        :database_host => database_host,
      }
    end

    it { should contain_class('puppet_enterprise::puppetdb::database_ini') }
    it { should contain_file('/etc/puppetlabs/puppetdb/conf.d/database.ini') }

    describe 'when using default values' do
      it { should contain_pe_ini_setting('puppetdb_psdatabase_username').
           with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'username',
             'value'   => 'pe-puppetdb'
      )}
      it { should_not contain_pe_ini_setting('puppetdb_psdatabase_password') }
      it { should contain_pe_ini_setting('puppetdb_classname').
           with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'classname',
             'value'   => 'org.postgresql.Driver'
      )}
      it { should contain_pe_ini_setting('puppetdb_subprotocol').
           with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'subprotocol',
             'value'   => 'postgresql'
      )}
      it { should contain_pe_ini_setting('puppetdb_subname').
           with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'subname',
             'value'   => "//#{database_host}:5432/pe-puppetdb"
      )}
    end

    describe 'when using a database password' do
      let(:params) do
        {
          :database_host     => database_host,
          :database_password => database_password
        }
      end

      it { should contain_pe_ini_setting('puppetdb_psdatabase_password').
           with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'password',
             'value'   => database_password
      )}
    end
  end
end
