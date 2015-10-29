require 'spec_helper'

describe 'pe_razor' do
  before :each do
    @facter_facts = {}
  end

  let(:facts) { @facter_facts }

  context 'supported operating system and version' do
    ['RedHat', 'CentOS'].each do |os|
      ['6', '7'].each do |os_version|
        context "#{os} version #{os_version}" do
          before :each do
            @facter_facts['operatingsystem'] = os
            @facter_facts['operatingsystemmajrelease'] = os_version
          end

          it 'compiles' do
            subject
          end
        end
      end
    end
  end

  context 'unsupported OS and supported version' do
    before :each do
      @facter_facts['operatingsystem'] = 'foo'
      @facter_facts['operatingsystemmajrelease'] = '6'
    end

    it 'fails to compile' do
      expect { subject }.to raise_error(Puppet::Error, /this version of Razor is only available/)
    end
  end

  context 'unsupported OS and unsupported version' do
    before :each do
      @facter_facts['operatingsystem'] = 'foo'
      @facter_facts['operatingsystemmajrelease'] = '5'
    end

    it 'fails to compile' do
      expect { subject }.to raise_error(Puppet::Error, /this version of Razor is only available/)
    end
  end

  context 'supported OS and unsupported version' do
    before :each do
      @facter_facts['operatingsystem'] = 'RedHat'
      @facter_facts['operatingsystemmajrelease'] = '4'
    end

    it 'fails to compile' do
      expect { subject }.to raise_error(Puppet::Error, /this version of Razor is only available/)
    end
  end
end
