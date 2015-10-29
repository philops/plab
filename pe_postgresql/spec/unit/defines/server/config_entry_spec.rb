require 'spec_helper'

describe 'pe_postgresql::server::config_entry', :type => :define do
  let :facts do
    {
      :osfamily => 'RedHat',
      :operatingsystem => 'RedHat',
      :operatingsystemrelease => '6.4',
      :kernel => 'Linux',
      :pe_concat_basedir => tmpfilename('contrib'),
      :id => 'root',
      :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    }
  end

  let(:title) { 'config_entry'}

  let :target do
    tmpfilename('postgresql_conf')
  end

  context "syntax check" do
    let :pre_condition do
      "class {'pe_postgresql::server':}"
    end

    let(:params) { { :ensure => 'present'} }
    it { should contain_pe_postgresql__server__config_entry('config_entry') }
  end

  context 'fedora 19' do
    let :facts do
      {
        :osfamily => 'RedHat',
        :operatingsystem => 'Fedora',
        :operatingsystemrelease => '19',
        :kernel => 'Linux',
        :pe_concat_basedir => tmpfilename('contrib'),
        :id => 'root',
        :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      }
    end
    let(:params) {{ :ensure => 'present', :name => 'port', :value => '5432' }}

    it 'stops postgresql and changes the port' do
      is_expected.to contain_file('systemd-port-override')
      is_expected.to contain_exec('restart-systemd')
    end
  end
end

