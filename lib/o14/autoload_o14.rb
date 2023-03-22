module O14
  autoload :Config, 'o14/config'
  autoload :ProjectLogger, 'o14/project_logger'
  autoload :WebBrowser, 'o14/web_browser'

  @config = O14::Config.get_config

  autoload :DB, 'o14/db'  if @config.autoloading['db']
  autoload :RMQ, 'o14/rmq' if @config.autoloading['rmq']
  autoload :RDS, 'o14/rds' if @config.autoloading['rds']
  autoload :ExceptionHandler, 'o14/rds' if @config.autoloading['exception_handler']
end

