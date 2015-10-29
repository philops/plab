#!/usr/bin/env rspec

require 'spec_helper'
require 'erb'
require 'fakefs/spec_helpers'
require 'facter/custom_auth_conf'

auth_conf_template = File.expand_path(File.join(File.dirname(__FILE__), "../../../templates/profile/master/auth.conf.erb"))
unmodified_auth_conf = ""
File.open(auth_conf_template, 'r') {|auth_conf_erb|
  auth_conf_erb = auth_conf_erb.read
  @console_client_certname = 'pe-internal-dashboard'
  @classifier_client_certname = 'pe-internal-classifier'
  unmodified_auth_conf = ERB.new(auth_conf_erb).result(binding)
}

describe "custom_auth_conf fact" do
  include FakeFS::SpecHelpers

  before :each do
    Facter.flush
    FileUtils.mkdir_p('/etc/puppetlabs/puppet/')
  end

  it "returns true when modified" do
    File.open('/etc/puppetlabs/puppet/auth.conf', 'w') {|f|
      f.write('This has been modified')
    }
    Facter.fact(:custom_auth_conf).value.should eq("true")
  end

  it "returns false when not modified" do
    File.open('/etc/puppetlabs/puppet/auth.conf', 'w') {|f|
      f.write(unmodified_auth_conf)
    }
    Facter.fact(:custom_auth_conf).value.should eq("false")
  end
end
