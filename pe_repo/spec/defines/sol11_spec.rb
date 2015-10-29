require 'spec_helper'

describe 'pe_repo::sol11' do
  let(:title) { 'solaris-11-sparc' }

  it "compiles" do
    should compile.with_all_deps
  end
end
