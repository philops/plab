require 'spec_helper_acceptance'

describe 'unsupported distributions and OSes', :if => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  it 'should fail for client' do
    pp = <<-EOS
    class { 'pe_postgresql::client': }
    EOS
    expect(apply_manifest(pp, :expect_failures => true).stderr).to match(/No preferred version defined or automatically detected/i)
  end
  it 'should fail for server' do
    pp = <<-EOS
    class { 'pe_postgresql::server': }
    EOS
    expect(apply_manifest(pp, :expect_failures => true).stderr).to match(/No preferred version defined or automatically detected/i)
  end
end
