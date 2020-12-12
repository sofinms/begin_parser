require 'headless'
require "selenium-webdriver"
require 'yaml'

class BrowserDriver
	attr_reader :browser_type, :headless, :driver

	def initialize settings
		@browser_type = settings[:browser_type]
		@headless = settings[:headless]
		at_exit do
			disconnect
		end
	end

	def disconnect
		@driver.exit rescue nil
	end

	def prepare_browser
		case @browser_type
		when 'firefox'
		  prepare_browser_firefox
		when 'chrome'
		  prepare_browser_chrome
		else
		  puts "Error: browser not detected in config"
		  exit
		end
		@driver
	end

	def prepare_browser_chrome
		options = Selenium::WebDriver::Chrome::Options.new
	#  	options.add_argument("--user-data-dir=/Users/macbook/Library/Application Support/Google/Chrome/parser2/")
		# options.add_argument("--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.80 Safari/537.36")
		options.add_argument("--window-size=1920,1080")
		options.add_argument('--headless') if @headless
		@driver = Selenium::WebDriver.for :chrome, options: options
	end

	def prepare_browser_firefox
		args = []
		args.oush '-headless' if @headless
		options = Selenium::WebDriver::Firefox::Options.new(args: args)
		@driver = Selenium::WebDriver.for(:firefox, options: options)
	end
end

config = YAML::load_file(File.expand_path('../config/config.yml', __FILE__))
settings = {
	:browser_type => config['browser'],
	:headless => config['headless']
}
browser_driver = BrowserDriver.new settings
driver = browser_driver.prepare_browser
driver.navigate.to 'https://google.com'


