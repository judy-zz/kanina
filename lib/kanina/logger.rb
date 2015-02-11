require 'logger'

module Kanina
  # `Kanina::Logger` simplifies sending messages to standard output and/or the
  # Rails log files.
  module Logger
    DEFAULT_LOG_LEVEL = ::Logger::INFO

    # Sets up the Rails logger
    # @return [Rails::Logger] the logger being used
    def logger
      Rails.logger ||= ::Logger.new(STDOUT)
      @logger ||= Rails.logger
    end

    # Sends a message to the log
    # @param text [String] the message to log
    # @param level the importance of the logged message. Default is Logger::INFO
    def say(text, level = DEFAULT_LOG_LEVEL)
      puts text if @loud
      logger.add level, "HARE: #{text}"
    end
  end
end
