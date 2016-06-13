# puppet-traefik
A Puppet module to manage [Traefik](https://traefik.io)

## Usage
You can just `include traefik` or set some basic parameters:
```puppet
class { 'traefik':
  version     => '1.0.0-rc1',
  config_hash => {
    'accessLogsFile' => '/var/log/traefik/access.log',
    'logLevel'       => 'INFO'
  },
}
```

Different sections of Traefik's TOML configuration file can be defined with the `traefik::config::section` type:
```puppet
traefik::config::section { 'web':
  description => 'API backend',
  order       => '10',
  hash        => {'address' => ':9090'}
}
```

## Limitations
* Currently **only works on Ubuntu 14.04** (pull requests welcome).
* Uses the [`toml-rb`](https://rubygems.org/gems/toml-rb) gem to generate config with a parser function. This means that your Puppet server must have the gem correctly installed. See [this page](https://docs.puppet.com/puppetserver/latest/gems.html) for Puppet 4 instructions.
* There is no validation on config parameters. Everything (and anything) can be specified via hashes.
* Does not (easily) provide a way to specify config in multiple files.
* Traefik is a fast moving project that hasn't yet had a stable release. Things will likely break as things change.
