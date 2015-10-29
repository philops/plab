require 'spec_helper_acceptance'

describe 'quoted paths' do
  basedir = default.tmpdir('pe_concat')

  before(:all) do
    pp = <<-EOS
      file { '#{basedir}':
        ensure => directory,
      }
      file { '#{basedir}/pe_concat test':
        ensure => directory,
      }
    EOS
    apply_manifest(pp)
  end

  context 'path with blanks' do
    pp = <<-EOS
      pe_concat { '#{basedir}/pe_concat test/foo':
      }
      pe_concat::fragment { '1':
        target  => '#{basedir}/pe_concat test/foo',
        content => 'string1',
      }
      pe_concat::fragment { '2':
        target  => '#{basedir}/pe_concat test/foo',
        content => 'string2',
      }
    EOS

    it 'applies the manifest twice with no stderr' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file("#{basedir}/pe_concat test/foo") do
      it { should be_file }
      it("should contain string1\nstring2", :unless => (fact('osfamily') == 'Solaris')) {
        should contain "string1\nstring2"
      }
    end
  end
end
