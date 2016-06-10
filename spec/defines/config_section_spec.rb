require 'spec_helper'

describe 'traefik::config::section' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:title) { 'test' }

      describe 'when hash is passed' do
        let(:params) { {:hash => {'test' => 'abc'}} }

        it { is_expected.to compile }
        it { is_expected.to contain_class('traefik::config') }

        it do
          is_expected.not_to contain_concat__fragment('traefik_test_header')
        end

        it do
          is_expected.to contain_concat__fragment('traefik_test')
            .with_target('/etc/traefik/traefik.toml')
            .with_order('20-1')
            .with_content(/^test = "abc"$/)
        end
      end

      describe 'when hash is not passed' do
        it do
          is_expected.to compile.and_raise_error(mustpass('hash'))
        end
      end

      describe 'when description is passed' do
        let(:params) do
          {
            :hash => {'test' => 'abc'},
            :description => 'Test section'
          }
        end

        it do
          is_expected.to contain_concat__fragment('traefik_test_header')
            .with_target('/etc/traefik/traefik.toml')
            .with_order('20-0')
            .with_content(/Test section/)
        end

        it do
          is_expected.to contain_concat__fragment('traefik_test')
            .with_target('/etc/traefik/traefik.toml')
            .with_order('20-1')
            .with_content(/^test = "abc"$/)
        end
      end

      describe 'when a custom order is set' do
        let(:params) do
          {
            :hash => {'test' => 'abc'},
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
    end
  end
end
