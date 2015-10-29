require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.default_facts = {
    :osfamily                  => 'RedHat',
    :operatingsystemmajrelease => '6',
    :lsbmajdistrelease         => '6',
    :puppetversion             => '3.8.0 (Puppet Enterprise 3.8.0)',
    :pe_concat_basedir         => '/tmp/file',
    :pe_razor_server_version   => '1.0.0.66',
  }
end

