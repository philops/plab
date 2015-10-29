require 'spec_helper'
require 'pry'


describe 'pe_nginx::directive', :type => :define do
  before(:each) do
    @title = 'server_name'
    @augeas_title = "pe_nginx::directive for #{@title}"
    @conf_file = '/etc/puppetlabs/httpd/conf.d/test.conf'
    @augeas_path = "/files/#{@conf_file}"

    @params = {
      :target => '/etc/puppetlabs/httpd/conf.d/test.conf',
      :value  => 'foo',
      :replace_value => false,
    }

    @changes = []

  end

  let(:title) { @title }
  let(:params) { @params }

  it { should contain_augeas(@augeas_title).with_notify('Service[pe-nginx]') }

  context 'invalid parameters' do
    context 'directive_ensure' do
      before(:each) do
        @params.merge!({:directive_ensure => 'this tots should raise an error, yo'})
      end

      it "fails to compile" do
        expect { subject }.to raise_error(Puppet::Error, /does not match/)
      end
    end
  end

  context 'comment parameter' do
    before(:each) do
      # Set the parameters
      @params[:value] = 'conf/mime.types'
      @params[:directive_name] = 'include'
      @params[:comment] = 'Include default mime types'

      # Set the expected changes
      @changes = [
        "set include[.='conf/mime.types'] 'conf/mime.types'",
        "ins #comment before include",
        "set #comment[following-sibling::*[1][self::include]] 'Include default mime types'"
      ]
    end


    it { should contain_augeas_with_changes(@augeas_title, @changes) }
    it { should contain_augeas(@augeas_title).with_context("#{@augeas_path}/http") }
  end

  context 'replace_value true' do 
    before(:each) do 
      @params[:replace_value] = true
      @params[:value] = 'conf/mime.types'
      @params[:directive_name] = 'include'
      @changes = "set include 'conf/mime.types'"
    end

    it { should contain_augeas_with_changes(@augeas_title, @changes) }
    it { should contain_augeas(@augeas_title).with_context("#{@augeas_path}/http") }
  end
  


  context 'http directive' do
    before(:each) do
      # Set the parameters
      @params[:value] = 'conf/mime.types'
      @params[:directive_name] = 'include'
    end

    context 'setting an include' do
      before(:each) do
        # Set the expected changes
        @changes = "set include[.='conf/mime.types'] 'conf/mime.types'"
      end

      it { should contain_augeas_with_changes(@augeas_title, @changes) }
      it { should contain_augeas(@augeas_title).with_context("#{@augeas_path}/http") }
    end

    context 'removing an include' do
      before(:each) do
        # Set the parameters
        @params[:directive_ensure] = 'absent'

        # Set the expected changes
        @changes = "rm include[include='conf/mime.types']"
      end

      it { should contain_augeas_with_changes(@augeas_title, @changes) }
      it { should contain_augeas(@augeas_title).with_context("#{@augeas_path}/http") }
    end
  end

  context 'server directive access_log' do
    before(:each) do
      # Set the parameters
      @params[:value] = '/var/log/puppetlabs/pe-nginx/puppetproxy.log'
      @params[:directive_name] = 'access_log'
      @params[:server_context] = 'console.example.vm'

      # Set the expected changes
      @changes = "set access_log[.='/var/log/puppetlabs/pe-nginx/puppetproxy.log'] '/var/log/puppetlabs/pe-nginx/puppetproxy.log'"
    end

    context 'with a simple server_context' do
      it { should contain_augeas_with_changes(@augeas_title, @changes) }
      it { should contain_augeas(@augeas_title).with_context("#{@augeas_path}/server[server_name='console.example.vm']") }
    end

    context 'with a server_context containing server_name and listen' do
      before(:each) do
        # Set the parameters
        @params[:server_context] = 'console.example.vm:443 ssl'
      end

      it { should contain_augeas_with_changes(@augeas_title, @changes) }
      it { should contain_augeas(@augeas_title).with_context("#{@augeas_path}/server[server_name='console.example.vm' and listen='443 ssl']") }
    end


    context 'removing a server directive' do
      before(:each) do
        # Set the parameters
        @params[:directive_ensure] = 'absent'

        # Set the expected changes
        @changes = "rm access_log[access_log='/var/log/puppetlabs/pe-nginx/puppetproxy.log']"
      end

      it { should contain_augeas_with_changes(@augeas_title, @changes) }
      it { should contain_augeas(@augeas_title).with_context("#{@augeas_path}/server[server_name='console.example.vm']") }
    end
  end

  context 'location directive "proxy_pass"' do
    before(:each) do
      # Set the parameters
      @params[:value] = 'http://127.0.0.1:4431'
      @params[:directive_name] = 'proxy_pass'
      @params[:server_context] = 'console.example.vm'
      @params[:location_context] = '/'

      # Set the expected changes
      @changes = [
        "set proxy_pass[.='http://127.0.0.1:4431'] 'http://127.0.0.1:4431'"
      ]
    end

    context 'with no server_context' do
      before(:each) do
        # Set the parameters
        @params.delete(:server_context)
      end

      it "fails to compile" do
        expect { subject }.to raise_error(Puppet::Error, /Location context passed without a server context/)
      end
    end

    context 'with no regex modifiers on location_context' do
      before(:each) do
        @changes << "set #uri '/'"
      end

      it { should contain_augeas_with_changes(@augeas_title, @changes) }
      it { should contain_augeas(@augeas_title).with_context("#{@augeas_path}/server[server_name='console.example.vm']/location[#uri='/']") }
    end


    %w[= ~ ~* ^~].each do |modifier|
      context "with regex modifier '#{modifier}'" do
        before(:each) do
          @params[:location_context] = "#{modifier} \.php$"
          @changes << "set #comp '#{modifier}'"
          @changes << "set #uri '\.php$'"
        end

        it { should contain_augeas_with_changes(@augeas_title, @changes) }
        it { should contain_augeas(@augeas_title).with_context("#{@augeas_path}/server[server_name='console.example.vm']/location[#comp='#{modifier}' and #uri='\.php$']") }
      end
    end

    context 'removing a location directive' do
      before(:each) do
        # Set the parameters
        @params[:directive_ensure] = 'false'

        # Set the expected changes
        @changes = "rm proxy_pass[proxy_pass='http://127.0.0.1:4431']"
      end

      it { should contain_augeas_with_changes(@augeas_title, @changes) }
      it { should contain_augeas(@augeas_title).with_context("#{@augeas_path}/server[server_name='console.example.vm']/location[#uri='/']") }
    end
  end
end
