require 'headless'
require 'selenium-webdriver'
require 'yaml'

module Parser
  class Example
    def self.run (log_level = 'ERROR', log_filename = nil)
      logger = Parser::ProjectLogger.get_logger log_level, log_filename
      driver = Parser::WebBrowser.get_driver
      db = Parser::DB.get_db

      driver.navigate.to 'https://google.com'
      sleep 30
    end
  end
end
