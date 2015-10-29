require 'spec_helper'

describe 'puppet_enterprise::trapperkeeper::activity' do
  before :all do
    @facter_facts = {
      'osfamily'          => 'Debian',
      'operatingsystem'   => 'Debian',
      'lsbmajdistrelease' => '6',
      'puppetversion'     => '3.6.2 (Puppet Enterprise 3.3.0)',
      'is_pe'             => 'true',
      'fqdn'              => 'rbac.rspec',
      'clientcert'        => 'awesomecert',
      'pe_concat_basedir' => '/tmp/file',
    }
    @params = {
      'rbac_url_prefix' => '/blah-api',
      'rbac_port'       => '1111',
    }
  end

  let(:facts) { @facter_facts }
  let(:params) { @params }
  let(:title) { 'activity' }

  context "when the parameters are valid" do
    it do
      should contain_file("/etc/puppetlabs/activity/conf.d/activity.conf").with(
        :owner => "pe-activity",
        :group => "pe-activity",
        :mode => "0640"
      )
    end
    it { should contain_pe_hocon_setting('activity.rbac-base-url').with_value('http://localhost:1111/blah-api/v1') }
    it { should contain_pe_hocon_setting('activity.cors-origin-pattern').with_value('.*') }
    it { should contain_pe_concat__fragment('activity activity-service') }
    it { should contain_pe_concat__fragment('activity jetty9-service') }
  end

  context "when given a database password" do
    before(:each) do
      @params['database_user'] = 'activityuser'
      @params['database_password'] = 'activitypass'
    end
    
    it { should contain_pe_hocon_setting('activity.database.subprotocol').with_value('postgresql') }
    it { should contain_pe_hocon_setting('activity.database.subname').with_ensure('present') }
    it { should contain_pe_hocon_setting('activity.database.user').with_value('activityuser') }
    it { should contain_pe_hocon_setting('activity.database.password').with_value('activitypass') }
  end

end
