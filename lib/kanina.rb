$:.unshift File.expand_path(File.dirname(__FILE__))

require 'bunny'

require 'kanina/version'
require 'kanina/logger'
require 'kanina/server'
require 'kanina/message'
require 'kanina/subscription'

require 'kanina/railtie'
