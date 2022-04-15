module Parser
  autoload :Config, 'config'
  autoload :ProjectLogger, 'project_logger'
  autoload :WebBrowser, 'web_browser'

  config = Parser::Config.get_config

  autoload :DB, 'db'  if config.autoloading['db']
  autoload :RMQ, 'rmq' if config.autoloading['rmq']
  autoload :RDS, 'rds' if config.autoloading['rds']

  autoload :Example, 'example'
end

