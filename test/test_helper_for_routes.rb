ENV['RACK_ENV'] = 'test'
require 'rack/test'
require 'minitest/autorun'
require "mocha/mini_test"
require 'minitest/stub_any_instance'
require 'minitest/hooks/test'

OUTER_APP = Rack::Builder.parse_file('config.ru').first

class RouteTester < Minitest::Test
  include Rack::Test::Methods
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

  def app
    OUTER_APP
  end

  def base_user
    User.new(
      id: 1,
      login_name: 'usr_login',
      user_name: 'User Name',
      password_hash: '$2a$10$wZQEHY77JEp93JgUUyVqgOkwhPb8bYZLswD5NVTWOKwU1ssQTYa.K',
      email: 'current_user@example.com',
      active: true
    )
  end

  def authorise_pass!
    UserRepo.any_instance.stubs(:find).returns(base_user)
    ProgramRepo.any_instance.stubs(:authorise?).returns(true)
  end

  def authorise_fail!
    UserRepo.any_instance.stubs(:find).returns(base_user)
    ProgramRepo.any_instance.stubs(:authorise?).returns(false)
  end

  def around
    authorise_pass!
    super
  end
end
