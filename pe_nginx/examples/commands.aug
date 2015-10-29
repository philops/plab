set /augeas/load/Nginx/lens Nginx.lns
set /augeas/load/Nginx/incl[4] /etc/puppetlabs/nginx/conf.d/puppetproxy.conf
set /augeas/load/Nginx/incl[5] /etc/puppetlabs/nginx/conf.d/nginx.conf
load
defvar proxyconf /files/etc/puppetlabs/nginx/conf.d/puppetproxy.conf
defvar conf /files/etc/puppetlabs/nginx/conf.d/nginx.conf

