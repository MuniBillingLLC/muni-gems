
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

ENV['RAILS_ENV'] = 'test'

require_relative '../spec/dummy/config/environment'
ENV['RAILS_ROOT'] ||= "#{File.dirname(__FILE__)}../../../spec/dummy" #

# start with brand new schema. this simplifies schema management, we
# dont have to write multiple migrations, can change the existing one
# in situ
Rails.application.load_tasks
Rake::Task['db:migrate:reset'].invoke
Rake::Task['db:seed'].invoke

require 'factory_bot_rails'
require 'faker'
require 'climate_control'

# Common modules included in all specs
Dir[Rails.root.join('spec', 'support', '*.rb')].each { |f| require f }
include SupportRandoms
