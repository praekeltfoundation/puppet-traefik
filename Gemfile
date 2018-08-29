source 'https://rubygems.org'

gem 'toml-rb', '~> 1.0'

group :test do
  gem 'rake'

  puppetversion = ENV['PUPPET_VERSION'] || '~> 4'
  gem 'puppet', puppetversion

  gem 'librarian-puppet'
  gem 'metadata-json-lint'
  gem 'puppetlabs_spec_helper', '~> 1.1.1'
  gem 'rspec-puppet-facts'

  gem 'rubocop', '~> 0.49.0'
end
