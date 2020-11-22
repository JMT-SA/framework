# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestSupplierInteractor < Minitest::Test
    def test_create_supplier
      x = interactor.create_supplier(party_id: 1)
      refute x.success

      PartyRepo.any_instance.stubs(:find_supplier).returns(fake_supplier)

      exp = interactor.success_response('Created supplier Supplier Name', fake_supplier)
      PartyRepo.any_instance.stubs(:create_supplier).returns(OpenStruct.new(success: true))
      x = interactor.create_supplier(supplier_attrs)
      assert_equal exp, x

      error_message = 'error message'
      exp = interactor.validation_failed_response(OpenStruct.new(messages: error_message))
      PartyRepo.any_instance.stubs(:create_supplier).returns(error: error_message)
      x = interactor.create_supplier(supplier_attrs)
      assert_equal exp, x

      PartyRepo.any_instance.stubs(:create_supplier).raises(Sequel::UniqueConstraintViolation)
      x = interactor.create_supplier(supplier_attrs)
      refute x.success
      error_message = { erp_supplier_number: ['This supplier already exists'] }
      exp = interactor.validation_failed_response(OpenStruct.new(messages: error_message))
      assert_equal exp, x
    end

    def test_update_supplier
      x = interactor.create_supplier(party_id: 1)
      refute x.success

      PartyRepo.any_instance.stubs(:find_supplier).returns(fake_supplier)

      exp = interactor.success_response('Updated supplier Supplier Name', fake_supplier)
      PartyRepo.any_instance.stubs(:update_supplier).returns(OpenStruct.new(success: true))
      x = interactor.update_supplier(1, supplier_attrs)
      assert_equal exp, x

      error_message = 'error message'
      exp = interactor.validation_failed_response(OpenStruct.new(messages: error_message))
      PartyRepo.any_instance.stubs(:update_supplier).returns(error: error_message)
      x = interactor.update_supplier(1, supplier_attrs)
      assert_equal exp, x
    end

    def test_delete_supplier
      PartyRepo.any_instance.stubs(:find_supplier).returns(OpenStruct.new(party_name: 'Supplier Name'))
      PartyRepo.any_instance.stubs(:delete_supplier).returns(true)

      x = interactor.delete_supplier(1)
      assert_equal 'Deleted supplier Supplier Name', x[:message]
    end

    def test_validate_new_supplier_params
      attrs = supplier_attrs

      x = interactor.send(:validate_new_supplier_params, attrs)
      assert_empty x.errors

      # optional(:id).filled(:int?)
      attrs_without_id = attrs.reject { |k, _| k == :id }
      x = interactor.send(:validate_new_supplier_params, attrs_without_id)
      assert_empty x.errors

      # required(:party_id).filled(:int?)
      attrs_without_party_id = attrs.reject { |k, _| k == :party_id }
      x = interactor.send(:validate_new_supplier_params, attrs_without_party_id)
      assert_equal(['is missing'], x.errors[:party_id])
      refute_empty x.errors

      # required(:supplier_type_ids).each(:int?)
      attrs_without_supplier_type_ids = attrs.reject { |k, _| k == :supplier_type_ids }
      x = interactor.send(:validate_new_supplier_params, attrs_without_supplier_type_ids)
      assert_equal(['is missing'], x.errors[:supplier_type_ids])
      refute_empty x.errors
      attrs_without_supplier_type_ids[:supplier_type_ids] = ['String one', 'String two', 'String three']
      x = interactor.send(:validate_new_supplier_params, attrs_without_supplier_type_ids)
      refute_empty x.errors
      expected = { supplier_type_ids: { 0 => ['must be an integer'], 1 => ['must be an integer'], 2 => ['must be an integer'] } }
      assert_equal(expected, x.errors.to_h)

      # required(:erp_supplier_number).maybe(:str?)
      attrs_without_erp_supplier_number = attrs.reject { |k, _| k == :erp_supplier_number }
      x = interactor.send(:validate_new_supplier_params, attrs_without_erp_supplier_number)
      assert_equal(['is missing'], x.errors[:erp_supplier_number])
      refute_empty x.errors
      attrs_without_erp_supplier_number[:erp_supplier_number] = 'name'
      x = interactor.send(:validate_new_supplier_params, attrs_without_erp_supplier_number)
      assert_empty x.errors
      attrs_without_erp_supplier_number[:erp_supplier_number] = 1
      x = interactor.send(:validate_new_supplier_params, attrs_without_erp_supplier_number)
      expected = { erp_supplier_number: ['must be a string'] }
      assert_equal(x.errors.to_h, expected)
    end

    def test_validate_edit_supplier_params
      attrs = supplier_attrs

      x = interactor.send(:validate_edit_supplier_params, attrs)
      assert_empty x.errors

      # optional(:id).filled(:int?)
      attrs_without_id = attrs.reject { |k, _| k == :id }
      x = interactor.send(:validate_edit_supplier_params, attrs_without_id)
      assert_empty x.errors

      # required(:supplier_type_ids).each(:int?)
      attrs_without_supplier_type_ids = attrs.reject { |k, _| k == :supplier_type_ids }
      x = interactor.send(:validate_edit_supplier_params, attrs_without_supplier_type_ids)
      assert_equal(['is missing'], x.errors[:supplier_type_ids])
      refute_empty x.errors
      attrs_without_supplier_type_ids[:supplier_type_ids] = ['String one', 'String two', 'String three']
      x = interactor.send(:validate_edit_supplier_params, attrs_without_supplier_type_ids)
      refute_empty x.errors
      expected = { supplier_type_ids: { 0 => ['must be an integer'], 1 => ['must be an integer'], 2 => ['must be an integer'] } }
      assert_equal(expected, x.errors.to_h)

      # required(:erp_supplier_number).maybe(:str?)
      attrs_without_erp_supplier_number = attrs.reject { |k, _| k == :erp_supplier_number }
      x = interactor.send(:validate_edit_supplier_params, attrs_without_erp_supplier_number)
      assert_equal(['is missing'], x.errors[:erp_supplier_number])
      refute_empty x.errors
      attrs_without_erp_supplier_number[:erp_supplier_number] = 'name'
      x = interactor.send(:validate_edit_supplier_params, attrs_without_erp_supplier_number)
      assert_empty x.errors
      attrs_without_erp_supplier_number[:erp_supplier_number] = 1
      x = interactor.send(:validate_edit_supplier_params, attrs_without_erp_supplier_number)
      expected = { erp_supplier_number: ['must be a string'] }
      assert_equal(x.errors.to_h, expected)
    end

    def supplier_attrs
      {
        id: 1,
        party_id: 1,
        party_role_id: 1,
        erp_supplier_number: '123456',
        supplier_type_ids: [4, 5, 6]
      }
    end

    def full_supplier_attrs
      {
        id: 1,
        party_id: 1,
        party_role_id: 1,
        erp_supplier_number: '123456',
        supplier_type_ids: [4, 5, 6],
        supplier_types: ['Pallets', 'Type 1', 'Type 2'],
        party_name: 'Supplier Name'
      }
    end

    def fake_supplier
      OpenStruct.new(full_supplier_attrs)
    end

    def test_repo
      repo = interactor.send(:repo)
      assert repo.is_a?(MasterfilesApp::PartyRepo)
    end

    def test_supplier
      expected = 'This is a full supplier returned from the repo'
      PartyRepo.any_instance.stubs(:find_supplier).returns(expected)
      actual = interactor.send(:supplier, 1)
      assert_equal expected, actual
    end

    private

    def interactor
      @interactor ||= SupplierInteractor.new(current_user, {}, {}, {})
    end
  end
end
