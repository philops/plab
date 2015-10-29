require 'spec_helper'
require 'yaml'

describe 'pe_r10k::config' do
  let(:params) do
    {
      'configfile'     => '/etc/puppetlabs/r10k/r10k.yaml',
      'cachedir'       => '/var/opt/puppetlabs/r10k/git',
      'remote'         => Undef.new,
      'sources'        => Undef.new,
      'git_settings'   => '',
      'forge_settings' => '',
      'postrun'        => Undef.new,
      'r10k_basedir'   => '/etc/puppetlabs/code/environments',
      'r10k_user'      => '0',
      'r10k_group'     => '0',
    }
  end

  it "creates the r10k.yaml file" do
    expect(subject).to contain_file('r10k.yaml').with(
      'ensure' => 'file',
      'owner'  => '0',
      'group'  => '0',
      'mode'   => '0644',
      'path'   => '/etc/puppetlabs/r10k/r10k.yaml',
    )
  end

  describe "templating the file" do
    let(:content) do
      resource = catalogue.resource('File[r10k.yaml]')
      YAML.load(resource[:content])
    end

    describe 'setting the cachedir' do
      it 'adds the setting to the config file' do
        expect(content).to include('cachedir' => '/var/opt/puppetlabs/r10k/git')
      end
    end

    describe 'setting the postrun command' do
      describe "with a valid postrun command" do
        let(:postrun) { ["/usr/bin/curl", "http://mysite.local/events", "-F", "deploy=done"] }

        before do
          params.merge!('postrun' => postrun)
        end

        it 'adds the setting to the config file' do
          expect(content).to include('postrun' => postrun)
        end
      end

      describe "with an invalid postrun command" do
        before do
          params.merge!('postrun' => "/bin/echo this will not work")
        end

        it "fails to compile with a validation error" do
          expect(subject).to_not compile
        end
      end
    end

    describe 'configuring sources' do
      describe "and the 'remote' parameter is set" do
        before do
          params.merge!('remote' => 'git://git-server.site/puppet-environments.git')
        end

        it "autoconfigures the sources field" do
          expect(content).to include(
            'sources' => {
              'puppet' => {
                'remote'  => 'git://git-server.site/puppet-environments.git',
                'basedir' => '/etc/puppetlabs/code/environments',
              }
            }
          )
        end
      end

      describe "and the 'sources' parameter is set" do
        let(:sources_hash) do
          {
            'puppet' => {
              'remote'  => 'git://git-server.site/puppet-code.git',
              'basedir' => '/etc/puppetlabs/code/environments',
            },
            'hiera' => {
              'remote'  => 'git://git-server.site/puppet-hieradata.git',
              'basedir' => '/etc/puppetlabs/puppet/hiera',
            }
          }
        end

        before do
          params.merge!('sources' => sources_hash)
        end

        it "uses the sources hash values" do
          expect(content).to include('sources' => sources_hash)
        end
      end

      describe "and both the 'remote' and 'sources' parameters are set" do
        let(:sources_hash) do
          {
            'puppet' => {
              'remote'  => 'git://git-server.site/puppet-code.git',
              'basedir' => '/etc/puppetlabs/code/environments',
            },
            'hiera' => {
              'remote'  => 'git://git-server.site/puppet-hieradata.git',
              'basedir' => '/etc/puppetlabs/puppet/hiera',
            }
          }
        end

        before do
          params.merge!(
            'sources' => sources_hash,
            'remote'  => 'git://some.server.site/not-used.git',
          )
        end

        it "uses the 'sources' parameter over the 'remote' parameter" do
          expect(content).to include('sources' => sources_hash)
        end
      end

      describe "and neither the 'remote' nor 'sources' parameters are set" do
        it "does not include the 'sources' field" do
          expect(content).to_not have_key('sources')
        end
      end
    end

    describe "configuring git settings" do
      describe "and the git_settings hash is empty" do
        it "does not add the git key to the config file when empty" do
          expect(content).to_not have_key('git')
        end
      end

      describe "and the git_settings hash is populated" do
        before do
          params.merge!(
            'git_settings' => {
              'provider'    => 'rugged',
              'username'    => 'git',
              'private_key' => '/etc/puppetlabs/r10k/id_rsa',
            }
          )
        end

        it "adds the git settings as a hash when populated" do
          expect(content).to include(
            'git' => {
              'provider'    => 'rugged',
              'username'    => 'git',
              'private_key' => '/etc/puppetlabs/r10k/id_rsa',
            }
          )
        end
      end
    end

    describe "configuring forge settings" do
      describe "and the forge_settings hash is empty" do
        it "does not add the forge key to the config file when empty" do
          expect(content).to_not have_key('forge')
        end
      end

      describe "and the forge_settings hash is populated" do
        before do
          params.merge!(
            'forge_settings' => {
              'proxy'   => 'https://user1:P455w0rd@proxy.example.com',
              'baseurl' => 'https://forgeapi.puppetlabs.com',
            }
          )
        end

        it "adds the forge settings as a hash when populated" do
          expect(content).to include(
            'forge' => {
              'proxy'   => 'https://user1:P455w0rd@proxy.example.com',
              'baseurl' => 'https://forgeapi.puppetlabs.com',
            }
          )
        end
      end
    end

  end
end
