require 'spec_helper'

describe 'traefik::config::file' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts.merge(:concat_basedir => '/tmp/concat') }

      describe 'with default parameters' do
        it { is_expected.to compile }

        it { is_expected.to contain_class('traefik::config') }
        it do
          is_expected.to contain_traefik__config__section('file')
            .with_order('10')
            .with_hash('watch' => false)
        end
      end

      describe 'when filename is passed' do
        let(:params) { {:filename => 'rules.toml'} }

        it do
          is_expected.to contain_concat('/etc/traefik/rules.toml')
            .with_ensure('present')
            .with_owner('root')
            .with_group('root')
            .that_requires('File[/etc/traefik]')
            .that_comes_before('Traefik::Config::Section[file]')
        end

        it do
          is_expected.to contain_concat__fragment('traefik_rules_header')
            .with_target('/etc/traefik/rules.toml')
            .with_order('00')
            .with_content(/WARNING: This file is managed by Puppet/)
            .with_content(/rules\.toml/)
            .with_content(/File configuration/)
        end

        it do
          is_expected.to contain_traefik__config__section('file')
            .with_hash(
              'filename' => '/etc/traefik/rules.toml',
              'watch' => false
            )
        end
      end

      describe 'when watch is true' do
        let(:params) { {:watch => true} }
        it do
          is_expected.to contain_traefik__config__section('file')
            .with_hash('watch' => true)
        end
      end
    end
  end
end
