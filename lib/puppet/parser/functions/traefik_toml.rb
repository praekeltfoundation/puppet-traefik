require 'toml-rb'

module Puppet
  module Parser
    module Functions # :nodoc:
      newfunction(:traefik_toml, :type => :rvalue, :doc => <<-EOS
This function takes a hash and outputs serialized TOML.
        EOS
                 ) do |args|
        if args.size != 1
          raise Puppet::ParseError, 'traefik_toml takes exactly 1 argument'
        end

        return TomlRB.dump(args[0])
      end
    end
  end
end
