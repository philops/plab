require 'spec_helper'

describe 'puppet_enterprise::master' do
  before :each do
    @facter_facts = {
      'osfamily'          => 'Debian',
      'operatingsystem'   => 'Debian',
      'lsbmajdistrelease' => '6',
      'puppetversion'     => '3.6.2 (Puppet Enterprise 3.3.0)',
      'is_pe'             => 'true',
      'fqdn'              => 'master.rspec',
      'clientcert'        => 'awesomecert',
      'pe_concat_basedir'    => '/tmp/file',
      'processorcount'    => '1',
    }

    @params = { 'certname' => 'master.rspec',
                'metrics_enabled' => true,
                'metrics_server_id' => 'localhost',
                'metrics_jmx_enabled' => true,
                'metrics_graphite_enabled' => false,
                'metrics_graphite_host' => 'graphite',
                'metrics_graphite_port' => 2003,
                'metrics_graphite_update_interval_seconds' => 30,
                'profiler_enabled' => true }
  end

  let(:facts) { @facter_facts }
  let(:params) { @params }
  let(:confdir) { "/etc/puppetlabs/puppet" }

  context "when managing default java_args" do
    context "1 GB of RAM => 512 MB heap" do
      before(:each) { @facter_facts['memorysize'] = '1073741824' }
      it { should contain_pe_ini_subsetting("pe-puppetserver_'Xmx'").with_value( '512m' ) }
      it { should contain_pe_ini_subsetting("pe-puppetserver_'Xms'").with_value( '512m' ) }
      it { should satisfy_all_relationships }
    end

    context "2 GB of RAM => 1 GB heap" do
      before(:each) { @facter_facts['memorysize'] = '2147483648' }
      it { should contain_pe_ini_subsetting("pe-puppetserver_'Xmx'").with_value('1024m') }
      it { should contain_pe_ini_subsetting("pe-puppetserver_'Xms'").with_value('1024m') }
      it { should satisfy_all_relationships }
    end

    context "4 GB of RAM => 2 GB heap" do
      before(:each) { @facter_facts['memorysize'] = '4294967296' }
      it { should contain_pe_ini_subsetting("pe-puppetserver_'Xmx'").with_value( '2048m' ) }
      it { should contain_pe_ini_subsetting("pe-puppetserver_'Xms'").with_value( '2048m' ) }
      it { should satisfy_all_relationships }
    end
  end

  context "wth custom java_args" do
    before(:each) { @params['java_args'] = { 'Xmx' => '128m' } }
    it { should contain_pe_ini_subsetting("pe-puppetserver_'Xmx'").with(
     'value'   => '128m',
     'require' => 'Package[pe-puppetserver]',
    ) }
    it { should satisfy_all_relationships }
  end

  context "managing files" do
    it { should contain_file("/var/log/puppetlabs/puppet").with_mode('0640') }
    it { should contain_file("/etc/puppetlabs/code/environments").with_mode('0755') }

    it { should contain_pe_ini_setting("puppetserver puppetconf certname").with_value('master.rspec') }
    it { should contain_pe_ini_setting("puppetserver puppetconf always_cache_features").with_value('true') }
    it { should contain_pe_ini_setting("puppetserver puppetconf user").with_value('pe-puppet') }
    it { should contain_pe_ini_setting("puppetserver puppetconf group").with_value('pe-puppet') }
    it { should_not contain_pe_ini_setting("parser").with_value('current') }
    it { should contain_class('puppet_enterprise::master::puppetserver') }
    it { should satisfy_all_relationships }

    context "managing parser - invalid parser" do
      before(:each) { @params['parser'] = 'past' }
      it { expect { should satisfy_all_relationships }.to raise_error(Puppet::Error) }
    end
  end

  context "with custom environments_dir_mode" do
    before(:each) { @params['environments_dir_mode'] = '0750' }
    it { should contain_file("/var/log/puppetlabs/puppet").with_mode('0640') }
    it { should contain_file("/etc/puppetlabs/code/environments").with_mode('0750') }
    it { should satisfy_all_relationships }
  end

  context "managing puppetsever" do
    it { should contain_package('pe-puppetserver') }
    it { should contain_package('pe-java') }
    it { should contain_class('puppet_enterprise::master::puppetserver') }
    it { should satisfy_all_relationships }
  end

  context "managing pe_build file" do
    before :each do
      # Without this, the updated function isn't recognized for subsequent tests.
      # I think it's because rspec-puppet has an @@cache based on args, and
      # facts are one of the arguments.  So by mutating facts, we are forcing
      # it get a new catalog for evaluation and the overridden function is
      # used...
      @facter_facts['foo'] = 'bar'
      Puppet::Parser::Functions.newfunction(:pe_build_version, :type => :rvalue) do |args|
        '1.2.3'
      end
    end

    it do
      should contain_file('/opt/puppetlabs/server/pe_build')
        .with_content('1.2.3')
    end
  end
end
