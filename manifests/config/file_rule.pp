# == Define: traefik::config::file_rule
#
# === Parameters
#
# [*frontend*]
#   The hash for the frontend rule for this service. The backend for this
#   frontend will be set to the backend created in this resource.
#
# [*backend*]
#   The hash for the backend rule for this service.
#
# [*order*]
#   The concat fragment order for the sections in this rule.
#
# [*description*]
#   A short description of this section. If provided, a header will be created
#   for this section in the config file.
define traefik::config::file_rule (
  $frontend    = {},
  $backend     = {},
  $order       = '30',
  $description = undef
) {
  include traefik::config::file

  $real_frontend = merge($frontend, {
    'backend' => "${name}-backend"
  })
  traefik::config::section { "${name}-frontend":
    table       => 'frontends',
    order       => "${order}-0",
    hash        => {
      "${name}-frontend" => $real_frontend, # lint:ignore:arrow_alignment
    },
    description => $description,
    target      => $traefik::config::file::rules_path
  }

  traefik::config::section { "${name}-backend":
    table  => 'backends',
    order  => "${order}-1",
    hash   => {
      "${name}-backend" => $backend, # lint:ignore:arrow_alignment
    },
    target => $traefik::config::file::rules_path
  }
}
