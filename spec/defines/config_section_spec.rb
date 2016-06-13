require 'spec_helper'

describe 'traefik::config::section' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:title) { 'test' }

      describe 'with default parameters' do
        it { is_expected.to compile }
        it { is_expected.to contain_class('traefik::config') }

        it do
          is_expected.not_to contain_concat__fragment('traefik_test_header')
        end

        it do
          is_expected.to contain_concat__fragment('traefik_test')
            .with_target('/etc/traefik/traefik.toml')
            .with_order('20-1')
            .with_content("[test]\n")
        end
      end

      describe 'when hash is passed' do
        let(:params) { {:hash => {'key' => 'value'}} }

        it do
          is_expected.to contain_concat__fragment('traefik_test')
            .with_target('/etc/traefik/traefik.toml')
            .with_order('20-1')
            .with_content(/^\[test\]$/)
            .with_content(/^key = "value"$/)
        end
      end

      describe 'when description is passed' do
        let(:params) { {:description => 'Test section'} }

        it do
          is_expected.to contain_concat__fragment('traefik_test_header')
            .with_target('/etc/traefik/traefik.toml')
            .with_order('20-0')
            .with_content(/Test section/)
        end
      end

      describe 'when a custom order is set' do
        let(:params) do
          {
            :description => 'Test section',
            :order => '33'
          }
        end

        it do
          is_expected.to contain_concat__fragment('traefik_test_header')
            .with_order('33-0')
        end

        it do
          is_expected.to contain_concat__fragment('traefik_test')
            .with_order('33-1')
        end
      end

      describe 'when table is passed' do
        let(:params) { {:table => 'tabular'} }
        it do
          is_expected.to contain_concat__fragment('traefik_test')
            .with_content("[tabular]\n")
        end
      end

      describe 'when table is false' do
        let(:params) do
          {
            :table => false,
            :hash => {'key' => 'value'}
          }
        end
        it do
          is_expected.to contain_concat__fragment('traefik_test')
            .with_content("key = \"value\"\n")
        end
      end
    end
  end
end
