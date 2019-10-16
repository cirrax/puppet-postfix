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
# @param parameters
#   Hash of parameters for server
# @param services
#   Hash of services for server
#   Defaults to {}
# @param maps
#   Hash of maps to generate 
#   Defaults to {}     
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
  Array   $packages         = ['postfix'],
  String  $package_ensure   = 'present',
  Hash    $parameters       = {},
  Hash    $services         = {},
  Hash    $maps             = {},
  String  $map_dir          = '/etc/postfix/maps',
  String  $postmap_command  = '/usr/sbin/postmap',
  String  $ssl_dir          = '/etc/postfix/ssl',
  Hash    $create_resources = {},
  String  $master_cf_file   = '/etc/postfix/master.cf',
  String  $main_cf_file     = '/etc/postfix/main.cf',
  String  $owner            = 'root',
  String  $group            = 'root',
  String  $mode             = '0644',
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
    parameters   => $parameters,
    main_cf_file => $main_cf_file,
    owner        => $owner,
    group        => $group,
    mode         => $mode,
  }

  class { '::postfix::config::master' :
    services       => $services,
    master_cf_file => $master_cf_file,
    owner          => $owner,
    group          => $group,
    mode           => $mode,
  }

  create_resources('::postfix::map', $maps, {
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
