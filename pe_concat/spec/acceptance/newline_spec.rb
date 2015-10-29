require 'spec_helper_acceptance'

describe 'pe_concat ensure_newline parameter' do
  basedir = default.tmpdir('pe_concat')
  context '=> false' do
    before(:all) do
      pp = <<-EOS
        file { '#{basedir}':
          ensure => directory
        }
      EOS

      apply_manifest(pp)
    end
    pp = <<-EOS
      pe_concat { '#{basedir}/file':
        ensure_newline => false,
      }
      pe_concat::fragment { '1':
        target  => '#{basedir}/file',
        content => '1',
      }
      pe_concat::fragment { '2':
        target  => '#{basedir}/file',
        content => '2',
      }
    EOS

    it 'applies the manifest twice with no stderr' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file("#{basedir}/file") do
      it { should be_file }
      it { should contain '12' }
    end
  end

  context '=> true' do
    pp = <<-EOS
      pe_concat { '#{basedir}/file':
        ensure_newline => true,
      }
      pe_concat::fragment { '1':
        target  => '#{basedir}/file',
        content => '1',
      }
      pe_concat::fragment { '2':
        target  => '#{basedir}/file',
        content => '2',
      }
    EOS

    it 'applies the manifest twice with no stderr' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe file("#{basedir}/file") do
      it { should be_file }
      it("should contain 1\n2\n", :unless => (fact('osfamily') == 'Solaris')) {
        should contain "1\n2\n"
      }
    end
  end
end
