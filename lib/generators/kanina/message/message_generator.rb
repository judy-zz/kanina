require 'rails/generators'

module Kanina
  # <tt>Kanina::MessageGenerator</tt> generates a template of a message file. Change the
  # resulting file with your intended exchange or routing_key information. For example:
  #
  #   rails generate message user_notification
  class MessageGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    # This method is automatically run by Rails when generating a new message.
    # It sets up the messages folder and adds the message template. Remember to
    # change the template to talk to the right exchange/queue!
    def create_message_file
      messages_folder = Rails.root + 'app/messages'
      empty_directory messages_folder
      template 'message.rb', messages_folder + "#{file_name}_message.rb"
    end
  end
end
