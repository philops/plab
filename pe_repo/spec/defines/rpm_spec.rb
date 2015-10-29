require 'spec_helper'

describe 'pe_repo::rpm' do
  let(:title) { 'sles-10-x86_64' }

  it "compiles" do
    should compile.with_all_deps
  end
end
