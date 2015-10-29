pe_concat { 'testconcat':
  ensure => present,
  path   => '/tmp/pe_concat',
  owner  => 'root',
  group  => 'root',
  mode   => '0664',
}

pe_concat::fragment { '1':
  target  => 'testconcat',
  content => '1',
  order   => '01',
}

pe_concat::fragment { '2':
  target  => 'testconcat',
  content => '2',
  order   => '02',
}
