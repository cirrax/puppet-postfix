#
# create the postfix Service
#
# Parameters:
# $service_name
#   The name of the service
#   Defaults to $postfix::params::service_name
# $service_ensure 
#   state of the service.
#   Defaults to  $postfix::params::service_ensure
# $service_enable
#   if service should be enabled
#   Defaults to $postfix::params::service_enable
#
class postfix::service(
  $service_name   = $postfix::params::service_name,
  $service_ensure = $postfix::params::service_ensure,
  $service_enable = $postfix::params::service_enable,
) inherits postfix::params {

  service{'postfix':
    ensure  => $service_ensure,
    name    => $service_name,
    enable  => $service_enable,
    require => Package['postfix'],
  }
}
