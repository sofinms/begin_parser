require 'redis'

module O14
  class RDS
    def self.instance
      @@rd ||= begin
        config = O14::Config.get_config
        rd = Redis.new(host: config.redis['host'], port: config.redis['port'])
        rd
      end
    end
  end
end
