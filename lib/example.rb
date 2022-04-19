require 'headless'
require 'selenium-webdriver'
require 'yaml'

module Parser
  class Example
    def self.run (log_level = 'ERROR', log_filename = nil)
      logger = Parser::ProjectLogger.get_logger log_level, log_filename
      driver = Parser::WebBrowser.get_driver
      config = Parser::Config.get_config
      db = Parser::DB.get_db  if config.autoloading['db']
      
      driver.navigate.to 'https://google.com'
      sleep 30
    end
  end
end
