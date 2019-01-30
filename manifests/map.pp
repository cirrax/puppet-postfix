# this defines a map for postfix
#
# you can either use $source or $content
# parameter or use your own concat::fragment
# resources to add content to the map.
#
# Parameters
#
# $map_dir
#   the directory to create the map in
# $postmap_command
#   postmap command
# $map_name
#   The name of the map defaults to $title
# $type
#   the type of the map
#   defaults to hash
# $source
#   source of the map
#   defaults to ''
# $contents
#   Array of lines to add to the map
#   defaults to []
#
define postfix::map (
  String $map_dir,
  String $postmap_command,
  String $owner,
  String $group,
  String $mode,
  String $map_name        = $title,
  String $type            = 'hash',
  String $source          = '',
  Array  $contents        = [],
) {

  $filename = "${map_dir}/${map_name}"

  concat { $filename:
    owner  => $owner,
    group  => $group,
    mode   => $mode,
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
      command     => "${postmap_command} ${type}:${filename}",
      subscribe   => Concat[$filename],
      refreshonly => true,
      creates     => "${filename}.${ext}",
      notify      => Service['postfix'],
    }
  }
}
