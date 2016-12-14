# == Class: traefik::params
#
class traefik::params {
  $install_method    = 'url'
  $download_url_base = 'https://github.com/containous/traefik/releases/download'
  $version           = '1.1.1'
  $archive_dir       = '/opt/puppet-archive'
  $bin_dir           = '/usr/local/bin'
  $max_open_files    = 16384

  $config_dir        = '/etc/traefik'
  $config_file       = 'traefik.toml'

  case $::architecture {
    'x86_64', 'amd64': { $arch = 'amd64' }
    'i386':            { $arch = '386'   }
    /^arm.*/:          { $arch = 'arm'   }
    default:           {
      fail("Unsupported kernel architecture: ${::architecture}")
    }
  }

  $os = downcase($::kernel)

  if $::operatingsystem == 'Debian' {
    if versioncmp($::operatingsystemmajrelease, '8') == 0 {
      $init_style = 'systemd'
    }
  } elsif $::operatingsystem == 'Ubuntu' {
    if versioncmp($::operatingsystemrelease, '14.04') == 0 {
      $init_style = 'upstart'
    } elsif versioncmp($::operatingsystemrelease, '16.04') == 0 {
      $init_style = 'systemd'
    }
  }
  if $init_style == undef {
    fail('Unsupported OS')
  }
}
