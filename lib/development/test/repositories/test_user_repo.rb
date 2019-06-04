# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module DevelopmentApp
  class TestUserRepo < MiniTestWithHooks
    def test_for_selects
      assert_respond_to repo, :for_select_user_email_groups
    end

    def test_crud_calls
      test_crud_calls_for :user_email_groups, name: :user_email_group, wrapper: UserEmailGroup
    end

    private

    def repo
      UserRepo.new
    end
  end
end
