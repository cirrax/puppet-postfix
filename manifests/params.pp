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

  $_default_parameters = {
    myhostname          => {
      comments => ['The internet hostname of this mail system'],
      value    => $::fqdn,
    },
    myorigin            => $::fqdn,
    mydestination       => [$::fqdn, $::hostname, 'localhost'],
    mynetworks          => [ '127.0.0.0/8', '[::ffff:127.0.0.0]/104', '[::1]/128' ],
    append_dot_mydomain => {
      comments => [ "appending .domain is the MUA's job." ],
      value    => 'no',
    },
    smtpd_banner        => {
      value    => '$myhostname ESMTP $mail_name',
    },
  }

  $default_services = {
    smtp       => {
      'type'  => 'inet',
      priv    =>  'n',
      chroot  =>  'y',
      command =>  'smtpd',
      order   =>  '60_100',
    },
    pickup     => {
      priv    =>  'n',
      chroot  =>  'y',
      wakeup  =>  60,
      maxproc =>  1,
      order   =>  '60_102',
    },
    cleanup    => {
      priv    =>  'n',
      chroot  =>  'y',
      maxproc =>  0,
      order   =>  '60_104',
    },
    qmgr       => {
      priv    =>  'n',
      chroot  =>  'n',
      wakeup  =>  300,
      maxproc =>  1,
      order   =>  '60_106',
    },
    tlsmgr     => {
      chroot  =>  'y',
      wakeup  =>  '1000?',
      maxproc =>  1,
      order   =>  '60_108',
    },
    rewrite    => {
      chroot  =>  'y',
      command =>  'trivial-rewrite',
      order   =>  '60_110',
    },
    bounce     => {
      chroot  =>  'y',
      maxproc =>  0,
      order   =>  '60_112',
    },
    defer      => {
      chroot  =>  'y',
      maxproc =>  0,
      command =>  'bounce',
      order   =>  '60_114',
    },
    trace      => {
      chroot  =>  'y',
      maxproc =>  0,
      command =>  'bounce',
      order   =>  '60_116',
    },
    verify     => {
      chroot  =>  'y',
      maxproc =>  1,
      order   =>  '60_118',
    },
    flush      => {
      priv    =>  'n',
      chroot  =>  'y',
      maxproc =>  0,
      wakeup  =>  '1000?',
      order   =>  '60_120',
    },
    proxymap   => {
      chroot =>  'n',
      order   =>  '60_122',
    },
    proxywrite => {
      chroot  =>  'n',
      maxproc =>  1,
      command =>  'proxymap',
      order   =>  '60_124',
    },
    smtp-unix => {
      service_names => ['smtp'],
      chroot  =>  'y',
      command =>  'smtp',
      order   =>  '60_126',
    },
    relay      => {
      chroot  =>  'y',
      command =>  'smtp',
      order   =>  '60_128',
    },
    showq      => {
      priv    =>  'n',
      chroot  =>  'y',
      order   =>  '60_130',
    },
    error      => {
      chroot =>  'y',
      order   =>  '60_132',
    },
    retry      => {
      chroot  =>  'y',
      command =>  'error',
      order   =>  '60_134',
    },
    discard    => {
      chroot =>  'y',
      order   =>  '60_136',
    },
    local      => {
      unpriv =>  'n',
      chroot =>  'n',
      order   =>  '60_138',
    },
    virtual    => {
      unpriv =>  'n',
      chroot =>  'n',
      order   =>  '60_140',
    },
    lmtp       => {
      chroot =>  'y',
      order   =>  '60_142',
    },
    anvil      => {
      chroot  =>  'y',
      maxproc =>  1,
      order   =>  '60_144',
    },
    scache     => {
      chroot  =>  'y',
      maxproc =>  1,
      order   =>  '60_146',
    },
  }

  # per Operating system defaults
  case $::osfamily {
    'OpenBSD': {
      $owner               = 'root'
      $group               = 'wheel'
      $postmap_command     = '/usr/local/sbin/postmap'
      $default_parameters  = merge( {
        mail_owner => {
          comments => ['Only set this on OpenBSD, since it is not default' ],
          value    => '_postfix',
        },
        setgid_group => {
          comments => ['Only set this on OpenBSD, since it is not default' ],
          value    => '_postdrop',
        },
        daemon_directory => {
          comments => ['Only set this on OpenBSD, since it is not default' ],
          value    => '/usr/local/libexec/postfix',
        },
        command_directory => {
          comments => ['Only set this on OpenBSD, since it is not default' ],
          value    => '/usr/local/sbin',
        },
      }, $_default_parameters )
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
