require 'spec_helper'

describe 'traefik' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { should compile }
    end
  end
end
