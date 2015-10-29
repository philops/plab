require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

unless ENV['RS_PROVISION'] == 'no' or ENV['BEAKER_provision'] == 'no'
  # This will install the latest available package on el and deb based
  # systems fail on windows and osx, and install via gem on other *nixes
  foss_opts = { :default_action => 'gem_install' }

  if default.is_pe?; then install_pe; else install_puppet( foss_opts ); end

  hosts.each do |host|
    on hosts, "mkdir -p #{host['distmoduledir']}"
  end
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    hosts.each do |host|
      on host, "mkdir -p #{host['distmoduledir']}/pe_concat"
      result = on host, "echo #{host['distmoduledir']}"
      target = result.raw_output.chomp

      %w(files lib manifests metadata.json).each do |file|
        scp_to host, "#{proj_root}/#{file}", File.join(target, 'pe_concat')
      end
      #copy_module_to(host, :source => proj_root, :module_name => 'pe_concat')
      scp_to host, "#{proj_root}/spec/fixtures/modules/puppet_enterprise", File.join(target, 'puppet_enterprise')
    end
  end

  c.before(:all) do
    shell('mkdir -p /tmp/pe_concat')
  end
  c.after(:all) do
    shell('rm -rf /tmp/pe_concat /var/lib/puppet/pe_concat')
  end

  c.treat_symbols_as_metadata_keys_with_true_values = true
end
