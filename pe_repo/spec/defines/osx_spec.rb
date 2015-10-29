require 'spec_helper'

describe 'pe_repo::osx' do
  let(:title) { 'osx-10.10-x86_64' }
  let(:facts) do
    {
      :aio_agent_build => '1.2.2',
    }
  end
  let(:params) do
    {
      :codename   => 'yosemite',
      :pe_version => '2015.2.0',
    }
  end

  it "compiles" do
    should compile.with_all_deps
  end

  it "downloads and creates a dmg file" do
    should contain_pe_staging__deploy('puppet-agent-osx-10.10.tar.gz')
      .with(:source  => 'https://pm.puppetlabs.com/puppet-agent/2015.2.0/1.2.2/repos/puppet-agent-osx-10.10.tar.gz')
      .with(:creates => '/opt/puppetlabs/server/data/packages/public/2015.2.0/osx-10.10-x86_64/puppet-agent-1.2.2-1.osx10.10.dmg')
      .with(:target  => '/opt/puppetlabs/server/data/packages/public/2015.2.0/osx-10.10-x86_64')
  end
end
