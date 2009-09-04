module Ginatra
  class Config

    current_path = File.expand_path("#{File.dirname(__FILE__)}")
    CONFIG_PATH = File.expand_path("~/.ginatra/config.yml")
      
    DEFAULT_CONFIG = {
      :git_dirs => [File.expand_path("#{current_path}/../../repos/*")],
      :ignored_files => ['README.md'],
      :description => "View My Git Repositories",
      :port => 9797
    }

    def self.setup! # Very Destructive Method. Use with care!
      File.open(CONFIG_PATH, 'w') do |f|
        YAML.dump(DEFAULT_CONFIG, f)
      end
    end

    unless File.exist?(CONFIG_PATH)
      require 'fileutils'
      FileUtils.mkdir_p(File.dirname(CONFIG_PATH))
      setup!
    end
    
    def self.load!
      @config = {}
      begin
        @config = YAML.load_file(CONFIG_PATH)
      rescue Errno::ENOENT
      end
      @config = DEFAULT_CONFIG.merge(@config)
    end

    def self.dump!
      File.open(CONFIG_PATH, 'w') do |f|
        YAML.dump(@config, f)
      end
    end

    def self.method_missing(sym, *args, &block)
      if @config.respond_to?(sym)
        @config.send(sym, *args, &block)
      elsif @config.has_key?(sym)
        @config[sym]
      else
        super
      end
    end

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
