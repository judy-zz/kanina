require 'rails/generators'

module Kanina
  # <tt>Kanina::SubscriptionGenerator</tt> generates a subscription file, for
  # example:
  #
  #   rails generate subscription user_notification
  class SubscriptionGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    # This method is called automatically by rails when you generate the
    # subscription. It sets up the subscriptions folder, then adds the
    # subscription to it.
    def create_subscription_file
      subscriptions_folder = Rails.root + 'app/subscriptions'
      empty_directory subscriptions_folder
      template 'subscription.rb', subscriptions_folder + "#{file_name}_subscription.rb"
    end
  end
end
