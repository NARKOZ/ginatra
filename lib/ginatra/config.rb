module Ginatra

  # A Wrapper for the ginatra configuration variables,
  # including methods to load, dump and lookup keys
  # using just the class.
  class Config

    current_path = File.expand_path("#{File.dirname(__FILE__)}")

    # A default path for our configuration variables!
    CONFIG_PATH = File.expand_path("~/.ginatra/config.yml")

    # A default config that we fall back to if no file is found.
    DEFAULT_CONFIG = {
      :git_dirs => [File.expand_path("#{current_path}/../../repos/*")],
      :ignored_files => ['README.md'],
      :description => "View My Git Repositories",
      :port => 9797,
      :host => "0.0.0.0",
      :prefix => "/"
    }

    # Dumps the Default configuration to +CONFIG_PATH+,
    # WITHOUT regard for what's already there.
    #
    # Very Destructive Method. Use with care!
    def self.setup!
      File.open(CONFIG_PATH, 'w') do |f|
        YAML.dump(DEFAULT_CONFIG, f)
      end
    end

    unless File.exist?(CONFIG_PATH)
      require 'fileutils'
      FileUtils.mkdir_p(File.dirname(CONFIG_PATH))
      setup!
    end
    
    # Loads the configuration and merges it with
    # the default configuration.
    #
    # @return [Hash] config a hash of the configuration options
    def self.load!
      @config = {}
      begin
        @config = YAML.load_file(CONFIG_PATH)
      rescue Errno::ENOENT
      end
      @config = DEFAULT_CONFIG.merge(@config)
    end

    # Dumps the _current_ configuration to +CONFIG_PATH+
    # again WITHOUT regard for what's already there.
    #
    # Very Destructive Method. Use with care!
    def self.dump!
      File.open(CONFIG_PATH, 'w') do |f|
        YAML.dump(@config, f)
      end
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
