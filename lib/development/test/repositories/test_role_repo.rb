# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module DevelopmentApp
  class TestRoleRepo < MiniTestWithHooks
    def test_for_selects
      assert_respond_to repo, :for_select_roles
    end

    def test_crud_calls
      test_crud_calls_for :roles, name: :role, wrapper: Role
    end

    private

    def repo
      RoleRepo.new
    end
  end
end
