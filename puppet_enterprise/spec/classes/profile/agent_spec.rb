require 'spec_helper'

describe 'puppet_enterprise::profile::agent' do
  before :each do
    @facter_facts = {
      'kernel'                    => 'Linux',
      'platform_symlink_writable' => true,
    }

    @params = {
      'manage_symlinks'   => true,
    }
  end

  let(:facts) { @facter_facts }
  let(:params) { @params }

  context "when parameter disables management of symlinks" do
    before :each do
      @params['manage_symlinks'] = false
    end

    it { should_not contain_file('/usr/local/bin/facter') }
    it { should_not contain_file('/usr/local/bin/puppet') }
    it { should_not contain_file('/usr/local/bin/pe-man') }
    it { should_not contain_file('/usr/local/bin/hiera') }
    it { should satisfy_all_relationships }
  end

  context "when non boolean is passed for paramater manage_symlinks" do
    before :each do
      @params['manage_symlinks'] = 'IamAString'
    end

    it { should compile.and_raise_error(/is not a boolean/) }
  end

  context "when platform symlink fact reports system path is not writable" do
    before :each do
      @facter_facts['platform_symlink_writable'] = false
    end

    it { should_not contain_file('/usr/local/bin/facter') }
    it { should_not contain_file('/usr/local/bin/puppet') }
    it { should_not contain_file('/usr/local/bin/pe-man') }
    it { should_not contain_file('/usr/local/bin/hiera') }
    it { should satisfy_all_relationships }
  end

  context "when using Windows fact should be false and symlinks should not be managed" do
    before :each do
      @facter_facts['kernel'] = 'windows'
      @facter_facts['platform_symlink_writable'] = false
    end

    it { should_not contain_file('/usr/local/bin/facter') }
    it { should_not contain_file('/usr/local/bin/puppet') }
    it { should_not contain_file('/usr/local/bin/pe-man') }
    it { should_not contain_file('/usr/local/bin/hiera') }
    it { should satisfy_all_relationships }
  end

  context "when using inherited paramater defaults" do
    before :each do
      @params.delete('manage_symlinks')
    end

    it { should contain_file('/usr/local/bin/facter').with_tag('pe-agent-symlinks') }
    it { should contain_file('/usr/local/bin/puppet').with_tag('pe-agent-symlinks') }
    it { should contain_file('/usr/local/bin/pe-man').with_tag('pe-agent-symlinks') }
    it { should contain_file('/usr/local/bin/hiera').with_tag('pe-agent-symlinks') }
    it { should satisfy_all_relationships }
  end

  it { should satisfy_all_relationships }
end
