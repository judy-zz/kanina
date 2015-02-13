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
  end
end
