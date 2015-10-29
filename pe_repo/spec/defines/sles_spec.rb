require 'spec_helper'

describe 'pe_repo::sles' do
  let(:title) { 'sles-12-x86_64' }

  it "compiles" do
    should compile.with_all_deps
  end
end
