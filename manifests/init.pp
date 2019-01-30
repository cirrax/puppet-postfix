#
# Main class
#
# Service definition:
#  $services, $common_services and $default_services are
#  merged to become the services to configure in master.cf.
#  You can overwrite only whole service definitions (no deep merge).
#  $services takes precedence over $common_services over
#  $default_services.
#  To completly deactivate a service set $active to true.
#  For a complete list of service parameters look
#  at define postfix::config::service
#
# Parameter definition:
#  $parameters, $common_parameters and $default_parameters are
#  merged to become the parameters to configure in main.cf.
#  You can overwrite a parameter.
#  $parameters takes precedence over $common_parameters over
#  $default_parameters.
#  To completly deactivate a parameters set it to ''.
#
# Parameters:
#   $packages
#     packagase to install
#     defaults to $postfix::params::packages
#   $package_ensure
#     defaults to 'install'
#   $common_parameters:
#     Hash of common parameters for satellite and server
#     used for postfix::satellite and postfix::server include
#   $default_parameters:
#     Hash of default parameters
#     used for postfix::satellite and postfix::server include
#   $parameters:
#     Hash of parameters for server
#   $common_services
#     Hash of common services for satellite and server 
#     used for postfix::satellite and postfix::server include
#   $default_services
#     Hash of default services
#     Defaults to $postfix::params::default_services
#     used for postfix::satellite and postfix::server include
#   $services:
#     Hash of services for server
#     Defaults to {}
#   $common_maps:
#     Hash of maps to generate 
#     Defaults to {}     
#     used for postfix::satellite and postfix::server include
#   $map_dir:
#     directory for maps to create
#     Defaults to $postfix::params::map_dir
#   $ssl_dir:
#     directory for ssl to create
#     Defaults to $postfix::params::ssl_dir
#
#
class postfix (
  Array   $packages           = $postfix::params::packages,
  String  $package_ensure     = $postfix::params::package_ensure,
  Hash    $default_parameters = $postfix::params::default_parameters,
  Hash    $common_parameters  = {},
  Hash    $parameters         = {},
  Hash    $default_services   = $postfix::params::default_services,
  Hash    $common_services    = {},
  Hash    $services           = {},
  Hash    $maps               = {},
  Hash    $common_maps        = {},
  String  $map_dir            = $postfix::params::map_dir,
  String  $ssl_dir            = $postfix::params::ssl_dir,
  Hash    $create_resources   = {},
) inherits ::postfix::params {

  Package<|tag == 'postfix-packages'|> -> File[ $map_dir, $ssl_dir ]

  $package_default = {
    ensure => $package_ensure,
    tag    => 'postfix-packages',
  }
  ensure_packages($packages, $package_default)

  file { [ $map_dir, $ssl_dir ]:
    ensure => directory,
    owner  => $postfix::params::owner,
    group  => $postfix::params::group,
    mode   => '0755',
  }

  include ::postfix::service

  $_parameters = merge($default_parameters, $common_parameters, $parameters)

  class { '::postfix::config::main' :
    parameters => $_parameters,
  }

  $_services = merge($default_services, $common_services, $services)

  class { '::postfix::config::master' :
    services => $_services,
  }

  $_maps = merge($common_maps, $maps)
  create_resources('::postfix::map', $_maps)

  # create generic resources (eg. to retrieve certificate)
  $create_resources.each | $res, $vals | {
    create_resources($res, $vals )
  }
}
