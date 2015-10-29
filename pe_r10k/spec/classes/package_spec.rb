require 'spec_helper'

describe 'pe_r10k::package' do
  it 'includes the pe-r10k package' do
    expect(subject).to contain_package('pe-r10k').with('ensure' => 'latest')
  end
end
