# == Class: traefik::config
#
# === Parameters
#
# [*config_dir*]
#   The directory in which config should be stored.
#
# [*config_file*]
#   The name of the config file which will be stored in the config directory.
#
# [*config_hash*]
#   A hash of config options to be serialized into TOML for the main section of
#   Traefik's configuration.
class traefik::config (
  $config_dir  = $traefik::params::config_dir,
  $config_file = $traefik::params::config_file,
  $config_hash = {},
) inherits traefik::params {
  $config_path = "${config_dir}/${config_file}"

  file { $config_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root'
  }
  -> concat { $config_path:
    ensure => present,
    owner  => 'root',
    group  => 'root'
  }

  $config_file_description = 'Global configuration'
  concat::fragment { 'traefik_header':
    target  => $config_path,
    order   => '00',
    content => template('traefik/config_file_header.toml.erb')
  }

  traefik::config::section { 'main':
    order       => '01',
    hash        => $config_hash,
    table       => false,
    description => 'Main section'
  }
}
