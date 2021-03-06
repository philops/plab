require 'spec_helper'
describe 'pe_staging::extract', :type => :define do

  # forcing a more sane caller_module_name to match real usage.
  let(:facts) { { :caller_module_name => 'spec',
                  :osfamily           => 'RedHat',
                  :path               => '/usr/local/bin:/usr/bin:/bin' } }

  describe 'when deploying tar.gz' do
    let(:title) { 'sample.tar.gz' }
    let(:params) { { :target => '/opt' } }

    it {
      should contain_file('/opt/puppetlabs/server/data/staging')
      should contain_exec('extract sample.tar.gz').with({
        :command => 'tar xzf /opt/puppetlabs/server/data/staging/spec/sample.tar.gz',
        :path    => '/usr/local/bin:/usr/bin:/bin',
        :cwd     => '/opt',
        :creates => '/opt/sample'
      })
    }
  end

  describe 'when deploying tar.gz with strip' do
    let(:title) { 'sample.tar.gz' }
    let(:params) { { :target => '/opt',
                     :strip  => 1, } }

    it {
      should contain_file('/opt/puppetlabs/server/data/staging')
      should contain_exec('extract sample.tar.gz').with({
        :command => 'tar xzf /opt/puppetlabs/server/data/staging/spec/sample.tar.gz --strip=1',
        :path    => '/usr/local/bin:/usr/bin:/bin',
        :cwd     => '/opt',
        :creates => '/opt/sample'
      })
    }
  end

  describe 'when deploying zip' do
    let(:title) { 'sample.zip' }
    let(:params) { { :target => '/opt' } }

    it { should contain_file('/opt/puppetlabs/server/data/staging')
      should contain_exec('extract sample.zip').with({
        :command => 'unzip /opt/puppetlabs/server/data/staging/spec/sample.zip',
        :path    => '/usr/local/bin:/usr/bin:/bin',
        :cwd     => '/opt',
        :creates => '/opt/sample'
      })
    }
  end

  describe 'when deploying zip with strip (noop)' do
    let(:title) { 'sample.zip' }
    let(:params) { { :target => '/opt',
                     :strip  => 1, } }

    it { should contain_file('/opt/puppetlabs/server/data/staging')
      should contain_exec('extract sample.zip').with({
        :command => 'unzip /opt/puppetlabs/server/data/staging/spec/sample.zip',
        :path    => '/usr/local/bin:/usr/bin:/bin',
        :cwd     => '/opt',
        :creates => '/opt/sample'
      })
    }
  end

  describe 'when deploying war' do
    let(:title) { 'sample.war' }
    let(:params) { { :target => '/opt' } }

    it { should contain_file('/opt/puppetlabs/server/data/staging')
      should contain_exec('extract sample.war').with({
        :command => 'jar xf /opt/puppetlabs/server/data/staging/spec/sample.war',
        :path    => '/usr/local/bin:/usr/bin:/bin',
        :cwd     => '/opt',
        :creates => '/opt/sample'
      })
    }
  end

  describe 'when deploying war with strip (noop)' do
    let(:title) { 'sample.war' }
    let(:params) { { :target => '/opt',
                     :strip  => 1, } }

    it { should contain_file('/opt/puppetlabs/server/data/staging')
      should contain_exec('extract sample.war').with({
        :command => 'jar xf /opt/puppetlabs/server/data/staging/spec/sample.war',
        :path    => '/usr/local/bin:/usr/bin:/bin',
        :cwd     => '/opt',
        :creates => '/opt/sample'
      })
    }
  end

  describe 'when deploying unknown' do
     let(:title) { 'sample.zzz'}
     let(:params) { { :target => '/opt' } }

     it { expect { should contain_exec("exec sample.zzz") }.to raise_error(Puppet::Error) }
  end
end
