require 'spec_helper'

describe 'traefik::install' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      describe 'with default parameters' do
        it { should compile }

        it { is_expected.to contain_class('archive') }

        it do
          is_expected.to contain_file('/opt/puppet-archive')
            .with_ensure('directory')
            .with_owner('root')
            .with_group('root')
        end

        it do
          is_expected.to contain_file('/opt/puppet-archive/traefik-1.0.0-rc2')
            .with_ensure('directory')
            .with_owner('root')
            .with_group('root')
            .that_requires('File[/opt/puppet-archive]')
        end

        it do
          is_expected.to contain_archive(
            '/opt/puppet-archive/traefik-1.0.0-rc2/traefik'
          ).with_ensure('present')
            .with_source('https://github.com/containous/traefik/releases/download/v1.0.0-rc2/traefik_linux-amd64')
            .that_requires('File[/opt/puppet-archive/traefik-1.0.0-rc2]')
        end

        it do
          is_expected.to contain_file(
            '/opt/puppet-archive/traefik-1.0.0-rc2/traefik'
          ).with_owner('root')
            .with_group('root')
            .with_mode('0755')
            .that_requires(
              'Archive[/opt/puppet-archive/traefik-1.0.0-rc2/traefik]'
            )
        end

        it do
          is_expected.to contain_file('/usr/local/bin/traefik')
            .with_ensure('link')
            .with_target('/opt/puppet-archive/traefik-1.0.0-rc2/traefik')
            .that_requires(
              'File[/opt/puppet-archive/traefik-1.0.0-rc2/traefik]'
            )
        end

        it do
          is_expected.to contain_file('/etc/init/traefik.conf')
            .with_content(%r{^exec /usr/local/bin/traefik$})
            .with_owner('root')
            .with_group('root')
            .with_mode('0444')
        end

        it do
          is_expected.to contain_file('/etc/init.d/traefik')
            .with_ensure('link')
            .with_target('/lib/init/upstart-job')
            .with_owner('root')
            .with_group('root')
        end
      end

      describe 'with a custom download_url' do
        let(:params) do
          {
            :download_url => 'http://www.example.com/downloads/traefik_linux-amd64'
          }
        end
        it do
          is_expected.to contain_archive(
            '/opt/puppet-archive/traefik-1.0.0-rc2/traefik'
          ).with_source('http://www.example.com/downloads/traefik_linux-amd64')
        end
      end

      describe 'with install_method "none"' do
        let(:params) { {:install_method => 'none'} }

        it { is_expected.not_to contain_class('archive') }
        it { is_expected.not_to contain_file('/opt/puppet-archive') }

        it do
          is_expected.not_to contain_file(
            '/opt/puppet-archive/traefik-1.0.0-rc2'
          )
        end

        it do
          is_expected.not_to contain_archive(
            '/opt/puppet-archive/traefik-1.0.0-rc2/traefik'
          )
        end

        it do
          is_expected.not_to contain_file(
            '/opt/puppet-archive/traefik-1.0.0-rc2/traefik'
          )
        end

        it { is_expected.not_to contain_file('/usr/local/bin/traefik') }
      end

      describe 'with an unsupported install_method' do
        let(:params) { {:install_method => 'package'} }
        it do
          is_expected.to raise_error(
            Puppet::Error,
            /The provided install method "package" is invalid/
          )
        end
      end

      describe 'with a custom bin_dir' do
        let(:params) { {:bin_dir => '/usr/bin'} }

        it do
          is_expected.to contain_file('/usr/bin/traefik')
            .with_ensure('link')
            .with_target('/opt/puppet-archive/traefik-1.0.0-rc2/traefik')
        end

        it do
          is_expected.to contain_file('/etc/init/traefik.conf')
            .with_content(%r{^exec /usr/bin/traefik$})
        end
      end

      describe 'with an unset init_style' do
        let(:params) { {:init_style => false} }
        it { is_expected.not_to contain_file('/etc/init/traefik.conf') }
        it { is_expected.not_to contain_file('/etc/init.d/traefik') }
      end

      describe 'with an unsupported init system style' do
        let(:params) { {:init_style => 'systemd'} }
        it do
          is_expected.to raise_error(Puppet::Error,
                                     /Unknown init system style: systemd/)
        end
      end
    end
  end
end
