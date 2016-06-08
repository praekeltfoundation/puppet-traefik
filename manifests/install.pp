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
# [*archive_path*]
#   Path to the directory that Traefik will be downloaded to.
#
# [*bin_dir*]
#   The directory that the Traefik binary will be symlinked into (from where it
#   was downloaded to).
class traefik::install (
  $install_method    = $traefik::params::install_method,

  $download_url_base = $traefik::params::download_url_base,
  $version           = $traefik::params::version,
  $os                = $traefik::params::os,
  $arch              = $traefik::params::arch,

  $download_url      = undef,

  $archive_path      = '/opt/puppet-archive',
  $bin_dir           = '/usr/local/bin',
) inherits traefik::params {
  case $install_method {
    'url': {
      $real_download_url = pick($download_url,
        "${download_url_base}/v${version}/traefik_${os}-${arch}")

      include archive

      file { [$archive_path, "${archive_path}/traefik-${version}"]:
        ensure => directory,
        owner  => 'root',
        group  => 'root',
      }

      archive { "${archive_path}/traefik-${version}/traefik":
        ensure       => present,
        source       => $real_download_url,
        # Workaround for https://github.com/voxpupuli/puppet-archive/issues/166
        # extract_path not actually used since we're not extracting
        extract_path => '/tmp'
      }->
      file {
        "${archive_path}/traefik-${version}/traefik":
          owner => 'root',
          group => 'root',
          mode  => '0755';
        "${bin_dir}/traefik":
          ensure => link,
          target => "${archive_path}/traefik-${version}/traefik";
      }
    }
    'none': {}
    default: {
      fail("The provided install method \"${install_method}\" is invalid")
    }
  }
}
