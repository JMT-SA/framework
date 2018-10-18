# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module DevelopmentApp
  class TestLoggingRepo < MiniTestWithHooks
    def test_crud_calls
      test_crud_calls_for :logged_action_details, name: :logged_action_detail, wrapper: LoggedActionDetail, schema: :audit
    end

    def test_find_logged_action
      skip 'todo: test that find uses correct id field and schema'
    end

    private

    def repo
      LoggingRepo.new
    end
  end
end
