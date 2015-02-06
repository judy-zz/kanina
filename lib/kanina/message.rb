module Kanina
  # `Kanina::Message` allows you to send messages to RabbitMQ, and have
  # your exchanges and bindings set up on the fly.
  #
  #     # app/messages/user_message.rb
  #     class UserMessage < Kanina::Message
  #       exchange "user.exchange"
  #     end
  #
  #     message = UserMessage.new("data")
  #     message.deliver
  #
  # Messages are encapsulated in JSON format. If you use
  # `Kanina::Subscription` to receive messages, they're automatically
  # parsed back out of JSON into native Ruby objects.
  class Message
    class << self
      # Helper method to return the channel opened by `Kanina::Server`.
      def channel
        Kanina::Server.channel or fail 'Kanina::Server.channel is not open'
      end

      # @overload exchange
      #   @return [String] the set exchange, or the default exchange.
      # @overload exchange(name, *opts)
      #   Set the name and type of the exchange messages should be sent to.
      #   @param name [String] the name of the exchange
      #   @param type [:direct, :fanout, :topic] the type of exchange
      #   @return [String] the exchange
      def exchange(name = nil, type: :direct)
        if name.present?
          @type = type
          @exchange = channel.exchange(name, type: type)
        else
          @exchange || channel.default_exchange
        end
      end

      [:direct, :fanout, :topic].each do |type|
        define_method type do |name|
          exchange(name, type: type)
        end
      end

      # Set the queue to which messages at this exchange should be sent to. Note
      # that you'll probably want to use this at the exchange level, OR a
      # binding at the queue level.
      # @overload routing_key
      #   @return [String] the routing key
      # @overload routing_key(name)
      #   Verifies that the queue exists or is created, and sets the routing key to it.
      #   @param name [String] the routing key
      #   @return [String] the routing key
      def routing_key(name = nil)
        if name.present?
          verify_queue(name)
          @routing_key = name
        else
          @routing_key
        end
      end

      # Sets outgoing messages to be persistent. **Note** that messages must be
      # sent to a durable queue, or they will still be lost! By default, this is
      # `true`.
      def persistent
        @persistent.nil? ? @persistent = true : @persistent
      end

      # Sets outgoing messages to be transient (*not* persistent). If the receiving queues
      # are taken down, messages could be lost. This might be the desired functionality,
      # if messages need to be timely and queues being destroyed aren't a big deal.
      def transient
        @persistent = false
      end

      # Creates the queue, or grabs the queue that already exists. Note that if
      # the queue already exists, it must exist with the same parameters (like durability),
      # or the Bunny gem is very unhappy.
      def verify_queue(routing_key)
        Kanina::Server.channel.queue(routing_key)
      end
    end

    # @!attribute [rw] data
    #   The actual contents of the message to be sent.
    attr_accessor :data

    # @!attribute [w] routing_key
    #   Set this to change the queue that this message should be sent to.
    #   (Overrides any routing key set at the class level.)
    attr_writer :routing_key

    # Create a new message to be sent.
    # @param data [Hash] The payload of the message
    # @param routing_key [String] Optional, to change the queue the message is sent to.
    def initialize(data = nil, routing_key: nil)
      @data = data || {}
      @routing_key = routing_key
      @persistent = persistent
    end

    # The exchange this message is going into
    # @return [String] exchange
    def exchange
      self.class.exchange
    end

    # @return [String] routing_key
    def routing_key
      @routing_key || self.class.routing_key
    end

    # @return [Boolean] whether this message is persistent or not
    #   Currently only set at the class level.
    def persistent
      @persistent.nil? ? self.class.persistent : @persistent
    end

    # @return [String] The json-formatted data being sent.
    def json
      data.present? ? data.to_json : {}.to_json
    end

    # Deliver the message to the specified exchange and/or queue.
    def deliver
      if exchange.name == ''
        if routing_key.present?
          exchange.publish(json, routing_key: routing_key, persistent: @persistent)
        else
          fail 'Routing key must be set when using default exchange.'
        end
      else
        exchange.publish(json, routing_key: routing_key)
      end
    end
  end
end
