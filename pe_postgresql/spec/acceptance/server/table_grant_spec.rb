require 'spec_helper_acceptance'

describe 'pe_postgresql::server::table_grant:', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  after :all do
    # Cleanup after tests have ran
    apply_manifest("class { 'pe_postgresql::server': ensure => absent }", :catch_failures => true)
  end

  it 'should grant all accesses to a user' do
    begin
      pp = <<-EOS.unindent
        $db = 'table_grant'
        $user = 'psql_grant_tester'
        $password = 'psql_table_pw'

        class { 'pe_postgresql::server': }

        # Since we are not testing pg_hba or any of that, make a local user for ident auth
        user { $user:
          ensure => present,
        }

        pe_postgresql::server::role { $user:
          password_hash => pe_postgresql_password($user, $password),
        }

        pe_postgresql::server::database { $db: }

        # Create a rule for the user
        pe_postgresql::server::pg_hba_rule { "allow ${user}":
          type        => 'local',
          database    => $db,
          user        => $user,
          auth_method => 'ident',
          order       => 1,
        }

        pe_postgresql_psql { 'Create testing table':
          command => 'CREATE TABLE "test_table" (field integer NOT NULL)',
          db      => $db,
          unless  => "SELECT * FROM pg_tables WHERE tablename = 'test_table'",
          require => Pe_postgresql::Server::Database[$db],
        }

        pe_postgresql::server::table_grant { 'grant insert test':
          privilege => 'ALL',
          table     => 'test_table',
          db        => $db,
          role      => $user,
          require   => Pe_postgresql_psql['Create testing table'],
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)

      ## Check that the user can create a table in the database
      psql('--command="create table foo (foo int)" postgres', 'psql_grant_tester') do |r|
        expect(r.stdout).to match(/CREATE TABLE/)
        expect(r.stderr).to eq('')
      end
    ensure
      psql('--command="drop table foo" postgres', 'psql_grant_tester')
    end
  end

  it 'should grant access so a user can insert in a table' do
    begin
      pp = <<-EOS.unindent
        $db = 'table_grant'
        $user = 'psql_grant_tester'
        $password = 'psql_table_pw'

        class { 'pe_postgresql::server': }

        # Since we are not testing pg_hba or any of that, make a local user for ident auth
        user { $user:
          ensure => present,
        }

        pe_postgresql::server::role { $user:
          password_hash => pe_postgresql_password($user, $password),
        }

        pe_postgresql::server::database { $db: }

        # Create a rule for the user
        pe_postgresql::server::pg_hba_rule { "allow ${user}":
          type        => 'local',
          database    => $db,
          user        => $user,
          auth_method => 'ident',
          order       => 1,
        }

        pe_postgresql_psql { 'Create testing table':
          command => 'CREATE TABLE "test_table" (field integer NOT NULL)',
          db      => $db,
          unless  => "SELECT * FROM pg_tables WHERE tablename = 'test_table'",
          require => Pe_postgresql::Server::Database[$db],
        }

        pe_postgresql::server::table_grant { 'grant insert test':
          privilege => 'INSERT',
          table     => 'test_table',
          db        => $db,
          role      => $user,
          require   => Pe_postgresql_psql['Create testing table'],
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)

      ## Check that the user can create a table in the database
      psql('--command="create table foo (foo int)" postgres', 'psql_grant_tester') do |r|
        expect(r.stdout).to match(/CREATE TABLE/)
        expect(r.stderr).to eq('')
      end
    ensure
      psql('--command="drop table foo" postgres', 'psql_grant_tester')
    end
  end
end
