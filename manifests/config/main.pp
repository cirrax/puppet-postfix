#
# configures the main.cf file
#
# This class is included by
# postfix::server and
# postfix::satellite to write the main.cf file
#
# @param main_cf_file
#   name and path of the main.cf file
# @param owner
#   owner of the main.cf file
# @param group
#   group of the main.cf file
# @param mode
#   mode of the main.cf file
# @param parameters
#   The parameters to set in the main.cf file
#   Defaults to {}
#
class postfix::config::main (
  String $main_cf_file,
  String $owner,
  String $group,
  String $mode,
  Hash   $parameters       = {},
) {
  Package<|tag == 'postfix-packages'|> -> File[$main_cf_file]

  file { $main_cf_file :
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content => epp('postfix/main.cf.epp', { parameters => $parameters }),
    notify  => Service['postfix'],
  }
}
