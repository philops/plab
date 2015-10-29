# A custom defined type for managing an nginx directive
#
# @example Creating a server directive with server_name of 'console.example.vm' and setting the listen port
# to 443
#
#   pe_nginx::directive { 'server_name':
#     ensure         => 'present',
#     target         => '/etc/puppetlabs/httpd/conf.d/test.conf',
#     value          => 'console.example.vm',
#     server_context => 'console.example.vm',
#   }
#
#   pe_nginx::directive { "listen":
#     ensure         => 'present',
#     target         => '/etc/puppetlabs/httpd/conf.d/test.conf',
#     value          => "443",
#     server_context => 'console.example.vm',
#   }
#
# @example creating a location directive to proxy all requests to console.example.vm to 127.0.0.1:4431
#
#   pe_nginx::directive { 'proxy_pass':
#     ensure           => 'present',
#     target           => '/etc/puppetlabs/httpd/conf.d/test.conf',
#     value            => 'http://127.0.0.1:4431',
#     server_context   => 'console.example.vm',
#     location_context => '/',
#   }
#
# @note This defined type does not support nested location directives.
# @note Currently this will insert the new directive at the bottom of whichever context
#       you are targeting.
#
# @param target [String] A file path to the nginx config file we are editing
# @param value [String] The value of the directive
# @param comment [String] Comment to be placed before the directive.
# @param directive_ensure [String] Whether or not the directive should be present. Valid values are one
# of: present, absent, true or false
# @param directive_name [String] The name of the directive we are managing. Defaults to $title
# @param location_context [String] The name of the location context to set this directive in. If none
# is set, it assumes the directive does not belong in a location block. If it cannot find the location
# block, it will be created.
# @param server_context [String] The server_name of the server context to set this directive in. If non
# is set, it assumes the directive belongs at the top level http block. If it cannot find the server
# context, it will be created.
define pe_nginx::directive(
  $target,
  $value,
  $comment          = undef,
  $directive_ensure = 'present',
  $directive_name   = $title,
  $location_context = undef,
  $server_context   = undef,
  $replace_value    = true,
) {
  pe_validate_re($directive_ensure, '^(present|absent|true|false)$')
  pe_validate_bool($replace_value)

  # If they passed in a location context, they must pass in a server context
  if pe_empty($server_context) and !pe_empty($location_context) {
    fail("Location context passed without a server context to ${title}")
  }

  # Our base augeas path, eg /files/etc/puppetlabs/nginx/conf.d/puppetproxy.conf,
  $path = "/files/${target}"

  # Create our server context string
  if !pe_empty($server_context) {
    # Nginx can have multiple server contexts with the same server name, so support a
    # server context in the form of <server_name>:<listen> to distinguish which one we should be targeting
    $server_contexts = split($server_context, ':')
    $server_name_context = "server_name='${server_contexts[0]}'"

    if $server_contexts[1] {
      $listen_context = "listen='${server_contexts[1]}'"
      $_server_context = "server[${server_name_context} and ${listen_context}]"
    }
    else {
      $_server_context = "server[${server_name_context}]"
    }
  }

  # Create our location context string
  if !pe_empty($location_context) {
    # A nginx location directive contains two parts, an optional regex modifier [ = | ~ | ~* | ^~ ],
    # and the uri.

    $location_contexts = split($location_context, ' ')

    if pe_empty($location_contexts[1]) {
      $_location_context = "/location[#uri='${location_contexts[0]}']"
      $location_uri_change = "set #uri '${location_contexts[0]}'"
    }
    else {
      $_location_context = "/location[#comp='${location_contexts[0]}' and #uri='${location_contexts[1]}']"
      $location_comp_change = "set #comp '${location_contexts[0]}'"
      $location_uri_change = "set #uri '${location_contexts[1]}'"
    }
  }

  # Figure out what our augeas context should be.
  # If no server or location, then it goes into http
  if pe_empty($server_context) and pe_empty($location_context) {
    $context = "${path}/http"
  }
  else {
    $context = "${path}/${_server_context}${_location_context}"
  }


  # Add the comment directly above the directive
  if !pe_empty($comment) {
    $comment_changes = [
      # Clear the existing comment, if it's the same as what we are going to set below,
      # augeas is smart enough to end up doing nothing. Otherwise we will end up with duplicate comments
      "rm #comment[following-sibling::*[self::${directive_name}]]",
      "ins #comment before ${directive_name}",
      "set #comment[following-sibling::*[1][self::${directive_name}]] '${comment}'"
    ]
  }

  if $directive_ensure =~  /^(absent|false)$/ {
    $changes = "rm ${directive_name}[${directive_name}='${value}']"
  }
  else {
    $set_directive = $replace_value ? {
      true => "set ${directive_name} '${value}'",
      false => "set ${directive_name}[.='${value}'] '${value}'",
    }
    $changes = pe_delete_undef_values(pe_flatten([
      $location_comp_change,
      $location_uri_change,
      $set_directive,
      $comment_changes,
      ]))
  }

  augeas { "pe_nginx::directive for ${title}":
    incl      => $target,
    lens      => 'Nginx.lns',
    context   => $context,
    changes   => $changes,
    notify    => Service['pe-nginx'],
  }
}
