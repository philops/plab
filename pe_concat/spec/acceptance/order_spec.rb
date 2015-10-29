require 'spec_helper_acceptance'

describe 'pe_concat order' do
  basedir = default.tmpdir('pe_concat')

  context '=> alpha' do
    pp = <<-EOS
      pe_concat { '#{basedir}/foo':
        order => 'alpha'
      }
      pe_concat::fragment { '1':
        target  => '#{basedir}/foo',
        content => 'string1',
      }
      pe_concat::fragment { '2':
        target  => '#{basedir}/foo',
        content => 'string2',
      }
      pe_concat::fragment { '10':
        target  => '#{basedir}/foo',
        content => 'string10',
      }
    EOS

    it 'applies the manifest twice with no stderr' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file("#{basedir}/foo") do
      it { should be_file }
      #XXX Solaris 10 doesn't support multi-line grep
      it("should contain string10\nstring1\nsring2", :unless => (fact('osfamily') == 'Solaris')) {
        should contain "string10\nstring1\nsring2"
      }
    end
  end

  context '=> numeric' do
    pp = <<-EOS
      pe_concat { '#{basedir}/foo':
        order => 'numeric'
      }
      pe_concat::fragment { '1':
        target  => '#{basedir}/foo',
        content => 'string1',
      }
      pe_concat::fragment { '2':
        target  => '#{basedir}/foo',
        content => 'string2',
      }
      pe_concat::fragment { '10':
        target  => '#{basedir}/foo',
        content => 'string10',
      }
    EOS

    it 'applies the manifest twice with no stderr' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file("#{basedir}/foo") do
      it { should be_file }
      #XXX Solaris 10 doesn't support multi-line grep
      it("should contain string1\nstring2\nsring10", :unless => (fact('osfamily') == 'Solaris')) {
        should contain "string1\nstring2\nsring10"
      }
    end
  end
end # pe_concat order

describe 'pe_concat::fragment order' do
  basedir = default.tmpdir('pe_concat')

  context '=> reverse order' do
    pp = <<-EOS
      pe_concat { '#{basedir}/foo': }
      pe_concat::fragment { '1':
        target  => '#{basedir}/foo',
        content => 'string1',
        order   => '15',
      }
      pe_concat::fragment { '2':
        target  => '#{basedir}/foo',
        content => 'string2',
        # default order 10
      }
      pe_concat::fragment { '3':
        target  => '#{basedir}/foo',
        content => 'string3',
        order   => '1',
      }
    EOS

    it 'applies the manifest twice with no stderr' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file("#{basedir}/foo") do
      it { should be_file }
      #XXX Solaris 10 doesn't support multi-line grep
      it("should contain string3\nstring2\nsring1", :unless => (fact('osfamily') == 'Solaris')) {
        should contain "string3\nstring2\nsring1"
      }
    end
  end

  context '=> normal order' do
    pp = <<-EOS
      pe_concat { '#{basedir}/foo': }
      pe_concat::fragment { '1':
        target  => '#{basedir}/foo',
        content => 'string1',
        order   => '01',
      }
      pe_concat::fragment { '2':
        target  => '#{basedir}/foo',
        content => 'string2',
        order   => '02'
      }
      pe_concat::fragment { '3':
        target  => '#{basedir}/foo',
        content => 'string3',
        order   => '03',
      }
    EOS

    it 'applies the manifest twice with no stderr' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file("#{basedir}/foo") do
      it { should be_file }
      #XXX Solaris 10 doesn't support multi-line grep
      it("should contain string1\nstring2\nsring3", :unless => (fact('osfamily') == 'Solaris')) {
        should contain "string1\nstring2\nsring3"
      }
    end
  end
end # pe_concat::fragment order
