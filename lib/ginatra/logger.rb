require 'logger'
require 'fileutils'

module Ginatra
  # Encapsulates the Logger
  module Logger
      # Locates and Prints the log file
    def logger
      Logger.logger
    end

    def self.logger
      return @logger if @logger

      log_file = find_log

      create_log(log_file)

      @logger = ::Logger.new log_file
      @logger.level = ::Logger::WARN
      @logger.formatter = proc do |severity, datetime, progname, msg|
        "[#{datetime} ##{Process.pid}] #{severity}: #{msg}\n"
      end
      @logger
    end

    # Finds log file if it is not in the instance variable
    def self.find_log
      if Ginatra.config.log_file
        log_file = File.expand_path(Ginatra.config.log_file)
      else
        log_file = STDOUT
      end
      log_file
    end

    # Creates Log file
    def self.create_log(log_file)
      unless log_file == STDOUT
        parent_dir, _separator, _filename = log_file.rpartition('/')
        FileUtils.mkdir_p parent_dir
        FileUtils.touch log_file
      end
    end
  end
end
