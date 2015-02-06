Kanina
====

A Rails plugin that makes it easier for your models to communicate with RabbitMQ.

[![Build Status](https://travis-ci.org/judy/kanina.svg?branch=master)](https://travis-ci.org/judy/kanina)
[![Code Climate](https://codeclimate.com/github/judy/kanina.png)](https://codeclimate.com/github/judy/kanina)
[![Coverage Status](https://coveralls.io/repos/judy/kanina/badge.png)](https://coveralls.io/r/judy/kanina)
[![Inline docs](http://inch-ci.org/github/judy/kanina.png?branch=master)](http://inch-ci.org/github/judy/kanina)

Kanina abstracts away queue and exchange creation, so you can focus on the message and subscription side of things in Rails.

Prerequisites
------------

You'll need **RabbitMQ** installed. Find instructions for your platform [here](http://www.rabbitmq.com/download.html).


Installation
------------

Put this in your `Gemfile`:

    gem 'kanina'

Then run `bundle install` to install the gem and its dependencies. Finally, run `rails generate kanina:install` to create bin/kanina and an amqp.yml.sample file in your config folder.

Copy amqp.yml.sample to amqp.yml, and change it to connect to your local RabbitMQ server. By default, it will connect to the one on your development machine, as long as you haven't changed the settings on it.

Sending Messages
----------------

Run the generator:

    rails generate kanina:message MessageName

Then specify the name of the exchange, OR the routing key for the intended queue. To send a message, generate an instance of your new class, add data, and hit send:

    msg = MessageName.new
    msg.data = {key: "value"}
    msg.deliver

You can also specify the type of exchange you want to create, like so:

    class WeatherMessage < Kanina::Message
        fanout "reports"
    end

Remember to use [RabbitMQ's documentation](http://www.rabbitmq.com/documentation.html) to understand the rules governing how to use different types of exchanges, bindings, and queues appropriately. You don't have to create those things ahead of time with Kanina, but you do have to understand how they work!

Receiving messages
------------------

Generate a subscription with this command:

    rails generate kanina:subscription SubscriptionName

Then tweak the resulting file to attach to the right queue, or use bindings to watch a named exchange. Use a subscribe block to define code that you want run when a message is received:

    class NotifyUserSubscription < Kanina::Subscription
      subscribe queue: "notify_user" do |data|
        User.where(id: data[:id]).first.notify
      end
    end

---

This project was written by [Clinton Judy](http://judy.github.io), and uses the ISC license.
