require 'spec_helper'

describe 'pe_repo::repo' do
  let(:title) { 'el-7-x86_64 2015.2.0' }
  let(:params) do
    {
      :installer_build => 'el-7-x86_64'
    }
  end

  it "compiles" do
    should compile.with_all_deps
  end
end
