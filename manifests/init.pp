#
# Main class
#
# Parameters:
#   $packages
#     packagase to install
#     defaults to $postfix::params::packages
#   $package_ensure
#     defaults to 'install'
#   $parameters:
#     Hash of parameters for server
#   $services:
#     Hash of services for server
#     Defaults to {}
#   $maps:
#     Hash of maps to generate 
#     Defaults to {}     
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
  Hash    $parameters         = {},
  Hash    $services           = {},
  Hash    $maps               = {},
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

  class { '::postfix::config::main' :
    parameters => $parameters,
  }

  class { '::postfix::config::master' :
    services => $services,
  }

  create_resources('::postfix::map', $maps)

  # create generic resources (eg. to retrieve certificate)
  $create_resources.each | $res, $vals | {
    create_resources($res, $vals )
  }
}
