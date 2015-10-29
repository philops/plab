require 'spec_helper'

RSpec.shared_examples("repo behavior") do |platform|
  context "on *nix", :if => platform !~ /^windows/ do
    it "creates a pe_repo::repo resource" do
      should contain_pe_repo__repo("#{platform_name} #{pe_build_version}")
        .with_agent_version(agent_version)
        .with_installer_build(platform_name)
        .with_pe_version(pe_build_version)
    end

    it "creates a pe_staging::deploy resource" do
      tarball_name = case platform_name
      when /osx/ then "puppet-agent-osx-#{platform_name.split('-')[1]}.tar.gz"
      else "puppet-agent-#{platform_name}.tar.gz"
      end

      should contain_pe_staging__deploy(tarball_name)
        .with_source("https://pm.puppetlabs.com/puppet-agent/#{pe_build_version}/#{agent_version}/repos/#{tarball_name}")
        .with_target("/opt/puppetlabs/server/data/packages/public/#{pe_build_version}/#{platform_name}")
    end
  end

  context "on windows", :if => platform =~ /^windows/ do
    let(:arch) { platform_name.split('-')[1] == 'i386' ? 'x86' : 'x64' }

    it "creates a pe_staging::file directly" do
      msi = "puppet-agent-#{arch}.msi"
      should contain_pe_staging__file(msi)
        .with_source("https://pm.puppetlabs.com/puppet-agent/#{pe_build_version}/#{agent_version}/repos/windows/#{msi}")
        .with_target("/opt/puppetlabs/server/data/packages/public/#{pe_build_version}/#{platform_name}/#{msi}")
    end
  end
end

[
  "aix-5.3-power",
  "aix-6.1-power",
  "aix-7.1-power",
  "debian-6-i386",
  "debian-6-amd64",
  "debian-7-i386",
  "debian-7-amd64",
  "debian-8-i386",
  "debian-8-amd64",
  "el-4-i386",
  "el-4-x86_64",
  "el-5-i386",
  "el-5-x86_64",
  "el-6-i386",
  "el-6-x86_64",
  "el-7-x86_64",
  "fedora-21-i386",
  "fedora-21-x86_64",
  "fedora-22-i386",
  "fedora-22-x86_64",
  "osx-10.9-x86_64",
  "osx-10.10-x86_64",
  "sles-10-i386",
  "sles-10-x86_64",
  "sles-11-i386",
  "sles-11-x86_64",
  "sles-12-x86_64",
  "solaris-10-i386",
  "solaris-10-sparc",
  "solaris-11-i386",
  "solaris-11-sparc",
  "ubuntu-10.04-i386",
  "ubuntu-10.04-amd64",
  "ubuntu-12.04-i386",
  "ubuntu-12.04-amd64",
  "ubuntu-14.04-i386",
  "ubuntu-14.04-amd64",
  "ubuntu-15.04-i386",
  "ubuntu-15.04-amd64",
  "windows-i386",
  "windows-x86_64",
].each do |platform|
  platform_class = platform.gsub('-','_').gsub('.','')

  RSpec.describe "pe_repo::platform::#{platform_class}" do
    let(:platform_name) { platform }
    let(:agent_version) { '1.2.2' }
    let(:params) do
      {
        :agent_version => agent_version
      }
    end

    it "compiles" do
      should compile.with_all_deps
    end

    context "with pe_build fact" do
      let(:pe_build_version) { '2015.2.0' }
      let(:facts) do
        {
          :pe_build => pe_build_version,
        }
      end

      include_examples("repo behavior", platform)
    end

    context "without pe_build fact" do
      # Mystery: Not specifying a nil pe_build causes the mock function not to be executed...?
      let(:facts) do
        {
          :pe_build => nil,
        }
      end
      let(:pe_build_version) { '2015.2.1' }

      before(:example) do
        mock_pe_build_version = double(:call => pe_build_version)
        Puppet::Parser::Functions.newfunction(:pe_build_version, :type => :rvalue) do |args|
          mock_pe_build_version.call()
        end
      end

      include_examples("repo behavior", platform)
    end
  end
end
