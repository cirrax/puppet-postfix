#
# This class creates a postfix satellite.
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
#   $parameters:
#     Hash of parameters for satellite
#   $common_parameters:
#     Hash of common parameters for satellite and server
#   $default_parameters:
#     Hash of default parameters
#   $services:
#     Hash of services for satellite
#     Defaults to {}
#   $common_services
#     Hash of common services for satellite and server 
#   $default_services
#     Hash of default services
#     Defaults to $postfix::params::default_services
#   $maps
#     Hash of maps to create
#     Defaults to {}
#   $common_maps
#     Hash of common maps to create
#     Defaults to {}
#   $packages
#     Array of packages to install (only on satellite)
#     Defaults to []
#   $package_ensure
#     ensure parameter for package installation.
#     Defaults to $postfix::params::package_ensure
#   $create_resources
#     a Hash of Hashes to create additional resources eg. to 
#     retrieve a certificate.
#     Defaults to {} (do not create any additional resources)
#     Example (hiera):
#
#     postfix::satellite::create_resources:
#         sslcert::get_cert:
#             get_my_postfix_cert:
#               private_key_path: '/etc/postfix/ssl/key.pem'
#               cert_path: '/etc/postfix/ssl/cert.pem'
#
#     Will result in  executing:
#
#     sslcert::get_cert{'get_my_postfix_cert':
#       private_key_path => "/etc/postfix/ssl/key.pem"
#       cert_path        => "/etc/postfix/ssl/cert.pem"
#     }
#
#
# Remark: this class should be equivalent
#         to postfix::server
#
class postfix::satellite (
  $parameters         = {},
  $common_parameters  = {},
  $default_parameters = $postfix::params::default_parameters,
  $services           = {},
  $common_services    = {},
  $default_services   = $postfix::params::default_services,
  $maps               = {},
  $common_maps        = {},
  $packages           = [],
  $package_ensure     = $postfix::params::package_ensure,
  $create_resources   = {},
) inherits postfix::params {

  $package_default = {
    ensure => $package_ensure,
    tag    => 'postfix',
  }
  ensure_packages($packages, $package_default)

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
