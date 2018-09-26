# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module DevelopmentApp
  class TestRoleRepo < MiniTestWithHooks

    def test_for_selects
      assert_respond_to repo, :for_select_roles
    end

    def test_crud_calls
      assert_respond_to repo, :find_role
      assert_respond_to repo, :create_role
      assert_respond_to repo, :update_role
      assert_respond_to repo, :delete_role
    end

    private

    def repo
      RoleRepo.new
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
