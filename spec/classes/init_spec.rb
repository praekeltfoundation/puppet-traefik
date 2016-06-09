require 'spec_helper'

describe 'traefik' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      describe 'with default parameters' do
        it { is_expected.to compile }
        it { is_expected.to contain_class('traefik::params') } # inherits

        it { is_expected.to contain_anchor('traefik::begin') }

        it do
          is_expected.to contain_class('traefik::install')
            .with(
              'install_method' => 'url',
              'download_url_base' => 'https://github.com/containous/traefik/releases/download',
              'version' => '1.0.0-rc2',
              'os' => 'linux',
              'arch' => 'amd64',
              'download_url' => nil,
              'archive_dir' => '/opt/puppet-archive',
              'bin_dir' => '/usr/local/bin',
              'init_style' => 'upstart',
              'config_path' => '/etc/traefik/traefik.toml'
            )
            .that_notifies('Class[traefik::service]')
            .that_requires('Anchor[traefik::begin]')
        end

        it do
          is_expected.to contain_class('traefik::config')
            .with(
              'config_dir' => '/etc/traefik',
              'config_file' => 'traefik.toml',
              'config_hash' => {}
            )
            .that_requires('Class[traefik::install]')
        end

        it do
          is_expected.to contain_class('traefik::service')
            .with(
              'manage' => true,
              'ensure' => 'running',
              'enable' => true
            )
            .that_subscribes_to('Class[traefik::config]')
            .that_comes_before('Anchor[traefik::end]')
        end

        it { is_expected.to contain_anchor('traefik::end') }
      end

      describe 'with custom install options' do
        let(:params) do
          {
            :install_method => 'none',
            :download_url_base => 'https://www.example.com/downloads',
            :version => '1.0.0-rc1',
            :os => 'windows',
            :arch => 'arm',
            :download_url => 'http://www.google.com',
            :archive_dir => '/opt/voxpupuli-archive',
            :bin_dir => '/usr/bin',
            :init_style => false,
            :config_dir => '/etc/traffic',
            :config_file => 'config.toml'
          }
        end

        it do
          is_expected.to contain_class('traefik::install')
            .with(
              'install_method' => 'none',
              'download_url_base' => 'https://www.example.com/downloads',
              'version' => '1.0.0-rc1',
              'os' => 'windows',
              'arch' => 'arm',
              'download_url' => 'http://www.google.com',
              'archive_dir' => '/opt/voxpupuli-archive',
              'bin_dir' => '/usr/bin',
              'init_style' => false,
              'config_path' => '/etc/traffic/config.toml'
            )
        end
      end

      describe 'with custom config options' do
        let(:params) do
          {
            :config_dir => '/etc/traffic',
            :config_file => 'config.toml',
            :config_hash => {'abc' => 'def'}
          }
        end

        it do
          is_expected.to contain_class('traefik::config')
            .with(
              'config_dir' => '/etc/traffic',
              'config_file' => 'config.toml',
              'config_hash' => {'abc' => 'def'}
            )
        end
      end

      describe 'with custom service options' do
        let(:params) do
          {
            :service_manage => false,
            :service_ensure => 'stopped',
            :service_enable => false
          }
        end

        it do
          is_expected.to contain_class('traefik::service')
            .with(
              'manage' => false,
              'ensure' => 'stopped',
              'enable' => false
            )
        end
      end
    end
  end
end
