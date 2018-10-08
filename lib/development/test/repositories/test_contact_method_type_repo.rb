# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module DevelopmentApp
  class TestContactMethodTypeRepo < MiniTestWithHooks
    def test_for_selects
      assert_respond_to repo, :for_select_contact_method_types
    end

    def test_crud_calls
      test_crud_calls_for :contact_method_types, name: :contact_method_type, wrapper: ContactMethodType
    end

    private

    def repo
      ContactMethodTypeRepo.new
    end
  end
end
