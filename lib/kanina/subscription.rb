module Kanina
  # `Kanina::Subscription` allows you to automatically receive messages
  # from RabbitMQ, and run a block of code upon receiving each new message.
  # Queues and bindings are set up on the fly. Subscriptions are also eagerly
  # loaded by Rails, so they're defined when the Rails environment is loaded.
  # Example:
  #
  #   # app/messages/user_message.rb
  #   class UserSubscription < Kanina::Subscription
  #     subscribe(bind: "user.exchange") do |data|
  #       puts data
  #     end
  #   end
  #
  # Messages are depacked from JSON, into plain old Ruby objects. If you use
  # `Kanina::Message` to send messages, it automatically encapsulates messages
  # into JSON to make the process easier.
  class Subscription
    class << self
      include Kanina::Logger

      # Helper method to return the channel that Kanina::Server is talking on.
      # @return [Bunny::Channel]
      def channel
        Kanina::Server.channel or fail 'Kanina::Server.channel is not open'
      end

      # Begins subscribing to the specified queue (or binds to an exchange and
      # sets up an anonymous queue). The block is called for every message
      # received, and data is passed in as a plain Ruby hash.
      # @param queue [String] Optional, the queue to watch.
      # @param bind [String] Optional, the exchange to bind to.
      # @param durable [Boolean] Optional, whether to make the queue and exchange durable.
      # @yieldparam data [HashWithIndifferentAccess] The payload of the message,
      #    automatically turned into a hash.
      def subscribe(queue:'', bind:nil, durable:false, routing_key: '#', &blk)
        create_queue(queue, durable: durable)
        create_binding(bind, durable: durable, routing_key: routing_key)
        @queue.subscribe do |delivery_info, properties, body|
          yield format_data(body)
        end
      end

      # Creates the queue **or** attaches to the existing queue. This will also
      # create a random queue if the queue supplied is an empty string.
      # @param name [String] The name of the queue.
      # @param durable [Boolean] Optional, false by default. Whether the queue
      #   should be durable or not.
      # @return [Bunny::Queue]
      def create_queue(name, durable: false)
        @queue = channel.queue(name, durable: durable)
      end

      # Ensures the named exchange exists, and binds the queue to it.
      # @param name [String] The name of the exchange to bind the queue to.
      # @param durable [Boolean] Optional, whether to make the exchange durable.
      def create_binding(name, durable: false, routing_key: '#')
        if name.present?
          ensure_exchange_exists(name, durable: durable)
          @queue.bind(name, routing_key: routing_key)
        end
      end

    private

      def ensure_exchange_exists(bind, durable: false)
        unless Kanina::Server.connection.exchange_exists?(bind)
          channel.exchange(bind, type: :direct, durable: durable)
        end
      end

      def format_data(body)
        obj = JSON.parse(body)
        HashWithIndifferentAccess.new(obj)
      rescue
        say "JSON data wasn't received, returning plain object"
        body
      end
    end
  end
end
