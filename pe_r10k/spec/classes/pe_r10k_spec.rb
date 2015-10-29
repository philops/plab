require 'spec_helper'

describe 'pe_r10k' do
  it 'includes the pe-r10k package' do
    expect(subject).to contain_pe_r10k__package
  end
end
