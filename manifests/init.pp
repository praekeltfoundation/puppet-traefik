# == Class: traefik
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
# [*max_open_files*]
#   Integer which controls 'nofile' ulimit value in init scripts, which sets
#   the maximum number of open files for the Traefik process.
#
# [*init_style*]
#   The style of the init system on the system. If false-y then no init script
#   will be installed. Possible values: upstart, false
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
#
# [*service_manage*]
#   Whether or not Puppet should manage the traefik service.
#
# [*service_ensure*]
#   The ensure value for the service, e.g. running, stopped
#
# [*service_enable*]
#   The enable value for the service (whether it should be enabled or disabled).
class traefik (
  $install_method    = $traefik::params::install_method,
  $download_url_base = $traefik::params::download_url_base,
  $version           = $traefik::params::version,
  $os                = $traefik::params::os,
  $arch              = $traefik::params::arch,
  $download_url      = undef,
  $archive_dir       = $traefik::params::archive_dir,
  $bin_dir           = $traefik::params::bin_dir,
  $max_open_files    = $traefik::params::max_open_files,
  $init_style        = $traefik::params::init_style,

  $config_dir        = $traefik::params::config_dir,
  $config_file       = $traefik::params::config_file,
  $config_hash       = {},

  $service_manage    = true,
  $service_ensure    = running,
  $service_enable    = true,

) inherits traefik::params {
  anchor { 'traefik::begin': }
  -> class { 'traefik::install':
    install_method    => $install_method,
    download_url_base => $download_url_base,
    version           => $version,
    os                => $os,
    arch              => $arch,
    download_url      => $download_url,
    archive_dir       => $archive_dir,
    bin_dir           => $bin_dir,
    max_open_files    => $max_open_files,
    init_style        => $init_style,
    config_path       => "${config_dir}/${config_file}",
    notify            => Class['traefik::service'],
  }
  -> class { 'traefik::config':
    config_dir  => $config_dir,
    config_file => $config_file,
    config_hash => $config_hash,
  }
  ~> class { 'traefik::service':
    ensure => $service_ensure,
    manage => $service_manage,
    enable => $service_enable,
  }
  -> anchor { 'traefik::end': }
}
