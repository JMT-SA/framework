# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module DevelopmentApp
  class TestAddressTypeRepo < MiniTestWithHooks
    def test_for_selects
      assert_respond_to repo, :for_select_address_types
    end

    def test_crud_calls
      test_crud_calls_for :address_types, name: :address_type, wrapper: AddressType
    end

    private

    def repo
      AddressTypeRepo.new
    end
  end
end
