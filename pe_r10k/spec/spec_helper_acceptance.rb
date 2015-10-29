#require 'beaker-rspec'
require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

UNSUPPORTED_PLATFORMS = ['windows', 'Darwin', 'Solaris']

if !(ENV['RS_PROVISION'] == 'no' || ENV['BEAKER_provision'] == 'no')
  install_pe
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    hosts.each do |host|
      copy_module_to(host, :source => proj_root, :module_name => 'pe_r10k')
      on host, puppet('module','install','puppetlabs/stdlib', '--force'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
