# this defines a map for postfix
#
# you can either use $source or $content
# parameter or use your own concat::fragment
# resources to add content to the map.
#
# @param map_dir
#   the directory to create the map in
# @param postmap_command
#   postmap command
# @param map_name
#   The name of the map defaults to $title
# @param type
#   the type of the map
#   defaults to hash
# @param source
#   source of the map
#   defaults to ''
# @param contents
#   Array of lines to add to the map
#   defaults to []
# @param owner
#   owner of the map file
# @param group
#   group of the map file
# @param mode
#   file mode of the map file
#
define postfix::map (
  String              $map_dir         = $postfix::map_dir,
  String              $postmap_command = $postfix::postmap_command,
  String              $owner           = $postfix::owner,
  String              $group           = $postfix::group,
  String              $mode            = $postfix::mode,
  String              $map_name        = $title,
  String              $type            = 'hash',
  Optional[String[1]] $source          = undef,
  Array               $contents        = [],
) {
  $filename = "${map_dir}/${map_name}"

  concat { $filename:
    owner  => $owner,
    group  => $group,
    mode   => $mode,
    notify => Service['postfix'],
  }

  if $source {
    concat::fragment { "postfix::map: source fragment ${title}":
      target => $filename,
      source => $source,
    }
  }
  if contents != [] {
    concat::fragment { "postfix::map: content fragment ${title}":
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
      command => "${postmap_command} ${type}:${filename}",
      require => Concat[$filename],
      unless  => "test ${filename}.${ext} -nt ${filename}",
      path    => '/bin:/usr/bin:/sbin:/usr/sbin',
      notify  => Service['postfix'],
    }
  }
}
