#
# configure postfix, main class
#
# @example
#   include postfix
#
# @param packages 
#   packages to install
# @param package_ensure
#   defaults to 'install'
# @param use_profile
#   profile for the configuration to use.
# @param parameters
#   Hash of parameters for server
#   Remark: in hiera this parameter is hash merged
# @param parameters_profiles
#   a Hash of profiles for parameters (see above)
#   if $postfix::use_profile is set then and 
#   $parameters_profiles["$postfix::use_profile"] exists,
#   the profile is merged with $postfix::parameters.
#   Like this several config profiles can be defined 
#   (eg. mailserver, mail sattelite, etc.)
#   Remark: in hiera this parameter is hash merged
# @param services
#   Hash of services for server
#   Defaults to {}
#   Remark: in hiera this parameter is hash merged
# @param services_profiles
#   a Hash of profiles for services (see above)
#   if $postfix::use_profile is set then and 
#   $services_profiles["$postfix::use_profile"] exists,
#   the profile is merged with $postfix::services.
#   Like this several config profiles can be defined 
#   (eg. mailserver, mail sattelite, etc.)
#   Remark: in hiera this parameter is hash merged
# @param maps
#   Hash of maps to generate 
#   Defaults to {}     
#   Remark: in hiera this parameter is hash merged
# @param maps_profiles
#   a Hash of profiles for maps (see above)
#   if $postfix::use_profile is set then and 
#   $maps_profiles["$postfix::use_profile"] exists,
#   the profile is merged with $postfix::maps.
#   Like this several config profiles can be defined 
#   (eg. mailserver, mail sattelite, etc.)
#   Remark: in hiera this parameter is hash merged
# @param map_dir
#   directory for maps to create
# @param ssl_dir
#   directory for ssl to create
# @param owner
#   file and directory owner
# @param group
#   file and directory group
# @param mode
#   file mode
# @param postmap_command
#   the postmap command to use
# @param create_resources
#   generic create_resources (for certificates etc)
# @param master_cf_file
#   filename and path to master.cf file
# @param main_cf_file
#   filename and path to main.cf file
#
class postfix (
  Array               $packages            = ['postfix'],
  String              $package_ensure      = 'present',
  String[1]           $use_profile         = 'none',
  Hash                $parameters          = {},
  Hash                $parameters_profiles = {},
  Hash                $services            = {},
  Hash                $services_profiles   = {},
  Hash                $maps                = {},
  Hash                $maps_profiles       = {},
  String              $map_dir             = '/etc/postfix/maps',
  String              $postmap_command     = '/usr/sbin/postmap',
  String              $ssl_dir             = '/etc/postfix/ssl',
  Hash                $create_resources    = {},
  String              $master_cf_file      = '/etc/postfix/master.cf',
  String              $main_cf_file        = '/etc/postfix/main.cf',
  String              $owner               = 'root',
  String              $group               = 'root',
  String              $mode                = '0644',
) {

  Package<|tag == 'postfix-packages'|> -> File[ $map_dir, $ssl_dir ]

  $package_default = {
    ensure => $package_ensure,
    tag    => 'postfix-packages',
  }
  ensure_packages($packages, $package_default)

  file { [ $map_dir, $ssl_dir ]:
    ensure => directory,
    owner  => $owner,
    group  => $group,
    mode   => '0755',
  }

  include ::postfix::service

  class { '::postfix::config::main' :
    parameters   => $parameters + pick($parameters_profiles[$use_profile], {}),
    main_cf_file => $main_cf_file,
    owner        => $owner,
    group        => $group,
    mode         => $mode,
  }

  class { '::postfix::config::master' :
    services       => $services + pick($services_profiles[$use_profile], {}),
    master_cf_file => $master_cf_file,
    owner          => $owner,
    group          => $group,
    mode           => $mode,
  }

  create_resources('::postfix::map', $maps + pick($maps_profiles[$use_profile], {}), {
    map_dir         => $map_dir,
    postmap_command => $postmap_command,
    owner           => $owner,
    group           => $group,
    mode            => $mode,
  })

  # create generic resources (eg. to retrieve certificate)
  $create_resources.each | $res, $vals | {
    create_resources($res, $vals )
  }
}
