require 'spec_helper'

describe 'pe_repo' do

  it "compiles" do
    should compile.with_all_deps
  end

  context "with pe_build fact" do
    let(:facts) do
      {
        :pe_build => '2015.2.0',
      }
    end

    it "uses the agent fact" do
      should contain_file('/opt/puppetlabs/server/data/packages/public/current')
        .with_target('/opt/puppetlabs/server/data/packages/public/2015.2.0')
    end
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

    it "relies on compiling master's pe_build_version()" do
      should contain_file('/opt/puppetlabs/server/data/packages/public/current')
        .with_target('/opt/puppetlabs/server/data/packages/public/2015.2.1')
    end
  end

end
