# == Define: traefik::config::section
#
# === Parameters
#
# [*hash*]
#   The hash of config options to put in this section of the config file.
#
# [*table*]
#   The TOML table for this section of config. This defaults to the resource's
#   name.
#
# [*order*]
#   The order of this section (concat fragment) within the config file.
#
# [*description*]
#   A short description of this section. If provided, a header will be created
#   for this section in the config file.
define traefik::config::section (
  $hash        = {},
  $table       = $name,
  $order       = '20',
  $description = undef
) {
  include traefik::config

  if $description != undef {
    concat::fragment { "traefik_${name}_header":
      target  => $traefik::config::config_path,
      order   => "${order}-0",
      content => template('traefik/config_section_header.toml.erb')
    }
  }

  if $table {
    # Have to put $table in string literal for Puppet 3 parser to be happy
    $real_hash = {"${table}" => $hash}
  } else {
    $real_hash = $hash
  }

  concat::fragment { "traefik_${name}":
    target  => $traefik::config::config_path,
    order   => "${order}-1",
    content => traefik_toml($real_hash)
  }
}
