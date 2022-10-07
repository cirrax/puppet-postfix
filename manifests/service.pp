#
# create the postfix Service
#
# @param service_name
#   The name of the service
# @param service_ensure 
#   state of the service.
# @param service_enable
#   if service should be enabled
# @param disabled_services
#   Array of Services to stop
# @param exec_postfix_enable
#   if set to true, we run postfix-enable
# @param sync_chroot
#   if set to a path, the according chroot 
#   is synced.
# @param ensure_syslog_flag
#   if set to true, and sync_chroot is choosen,
#   a flag is set to allow logging from chroot
#   this is very OpenBSD specific !
#
class postfix::service (
  String  $service_name        = 'postfix',
  String  $service_ensure      = 'running',
  Boolean $service_enable      = true,
  Array   $disabled_services   = [],
  Boolean $exec_postfix_enable = false,
  String  $sync_chroot         = '',
  Boolean $ensure_syslog_flag  = false,
) {
  Package<|tag == 'postfix-packages'|> -> File<|tag == 'postfix-require-package' |> -> Service['postfix']

  service { 'postfix':
    ensure => $service_ensure,
    name   => $service_name,
    enable => $service_enable,
  }

  service { $disabled_services :
    ensure => 'stopped',
    enable => false,
    before => Service['postfix'],
  }

  if $exec_postfix_enable {
    # enable postfix in mailer.conf for OpenBSD
    exec { 'postfix-enable':
      path    => ['/sbin','/usr/sbin','/bin','/usr/bin','/usr/local/sbin','/usr/local/bin'],
      command => 'postfix-enable',
      onlyif  => 'test -e /etc/mailer.conf.postfix',
      before  => Service['postfix'],
    }
  }

  if $sync_chroot != '' {
    file { "${sync_chroot}/etc":
      ensure => 'directory',
      notify => Service['postfix'],
      tag    => 'postfix-require-packages',
    }
    file { "${sync_chroot}/etc/resolv.conf":
      source => '/etc/resolv.conf',
      notify => Service['postfix'],
    }
    file { "${sync_chroot}/etc/hosts":
      source => '/etc/hosts',
      notify => Service['postfix'],
    }
    file { "${sync_chroot}/etc/services":
      source => '/etc/services',
      notify => Service['postfix'],
    }
  }
  if ( $ensure_syslog_flag )  and ( $sync_chroot != '' ) {
    # allow logging from postfix chroot (needs restart of syslogd) 
    file_line { 'postfix syslog':
      path => '/etc/rc.conf.local',
      line => "syslogd_flags='\$syslogd_flags -a ${sync_chroot}/dev/log'",
      # require => File['/etc/rc.conf.local'], this is autorequired
    }
  }
}
