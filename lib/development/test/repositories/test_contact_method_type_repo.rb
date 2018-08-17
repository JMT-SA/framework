# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module DevelopmentApp
  class TestContactMethodTypeRepo < MiniTestWithHooks

    def test_for_selects
      assert_respond_to repo, :for_select_contact_method_types
    end

    def test_crud_calls
      assert_respond_to repo, :find_contact_method_type
      assert_respond_to repo, :create_contact_method_type
      assert_respond_to repo, :update_contact_method_type
      assert_respond_to repo, :delete_contact_method_type
    end

    private

    def repo
      ContactMethodTypeRepo.new
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
