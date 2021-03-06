require 'spec_helper'

describe 'pe_concat::setup', :type => :class do

  shared_examples 'setup' do |concatdir|
    concatdir = '/foo' if concatdir.nil?

    let(:facts) {{ :pe_concat_basedir => concatdir, :id => 'root', :gid => 'root'}}

    it do
      should contain_file("#{concatdir}/bin/concatfragments.sh").with({
        :mode   => '0755',
        :source => 'puppet:///modules/pe_concat/concatfragments.sh',
        :backup => false,
        :owner  => 'root',
        :group  => 'root',
      })
    end

    [concatdir, "#{concatdir}/bin"].each do |file|
      it do
        should contain_file(file).with({
          :ensure => 'directory',
          :mode   => '0755',
          :backup => false,
          :owner  => 'root',
          :group  => 'root',
        })
      end
    end
  end

  context 'facts' do
    context 'pe_concat_basedir =>' do
      context '/foo' do
        it_behaves_like 'setup', '/foo'
      end
    end
  end # facts

  context 'deprecated as a public class' do
    it 'should create a warning' do
      pending('rspec-puppet support for testing warning()')
    end
  end

  context "on osfamily Solaris" do
    concatdir = '/foo'
    let(:facts) do
      {
        :pe_concat_basedir => concatdir,
        :osfamily       => 'Solaris',
        :id             => 'root',
        :gid            => 'root',
      }
    end

    it do
      should contain_file("#{concatdir}/bin/concatfragments.rb").with({
        :ensure => 'file',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0755',
        :source => 'puppet:///modules/pe_concat/concatfragments.rb',
        :backup => false,
      })
    end
  end # on osfamily Solaris

  context "on osfamily windows" do
    concatdir = '/foo'
    let(:facts) do
      {
        :pe_concat_basedir => concatdir,
        :osfamily       => 'windows',
        :id             => 'batman',
      }
    end

    it do
      should contain_file("#{concatdir}/bin/concatfragments.rb").with({
        :ensure => 'file',
        :owner  => nil,
        :group  => nil,
        :mode   => nil,
        :source => 'puppet:///modules/pe_concat/concatfragments.rb',
        :backup => false,
      })
    end
  end # on osfamily windows
end
