require 'rails/generators'

module Kanina
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    # This method is called automatically by rails when you 'install' Kanina. It
    # copies a sample amqp.yml file to the Rails config folder, and adds amqp.yml
    # to the .gitignore.
    def create_amqp_config_file
      filepath = Rails.root + "config"
      template "amqp.yml.sample", filepath + "amqp.yml.sample"
      append_file Rails.root + '.gitignore', 'config/amqp.yml'
    end
  end
end
