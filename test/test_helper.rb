# frozen_string_literal: true

require 'minitest/autorun'
require "mocha/mini_test"
require 'minitest/stub_any_instance'
require 'crossbeams/layout'
require 'yaml'
require 'dry-struct'
require 'dry-validation'
require 'sequel'

ENV['RACK_ENV'] = 'test'
require './config/environment'

module Types
  include Dry::Types.module
end
require './lib/crossbeams_responses'
require './lib/repo_base'

root_dir = File.expand_path('../..', __FILE__)

Dir["#{root_dir}/helpers/**/*.rb"].each { |f| require f }
require './lib/base_service'
require './lib/base_interactor'
require './lib/ui_rules'

Dir["#{root_dir}/lib/applets/*.rb"].each { |f| require f }

require 'minitest/hooks/test'
class MiniTestWithHooks < Minitest::Test
  include Minitest::Hooks

  def around
    DB.transaction(rollback: :always, savepoint: true, auto_savepoint: true) do
      super
    end
  end

  def around_all
    DB.transaction(rollback: :always) do
      super
    end
  end
end

def current_user
  User.new(
    id: 1,
    login_name: 'usr_login',
    user_name: 'User Name',
    password_hash: '$2a$10$wZQEHY77JEp93JgUUyVqgOkwhPb8bYZLswD5NVTWOKwU1ssQTYa.K',
    email: 'current_user@example.com',
    active: true
  )
end
