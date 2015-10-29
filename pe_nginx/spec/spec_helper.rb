require 'puppetlabs_spec_helper/module_spec_helper'
require 'matchers/augeas_matchers'


RSpec.configure do |c|
  c.hiera_config = 'spec/fixtures/hiera/hiera.yaml'
  c.default_facts = {
    :osfamily                => 'RedHat',
    :lsbmajdistrelease       => '6',
    :puppetversion           => '3.6.2 (Puppet Enterprise 3.3.0)',
    :is_pe                   => 'true',
  }
end
