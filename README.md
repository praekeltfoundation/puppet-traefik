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

Different sections of Traefik's TOML configuration file can be defined with the `traefik::config::section` type. The name of the Puppet resource, in this case 'web' is used for the top-level of the resulting hash and will result in a table [web] in the TOML file:
```puppet
traefik::config::section { 'web':
  description => 'API backend',
  order       => '10',
  hash        => {'address' => ':9090'}
}
```

Hashes can be nested to produce nested TOML tables. The following resource will output the common http and https EntryPoints.
```puppet
traefik::config::section { 'entryPoints':
  hash => {
    'http'  => {
      'address' => ':80'
    },
    'https' => {
      'address' => ':443',
      'tls'     => {}
    }
  }
}
```

### File backend
Configuring backends and frontends using hashes in `traefik::config::section` resources can quickly get tedious. The `traefik::config::file` class and `traefik::config::file_rule` defined type make setting this up a bit easier.

To start, configure some basics for the file backend:
```puppet
class { 'traefik::config::file':
  filename => 'rules.toml',
  watch    => true
}
```
This will set up Traefik to read configuration for the file backend from a file called `rules.toml` and to watch that file for changes. Next, we create some frontend and backend rules:
```puppet
traefik::config::file_rule { 'my-service':
  frontend => {
    'routes' => {
      'test_1' => {
        'rule' => 'Host:my-service.example.com'
      }
    }
  },
  backend  => {
    'servers' => {
      'server1' => {
        'url'    => 'http://172.17.0.2:80',
        'weight' => 10
      },
      'server2' => {
        'url'    => 'http://172.17.0.3:80',
        'weight' => 1
      }
    }
  }
}
```

This should produce (roughly) the following config in `rules.toml`:
```toml
[frontends.my-service-frontend]
backend = 'my-service-backend'

[frontends.my-service-frontend.routes.test_1]
rule = "Host:my-service.example.com"

[backends.my-service-backend.servers.server1]
url = "http://172.17.0.2:80"
weight = 10

[backends.my-service-backend.servers.server2]
url = "http://172.17.0.3:80"
weight = 1
```

## Limitations
* Currently **only works on Ubuntu 14.04 and Debian 8** (pull requests welcome).
* Uses the [`toml-rb`](https://rubygems.org/gems/toml-rb) gem to generate config with a parser function. This means that your Puppet server must have the gem correctly installed. See [this page](https://docs.puppet.com/puppetserver/latest/gems.html) for Puppet 4 instructions.
* There is no validation on config parameters. Everything (and anything) can be specified via hashes.
