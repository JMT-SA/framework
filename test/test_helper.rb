require 'minitest/autorun'
# require 'crossbeams/layout' ### >>>> creates rouge err messages!!!
require 'yaml'
require 'dry-struct'
require 'dry-validation'

module Types
  include Dry::Types.module
end
require './lib/repo_base'

root_dir = File.expand_path('../..', __FILE__)

Dir["#{root_dir}/helpers/**/*.rb"].each { |f| require f }
require './lib/base_service'
require './lib/ui_rules'

Dir["#{root_dir}/lib/applets/*.rb"].each { |f| require f }
