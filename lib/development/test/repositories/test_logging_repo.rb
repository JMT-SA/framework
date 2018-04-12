# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module DevelopmentApp
  class TestLoggingRepo < MiniTestWithHooks
    def test_crud_calls
      assert_respond_to repo, :find_logged_action_detail
      assert_respond_to repo, :create_logged_action_detail
      assert_respond_to repo, :update_logged_action_detail
      assert_respond_to repo, :delete_logged_action_detail
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
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
