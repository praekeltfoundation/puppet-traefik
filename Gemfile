source 'https://rubygems.org'

gem 'toml-rb'

group :test do
  gem 'rake'

  puppetversion = ENV['PUPPET_VERSION'] || '~> 4'
  gem 'puppet', puppetversion

  gem 'librarian-puppet'
  gem 'metadata-json-lint'
  gem 'puppetlabs_spec_helper', '~> 1.1.1'
  gem 'rspec-puppet-facts'

  gem 'rubocop', '~> 0.40.0'

  # json 2.0.0 gem dropped support for Ruby < 2.0
  gem 'json', '< 2.0.0' if RUBY_VERSION.start_with?('1.9')
end
