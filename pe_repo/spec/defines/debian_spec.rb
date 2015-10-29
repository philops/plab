require 'spec_helper'

describe 'pe_repo::debian' do
  let(:title) { 'ubuntu-14.04-amd64' }
  let(:params) do
    {
      :codename => 'trusty'
    }
  end

  it "compiles" do
    should compile.with_all_deps
  end
end
