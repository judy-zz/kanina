describe Kanina::Subscription do
  describe '.subscribe' do
    it 'watches a queue' do
      result = nil
      Kanina::Subscription.subscribe queue: 'kanina.subscription_spec.subscribe' do |data|
        result = data[:string]
      end

      Kanina::Server.channel.default_exchange.publish(
        { string: 'success' }.to_json,
        routing_key: 'kanina.subscription_spec.subscribe'
      )

      sleep(0.1)
      expect(result).to eql 'success'
    end

    it 'sets up a durable queue' do
      result = nil

      # The queue must exist first before we send messages to it.
      Kanina::Subscription.create_queue('kanina.subscription_spec.durable_queue', durable: true)

      # Push the message
      Kanina::Server.channel.default_exchange.publish(
        { string: 'success' }.to_json,
        routing_key: 'kanina.subscription_spec.durable_queue'
      )

      Kanina::Server.stop
      Kanina::Server.start

      # Re-open the subscription to the queue
      Kanina::Subscription.subscribe queue: 'kanina.subscription_spec.durable_queue', durable: true do |data|
        result = data[:string]
      end

      sleep(0.1)
      expect(result).to eql 'success'
    end

    it 'sets up a durable exchange' do
      # TODO: Fix this spec! Should be passing on travis, don't know why it isn't.
      skip "fails on travis because rabbitmqctl is working differently."
      Kanina::Subscription.subscribe bind: 'kanina.subscription_spec.binding_to_durable_exchange', durable: true do |_|
      end

      expect(`rabbitmqctl list_exchanges name durable`).to include("kanina.subscription_spec.binding_to_durable_exchange\ttrue")
    end

    it 'sets up a binding to a named exchange' do
      result = nil
      Kanina::Subscription.subscribe bind: 'kanina.subscription_spec.binding_to_named_exchange' do |data|
        result = data[:string]
      end
      Kanina::Server.channel.direct('kanina.subscription_spec.binding_to_named_exchange').publish(
        { string: 'success' }.to_json
      )

      sleep(0.1)
      expect(result).to eql 'success'
    end

    it 'can bind with a routing_key' do
      result = nil

      exchange_name = 'kanina.subscription_spec.routing_key_exchange'
      topic = Kanina::Server.channel.topic(exchange_name)

      Kanina::Subscription.subscribe bind: exchange_name, routing_key: 'should.be.*' do |data|
        result = data[:string]
      end

      topic.publish(
        { string: 'success' }.to_json,
        { routing_key: 'should.be.received' }
      )

      topic.publish(
        { string: 'failure' }.to_json,
        { routing_key: 'should.not_be.received' }
      )

      sleep(0.1)
      expect(result).to eql 'success'
    end
  end
end
