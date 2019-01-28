# this defines a map for postfix
#
# you can either use $source or $content
# parameter or use your own concat::fragment
# resources to add content to the map.
#
# Parameters
#
# $map_name
#   The name of the map
#   defaults to $title
# $map_dir     = '',
#   the directory to create the map in
#   if set to '' (default) $postfix::params::map_dir
#   is used.
# $type
#   the type of the map
#   defaults to hash
# $source
#   source of the map
#   defaults to ''
# $contents
#   Array of lines to add to the map
#   defaults to []
# $postmap_command
#   postmap command
#   if set to '' (default $postfix::params::postmap_command
#   is used.
#
define postfix::map (
  String $map_name        = $title,
  String $map_dir         = '',
  String $type            = 'hash',
  String $source          = '',
  Array  $contents        = [],
  String $postmap_command = '',
) {

  include ::postfix::params
  if $map_dir == '' {
    $filename = "${postfix::params::map_dir}/${map_name}"
  } else {
    $filename = "${map_dir}/${map_name}"
  }

  if $postmap_command == '' {
    $_postmap_command = $postfix::params::postmap_command
  } else {
    $_postmap_command = $postmap_command
  }

  concat { $filename:
    owner  => $postfix::params::owner,
    group  => $postfix::params::group,
    mode   => $postfix::params::mode,
    notify => Service['postfix'],
  }

  if $source != '' {
    concat::fragment{ "postfix::map: source fragment ${title}":
      target => $filename,
      source => $source,
    }
  }
  if contents != [] {
    concat::fragment{ "postfix::map: content fragment ${title}":
      target  => $filename,
      content => $contents.join("\n"),
    }
  }

  case $type {
    'btree', 'hash' : {
      $ext = 'db'
    }
    'cdb'           : {
      $ext = 'cdb'
    }
    'dbm', 'sdbm'   : {
      $ext = 'pag'
    }
    default         : {
      $ext = 'unknown'
    }
  }

  if $ext != 'unknown' {
    exec { "rebuild map ${title}":
      command     => "${_postmap_command} ${type}:${filename}",
      subscribe   => Concat[$filename],
      refreshonly => true,
      creates     => "${filename}.${ext}",
      notify      => Service['postfix'],
    }
  }
}
