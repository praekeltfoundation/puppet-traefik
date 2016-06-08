require 'spec_helper'

describe 'traefik::params' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile }
    end
  end

  describe 'with an unsupported architecture' do
    let(:facts) do
      {
        :kernel => 'Linux',
        :operatingsystem => 'Ubuntu',
        :operatingsystemrelease => '14.04',
        :architecture => 'sparc'
      }
    end

    it do
      is_expected.to raise_error(
        Puppet::Error, /Unsupported kernel architecture: sparc/
      )
    end
  end

  describe 'with an unsupported OS' do
    let(:facts) do
      {
        :kernel => 'Linux',
        :architecture => 'amd64',
        :operatingsystem => 'Fedora',
        :operatingsystemrelease => 'The explorer'
      }
    end

    it { is_expected.to raise_error(Puppet::Error, /Unsupported OS/) }
  end
end
