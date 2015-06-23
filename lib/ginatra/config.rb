require 'yaml'
require 'ostruct'
 # This Class holds the config settings for ginatra
module Ginatra
  def self.config
    @config ||= OpenStruct.new load_config
  end

  # Loads the configuration and merges it with
  # custom configuration if necessary.
  #
  # @return [Hash] config a hash of the configuration options
  def self.load_config
    current_path        = File.expand_path(File.dirname(__FILE__))
    custom_config_file  = File.expand_path('~/.ginatra/config.yml')
    default_config_file = File.expand_path("#{current_path}/../../config.yml")

    # Our own file should be there and we don't need to check its syntax
    abort "ginatra config file #{default_config_file}"\
          " is missing." unless File.exists?(default_config_file)
    final_config = YAML.load_file(default_config_file)

    # User config file may not exist or be broken
    final_config = merge_config(final_config, custom_config_file)

    final_config
  end

  # merges the custom config file if it exists
  def self.merge_config(final_config, custom_config_file)
    if File.exists?(custom_config_file)
      parse_custom_config(custom_config_file)
      final_config.merge!(custom_config)
    else
      puts "User config file #{custom_config_file} absent."\
           " Will only see repos in #{final_config["git_dirs"].join(", ")}."
    end
    final_config
  end

  #parses the config file if it exists
  def parse_custom_config(custom_config_file)
    begin
      custom_config = YAML.load_file(custom_config_file)
    rescue Psych::SyntaxError => ex
      puts "Cannot parse your config file #{ex.message}."
      custom_config = {}
    end
    custom_config
  end
end
