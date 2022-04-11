require 'headless'
require 'selenium-webdriver'
require 'yaml'

class BrowserDriver
	attr_reader :driver

	def initialize settings
		@use_profile_directory = settings[:use_profile_directory]
		@path_to_profile_dir = settings[:path_to_profile_dir]
		@proxy_host = settings[:proxy_host]
		@browser_type = settings[:browser_type]
		@proxy_port = settings[:proxy_port]
		@use_proxy = settings[:use_proxy]
		@headless = settings[:headless]

		at_exit do
			@driver.exit rescue nil
		end
	end

	def disconnect
		@driver.exit rescue nil
	end

	def restart_browser
		@driver.quit rescue nil
		prepare_browser
	end

	def prepare_browser
		case @browser_type
		when 'firefox'
		  prepare_browser_firefox
		when 'chrome'
		  prepare_browser_chrome
		else
		  puts 'Error: browser not detected in config'
		  exit
		end
		@driver
	end

	def prepare_browser_chrome
		options = Selenium::WebDriver::Chrome::Options.new
		options.add_argument('--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.80 Safari/537.36')
	 	options.add_argument("--user-data-dir=#{@path_to_profile_dir}") if @use_profile_directory
		options.add_argument("--proxy-server=#{@proxy_host}:#{@proxy_port}") if @use_proxy
		options.add_argument('--headless') if @headless
		options.add_argument('--window-size=1920,1080')

		@driver = Selenium::WebDriver.for :chrome, options: options
	end

	def prepare_browser_firefox
		profile = Selenium::WebDriver::Firefox::Profile.new
		profile.from_name(@path_to_profile_dir) if @use_profile_directory
		profile['general.useragent.override'] = 'Mozilla/5.0(iPad; U; CPU iPhone OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B314 Safari/531.21.10'

		if @use_proxy
			proxy_address = @proxy_host + ':' + @proxy_port
			proxy = Selenium::WebDriver::Proxy.new(http: proxy_address, ssl: proxy_address)
			profile.proxy = proxy
		end

		options = Selenium::WebDriver::Firefox::Options.new
		options.headless! if @headless
		options.profile = profile

		@driver = Selenium::WebDriver.for(:firefox, capabilities: options)

		@driver
	end
end

config = YAML::load_file(File.expand_path('../config/config.yml', __FILE__))
settings = {
	browser_type: config['browser'],
	headless: config['headless'],
	use_profile_directory: config['use_profile_directory'],
	use_proxy: config['use_proxy'],
	path_to_profile_dir: config['path_to_profile_dir'],
	proxy_host: config['proxy_host'],
	proxy_port: config['proxy_port']
}
browser_driver = BrowserDriver.new settings
driver = browser_driver.prepare_browser
driver.navigate.to 'https://google.com'
sleep 30
