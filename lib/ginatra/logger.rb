require 'logger'
require 'fileutils'

module Ginatra
  module Logger
    def logger
      Logger.logger
    end

    def self.logger
      return @logger if @logger

      if Ginatra.config.log_file
        log_file = File.expand_path(Ginatra.config.log_file)
      else
        log_file = STDOUT
      end

      unless log_file == STDOUT
        parent_dir, _separator, _filename = log_file.rpartition('/')
        FileUtils.mkdir_p parent_dir
        FileUtils.touch log_file
      end

      @logger = ::Logger.new log_file
      @logger.level = ::Logger::WARN
      @logger.formatter = proc do |severity, datetime, progname, msg|
        "[#{datetime} ##{Process.pid}] #{severity}: #{msg}\n"
      end
      @logger
    end
  end
end
