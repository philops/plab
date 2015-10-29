require 'spec_helper'

describe 'pe_repo::el' do
  let(:title) { 'el-7-x86_64' }

  it "compiles" do
    should compile.with_all_deps
  end
end
