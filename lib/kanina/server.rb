module Kanina
  # `Kanina::Server` loads configuration, opens a connection to RabbitMQ
  # and opens a channel so messages can be received and sent. This class is
  # automatically called and handled by a Railtie, so you shouldn't have to
  # invoke it by hand.
  class Server
    class << self
      include Kanina::Logger

      attr_reader :connection, :channel
      attr_accessor :config, :loud

      # Returns the current status of the server connection.
      # @return [String] status, as 'off', 'starting', 'started', or 'stopping'
      def status
        @status || 'off'
      end

      # Loads the configuration, opens a connection, and opens the channel. This
      # will automatically be run in the railtie when you install Kanina into a
      # Rails project, so you shouldn't have to run it yourself.
      # @return [String] status as 'started', unless something went wrong.
      def start
        set_status 'starting'
        load_config unless @config.present?
        open_connection
        open_channel
        set_status 'started'
      end

      # Closes the connection to RabbitMQ.
      # @return [String] status as 'stopping'
      def stop
        set_status 'stopping'
        cleanup
      end

      private

      def set_status(string)
        @status = string
        say "Status changed to #{@status}"
        @status
      end

      def cleanup
        @connection.try(:close)
        set_status 'off'
      end

      def config_file_location
        (Rails.try(:root) || './') + 'config/amqp.yml'
      end

      def load_config
        if Pathname.new(config_file_location).exist?
          @config = HashWithIndifferentAccess.new(
            YAML.load_file(config_file_location)
          )[Rails.env]
          say 'Loaded config.'
        else
          say 'amqp.yml not found! Not loading any configuration'
        end
      end

      def open_connection
        @connection ||= Bunny.new(@config)
        if @connection.start
          say "Opened connection: #{@connection}"
        end
      end

      def open_channel
        if @connection.present?
          @channel = @connection.create_channel
          say "Opened channel: #{@channel}"
        else
          fail 'Connection needs to be opened before opening a channel.'
        end
      end
    end
  end
end
