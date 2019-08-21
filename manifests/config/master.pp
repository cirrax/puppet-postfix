#
class postfix::config::master (
  String $master_cf_file,
  String $owner,
  String $group,
  String $mode,
  Hash   $services = {},
) {

  Package<|tag == 'postfix-packages'|> -> Concat[ $master_cf_file ]

  concat { $master_cf_file :
    owner  => $owner,
    group  => $group,
    mode   => $mode,
    notify => Service['postfix'],
  }

  concat::fragment{'postfix: master_cf_header' :
    target  => $master_cf_file,
    content => template('postfix/service_header.erb'),
    order   => '00',
  }

  $service_defaults = {
    master_cf_file => $master_cf_file,
  }

  # create the services
  create_resources('postfix::config::service', $services, $service_defaults)
}
