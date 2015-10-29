require 'spec_helper'

describe 'pe_repo::windows' do
  let(:title) { 'windows-x86_64' }
  let(:params) do
    {
      :arch => 'x64',
    }
  end

  it "compiles" do
    should compile.with_all_deps
  end
end
