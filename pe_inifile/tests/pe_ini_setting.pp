pe_ini_setting { 'sample setting':
  ensure  => present,
  path    => '/tmp/foo.ini',
  section => 'foo',
  setting => 'foosetting',
  value   => 'FOO!',
}

pe_ini_setting { 'sample setting2':
  ensure            => present,
  path              => '/tmp/foo.ini',
  section           => 'bar',
  setting           => 'barsetting',
  value             => 'BAR!',
  key_val_separator => '=',
  require           => Pe_ini_setting['sample setting'],
}

pe_ini_setting { 'sample setting3':
  ensure  => absent,
  path    => '/tmp/foo.ini',
  section => 'bar',
  setting => 'bazsetting',
  require => Pe_ini_setting['sample setting2'],
}
