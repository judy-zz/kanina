require 'kanina'
require 'rails'

module Kanina
  # This Railtie starts a connection to RabbitMQ, and eagerly loads messages
  # and subscriptions so they have time to create the necessary AMQP
  # structures.
  class Railtie < Rails::Railtie
    initializer 'kanina' do
      Kanina::Server.start

      connection_attempts = 1
      while Kanina::Server.status != 'started' && connection_attempts <= 5
        sleep(connection_attempts) # Progressively sleep longer between connection attempts.
        connection_attempts = connection_attempts + 1
      end

      eagerloads = []
      eagerloads.concat(Dir.glob("#{Rails.root}/app/messages/**/*.rb"))
      eagerloads.concat(Dir.glob("#{Rails.root}/app/subscriptions/**/*.rb"))

      # TODO: I'd love to use `require_dependency` here instead, but it's doing something weird
      # when reloading subscriptions. We might be able to close and re-open the channel before
      # every server request, so subscription objects don't collide (or whatever they're doing
      # that keeps them from receiving messages.)
      eagerloads.sort.each { |file| require file }
    end
  end
end
