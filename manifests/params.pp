# default paraeters
class postfix::params {

  $service_name   = 'postfix'
  $service_ensure = 'running'
  $service_enable = true

  $main_cf_file   = '/etc/postfix/main.cf'
  $master_cf_file = '/etc/postfix/master.cf'
  $ssl_dir        = '/etc/postfix/ssl'

  $packages       = ['postfix']
  $package_ensure = 'present'

  # per Operating system defaults
  case $::osfamily {
    'OpenBSD': {
      $owner               = 'root'
      $group               = 'wheel'
      $postmap_command     = '/usr/local/sbin/postmap'
      $exec_postfix_enable = true
      $disabled_services   = ['smtpd']
      $sync_chroot         = '/var/spool/postfix'
      $ensure_syslog_flag  = false
    }
    default: {
      $owner               = 'root'
      $group               = 'root'
      $postmap_command     = '/usr/sbin/postmap'
      $default_parameters  = $_default_parameters
      $exec_postfix_enable = false
      $disabled_services   = []
      $sync_chroot         = ''  # do not sync
      $ensure_syslog_flag  = false
    }
  }

  $mode           = '0644'

  $map_dir        = '/etc/postfix/maps'
  $map_owner      = $owner
  $map_group      = $group
  $map_mode       = '0640'

}
