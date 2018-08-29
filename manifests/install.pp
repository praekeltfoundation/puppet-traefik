# == Class: traefik::install
#
# === Parameters
#
# [*install_method*]
#   The installation method to use. Possible values: url, none
#
# [*download_url_base*]
#   The base part of the URL to download Traefik from.
#
# [*version*]
#   The version of Traefik to download.
#
# [*os*]
#   The operating system to download Traefik for. Current possible values: linux
#
# [*arch*]
#   The architecture to download Traefik for. Current possible values: 386,
#   amd64, arm
#
# [*download_url*]
#   Override the download URL for Traefik. Setting this parameter means that the
#   download_url_base, version, os, and arch parameters are not used.
#
# [*archive_dir*]
#   Path to the directory that Traefik will be downloaded to.
#
# [*bin_dir*]
#   The directory that the Traefik binary will be symlinked into (from where it
#   was downloaded to).
#
# [*init_style*]
#   The style of the init system on the system. If false-y then no init script
#   will be installed. Possible values: upstart, false
#
# [*config_path*]
#   The path to the config file that Traefik should load on startup. By default,
#   Traefik looks in a few places for a config file. This is described in its
#   documentation.
class traefik::install (
  $install_method    = $traefik::params::install_method,

  $download_url_base = $traefik::params::download_url_base,
  $version           = $traefik::params::version,
  $os                = $traefik::params::os,
  $arch              = $traefik::params::arch,
  $max_open_files    = $traefik::params::max_open_files,

  $download_url      = undef,

  $archive_dir       = $traefik::params::archive_dir,
  $bin_dir           = $traefik::params::bin_dir,

  $init_style        = $traefik::params::init_style,
  $config_path       = undef,
) inherits traefik::params {

  validate_integer($max_open_files)

  case $install_method {
    'url': {
      $real_download_url = pick($download_url,
        "${download_url_base}/v${version}/traefik_${os}-${arch}")

      include archive

      # Other modules that use puppet-archive may have created this directory
      # themselves.
      unless defined(File[$archive_dir]) {
        file { $archive_dir:
          ensure => directory,
          owner  => 'root',
          group  => 'root',
        }
      }

      file { "${archive_dir}/traefik-${version}":
        ensure => directory,
        owner  => 'root',
        group  => 'root',
      }

      archive { "${archive_dir}/traefik-${version}/traefik":
        ensure       => present,
        source       => $real_download_url,
        # Workaround for https://github.com/voxpupuli/puppet-archive/issues/166
        # extract_path not actually used since we're not extracting
        extract_path => '/tmp'
      }
      -> file {
        "${archive_dir}/traefik-${version}/traefik":
          owner => 'root',
          group => 'root',
          mode  => '0755';
        "${bin_dir}/traefik":
          ensure => link,
          target => "${archive_dir}/traefik-${version}/traefik";
      }
    }
    'none': {}
    default: {
      fail("The provided install method \"${install_method}\" is invalid")
    }
  }

  if $init_style {
    case $init_style {
      'systemd': {
        file { '/lib/systemd/system/traefik.service':
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => template('traefik/traefik.systemd.erb'),
        }
        ~> exec { 'traefik-systemd-reload':
          command     => 'systemctl daemon-reload',
          path        => ['/usr/bin', '/bin', '/usr/sbin'],
          refreshonly => true,
        }
      }
      'upstart': {
        file { '/etc/init/traefik.conf':
          content => template('traefik/traefik.upstart.erb'),
          owner   => 'root',
          group   => 'root',
          mode    => '0444',
        }
        file { '/etc/init.d/traefik':
          ensure => link,
          target => '/lib/init/upstart-job',
          owner  => 'root',
          group  => 'root',
        }
      }
      default: {
        fail("Unknown init system style: ${init_style}")
      }
    }
  }
}
