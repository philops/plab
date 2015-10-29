require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

UNSUPPORTED_PLATFORMS = []

unless ENV['RS_PROVISION'] == 'no' or ENV['BEAKER_provision'] == 'no'
  # This will install the latest available package on el and deb based
  # systems fail on windows and osx, and install via gem on other *nixes
  foss_opts = { :default_action => 'gem_install' }

  if default.is_pe?; then install_pe; else install_puppet( foss_opts ); end

  hosts.each do |host|
    on host, "mkdir -p #{host['distmoduledir']}"
  end
end

opensslscript =<<EOS
  require 'openssl'
  key = OpenSSL::PKey::RSA.new 1024
  ca = OpenSSL::X509::Certificate.new
  ca.serial = 1
  ca.public_key = key.public_key
  subj = '/CN=Test CA/ST=Denial/L=Springfield/O=Dis/CN=www.example.com'
  ca.subject = OpenSSL::X509::Name.parse subj
  ca.issuer = ca.subject
  ca.not_before = Time.now
  ca.not_after = ca.not_before + 360
  ca.sign(key, OpenSSL::Digest::SHA256.new)

  File.open('/tmp/privkey.pem', 'w') { |f| f.write key.to_pem }
  File.open('/tmp/ca.pem', 'w') { |f| f.write ca.to_pem }
EOS

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'pe_java_ks')
    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs-java') if host['roles'].include?('master')
      # Generate private key and CA for keystore
      path = '${PATH}'
      path = "/opt/csw/bin:#{path}" # Need ruby's path on solaris 10 (foss)
      path = "/opt/puppet/bin:#{path}" # But try PE's ruby first
      on host, "PATH=#{path} ruby -e \"#{opensslscript}\""
    end
  end
end
