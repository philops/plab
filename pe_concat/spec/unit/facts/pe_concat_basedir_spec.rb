require 'spec_helper'

describe 'pe_concat_basedir', :type => :fact do
  before(:each) { Facter.clear }

  context 'Puppet[:vardir] ==' do
    it '/var/lib/puppet' do
      Puppet.stubs(:[]).with(:vardir).returns('/var/lib/puppet')
      Facter.fact(:pe_concat_basedir).value.should == '/var/lib/puppet/pe_concat'
    end

    it '/home/apenny/.puppet/var' do
      Puppet.stubs(:[]).with(:vardir).returns('/home/apenny/.puppet/var')
      Facter.fact(:pe_concat_basedir).value.should == '/home/apenny/.puppet/var/pe_concat'
    end
  end

end
