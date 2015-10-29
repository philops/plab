# This example manifest will do the following:
#
# * install pe-nginx
# * Create a vhost file that looks like this:
#
# server {
#   server_name dev.example.vm;
#   listen 80;
#
#   location / {
#     proxy_pass  http://127.0.0.1:8080;
#   }
# }

include pe_nginx

$vhost_file = '/etc/puppetlabs/nginx/conf.d/dev.example.vm.conf'

file { $vhost_file:
  mode    => '0644',
  notify  => Service['pe-nginx'],
}

Pe_nginx::Directive {
  directive_ensure => 'present',
  target           => $vhost_file,
  server_context   => 'dev.example.vm',
}

pe_nginx::directive { 'server_name':
  value => 'dev.example.vm',
}

pe_nginx::directive { 'listen':
  value   => '80',
}

pe_nginx::directive { 'proxy_pass':
  value            => 'http://127.0.0.1:8080',
  location_context => '/',
}
