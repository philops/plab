require 'spec_helper'

describe 'pe_postgresql::globals', :type => :class do
  let :facts do
    {
      :osfamily               => 'RedHat',
      :operatingsystem        => 'RedHat',
      :operatingsystemrelease => '6.0',
      :lsbdistid              => 'RedHat',
    }
  end

  describe 'with no parameters' do
    it 'should work' do
      should contain_class("pe_postgresql::globals")
    end
  end

  describe 'manage_package_repo => true' do
    let(:params) do
      {
        :manage_package_repo => true,
      }
    end
    it 'should pull in class pe_postgresql::repo' do
      should contain_class("pe_postgresql::repo")
    end
  end
end
