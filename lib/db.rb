require 'sequel'
require 'mysql2'

module Parser
  class DB
    def self.get_db
      @db ||= begin
        config = Parser::Config.get_config

        db_connection_params = {
          adapter: 'mysql2',
          host: config.db['host'],
          port: config.db['port'],
          database: config.db['database'],
          user: config.db['user'],
          password: config.db['password'],
          max_connections: 10,
          encoding: 'utf8'
        }

        db = Sequel.connect(db_connection_params)

        db.extension(:connection_validator)

        at_exit { disconnect }

        db
      end
    end

    def self.disconnect
      @db.disconnect
      rescue StandardError
      nil
    end
  end
end
