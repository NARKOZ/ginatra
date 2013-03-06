require 'yaml'

module Ginatra
  # A Wrapper for the ginatra configuration variables,
  # including methods to load, dump and lookup keys
  # using just the class.
  class Config
    # Loads the configuration and merges it with
    # custom configuration if necessary.
    #
    # @return [Hash] config a hash of the configuration options
    def self.load!
      current_path        = File.expand_path("#{File.dirname(__FILE__)}")
      custom_config_file  = File.expand_path("~/.ginatra/config.yml")
      default_config_file = File.expand_path("#{current_path}/../../config.yml")

      @config = YAML.load_file(default_config_file)

      if File.exist?(custom_config_file)
        custom_config = YAML.load_file(custom_config_file)
        @config.merge!(custom_config)
      end

      @config = symbolize_keys(@config)
    end

    # Returns a new hash with all keys converted to symbols
    def self.symbolize_keys(hash)
      hash.each_with_object({}) {|(k, v), h| h[k.to_sym] = v }
    end

    # Allows us to do many things.
    #
    # The first is respond to any hash methods
    # and execute them on the +@config+ hash.
    #
    # The second is to do something like
    # +Ginatra::Config.port+ instead of something
    # like +Ginatra::Config[:port]+
    #
    # @return depends on what's in the config hash.
    def self.method_missing(sym, *args, &block)
      if @config.respond_to?(sym)
        @config.send(sym, *args, &block)
      elsif @config.has_key?(sym)
        @config[sym]
      else
        super
      end
    end

    # This is so that we can be clever by using
    # +#try()+ and so that this mirrors +method_missing+.
    #
    # @see Ginatra::Config.method_missing
    def self.respond_to?(name)
      if @config.respond_to?(name)
        true
      elsif @config.has_key?(name)
        true
      else
        super
      end
    end
  end
end
