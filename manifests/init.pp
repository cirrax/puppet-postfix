#
# Main class
#
# Parameters:
#   $is_satellite:
#     if true, it includes ::postfix::satellite
#     if false ::postfix::server is included
#     this allows you to specify to different hiera
#     configurations.
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
#   $common_services
#     Hash of common services for satellite and server 
#     used for postfix::satellite and postfix::server include
#   $default_services
#     Hash of default services
#     Defaults to $postfix::params::default_services
#     used for postfix::satellite and postfix::server include
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
  $is_satellite       = true,
  $packages           = $postfix::params::packages,
  $package_ensure     = $postfix::params::package_ensure,
  $common_parameters  = {},
  $default_parameters = $postfix::params::default_parameters,
  $common_services    = {},
  $default_services   = $postfix::params::default_services,
  $common_maps        = {},
  $map_dir            = $postfix::params::map_dir,
  $ssl_dir            = $postfix::params::ssl_dir,
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

  if $is_satellite {
    class{ '::postfix::satellite':
      common_parameters  => $common_parameters,
      default_parameters => $default_parameters,
      common_services    => $common_services,
      default_services   => $default_services,
      common_maps        => $common_maps,
    }
  } else {
    class{ '::postfix::server':
      common_parameters  => $common_parameters,
      default_parameters => $default_parameters,
      common_services    => $common_services,
      default_services   => $default_services,
      common_maps        => $common_maps,
    }
  }
}
