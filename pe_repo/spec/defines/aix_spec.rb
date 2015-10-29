require 'spec_helper'

describe 'pe_repo::aix' do
  let(:title) { 'aix-7.1-power' }

  it "compiles" do
    should compile.with_all_deps
  end
end
