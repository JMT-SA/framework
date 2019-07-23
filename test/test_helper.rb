# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'mocha/minitest'
require 'minitest/stub_any_instance'
require 'minitest/hooks/test'
require 'minitest/rg'

require 'dotenv'
Dotenv.load('.env.local', '.env')

require './app_loader'

# Re-define Que::Job so it can be used for testing.
module Que
  class Job
    attr_reader :enqueued, :job
    def initialize
      @enqueued = nil
    end

    def enqueue(*args)
      @job = self.class
      @enqueued = args
    end

    def finish; end

    def destroy; end
  end
end

root_dir = File.expand_path('../..', __FILE__)

# Database seeds - called in `around_all` hook of MiniTestWithHooks
# Each seed file must reopen the MiniTestSeeds module.
# Each seed file MUST have at least one method with a name that start with "db_create_".
# The methods should add lookup information (like key id values) to `@fixed_table_set`.
# Place database seed logic in those methods.
module MiniTestSeeds end
Dir["#{root_dir}/test/db_seeds/*.rb"].each { |f| require f }

# Include helper methods & factories
Dir["#{root_dir}/lib/*/test/factories/*.rb"].each { |f| require f }

class MiniTestWithHooks < Minitest::Test
  include Minitest::Hooks
  include MiniTestSeeds
  include Crossbeams::Responses

  def ok_response(message: nil, instance: nil)
    success_response((message || 'OK'), instance.nil? ? nil : OpenStruct.new(instance))
  end

  def bad_response(message: nil, instance: nil)
    failed_response((message || 'FAILED'), instance.nil? ? nil : OpenStruct.new(instance))
  end

  def around
    Faker::UniqueGenerator.clear
    DB.transaction(rollback: :always, savepoint: true, auto_savepoint: true) do
      super
    end
  end

  def around_all
    DB.transaction(rollback: :always) do
      # Run all the seed-creation methods:
      @fixed_table_set = {}
      methods.grep(/^db_create_.+/).each { |m| send(m) }
      super
    end
  rescue StandardError => e
    p e
    raise "Display possible around errors"
  end
end

class MiniTestInteractors < Minitest::Test
  include Crossbeams::Responses

  def ok_response(message: nil, instance: nil)
    success_response((message || 'OK'), instance.nil? ? nil : OpenStruct.new(instance))
  end

  def bad_response(message: nil, instance: nil)
    failed_response((message || 'FAILED'), instance.nil? ? nil : OpenStruct.new(instance))
  end

  def around
    Faker::UniqueGenerator.clear
  end
end

def current_user
  DevelopmentApp::User.new(
    id: 1,
    login_name: 'usr_login',
    user_name: 'User Name',
    password_hash: '$2a$10$wZQEHY77JEp93JgUUyVqgOkwhPb8bYZLswD5NVTWOKwU1ssQTYa.K',
    email: 'current_user@example.com',
    active: true
  )
end

def test_crud_calls_for(table_name, options = {}) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize
  name    = options[:name] || table_name
  wrapper = options[:wrapper]
  skip    = options[:exclude] || []

  repo = self.send(:repo)
  unless wrapper.nil?
    assert_respond_to repo, :"find_#{name}"
  end

  unless skip.include?(:create)
    assert_respond_to repo, :"create_#{name}"
  end

  unless skip.include?(:update)
    assert_respond_to repo, :"update_#{name}"
  end

  return if skip.include?(:delete)
  assert_respond_to repo, :"delete_#{name}"
end

# Expect the number of records in table to increase or decrease by change.
def assert_count_changed(table, change)
  cnt = DB[table].count
  yield
  new_cnt = DB[table].count
  assert_equal cnt + change, new_cnt, "Expected count for #{table} to change from #{cnt} to #{cnt + change} but count is now #{new_cnt}"
end
