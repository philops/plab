require 'spec_helper_acceptance'

describe 'pe_postgresql::server::database:', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  after :all do
    # Cleanup after tests have ran
    apply_manifest("class { 'pe_postgresql::server': ensure => absent }", :catch_failures => true)
  end

  it 'should idempotently create a db that we can connect to' do
    begin
      pp = <<-EOS.unindent
        $db = 'postgresql_test_db'
        class { 'pe_postgresql::server': }

        pe_postgresql::server::database { $db: }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)

      psql('--command="select datname from pg_database" postgresql_test_db') do |r|
        expect(r.stdout).to match(/postgresql_test_db/)
        expect(r.stderr).to eq('')
      end
    ensure
      psql('--command="drop database postgresql_test_db" postgres')
    end
  end
end

describe 'pe_postgresql::server::database: alternate port', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  it 'should idempotently create a db on a non-default port that we can connect to' do
    begin
      pp = <<-EOS.unindent
        $db = 'postgresql_test_db'
        class { 'pe_postgresql::server':
          port => 5433,
        }

        pe_postgresql::server::database { $db: }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)

      psql('--command="select datname from pg_database" --port=5433 postgresql_test_db') do |r|
        expect(r.stdout).to match(/postgresql_test_db/)
        expect(r.stderr).to eq('')
      end
    ensure
      psql('--command="drop database postgresql_test_db" --port=5433 postgres')
    end
  end
end
