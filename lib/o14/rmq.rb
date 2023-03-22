# frozen_string_literal: true

require 'json'
require 'bunny'

module O14
  class RMQ
		APP_ID = 'uw_youtube'
		def self.get_channel
			@@ch ||= begin
				config = O14::Config.get_config

				conn = Bunny.new :host => config.rmq['host'], :port => config.rmq['port'], :user => config.rmq['username'],
				 :pass => config.rmq['password'], :vhost => config.rmq['vhost']
				conn.start
				ch = conn.create_channel
				ch.prefetch(1)

			  	at_exit { ch.close rescue nil }

			  	ch
			end
		end
		
		def self.create_channel config
			conn = Bunny.new :host => config['host'], :port => config['port'], :user => config['username'],
			 :pass => config['password'], :vhost => config['vhost']
			conn.start
			ch = conn.create_channel
			ch.prefetch(1)

		  	at_exit { ch.close rescue nil }

		  	ch
		end

		def self.send_message(exchage, message)
			exchage.publish JSON.generate(message), persistent: true, app_id: APP_ID.to_sym, host: Socket.gethostname, content_type: 'application/json'
		end
	end
end
