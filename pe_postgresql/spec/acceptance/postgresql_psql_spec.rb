require 'spec_helper_acceptance'

describe 'pe_postgresql_psql:', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  after :all do
    # Cleanup after tests have ran
    apply_manifest("class { 'pe_postgresql::server': ensure => absent }", :catch_failures => true)
  end

  it 'should run some SQL when the unless query returns no rows' do
    pp = <<-EOS.unindent
      class { 'pe_postgresql::server': }

      pe_postgresql_psql { 'foobar':
        db        => 'postgres',
        psql_user => 'postgres',
        command   => 'select 1',
        unless    => 'select 1 where 1=2',
        require   => Class['pe_postgresql::server'],
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_failures => true)
  end

  it 'should not run SQL when the unless query returns rows' do
    pp = <<-EOS.unindent
      class { 'pe_postgresql::server': }

      pe_postgresql_psql { 'foobar':
        db        => 'postgres',
        psql_user => 'postgres',
        command   => 'select * from pg_database limit 1',
        unless    => 'select 1 where 1=1',
        require   => Class['pe_postgresql::server'],
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)
  end

end
