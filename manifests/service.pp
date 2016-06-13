# == Class: traefik::service
#
# === Parameters
#
# [*manage*]
#   Whether or not Puppet should manage the traefik service.
#
# [*ensure*]
#   The ensure value for the service, e.g. running, stopped
#
# [*enable*]
#   The enable value for the service (whether it should be enabled or disabled).
class traefik::service (
  $manage = true,
  $ensure = running,
  $enable = true,
) {
  if $manage {
    service { 'traefik':
      ensure => $ensure,
      enable => $enable,
    }
  }
}
