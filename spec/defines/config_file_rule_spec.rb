require 'spec_helper'

describe 'traefik::config::file_rule' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts.merge(:concat_basedir => '/tmp/concat') }

      let(:title) { 'test' }

      describe 'with default parameters' do
        it { is_expected.to compile }
        it { is_expected.to contain_class('traefik::config::file') }

        it do
          is_expected.to contain_traefik__config__section('test-frontend')
            .with_table('frontends')
            .with_order('30-0')
            .with_hash('test-frontend' => {'backend' => 'test-backend'})
            .with_target('/etc/traefik/traefik.toml')
        end

        it do
          is_expected.to contain_traefik__config__section('test-backend')
            .with_table('backends')
            .with_order('30-1')
            .with_hash('test-backend' => {})
            .with_target('/etc/traefik/traefik.toml')
        end
      end

      describe 'when frontend is passed' do
        let(:frontend) do
          {
            'servers' => {
              'server1' => {
                'url' => 'http://127.0.0.1:5000',
                'weight' => 1
              }
            }
          }
        end
        let(:params) { {:frontend => frontend} }

        it do
          is_expected.to contain_traefik__config__section('test-frontend')
            .with_hash(
              'test-frontend' => frontend.merge('backend' => 'test-backend')
            )
        end
      end

      describe 'when backend is passed' do
        let(:backend) do
          {
            'servers' => {
              'server1' => {
                'url' => 'http://127.0.0.1:5000',
                'weight' => 1
              }
            }
          }
        end
        let(:params) { {:backend => backend} }

        it do
          is_expected.to contain_traefik__config__section('test-backend')
            .with_hash('test-backend' => backend)
        end
      end

      describe 'when a custom order is set' do
        let(:params) { {:order => '42'} }

        it do
          is_expected.to contain_traefik__config__section('test-frontend')
            .with_order('42-0')
        end

        it do
          is_expected.to contain_traefik__config__section('test-backend')
            .with_order('42-1')
        end
      end

      describe 'when description is passed' do
        let(:params) { {:description => 'Test setup'} }

        it do
          is_expected.to contain_traefik__config__section('test-frontend')
            .with_description('Test setup')
        end
      end
    end
  end
end
