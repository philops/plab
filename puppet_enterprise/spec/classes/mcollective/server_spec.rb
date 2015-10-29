require 'spec_helper'

describe 'puppet_enterprise::mcollective::server' do

  let(:server_cfg) { '/etc/puppetlabs/mcollective/server.cfg' }

  def should_have_setting(setting, value)
    should contain_file(server_cfg).with_content(%r[^#{Regexp.escape(setting)}\s*=\s*#{Regexp.escape(value)}$])
  end

  before :each do
    @facter_facts = {
      'osfamily'          => 'RedHat',
      'lsbmajdistrelease' => '6',
      'puppetversion'     => '3.6.2 (Puppet Enterprise 3.3.0)',
      'is_pe'             => 'true',
      'fqdn'              => 'somenode.rspec',
      'clientcert'        => 'awesomecert',
    }
    @params = {}
  end

  let(:facts) { @facter_facts }
  let(:params) { @params }

  context "on a windows machine" do
    before :each do
      @facter_facts['osfamily'] = 'windows'
      @facter_facts['operatingsystem'] = 'windows'
    end
    it { catalogue }
  end

  context "on a RedHat machine" do
    it { should compile }

    it { should contain_file('/etc/puppetlabs/mcollective/server.cfg').with_notify('Service[mcollective]') }
  end

  context "server.cfg" do
    it { should_have_setting('libdir', '/opt/puppet/libexec/mcollective:/opt/puppetlabs/mcollective/plugins') }
  end

  context "randomzie_activemq" do
    context "false" do
      it { should_have_setting('plugin.activemq.randomize','false') }
    end
    context "true" do
      before(:each) do
        @params['randomize_activemq'] = true
      end
      it { should_have_setting('plugin.activemq.randomize','true') }
    end
  end

  context "activemq_heartbeat_interval should be set to the correct value depending on version" do
    context "0 when pe version is below 3.7" do
      before(:each) {
        @facter_facts = {
          'pe_minor_version'  => '3',
          'pe_major_version' =>'3',
        }
      }
      it { should_have_setting('plugin.activemq.heartbeat_interval', '0') }
    end
    context "120 when pe version is above 3.7" do
      before(:each) {
        @facter_facts = {
          'pe_minor_version'  => '3',
          'pe_major_version' =>'9',
        }
      }
      it { should_have_setting('plugin.activemq.heartbeat_interval', '120') }
    end
    context "120 when pe version is 3.7" do
      before(:each) {
        @facter_facts = {
          'pe_minor_version'  => '3',
          'pe_major_version' =>'7',
        }
      }
      it { should_have_setting('plugin.activemq.heartbeat_interval', '120') }
    end
    context "120 when pe version is 4.1" do
      before(:each) {
        @facter_facts = {
          'pe_minor_version'  => '4',
          'pe_major_version' =>'1',
        }
      }
      it { should_have_setting('plugin.activemq.heartbeat_interval', '120') }
    end
  end

  context "to not enforce action policies" do

    it do
      should contain_file('/etc/puppetlabs/mcollective/server.cfg').with_content(/plugin.actionpolicy.allow_unconfigured = 1/)
    end
  end

  context "to enforce action policies" do
    let(:params) {
      {
        'allow_no_actionpolicy'  => '0',
      }
    }

    it do
      should contain_file('/etc/puppetlabs/mcollective/server.cfg').with_content(/plugin.actionpolicy.allow_unconfigured = 0/)
    end
  end

  context "fail if allow_no_actionpolicy is not 1 or 0" do
    let(:params) {
      {
        'allow_no_actionpolicy'  => 'beer',
      }
    }

    it { should compile.and_raise_error(/does not match/) }
  end

  it { should satisfy_all_relationships }
end
