require 'redis'

module Parser
  class RDS
    def self.instance
      @@rd ||= begin
        config = Parser::Config.get_config
        rd = Redis.new(host: config.redis['host'], port: config.redis['port'])
        rd
      end
    end
  end
end
