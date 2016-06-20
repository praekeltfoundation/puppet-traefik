# == Class: traefik::config::file
#
# === Parameters
#
# [*filename*]
#   The filename of the file in which to put rules for the file provider. If
#   set, a new config file will be created and all traefik::config::file_rule
#   resources will be added to the file. If unset, rules will be added to the
#   main Traefik config file.
#
# [*watch*]
#   Whether or not to watch the config for changes to the file rules. This
#   should be used together with *filename* as changes to the main Traefik
#   config file will trigger a restart or Traefik.
class traefik::config::file (
  $filename = undef,
  $watch    = false,
) {
  include traefik::config

  if $filename != undef {
    $rules_path = "${traefik::config::config_dir}/${filename}"

    concat { $rules_path:
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      require => File[$traefik::config::config_dir],
      before  => Traefik::Config::Section['file']
    }

    # Set these variables for the template
    $config_file = $filename
    $config_file_description = 'File configuration'
    concat::fragment { 'traefik_rules_header':
      target  => $rules_path,
      order   => '00',
      content => template('traefik/config_file_header.toml.erb')
    }

    $base_hash = {'filename' => $rules_path}
  } else {
    $rules_path = $traefik::config::config_path
    $base_hash = {}
  }

  traefik::config::section { 'file':
    order => '10',
    hash  => merge($base_hash, {
      'watch' => $watch
    })
  }
}
