require 'spec_helper_acceptance'
require 'yaml'

describe 'pe_r10k class', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  let(:remote) { 'https://github.com/glarizza/puppet_repository.git' }

  describe 'applying the class' do
    let(:pp) { "class { 'pe_r10k': remote => '#{remote}' }" }

    it "should apply changes on the first run" do
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stderr).not_to match(/error/i)
        expect(r.exit_code).to eq(2)
      end
    end

    it "does not make changes on the subsequent run" do
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stderr).not_to eq(/error/i)
        expect(r.exit_code).to be_zero
      end
    end
  end

  describe 'creating r10k.yaml' do
    before do
      pp = "class { 'pe_r10k': remote => '#{remote}' }"
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("/etc/puppetlabs/r10k/r10k.yaml") do

      let(:parsed_content) { YAML.load(subject.content) }

      it { should be_file }
      it { should be_mode 644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }

      it "has the expected content structure" do
        expect(parsed_content).to eq(
          'cachedir' => '/opt/puppetlabs/puppet/cache/r10k',
          'sources'  => {
            'puppet' => {
              'remote'  => remote,
              'basedir' => '/etc/puppetlabs/code/environments',
            }
          }
        )
      end
    end
  end
end
