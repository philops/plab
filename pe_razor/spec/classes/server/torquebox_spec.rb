require 'spec_helper'

describe 'pe_razor::server::torquebox' do
  before :each do
    @facter_facts = {
      'clientcert' => 'test.example.vm',
    }
    @params = {
      'server_http_port'  => 8150,
      'server_https_port' => 8151
    }
  end

  let(:params) { @params }
  let(:facts) { @facter_facts }
  let(:jboss_standalone_xml) { '/opt/puppetlabs/server/apps/razor-server/share/torquebox/jboss/standalone/configuration/standalone.xml' }

  context 'with valid parameter' do
    context 'java keystores' do
      it { should contain_pe_java_ks('pe-razor:truststore').with(
        'certificate' => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
        'target'      => '/etc/puppetlabs/razor-server/pe-razor.ts',
      )}

      it { should contain_pe_java_ks('pe-razor:keystore').with(
        'certificate' => '/etc/puppetlabs/puppet/ssl/certs/test.example.vm.pem',
        'private_key' => '/etc/puppetlabs/puppet/ssl/private_keys/test.example.vm.pem',
        'target'      => '/etc/puppetlabs/razor-server/pe-razor.ks',
      )}
    end

    context 'standalone.xml' do
      it { should contain_file(jboss_standalone_xml).with_content(/<ssl.*key-alias="pe-razor" password="pe-razor" certificate-key-file="\/etc\/puppetlabs\/razor-server\/pe-razor\.ks"/) }
      it { should contain_file(jboss_standalone_xml).with_content(/socket-binding name='http'.*port='8150'/) }
      it { should contain_file(jboss_standalone_xml).with_content(/socket-binding name='https'.*port='8151'/) }
    end
  end
end
