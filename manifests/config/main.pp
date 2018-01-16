#
# configures the main.cf file
#
# This class is included by
# postfix::server and
# postfix::satellite to write the main.cf file
#
# Parameters:
#  $main_cf_file
#    name and path of the main.cf file
#    Defaults to $postfix::params::main_cf_file,
#  $owner
#    owner of the main.cf file
#    Defaults to $postfix::params::owner
#  $group
#    group of the main.cf file
#    Defaults to $postfix::params::group,
#  $mode
#    mode of the main.cf file
#    Defaults to $postfix::params::mode,
#  $parameters
#    The parameters to set in the main.cf file
#    Defaults to {}
#
class postfix::config::main (
  $main_cf_file = $postfix::params::main_cf_file,
  $owner        = $postfix::params::owner,
  $group        = $postfix::params::group,
  $mode         = $postfix::params::mode,
  $parameters   = {},
) inherits ::postfix::params {

  file { $main_cf_file :
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content => epp('postfix/main.cf.epp',{ parameters => $parameters } ),
    notify  => Service['postfix'],
  }

}
