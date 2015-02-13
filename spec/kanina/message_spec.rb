describe Kanina::Message do
  describe '.exchange' do
    it 'sets and returns the exchange' do
      dummy_class = Class.new(Kanina::Message) do
        exchange 'kanina.message_spec.exchange', type: :direct
      end
      expect(dummy_class.exchange.name).to eql 'kanina.message_spec.exchange'
      expect(dummy_class.exchange.type).to eql :direct
    end

    it "returns the default exchange if exchange hasn't been set." do
      dummy_class = Class.new(Kanina::Message)
      expect(dummy_class.exchange.name).to eql ''
      expect(dummy_class.exchange.type).to eql :direct
    end

    it 'makes a durable exchange' do
      dummy_class = Class.new(Kanina::Message) do
        exchange 'kanina.message_spec.durable_exchange', durable: :true
      end

      expect(`rabbitmqctl list_exchanges name durable`).to include("kanina.message_spec.durable_exchange\ttrue")
    end
  end

  describe '.routing_key' do
    it 'sets and returns the routing_key variable' do
      dummy_class = Class.new(Kanina::Message) do
        routing_key 'kanina.message_spec.routing_key'
      end
      expect(dummy_class.routing_key).to eql 'kanina.message_spec.routing_key'
    end
  end

  describe '.persistent' do
    it 'sets @persistent to true' do
      dummy_class = Class.new(Kanina::Message) do
        persistent
      end
      expect(dummy_class.instance_variable_get(:@persistent)).to eql true
    end

    it 'returns the value of @persistent' do
      dummy_class = Class.new(Kanina::Message)
      dummy_class.instance_variable_set(:@persistent, true)
      expect(dummy_class.persistent).to eql true
      dummy_class.instance_variable_set(:@persistent, false)
      expect(dummy_class.persistent).to eql false
    end
  end

  describe '.transient' do
    it 'sets @persistent to false' do
      dummy_class = Class.new(Kanina::Message) do
        transient
      end
      expect(dummy_class.instance_variable_get(:@persistent)).to eql false
    end
  end

  describe '#deliver' do
    it 'raises an error if nothing is defined' do
      dummy_class = Class.new(Kanina::Message)

      message = dummy_class.new('test')
      expect { message.deliver }.to raise_error
    end

    it 'delivers a message to the default exchange' do
      dummy_class = Class.new(Kanina::Message) do
        routing_key 'kanina.message_spec.default_exchange_to_queue'
      end

      q = Kanina::Server.channel.queue('kanina.message_spec.default_exchange_to_queue')
      message = dummy_class.new('test')
      result = nil
      message.deliver

      q.subscribe do |delivery_info, properties, body|
        result = body
      end

      sleep(0.1)
      expect(result).to eql('"test"')
    end

    it 'delivers a message to a fanout exchange' do
      dummy_class = Class.new(Kanina::Message) do
        fanout 'kanina.message_spec.fanout_exchange'
      end

      q = Kanina::Server.channel.queue('')
      q.bind('kanina.message_spec.fanout_exchange')
      message = dummy_class.new('data')
      message.deliver
      result = nil

      q.subscribe do |delivery_info, properties, body|
        result = body
      end

      sleep(0.1)
      expect(result).to eql('"data"')
    end

    it 'delivers a message to a direct exchange' do
      dummy_class = Class.new(Kanina::Message) do
        exchange 'kanina.message_spec.direct_exchange', type: :direct
      end

      q = Kanina::Server.channel.queue('')
      q.bind('kanina.message_spec.direct_exchange')
      message = dummy_class.new('data')
      message.deliver
      result = nil

      q.subscribe do |delivery_info, properties, body|
        result = body
      end

      sleep(0.1)
      expect(result).to eql('"data"')
    end
    context "with a topic exchange" do
      before(:each) do
        @dummy_class = Class.new(Kanina::Message) do
          topic "kanina.message_spec.topic_exchange"
          routing_key "kanina.message_spec.topic_exchange.suffix"
        end
        @q = Kanina::Server.channel.queue('')
        @ex = @dummy_class.class_eval{exchange}
        @result = nil
      end

      after(:each) do
        @q.subscribe {|_, _, body| @result = body }
        @dummy_class.new('data').deliver
        sleep(0.1)
        expect(@result).to eql('"data"')
      end

      it "should match a full topic" do
        @q.bind @ex, routing_key: "kanina.message_spec.topic_exchange.suffix"
      end

      it "should match a prefix" do
        @q.bind @ex, routing_key: "kanina.message_spec.topic_exchange.#"
      end

      it "should match a suffix" do
        @q.bind @ex, routing_key: "#.topic_exchange.suffix"
      end
    end

    context 'with persistence turned on' do
      it 'should make messages persistent' do
        Kanina::Server.channel.queue('kanina.message_spec.persistent_messages', durable: true)

        dummy_class = Class.new(Kanina::Message) do
          routing_key 'kanina.message_spec.persistent_messages'
          persistent
        end
        result = nil

        dummy_class.new('persistent').deliver

        Kanina::Server.stop
        Kanina::Server.start

        Kanina::Server.channel.queue('kanina.message_spec.persistent_messages', durable: true).subscribe do |_, _, body|
          result = body
        end

        sleep(0.1)
        expect(result).to eql('"persistent"')
      end
    end

    context 'with persistence turned off' do
      it 'should make messages transient' do
        # TODO: Fix this test so it reliably restarts RabbitMQ across all
        # platforms, including TravisCI.
        skip "can fail when restarting RabbitMQ server."
        Kanina::Server.channel.queue('kanina.message_spec.transient_messages', durable: true)

        dummy_class = Class.new(Kanina::Message) do
          routing_key 'kanina.message_spec.transient_messages'
          transient
        end
        result = nil

        msg = dummy_class.new('I am transient.')
        msg.deliver

        Kanina::Server.stop
        sleep 1
        `rabbitmqctl stop_app`
        sleep 1
        `rabbitmqctl start_app`
        sleep 1
        Kanina::Server.start

        Kanina::Server.channel.queue('kanina.message_spec.transient_messages', durable: true).subscribe do |_, _, body|
          result = body
        end

        sleep(0.1)
        expect(result).to eql(nil)
      end
    end
  end
end
