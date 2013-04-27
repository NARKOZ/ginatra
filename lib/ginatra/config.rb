require 'yaml'
require 'ostruct'

module Ginatra
  def self.config
    @config ||= OpenStruct.new load_config
  end

  # Loads the configuration and merges it with
  # custom configuration if necessary.
  #
  # @return [Hash] config a hash of the configuration options
  def self.load_config
    current_path        = File.expand_path("#{File.dirname(__FILE__)}")
    custom_config_file  = File.expand_path("~/.ginatra/config.yml")
    default_config_file = File.expand_path("#{current_path}/../../config.yml")

    config = YAML.load_file(default_config_file)

    if File.exist?(custom_config_file)
      custom_config = YAML.load_file(custom_config_file)
      config.merge!(custom_config)
    end

    config
  end
end
