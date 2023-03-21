require 'closed_struct'
require 'yaml'

module O14
  class Config
    CONFIG_PATH = File.join(__dir__, '..', '..', 'config', 'config.yml')

    def self.get_config
      @config ||= ClosedStruct.new(load_config)
    end

    def self.load_config
      YAML.load_file(File.expand_path(CONFIG_PATH, __FILE__))
    end
  end
end
