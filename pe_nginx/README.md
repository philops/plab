#pe_nginx

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with pe_nginx](#setup)
4. [Usage - The available classes and profiles](#usage)
    * [Class: pe_nginx](#class-pe_nginx)
    * [Defined Type: directive](#defined-type-directive)
        * [Context: http](#context-http)
        * [Context: server](#context-server)
        * [Context: location](#context-location)
5. [Development - Guide for contributing to the module](#development)
    * [How to Augeas](#how-to-augeas)
    * [Contributing](#contributing)
    * [How to run spec tests](#spec-tests)
    * [Why did you rewrite modules](#why-did-you-rewrite-modules)


##Overview
This module is expected to be used by several different services (update service, console) that could
live on the same node.

Due to that possibility, params should be avoided being added to the base class (`init.pp`) so that it can be
consumed by end users with an `include pe_nginx`, thereby avoiding duplicate resource conflicts.

In the event that params are required, consumers of this module should still use the `include
pe_nginx` syntax over creating a class resource, and provide any overrides to this classes params via
hiera.

If you have any questions that are not covered in this readme, you can ask in the `Integration` hipchat
room.

##Module Description
Nginx has many features, however for use in the Puppet Enterprise stack, we really only care about
setting up a vhost with support for reverse proxying and custom SSL configuration.

##Setup
To install pe-nginx, simply `include pe_nginx` in your manifest.

##Usage
For end users, this module should be considered internal / private and should not be applied directly.

###Class: `pe_nginx`
This class will install the pe_nginx package and ensure the service is running.

###Defined Type: `directive`
For nginx, all configuration options are known as `directives`. Each `directive` belongs to a specific
`context`.  This module has support for 3 of the roughly dozen or so contexts that exist: `http`,
`server` and `location`.

#### Context: http
To target the `http` context, do not specify the `server_context` or `location_context` param.

#### Context: server
Nginx does not have a unique key value pair to specify a `server_context` by, meaning you could have
multiple `server` contexts with the `server_name` set to `console.example.vm`. If that's the case, it
will then fall back to which port the user is requesting, which correlates to the `listen` directive.

To work around this, if you wish to target the `server` context that is setup to listen for requests
matching the host `console.example.vm` on port `443`, you would want to specify the `server_context` of
`console.example.vm:443`.

#### Context: location
A location context is made up of two things: a regex modifier and a location string.

To match on a basic `location` of `/`, you would use `location_context => '/'`.

To match a more complex location, such as `location ~ \.php$`, you would use:
`location_context => '~ \.php$'`.

Note: The `directive` type does not currently support nested locations.

##Development
###How to Augeas
The [Augeas wiki](https://github.com/hercules-team/augeas/wiki) contains good information, specifically:

https://github.com/hercules-team/augeas/wiki/Path-expressions

In the examples directory are a couple supporting files to help ease development of any augeas related
changes. They assume you have a working PE install.

`commands.aug` is a file with a set of Augeas commands that you can pass into the command line. It does
the following:

* Loads the nginx lense
* Loads two files into the tree:
  * /etc/puppetlabs/nginx/conf.d/puppetproxy.conf
  * /etc/puppetlabs/nginx/nginx.conf
* Sets up two variables for referencing those files: `proxyconf` and `conf`

To use this file, run the following command:

```
/opt/puppet/bin/augtool --noload --noautoload -if examples/commands.aug
```

At that point, you will be inside an augeas shell and can test your augeas commands.

For example, to print out the tree of `/etc/puppetlabs/nginx/conf.d/puppetproxy.conf`,

```
print $proxyconf
```

To change the existing `server_name console.example.vm;` to `server_name foo;`,

```
set $proxyconf/server[server_name='console.example.vm']/server_name foo
```

###Contributing
The end goal of the `puppet_enterprise` module is to be a self serve type module that each team will
end up owning the component module for. For now, the integration team still owns the module in whole.

We want to keep it as easy as possible to contribute changes so that our modules work together in the
PE environment. There are a few guidelines that we need contributors to follow so that we can have a
chance of keeping on top of things.

Read the complete module contribution guide in [CONTRIBUTING.md](./CONTRIBUTING.md)

###Spec Tests
For more information on how to run the spec tests, see the [CONTRIBUTING.md](./CONTRIBUTING.md)
document.


####Why did you rewrite modules
Instead of using the FOSS version.

The short answer to this is because of module environment separation. In the past we used the FOSS
version of the modules, however customers may want to use a different version of that module. If that
new version changes the behavior of the class that we are using, the PE module is now broken.

The short term fix for this is to name space everything that the `puppet_enterprise` module uses.
However namespacing is a very expensive (in terms of time) process that must be repeated after every
release. To alleviate that, the component modules contain a bare bones version of the FOSS module for
accomplishing the goal.

Some modules where namespaced completely, those being:

[puppetlabs-pe_postgresql](https://github.com/puppetlabs/puppetlabs-pe_postgresql)
[puppetlabs-pe_java_ks](https://github.com/puppetlabs/puppetlabs-pe_java_ks)
[puppetlabs-pe_inifile](https://github.com/puppetlabs/puppetlabs-pe_inifile)
[puppetlabs-pe_concat](https://github.com/puppetlabs/puppetlabs-pe_concat)
