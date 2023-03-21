require 'selenium-webdriver'

module O14
  module WebBrowser
    def self.get_driver
      config = O14::Config.get_config

      @use_profile_directory = config.web_browser['use_profile_directory']
      @path_to_profile_dir = config.web_browser['path_to_profile_dir']
      @proxy_host = config.web_browser['proxy_host']
      @browser_type = config.web_browser['browser']
      @proxy_port = config.web_browser['proxy_port']
      @use_proxy = config.web_browser['use_proxy']
      @headless = config.web_browser['headless']

      @@driver ||= begin
        case @browser_type
        when 'firefox'
          if @use_profile_directory
            O14::ProjectLogger.get_logger.info "profile_dir = #{@path_to_profile_dir}"
            profile = Selenium::WebDriver::Firefox::Profile.new(@path_to_profile_dir)
          else
            p "no profile_dir"
            O14::ProjectLogger.get_logger.info "no profile_dir"
            profile = Selenium::WebDriver::Firefox::Profile.new
          end
          profile['geo.enabled'] = true # appCodeName
          profile['geo.prompt.testing'] = true
          profile['geo.prompt.testing.allow'] = true
          profile['general.description.override'] = "Mozilla" # appCodeName
          profile['general.appname.override'] = "Netscape"
          profile['general.appversion.override'] = "5.0 (Macintosh)"
          profile['general.platform.override'] = "MacIntel"
          profile['general.oscpu.override'] = "Intel Mac OS X 10.15"
          profile['general.useragent.override'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:87.0) Gecko/20100101 Firefox/87.0'
          if @use_proxy
            profile['network.proxy.http'] = @proxy_host
            profile['network.proxy.http_port'] = @proxy_port
          end
          if config.web_browser['disable_images']
            profile['permissions.default.image'] = 2
          end
          args = []
          args.push '-headless' if config.web_browser['headless']
          options = Selenium::WebDriver::Firefox::Options.new(args: args, profile: profile)
          driver = Selenium::WebDriver.for :firefox, options: options
          target_size = Selenium::WebDriver::Dimension.new(config.web_browser['window_width'], config.web_browser['window_height'])
          driver.manage.window.size = target_size

          driver
        when 'chrome'
          options = Selenium::WebDriver::Chrome::Options.new
          options.headless! if @headless
          options.add_argument('--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.80 Safari/537.36')
          options.add_argument("--user-data-dir=#{@path_to_profile_dir}") if @use_profile_directory
          options.add_argument("--proxy-server=#{@proxy_host}:#{@proxy_port}") if @use_proxy
          options.add_argument("--window-size=#{config.web_browser['window_width']},#{config.web_browser['window_height']}")
          if config.web_browser['disable_images']
            options.add_argument('--blink-settings=imagesEnabled=false')
          end

          driver = Selenium::WebDriver.for :chrome, capabilities: options
        else
          O14::ProjectLogger.get_logger.error "Error: browser not detected in config"
          exit
        end
        driver
      end
    end

    def self.restart_browser
      quit_browser
      O14::ProjectLogger.get_logger.info 'Restart browser'
      get_driver
    end

    def self.quit_browser
      @@driver.quit rescue nil
      @@driver = nil
    end
  end
end
