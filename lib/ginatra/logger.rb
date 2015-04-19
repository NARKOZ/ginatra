require 'logger'

module Ginatra
  module Logger
    GINATRA_DIR = File.expand_path('~/.ginatra')
    LOGFILE = File.expand_path('~/.ginatra/ginatra.log')

    def logger
      Logger.logger
    end

    def self.logger
      @logger ||= begin
        create_dir unless File.directory?(GINATRA_DIR)
        file = File.open(LOGFILE, File::WRONLY | File::APPEND | File::CREAT)
        logger = ::Logger.new file
        logger.level = ::Logger::WARN
        logger.formatter = proc do |severity, datetime, progname, msg|
          "[#{datetime} ##{Process.pid}] #{severity}: #{msg}\n"
        end
        logger
      end
    end

    private

    def create_dir
      require 'fileutils'
      FileUtils.mkdir_p GINATRA_DIR
    end
  end
end
