require 'spec_helper'

describe 'traefik::config' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      describe 'with default parameters' do
        it { should compile }

        it do
          is_expected.to contain_file('/etc/traefik')
            .with_ensure('directory')
            .with_owner('root')
            .with_group('root')
        end

        it do
          is_expected.to contain_concat('/etc/traefik/traefik.toml')
            .with_ensure('present')
            .with_owner('root')
            .with_group('root')
            .that_requires('File[/etc/traefik]')
        end

        it do
          is_expected.to contain_concat__fragment('traefik_header')
            .with_target('/etc/traefik/traefik.toml')
            .with_order('00')
            .with_content(/WARNING: This file is managed by Puppet/)
            .with_content(/traefik\.toml/)
            .with_content(/Global configuration/)
        end

        it do
          is_expected.to contain_traefik__config__section('main')
            .with_order('01')
            .with_hash({})
            .with_description('Main section')
        end
      end

      describe 'with custom config file location' do
        let(:params) do
          {
            :config_dir => '/etc/traffic',
            :config_file => 'config.toml'
          }
        end

        it do
          is_expected.to contain_file('/etc/traffic').with_ensure('directory')
        end

        it do
          is_expected.to contain_concat('/etc/traffic/config.toml')
            .that_requires('File[/etc/traffic]')
        end

        it do
          is_expected.to contain_concat__fragment('traefik_header')
            .with_target('/etc/traffic/config.toml')
        end
      end

      describe 'with config options set in config_hash' do
        let(:config_hash) do
          {
            'traefikLogsFile' => '/var/log/traefik/traefik.log',
            'accessLogsFile' => '/var/log/traefik/access.log',
            'logLevel' => 'INFO',
            'MaxIdleConnsPerHost' => 100,
            'defaultEntryPoints' => ['http', 'https'],
          }
        end
        let(:params) { {:config_hash => config_hash} }

        it do
          is_expected.to contain_traefik__config__section('main')
            .with_order('01')
            .with_hash(config_hash)
            .with_description('Main section')
        end
      end
    end
  end
end
