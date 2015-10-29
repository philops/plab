require 'spec_helper'

describe 'puppet_enterprise::certs::rbac_whitelist_entry', :type => :define do
  context 'on a supported platform' do
    let(:title) { 'export pe-internal-dashboard dashboard' }

    let(:facts) do
      {
        :osfamily => 'RedHat',
        :fqdn     => 'test.domain.local'
      }
    end

    let(:params) do
      {
        :certname => 'pe-internal-dashboard',
      }
    end

    it { should contain_pe_file_line("/etc/puppetlabs/console-services/rbac-certificate-whitelist:pe-internal-dashboard").with('line' => 'pe-internal-dashboard') }
  end
end
