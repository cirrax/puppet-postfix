#
# define a service in master.cf file of postfix
#
# @param type
#   Specify the service type. one of:
#   inet, unix, fifo, pass.
#   defaults to 'unix'
# @param command
#   The command to be executed.
#   defaults to $title
# @param args       
#    Array of commands arguments
# @param service_names
#   Array of service names to configure. 
#   defaults to [$title]
# @param priv
#   Whether or not access is restricted to the mail system.
#   defaults '-' (use built-in default)
# @param unpriv
#   Whether the service runs with root privileges or as 
#   the owner of the Postfix system.
#   defaults '-' (use built-in default)
# @param chroot
#   Whether or not the service runs chrooted to the mail
#   queue directory.
#   defaults '-' (use built-in default)
# @param wakeup
#   Wake up time
#   defaults 'n' (default for postfix >= 3.0)
# @param maxproc
#   The maximum number of processes that may execute
#   this service simultaneously
#   defaults 'n' (default for postfix >= 3.0)
# @param active
#   if false, the service will not be activated (commented out)
#   default: true,
# @param comments
#   Array of comments to print in front of the service definition.
#   defaults to [] (no comment)
# @param order
#   order of the fragment (defaults to '55')
# @param master_cf_file
#   target
#
# See master(5) for details
#
define postfix::config::service (
  String  $master_cf_file,
  String  $type           = 'unix',
  String  $command        = $title,
  Array   $service_names  = [$title],
  String  $priv           = '-',
  String  $unpriv         = '-',
  String  $chroot         = '-',
  String  $wakeup         = '-',
  String  $maxproc        = '-',
  Array   $args           = [],
  Array   $comments       = [],
  Boolean $active         = true,
  String  $order          = '55',
) {
  concat::fragment { "master.cf service: ${title}":
    target  => $master_cf_file,
    content => template('postfix/service.erb'),
    order   => $order,
  }
}
