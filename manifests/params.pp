# == Class: traefik::params
#
class traefik::params {
  $install_method        = 'url'
  $download_url_base     = 'https://github.com/containous/traefik/releases/download'
  $version               = '1.0.0-rc2'
  $archive_path          = '/opt/puppet-archive'
  $bin_dir               = '/usr/local/bin'

  $config_dir            = '/etc/traefik'
  $config_file           = 'traefik.toml'

  case $::architecture {
    'x86_64', 'amd64': { $arch = 'amd64' }
    'i386':            { $arch = '386'   }
    /^arm.*/:          { $arch = 'arm'   }
    default:           {
      fail("Unsupported kernel architecture: ${::architecture}")
    }
  }

  $os = downcase($::kernel)

  if $::operatingsystem == 'Ubuntu' {
    if versioncmp($::operatingsystemrelease, '14.04') == 0 {
      $init_style = 'upstart'
    }
  }
  if $init_style == undef {
    fail('Unsupported OS')
  }
}
