require 'minitest/autorun'
p '====================================< 1 >=================================='
require 'crossbeams/layout'
p '====================================< 2 >=================================='
require 'yaml'
p '====================================< 3 >=================================='
require 'dry-struct'
p '====================================< 4 >=================================='
require 'dry-validation'
p '====================================< 5 >=================================='
# require 'pry' # TODO: Put this in based on dev env.

module Types
  include Dry::Types.module
end
require './lib/repo_base'
p '====================================< 6 >=================================='
# Dir['./lib/helpers/**/*.rb'].each { |f| p "TEST PRINTOUT HERE ================================================================================ #{f}"; }
# Dir['./lib/helpers/**/*.rb'].each { |f| p "TEST PRINTOUT HERE ================================================================================ #{f}"; require f; }
Dir['../helpers/**/*.rb'].each { |f| p "TEST PRINTOUT HERE ================================================================================ #{f}"; require f; }
require './lib/base_service'
p '====================================< 7 >=================================='
require './lib/ui_rules'
p '====================================< 8 >=================================='

# Dir['./lib/applets/*.rb'].each { |f| require f }


Dir['../lib/applets/*.rb'].each { |f| require f }
# require File.join(File.expand_path('../../../../../test', __FILE__), 'test_helper')
