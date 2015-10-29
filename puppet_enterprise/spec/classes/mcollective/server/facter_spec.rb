require 'spec_helper'

describe 'puppet_enterprise::mcollective::server::facter' do
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
  let(:winfile) { 'refresh-mcollective-metadata.bat' }
  let(:unixfile) { '/opt/puppetlabs/puppet/bin/refresh-mcollective-metadata' }
  let(:cronname) { 'pe-mcollective-metadata' }

  context "on a windows machine" do
    before :each do
      @facter_facts['osfamily'] = 'windows'
      @facter_facts['operatingsystem'] = 'windows'
    end

    it { catalogue }

    it { should contain_scheduled_task('pe-mcollective-metadata') }

    it { should satisfy_all_relationships }
  end

  context "on a AIX machine" do
    before :each do
      @facter_facts['operatingsystem'] = 'AIX'
    end

    it { should compile }

    it { should contain_file(unixfile).with(
      'owner' => 'root',
      'group' => 'system',
      'mode'  => '0775',
    )}

    it { should contain_cron(cronname).with(
      'user' => 'root',
    )}

    it { should satisfy_all_relationships }
  end

  context "on a RedHat machine" do
    it { should compile }

    it { should contain_file(unixfile).with(
      'owner' => 'root',
      'group' => 'root',
      'mode'  => '0775',
    )}

    describe "Cron job resource defaults to managed" do
      it { should contain_cron(cronname).with(
        'user' => 'root',
      )}
    end

    describe "Cron job resource can be disabled" do
      before :each do
        @params = {'manage_metadata_cron' => false }
      end

      it { should_not contain_cron(cronname) }
    end

    it { should satisfy_all_relationships }
  end
end
