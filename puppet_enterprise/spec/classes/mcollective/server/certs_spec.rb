require 'spec_helper'

describe 'puppet_enterprise::mcollective::server::certs' do
  before :each do
    @facter_facts = {
      'osfamily'          => 'RedHat',
      'lsbmajdistrelease' => '6',
      'puppetversion'     => '3.6.2 (Puppet Enterprise 3.3.0)',
      'is_pe'             => 'true',
      'fqdn'              => 'somenode.rspec',
      'clientcert'        => 'awesomecert',
    }
  end

  let(:facts) { @facter_facts }
  let(:unixcertdir) { '/etc/puppetlabs/mcollective/ssl/' }
  let(:wincertdir) { '/PuppetLabs/mcollective/etc/ssl' }

  context "on a windows machine" do
    before :each do
      @facter_facts['osfamily'] = 'windows'
      @facter_facts['operatingsystem'] = 'windows'
    end

    it { should compile }

    it { should contain_file(wincertdir).with(
      'owner' => 'S-1-5-32-544',
      'group' => 'S-1-5-32-544',
      'mode'  => '0660',
    )}
  end

  context "on a windows machine" do
    before :each do
      @facter_facts['operatingsystem'] = 'AIX'
    end

    it { should compile }

    it { should contain_file(unixcertdir).with(
      'owner' => 'root',
      'group' => 'system',
      'mode'  => '0660',
    )}
  end

  context "on a RedHat machine" do
    it { should compile }

    it { should contain_file(unixcertdir).with(
      'owner' => 'root',
      'group' => 'root',
      'mode'  => '0660',
    )}
  end

  it { should satisfy_all_relationships }
end
