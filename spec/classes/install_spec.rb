require 'spec_helper'

describe 'traefik::install' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:version) { '1.0.0' }

      describe 'with default parameters' do
        let(:params) { {:version => version} }
        it { should compile }

        it { is_expected.to contain_class('archive') }

        it do
          is_expected.to contain_file('/opt/puppet-archive')
            .with_ensure('directory')
            .with_owner('root')
            .with_group('root')
        end

        it do
          is_expected.to contain_file("/opt/puppet-archive/traefik-#{version}")
            .with_ensure('directory')
            .with_owner('root')
            .with_group('root')
            .that_requires('File[/opt/puppet-archive]')
        end

        it do
          is_expected.to contain_archive(
            "/opt/puppet-archive/traefik-#{version}/traefik"
          ).with_ensure('present')
            .with_source('https://github.com/containous/traefik/releases/'\
                         "download/v#{version}/traefik_linux-amd64")
            .that_requires("File[/opt/puppet-archive/traefik-#{version}]")
        end

        it do
          is_expected.to contain_file(
            "/opt/puppet-archive/traefik-#{version}/traefik"
          ).with_owner('root')
            .with_group('root')
            .with_mode('0755')
            .that_requires(
              "Archive[/opt/puppet-archive/traefik-#{version}/traefik]"
            )
        end

        it do
          is_expected.to contain_file('/usr/local/bin/traefik')
            .with_ensure('link')
            .with_target("/opt/puppet-archive/traefik-#{version}/traefik")
            .that_requires(
              "File[/opt/puppet-archive/traefik-#{version}/traefik]"
            )
        end

        if facts[:operatingsystem] == 'Debian'
          it do
            is_expected.to contain_file('/lib/systemd/system/traefik.service')
              .with_content(%r{^ExecStart=/usr/local/bin/traefik$})
              .with_owner('root')
              .with_group('root')
              .with_mode('0644')
          end

          it do
            is_expected.to contain_exec('traefik-systemd-reload')
              .with_command('systemctl daemon-reload')
              .with_path(['/usr/bin', '/bin', '/usr/sbin'])
              .with_refreshonly(true)
          end

        elsif facts[:operatingsystem] == 'Ubuntu'
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
      end

      describe 'with custom download parameters' do
        let(:params) do
          {
            :download_url_base => 'http://www.example.com/downloads',
            :version => '1.0.0-rc1',
            :os => 'windows',
            :arch => 'arm'
          }
        end

        it do
          is_expected.to contain_file('/opt/puppet-archive/traefik-1.0.0-rc1')
        end

        it do
          is_expected.to contain_archive(
            '/opt/puppet-archive/traefik-1.0.0-rc1/traefik'
          ).with_source('http://www.example.com/downloads/v1.0.0-rc1/traefik_windows-arm')
        end

        it do
          is_expected.to contain_file(
            '/opt/puppet-archive/traefik-1.0.0-rc1/traefik'
          )
        end

        it do
          is_expected.to contain_file('/usr/local/bin/traefik')
            .with_target('/opt/puppet-archive/traefik-1.0.0-rc1/traefik')
        end
      end

      describe 'with a custom download_url' do
        let(:params) do
          {
            :version => version,
            :download_url => 'http://www.example.com/downloads/traefik_linux-amd64'
          }
        end
        it do
          is_expected.to contain_archive(
            "/opt/puppet-archive/traefik-#{version}/traefik"
          ).with_source('http://www.example.com/downloads/traefik_linux-amd64')
        end
      end

      describe 'with a custom archive_dir' do
        let(:params) do
          {
            :version => version,
            :archive_dir => '/opt/voxpupuli-archive'
          }
        end

        it { is_expected.to contain_file('/opt/voxpupuli-archive') }

        it do
          is_expected.to contain_file(
            "/opt/voxpupuli-archive/traefik-#{version}"
          )
        end

        it do
          is_expected.to contain_archive(
            "/opt/voxpupuli-archive/traefik-#{version}/traefik"
          )
        end

        it do
          is_expected.to contain_file(
            "/opt/voxpupuli-archive/traefik-#{version}/traefik"
          )
        end

        it do
          is_expected.to contain_file('/usr/local/bin/traefik')
            .with_target("/opt/voxpupuli-archive/traefik-#{version}/traefik")
        end
      end

      describe 'with install_method "none"' do
        let(:params) do
          {
            :version => version,
            :install_method => 'none'
          }
        end

        it { is_expected.not_to contain_class('archive') }
        it { is_expected.not_to contain_file('/opt/puppet-archive') }

        it do
          is_expected.not_to contain_file(
            "/opt/puppet-archive/traefik-#{version}"
          )
        end

        it do
          is_expected.not_to contain_archive(
            "/opt/puppet-archive/traefik-#{version}/traefik"
          )
        end

        it do
          is_expected.not_to contain_file(
            "/opt/puppet-archive/traefik-#{version}/traefik"
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
            .with_target("/opt/puppet-archive/traefik-#{version}/traefik")
        end

        if facts[:operatingsystem] == 'Debian'
          it do
            is_expected.to contain_file('/lib/systemd/system/traefik.service')
              .with_content(%r{^ExecStart=/usr/bin/traefik$})
          end
        elsif facts[:operatingsystem] == 'Ubuntu'
          it do
            is_expected.to contain_file('/etc/init/traefik.conf')
              .with_content(%r{^exec /usr/bin/traefik$})
          end
        end
      end

      describe 'with an unset init_style' do
        let(:params) { {:init_style => false} }
        it { is_expected.not_to contain_file('/etc/init/traefik.conf') }
        it { is_expected.not_to contain_file('/etc/init.d/traefik') }
      end

      describe 'with an unsupported init system style' do
        let(:params) { {:init_style => 'launchd'} }
        it do
          is_expected.to raise_error(Puppet::Error,
                                     /Unknown init system style: launchd/)
        end
      end

      describe 'with a custom config_path' do
        let(:config_path) { '/etc/traefik/config.toml' }
        let(:binary) { '/usr/local/bin/traefik' }
        let(:params) { {:config_path => config_path} }

        if facts[:operatingsystem] == 'Debian'
          it do
            is_expected.to contain_file('/lib/systemd/system/traefik.service')
              .with_content(/^ExecStart=#{binary} --configFile=#{config_path}$/)
          end
        elsif facts[:operatingsystem] == 'Ubuntu'
          it do
            is_expected.to contain_file('/etc/init/traefik.conf')
              .with_content(/^exec #{binary} --configFile=#{config_path}$/)
          end
        end
      end
    end
  end
end
