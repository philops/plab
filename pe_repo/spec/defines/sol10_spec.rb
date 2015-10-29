require 'spec_helper'

describe 'pe_repo::sol10' do
  let(:title) { 'solaris-10-sparc' }

  it "compiles" do
    should compile.with_all_deps
  end
end
