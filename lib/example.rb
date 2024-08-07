module Parser
  class Example
    def self.run
      logger = O14::ProjectLogger.get_logger
      driver = O14::WebBrowser.get_driver
      config = O14::Config.get_config
      db = O14::DB.get_db
      
      driver.navigate.to 'https://google.com'
      sleep 30
    end
  end
end
