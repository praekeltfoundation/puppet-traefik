require 'spec_helper'

describe 'traefik::service' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      describe 'with default parameters' do
        it { should compile }

        it do
          is_expected.to contain_service('traefik')
            .with_ensure('running')
            .with_enable(true)
        end
      end

      describe 'with manage set false' do
        let(:params) { {:manage => false} }
        it { is_expected.not_to contain_service('traefik') }
      end

      describe 'with a custom ensure value' do
        let(:params) { {:ensure => 'stopped'} }
        it do
          is_expected.to contain_service('traefik')
            .with_ensure('stopped')
        end
      end

      describe 'with a enable set to false' do
        let(:params) { {:enable => false} }
        it do
          is_expected.to contain_service('traefik')
            .with_enable(false)
        end
      end
    end
  end
end
