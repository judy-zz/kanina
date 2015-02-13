$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'kanina/version'

Gem::Specification.new do |s|
  s.name          = 'kanina'
  s.version       = Kanina::VERSION
  s.authors       = ['Clinton Judy']
  s.email         = ['clinton@j-udy.com']
  s.summary       = 'Rails plugin for RabbitMQ'
  s.description   = <<-DESC
This is a Rails plugin that makes it easier for your models
to communicate via AMQP to RabbitMQ.
DESC
  s.homepage      = 'http://judy.github.io/kanina/'
  s.license       = 'ISC'

  s.files         = `git ls-files -z`.split("\x0")
  s.test_files    = s.files.grep(/spec\//)
  s.require_paths = %w(lib)

  s.add_dependency 'railties', '> 4.0'
  s.add_dependency 'bunny', '> 1.6'
  s.add_dependency 'daemons', '~> 1.1'

  # All used for testing and code climate.
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rails', '~> 4.2'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '3.2.0'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'guard-livereload'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rubocop'

  # Documentation
  s.add_development_dependency 'yard'
  s.add_development_dependency 'redcarpet'
  s.add_development_dependency 'github-markup'
  s.add_development_dependency 'guard-yard'
end
